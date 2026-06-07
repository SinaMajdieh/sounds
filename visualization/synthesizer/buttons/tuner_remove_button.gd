extends Button

signal tuner_removed_request(tuner: SignalTuner)


@export var tuner: SignalTuner
@export_subgroup("Colors")
@export var hover_color: Color 
@export var color: Color


func _ready() -> void:
    pressed.connect(_on_pressed)
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)


func _on_pressed() -> void:
    if not tuner:
        return
    tuner_removed_request.emit(tuner)


func _on_mouse_entered() -> void:
    modulate = hover_color


func _on_mouse_exited() -> void:
    modulate = color
