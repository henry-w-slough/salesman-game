extends Node


@export var scenes: Array[Scene] = []

signal scene_started(scene: Scene)
signal scene_finished(scene: Scene)
signal sequence_finished()

var current_scene_index: int = -1
var is_running: bool = false
var _scenes_to_run: Array[Scene] = []


func _ready() -> void:
	var dialogue_manager: Node = Engine.get_singleton("DialogueManager")
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)

	for scene: Scene in scenes:
		if is_instance_valid(scene) and scene.start_immediately:
			run.call_deferred()
			return


func run() -> void:
	if is_running:
		return

	is_running = true
	current_scene_index = -1
	_scenes_to_run.clear()
	var regular_scenes: Array[Scene] = []

	for scene: Scene in scenes:
		if is_instance_valid(scene):
			scene.initialize(self)
			if scene.start_immediately:
				_scenes_to_run.append(scene)
			else:
				regular_scenes.append(scene)

	_scenes_to_run.append_array(regular_scenes)

	await _run_next()


func _run_next() -> void:
	current_scene_index += 1
	if current_scene_index >= _scenes_to_run.size():
		is_running = false
		sequence_finished.emit()
		return

	var scene: Scene = _scenes_to_run[current_scene_index]
	if scene.should_transition:
		await SceneTransition.fade_out()

	scene_started.emit(scene)
	var waiting_for_dialogue: bool = await scene.start()
	if scene.should_transition:
		await SceneTransition.fade_in()

	if not waiting_for_dialogue:
		_finish_scene(scene)
		await _run_next()


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	if not is_running:
		return

	if current_scene_index < 0 or current_scene_index >= _scenes_to_run.size():
		return

	var scene: Scene = _scenes_to_run[current_scene_index]
	if _resource != scene.get_dialogue_resource():
		return

	_finish_scene(scene)

	await _run_next()


func _finish_scene(scene: Scene) -> void:
	scene_finished.emit(scene)
	scene.send_post_scene_signal()
