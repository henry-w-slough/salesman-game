class_name Scene extends Resource


@export var camera_paths: Dictionary[String, NodePath] = {}
var _cameras: Dictionary[String, Camera2D] = {}


func enable_camera(name: String) -> void:
    
    if not _cameras.has(name):
        push_warning("Camera of name: '"+name+"' was set to be current but does not exist.")
        return

    _cameras[name].enabled = true
    _cameras[name].make_current()


func get_cameras() -> Dictionary[String, Camera2D]:
    return _cameras

    
func initialize(context: Node) -> void:
    _cameras.clear()

    for camera_name in camera_paths:
        var camera_node := context.get_node_or_null(camera_paths[camera_name])
        if not camera_node is Camera2D:
            push_error("Camera path for '" + camera_name + "' does not point to a Camera2D.")
            continue

        _cameras[camera_name] = camera_node


    