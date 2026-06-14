extends Button

@export var tuner_group: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	tuner_group.add_tuner()