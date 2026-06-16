class_name SpectrogramRenderer extends Control

@export_category("Elements")
@export var canvas: Control

@export_category("Data")
@export var num_segments: int = 1
@export var normalize_amplitude: bool = false

@export_category("Shader")
@export var gradient: Gradient
@export var display_seconds: float = -1
@export var display_frequency: float = -1

@export_global_file("*.wav") var wav_path: String

var spectrogram: Spectrogram
var _spectrogram_texture: Texture2D
var _gradient_texture: GradientTexture1D


func _ready() -> void:
	spectrogram = Spectrogram.new()
	if not _load_signal():
		return
	_gradient_texture = _get_gradient()
	_spectrogram_texture = spectrogram.GenerateTexture()
	update_shader()


func _open_wav() -> SignalResource:
	if wav_path.is_empty():
		return

	var wav_file: FileAccess = FileAccess.open(wav_path, FileAccess.READ)
	if not wav_file:
		push_error(FileAccess.get_open_error())
		return

	var wav_signal = WavReader.read(wav_file)
	return SignalResource.Create(
		wav_signal.samples,
		wav_signal.sample_rate
	)


func _load_signal() -> bool:
	var source_signal: SignalResource = _open_wav()
	if not source_signal:
		return false
	num_segments = max(1, num_segments)

	var samples_per_segment: int = ceili(
		source_signal.SampleCount / float(num_segments)
	)
	spectrogram.LoadSignal(source_signal, samples_per_segment)
	return true


func _get_gradient() -> GradientTexture1D:
	var texture: GradientTexture1D = GradientTexture1D.new()
	texture.gradient = gradient
	# texture.width = 256
	return texture


func update_shader() -> void:
	var mat: ShaderMaterial = canvas.material as ShaderMaterial
	if not mat:
		push_error("canvas.material is not a ShaderMaterial")
		return

	display_seconds = display_seconds if display_seconds > 0 else spectrogram.Duration
	display_frequency = display_frequency if display_frequency > 0 else spectrogram.MaxFrequency

	mat.set_shader_parameter("spectrogram_texture", _spectrogram_texture)
	mat.set_shader_parameter("gradient_texture", _gradient_texture)
	mat.set_shader_parameter("normalize", normalize_amplitude)
	mat.set_shader_parameter("max_amplitude", spectrogram.MaxAmplitude)
	mat.set_shader_parameter("max_frequency", spectrogram.MaxFrequency)
	mat.set_shader_parameter("display_frequency", display_frequency)
	mat.set_shader_parameter("total_seconds", spectrogram.Duration)
	mat.set_shader_parameter("display_seconds", display_seconds)
