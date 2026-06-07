extends Label

@export var tuner_group: Node

func _process(_delta: float) -> void:
	var tuner_count: int = 0
	if tuner_group:
		tuner_count = tuner_group.get_child_count()
	text = "Number of Signals %d" % tuner_count
