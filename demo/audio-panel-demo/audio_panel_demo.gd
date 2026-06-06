extends Node

@export var panel: Node
@export_global_file("*.wav") var wav_path: String

func _ready() -> void:
    panel.open(wav_path)