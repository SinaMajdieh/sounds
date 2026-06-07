extends Node

@export var num_tuners: int = 10
@export var tuner_group: Node

func _ready() -> void:
    tuner_group.add_tuner(num_tuners)