class_name Scene extends Resource


@export var camera_path: NodePath
@export var start_immediately: bool = false
@export var should_transition: bool = false
@export var character_path: NodePath
@export var move_character_to_position: bool = false
@export var character_move_position_path: NodePath
@export var dialogue_resource: DialogueResource
@export var dialogue_cue: String = ""
@export var post_scene_signal_target_path: NodePath
@export var post_scene_signal_name: StringName = &""

var _camera: Camera2D
var _character: Node2D
var _context: Node
var _has_started: bool = false
var _active_resource: DialogueResource


func get_dialogue_resource() -> DialogueResource:
	return _active_resource


func send_post_scene_signal() -> void:
	if post_scene_signal_target_path.is_empty() and post_scene_signal_name == &"":
		return

	if post_scene_signal_target_path.is_empty() or post_scene_signal_name == &"":
		push_error("Both post-scene signal target and name must be configured.")
		return

	var target: Node = _context.get_node_or_null(post_scene_signal_target_path)
	if not is_instance_valid(target):
		push_error("Post-scene signal target path does not resolve to a node.")
		return

	if not target.has_signal(post_scene_signal_name):
		push_error("Post-scene signal target does not have signal '%s'." % post_scene_signal_name)
		return

	var error: Error = target.emit_signal(post_scene_signal_name)
	if error != OK:
		push_error("Could not emit post-scene signal '%s'." % post_scene_signal_name)


func initialize(context: Node) -> void:
	_context = context
	_has_started = false
	_active_resource = null
	_camera = null

	if not camera_path.is_empty():
		var camera_node: Node = context.get_node_or_null(camera_path)
		if camera_node is Camera2D:
			_camera = camera_node
		else:
			push_error("Camera path does not point to a Camera2D.")

	if not character_path.is_empty():
		var character_node: Node = context.get_node_or_null(character_path)
		if character_node is Node2D:
			_character = character_node
		else:
			push_error("Character path in scene does not point to a Node2D.")


func start() -> bool:
	if _has_started:
		return false

	_has_started = true

	if is_instance_valid(_camera):
		_camera.make_current()

	if move_character_to_position:
		await _move_character()

	var resource: DialogueResource = dialogue_resource
	if not is_instance_valid(resource) and _character and "dialogue_resource" in _character:
		resource = _character.dialogue_resource

	if is_instance_valid(resource):
		_active_resource = resource
		var dialogue_manager: Node = Engine.get_singleton("DialogueManager")
		dialogue_manager.show_dialogue_balloon(resource, dialogue_cue, [_character, _context])
		return true

	push_warning("Scene has no dialogue resource.")
	
	return false


func _move_character() -> void:
	if character_move_position_path.is_empty():
		push_warning("move_character_to_position is enabled but character_move_position_path is not set.")
		return

	var character_move_position: Node = _context.get_node_or_null(character_move_position_path)
	if not character_move_position is Node2D:
		push_warning("character_move_position_path does not point to a Node2D.")
		return

	if _character and _character.has_method("set_navigation_target"):
		_character.set_navigation_target(character_move_position.global_position)
		await _character.navigation_finished


	
