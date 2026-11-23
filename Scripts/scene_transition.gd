extends CanvasLayer


@export var fade_duration: float = 0.35

var _overlay: ColorRect
var _is_transitioning: bool = false


func _ready() -> void:
	layer = 100

	_overlay = ColorRect.new()
	_overlay.color = Color.BLACK
	_overlay.modulate.a = 0.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)


func change_scene(scene_path: String) -> void:
	if _is_transitioning or scene_path.is_empty():
		return

	await fade_out()

	var error: Error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Could not change scene to: %s" % scene_path)

	await get_tree().process_frame
	await fade_in()


func fade_out() -> void:
	if _is_transitioning:
		return

	_is_transitioning = true
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0)


func fade_in() -> void:
	if not _is_transitioning:
		return

	await _fade_to(0.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false


func _fade_to(target_alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(_overlay, "modulate:a", target_alpha, fade_duration)
	await tween.finished
