class_name Door extends CharacterBody2D


@export_file("*.tscn") var destination_scene: String = ""


func _ready() -> void:
	var enter_house: Node = get_tree().current_scene.find_child("EnterHouse", true, false)
	if enter_house is EnterHouse:
		enter_house.enter_house.connect(_on_enter_house)
	else:
		$EnterArea.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		_change_scene()


func _on_enter_house() -> void:
	_change_scene()


func _change_scene() -> void:
	SceneTransition.change_scene(destination_scene)
