extends Node


@export var scene_manager: Node
@export var _start_scene: bool = true


func _process(_delta: float) -> void:
	if not _start_scene:
		return

	_start_scene = false

	if not scene_manager:
		push_error("No scene manager assigned to game.")
		return

	scene_manager.run()
