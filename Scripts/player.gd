extends CharacterBody2D


var sprite: AnimatedSprite2D = null

@export var move_speed = 100
var dialogue_active: bool = false
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var _using_navigation: bool = false

signal navigation_finished


func _ready() -> void:
    sprite = get_node("AnimatedSprite2D")
    collision_layer = 3
    collision_mask = 1
    add_to_group("players")

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

    var manual_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if _is_moving_toward_npc(manual_direction):
        velocity = Vector2.ZERO
        return

    if _using_navigation:
        if navigation_agent.is_navigation_finished():
            velocity = Vector2.ZERO
            return

        var next_position: Vector2 = navigation_agent.get_next_path_position()
        var direction: Vector2 = global_position.direction_to(next_position)
        velocity = direction * move_speed
        return

    velocity = manual_direction * move_speed


func _is_moving_toward_npc(direction: Vector2) -> bool:
    if direction == Vector2.ZERO:
        return false

    for npc: Node in get_tree().get_nodes_in_group("npcs"):
        if npc is Node2D:
            var to_npc: Vector2 = npc.global_position - global_position
            if to_npc.length() < 14.0 and direction.dot(to_npc.normalized()) > 0.5:
                return true
    return false


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

    