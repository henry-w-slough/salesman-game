class_name Door extends CharacterBody2D


@export_file("*.tscn") var destination_scene: String = ""

var _is_mouse_over: bool = false


func _ready():

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	

func _process(_delta: float) -> void:

	if not _is_mouse_over:
		return

	if Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file(destination_scene)


func _on_mouse_entered():
	_is_mouse_over = true


func _on_mouse_exited():
	_is_mouse_over = false
