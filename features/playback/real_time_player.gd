extends Node
class_name RealtimeAudioPlayer

@export var sample_rate: int = 44100
@export var buffer_length: float = 0.5

var _player: AudioStreamPlayer
var _generator_stream: AudioStreamGenerator
var _playback: AudioStreamGeneratorPlayback

var generator: Callable
var playing: bool = false

var _frame: Vector2 = Vector2.ZERO


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)

	_generator_stream = AudioStreamGenerator.new()
	_generator_stream.mix_rate = sample_rate
	_generator_stream.buffer_length = buffer_length

	_player.stream = _generator_stream
	_player.play()

	_playback = _player.get_stream_playback()


func set_generator(gen_func: Callable) -> void:
	generator = gen_func


func play() -> void:
	playing = true


func pause() -> void:
	playing = false


func stop() -> void:
	playing = false


func is_playing() -> bool:
	return playing


func _process(_delta: float) -> void:
	if not playing:
		return

	if not _playback:
		return

	if not generator.is_valid():
		return

	var frames: int = _playback.get_frames_available()

	if frames <= 0:
		return

	for i in range(frames):

		var s: float = generator.call()
		# s = clamp(s, -1.0, 1.0)

		_frame.x = s
		_frame.y = s

		_playback.push_frame(_frame)
