extends Node

var canvas_layer: CanvasLayer
var color_rect: ColorRect
var is_transitioning: bool = false

func _ready() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	color_rect = ColorRect.new()
	color_rect.color = Color.BLACK
	color_rect.modulate.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(color_rect)

func change_scene(target_path: String, duration: float = 0.5) -> void:
	if is_transitioning:
		return

	is_transitioning = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween_out = create_tween()
	tween_out.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween_out.finished
	
	get_tree().change_scene_to_file(target_path)
	
	var tween_in = create_tween()
	tween_in.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween_in.finished
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
