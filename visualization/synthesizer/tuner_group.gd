extends Control

signal frequency_data_changed(new_frequencies: Array[FrequencyData])

@export_subgroup("Elements")
@export var sample_tuner: SignalTuner
@export var remove_button_path: String
@export var audio_player: RealtimeAudioPlayer
@export var button_group: ButtonGroup = ButtonGroup.new()
@export_subgroup("Properties")
@export var palette: ColorPalette

var tuner_frequency: Dictionary[SignalTuner, FrequencyData] = {}


func add_tuner(amount: int = 1) -> void:
	for i in range(amount):
		var new_tuner: SignalTuner = sample_tuner.duplicate()
		new_tuner.waveform_renderer.color = _resolve_color()
		_setup_tuner(new_tuner)
		add_child(new_tuner)
		move_child(new_tuner, 0)
		new_tuner.show()


func _setup_tuner(tuner: SignalTuner) -> void:
	tuner_frequency.set(tuner, tuner.frequency_tuner.frequency_data)
	tuner.frequency_tuner.frequency_data_changed.connect(_on_frequency_data_changed)
	var tuner_remove_button: Button = tuner.get_node(remove_button_path)
	if tuner_remove_button:
		tuner_remove_button.tuner_removed_request.connect(remove_tuner)
	tuner.play_button.audio_player = audio_player
	tuner.play_button.button_group = button_group
	frequency_data_changed.emit(tuner_frequency.values())



func remove_tuner(tuner: SignalTuner) -> void:
	if not tuner or not tuner_frequency.has(tuner):
		return
	tuner_frequency.erase(tuner)
	tuner.queue_free()
	frequency_data_changed.emit(tuner_frequency.values())


func setup_tuners() -> void:
	for tuner in get_children():
		if not tuner is SignalTuner:
			continue
		_setup_tuner(tuner)


func _on_frequency_data_changed(_new_data: FrequencyData) -> void:
	frequency_data_changed.emit(tuner_frequency.values())


func _resolve_color() -> Color:
	var num_tuners: int = get_child_count()
	var color_index: int = (num_tuners) % palette.colors.size()
	return palette.colors[color_index]
