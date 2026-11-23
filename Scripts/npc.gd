extends CharacterBody2D


@export var move_speed: float = 100.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var dialogue_active: bool = false
var _using_navigation: bool = false

signal navigation_finished


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	add_to_group("npcs")

	var dialogue_manager: Node = Engine.get_singleton("DialogueManager")
	dialogue_manager.dialogue_started.connect(_on_dialogue_started)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	navigation_agent.navigation_finished.connect(_on_navigation_finished)


func _physics_process(_delta: float) -> void:
	_update_movement()
	_update_animation()
	move_and_slide()


func _update_movement() -> void:
	if dialogue_active:
		velocity = Vector2.ZERO
		return

	if _using_navigation:
		if navigation_agent.is_navigation_finished():
			velocity = Vector2.ZERO
			return

		var next_position: Vector2 = navigation_agent.get_next_path_position()
		var direction: Vector2 = global_position.direction_to(next_position)
		var to_player: Vector2 = _nearest_player_position() - global_position
		if to_player.length() < 14.0 and direction.dot(to_player.normalized()) > 0.5:
			velocity = Vector2.ZERO
			return

		velocity = direction * move_speed
		return

	velocity = Vector2.ZERO


func _nearest_player_position() -> Vector2:
	var nearest_position: Vector2 = global_position
	var nearest_distance: float = INF
	for player: Node in get_tree().get_nodes_in_group("players"):
		if player is Node2D:
			var distance: float = global_position.distance_to(player.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_position = player.global_position
	return nearest_position


func set_navigation_target(target_position: Vector2) -> void:
	dialogue_active = false
	_using_navigation = true
	navigation_agent.target_position = target_position


func _on_navigation_finished() -> void:
	if _using_navigation:
		_using_navigation = false
		velocity = Vector2.ZERO
		navigation_finished.emit()


func _update_animation() -> void:
	if velocity == Vector2.ZERO:
		sprite.play("idle_right")
	else:
		sprite.play("walk_right")

	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false


func _on_dialogue_started(_resource: DialogueResource) -> void:
	dialogue_active = true


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	dialogue_active = false
