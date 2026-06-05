extends Control

@export var wave_form_draw: WaveFormUI

func _ready() -> void:
	wave_form_draw.set_display(size.x, size.y)
	wave_form_draw.global_position = global_position
	resized.connect(_on_resized)


func _on_resized() -> void:
	wave_form_draw.set_display(size.x, size.y) 
