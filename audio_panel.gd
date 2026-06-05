extends Control

@export var wave_form_draw: WaveFormUI
@export var audio_name_label: Label
@export var audio_info_label: Label
@export_global_file("*.wav") var wav_path: String

var audio: WavSignal = WavSignal.new()

func _ready() -> void:
	var wav_file: FileAccess = FileAccess.open(wav_path, FileAccess.READ)
	assert(wav_file)
	audio = WavReader.read(wav_file)
	wav_file.close()

func _display_audio() -> void:
	wave_form_draw.animate_draw(audio.samples, 1.618)
	audio_name_label.text = wav_path
	audio_info_label.text = "Sampling Rate: %d\nNumber of Samples: %d\nDuration: %.2fs" % [
		audio.sample_rate,
		audio.samples.size(),
		audio.samples.size() / float(audio.sample_rate)
	]

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ENTER:
			_display_audio()
