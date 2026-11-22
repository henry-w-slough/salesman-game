extends CharacterBody2D


@onready var trigger_area: Area2D = $Area2D


func _ready() -> void:
	trigger_area.body_entered.connect(_on_body_entered)
	trigger_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	#opaqueness on overlapping player 
	if body.name == "Player":
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.25)


func _on_body_exited(body: Node2D) -> void:
	#opaqueness on overlapping player undo
	if body.name == "Player":
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.25)
