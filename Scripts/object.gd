extends CharacterBody2D


@export var dialogue_resource: DialogueResource
@export var dialogue_cue: String = ""

var _is_mouse_over: bool = false
var _dialogue_active: bool = false
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _original_material: Material = _sprite.material
@onready var _outline_material: ShaderMaterial = ShaderMaterial.new()


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	_outline_material.shader = load("res://Assets/outline.gdshader")
	_outline_material.set_shader_parameter("color", Color.WHITE)
	_outline_material.set_shader_parameter("width", 1.0)
	_outline_material.set_shader_parameter("pattern", 1)
	_outline_material.set_shader_parameter("inside", true)
	_outline_material.set_shader_parameter("add_margins", false)

	var dialogue_manager: Node = Engine.get_singleton("DialogueManager")
	dialogue_manager.dialogue_started.connect(_on_dialogue_started)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)


func _process(_delta: float) -> void:
	if not _is_mouse_over or _dialogue_active:
		return

	if Input.is_action_just_pressed("interact"):
		_dialogue_active = true
		Engine.get_singleton("DialogueManager").show_dialogue_balloon(
			dialogue_resource,
			dialogue_cue,
			[]
		)


func _on_mouse_entered() -> void:
	_is_mouse_over = true
	_sprite.material = _outline_material


func _on_mouse_exited() -> void:
	_is_mouse_over = false
	_sprite.material = _original_material


func _on_dialogue_started(_resource: DialogueResource) -> void:
	_dialogue_active = true


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	_dialogue_active = false

