class_name PlaybackButton extends ToggleIconButton

@export var audio_player: Node


func _ready() -> void:
	super()
	toggled.connect(_on_toggled)


func _process(_delta: float) -> void:
	if not audio_player:
		return
	if button_pressed and not audio_player.is_playing():
		button_pressed = false

	_update_icon(audio_player.is_playing())


func _update_icon(is_toggled: bool) -> void:
	var active: bool = true
	if button_group:
		active = button_group.get_pressed_button() == self
	super(is_toggled and active)


func _on_toggled(is_toggled: bool) -> void:
	if is_toggled:
		if is_equal_approx(audio_player.get_progress(), 1.0):
			audio_player.stop()
		audio_player.play()
	else:
		audio_player.pause()
