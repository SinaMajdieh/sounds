extends Node

@export_category("Elements")
@export var waveform_renderer: WaveformRenderer
@export var audio_player: BufferPlayer
@export var info: Control

@export_subgroup("Slider")
@export var slider_label: Label
@export var slider: HSlider

@export_category("Data")
@export var num_segments: int = 1
@export var selected_segment_num: int = -1

@export_global_file("*.wav") var wav_path: String

var stft: StftResultResource
var source_signal: SignalResource
var reconstructed_signal: SignalResource

var samples_per_segment: int = 0
var current_segment_index: int = -1


func _ready() -> void:
	slider.value_changed.connect(_on_slider_value_changed)
	
	demo_reconstruction()
	
	slider.value = 0.0
	_on_slider_value_changed(slider.value)


func demo_reconstruction() -> void:
	open_wav()
	apply_stft()
	take_top_frequencies(selected_segment_num)
	reconstruct()
	audio_player.load_signal(reconstructed_signal)
	info.update_info(source_signal, samples_per_segment, num_segments)


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


## Taking the specified number of top frequencies in each segment
func take_top_frequencies(num: int) -> void:
	if num <= 0:
		return
	for segment: StftSegmentResource in stft.Segments:
		segment.Spectrum.sort_custom(
			func(a, b):
				if abs(a.Frequency) > (b.Frequency):
					return true
				return false 
		)
		segment.Spectrum = segment.Spectrum.slice(0, num)