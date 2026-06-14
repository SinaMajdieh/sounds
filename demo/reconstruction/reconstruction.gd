extends Node

@export_category("Elements")
@export var waveform_renderer: WaveformRenderer
@export var audio_player: BufferPlayer

@export_subgroup("Slider")
@export var slider_label: Label
@export var slider: HSlider

@export_subgroup("Labels")
@export var samples_per_segment_label: Label
@export var segment_duration_label: Label
@export var frequency_per_segment_label: Label
@export var frequency_spacing_label: Label

@export_category("Data")
@export var num_segments: int = 1

@export_global_file("*.wav") var wav_path: String

var stft: StftResultResource
var source_signal: SignalResource
var reconstructed_signal: SignalResource

var samples_per_segment: int = 0
var current_segment_index: int = -1


func _ready() -> void:
	slider.value_changed.connect(_on_slider_value_changed)

	open_wav()
	apply_stft()
	reconstruct()
	audio_player.load_signal(reconstructed_signal)
	update_info()

	slider.value = 0.0
	_on_slider_value_changed(slider.value)


func _on_slider_value_changed(value: float) -> void:
	if not stft or stft.Segments.is_empty():
		return

	value = clamp(value, 0.0, 1.0)

	var max_index: int = stft.Segments.size() - 1
	var segment_index: int = floori(value * max_index)

	if segment_index == current_segment_index:
		return

	current_segment_index = segment_index

	slider_label.text = "Segment [%d / %d]" % [
		segment_index + 1,
		stft.Segments.size()
	]

	var segment = stft.Segments[segment_index]
	draw_form(segment.StartIndex, segment.StartIndex + segment.SampleCount)


func open_wav() -> void:
	if wav_path.is_empty():
		return

	var wav_file: FileAccess = FileAccess.open(wav_path, FileAccess.READ)
	if not wav_file:
		push_error(FileAccess.get_open_error())
		return

	var wav_signal = WavReader.read(wav_file)
	source_signal = SignalResource.Create(
		wav_signal.samples,
		wav_signal.sample_rate
	)


func apply_stft() -> void:
	if not source_signal:
		return

	num_segments = max(1, num_segments)

	samples_per_segment = ceil(
		source_signal.SampleCount / float(num_segments)
	)

	stft = Stft.ComputeResource(source_signal, samples_per_segment)


func reconstruct() -> void:
	if not stft:
		return

	reconstructed_signal = Stft.ReconstructSignalResource(stft)


func draw_form(begin: int, end: int) -> void:
	if not reconstructed_signal:
		return
	waveform_renderer.draw(reconstructed_signal.Samples, begin, end)


func update_info() -> void:
	if not source_signal:
		return

	var segment_duration_ms := int(
		samples_per_segment / float(source_signal.SampleRate) * 1000.0
	)

	samples_per_segment_label.text = str(samples_per_segment)
	segment_duration_label.text = "%d ms" % segment_duration_ms

	var nyquist := int(source_signal.SampleRate / 2.0 + 1)
	frequency_per_segment_label.text = str(nyquist)

	frequency_spacing_label.text = "%d Hz" % num_segments
