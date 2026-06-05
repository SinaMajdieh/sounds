class_name WaveFormView extends Control

@export var wave_form_draw: WaveFormRenderer
@export_subgroup("Margin")
@export var margin: Dictionary[String, float] = {
	top = 3.0,
	right = 3.0,
	bottom = 3.0,
	left = 3.0
}

func _ready() -> void:
	wave_form_draw.set_display(size.x - margin.left - margin.right, size.y - margin.top - margin.bottom)
	wave_form_draw.global_position = global_position + Vector2(margin.left, margin.top)
	resized.connect(_on_resized)


func _on_resized() -> void:
	wave_form_draw.set_display(size.x - margin.left - margin.right, size.y - margin.top - margin.bottom)
	wave_form_draw.global_position = global_position + Vector2(margin.left, margin.top)
