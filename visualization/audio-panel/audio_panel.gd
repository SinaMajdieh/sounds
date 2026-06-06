extends Control

@export_subgroup("Elements")
@export var wave_form_draw: WaveformRenderer
@export var audio_name_label: Label
@export var audio_info_label: Label
@export var buffer_player: SampleBufferPlayer
@export_subgroup("Buttons")
@export var play_button: CheckButton
@export var render_button: Button


var file_name: String
var audio: WavSignal = WavSignal.new()


func _ready() -> void:
	play_button.toggled.connect(toggle_play_back)
	render_button.pressed.connect(render_waveform)
	render_waveform()


func open(wav_path: String) -> void:
	if wav_path.is_empty():
		return
	
	var wav_file: FileAccess = FileAccess.open(wav_path, FileAccess.READ)

	if not wav_file:
		return

	audio = WavReader.read(wav_file)
	wav_file.close()

	buffer_player.load_signal(audio)

	file_name = wav_path.get_file()
	render_waveform()


func render_waveform() -> void:
	wave_form_draw.animate_draw(audio.samples, 1.618)
	audio_name_label.text = file_name
	audio_info_label.text = "Sampling Rate: %d\nNumber of Samples: %d\nDuration: %.2fs" % [
		audio.sample_rate,
		audio.samples.size(),
		audio.get_duration()
	]


func toggle_play_back(toggled: bool) -> void:
	if toggled:
		buffer_player.play()
	else:
		buffer_player.pause()

