class_name PlaybackButton extends ToggleIconButton

@export var audio_player: Node


func _ready() -> void:
	super()
	toggled.connect(_on_toggled)


func _process(_delta: float) -> void:
	if button_pressed and not audio_player.is_playing():
		button_pressed = false


func _on_toggled(is_toggled: bool) -> void:
	if is_toggled:
		audio_player.play()
	else:
		audio_player.pause()
