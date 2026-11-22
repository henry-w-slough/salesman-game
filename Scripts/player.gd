extends CharacterBody2D


var sprite: AnimatedSprite2D = null

@export var move_speed = 100


func _ready() -> void:
    sprite = get_node("AnimatedSprite2D")


func _physics_process(_delta: float) -> void:
    _update_movement()
    _update_animation()
    move_and_slide()


func _update_movement() -> void:
    var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_direction * move_speed


func _update_animation() -> void:

    if velocity == Vector2.ZERO:
        sprite.play("idle_right")
    else:
        sprite.play("walk_right")

    if velocity.x < 0:
        sprite.flip_h = true
    elif velocity.x > 0:
        sprite.flip_h = false

    