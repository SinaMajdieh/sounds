class_name ScrubberSlider extends Slider

@export var audio_player: BufferPlayer
@export var follow_playback: bool = true

# var _last_value: float = 0.0
var _scrubbing: bool = false


func _ready() -> void:
	min_value = 0.0
	max_value = 1.0

func _process(_delta: float) -> void:
	if not audio_player:
		return

	if follow_playback and not _scrubbing:
		value = audio_player.get_progress()
		return
	if _scrubbing:
		_update_scrub()


func _gui_input(event: InputEvent) -> void:
	if not audio_player:
		return
	
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_begin_scrub()
		elif mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			_end_scrub()



func _begin_scrub() -> void:
	_scrubbing = true
	audio_player.begin_scrub()
	audio_player.seek_progress(value)


func _update_scrub() -> void:
	audio_player.set_speed(1)
	audio_player.seek_progress(value)



func _end_scrub() -> void:
	if not _scrubbing:
		return
	_scrubbing = false
	audio_player.end_scrub()
