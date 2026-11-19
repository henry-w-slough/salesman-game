extends Node


#properties
@export var scenes: Array[Scene] = []


func _ready() -> void:

    for scene in scenes:
        scene.initialize(self)


func _process(_delta: float) -> void:
    
    scenes[0].enable_camera("Willy")
