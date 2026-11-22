extends Node


#properties
@export var scenes: Array[Scene] = []


func _ready() -> void:

    for scene in scenes:
        scene.initialize(self)



