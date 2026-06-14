class_name BufferPlayer extends Node

@export var buffer_length: float = 0.5
@export var looped: bool = false
@export var scrub_speed_limit: float = 8.0

var _player: AudioStreamPlayer
var _generator: AudioStreamGenerator
var _playback: AudioStreamGeneratorPlayback

var audio_signal: SignalResource = SignalResource.new()
var _position: float = 0.0
var _speed: float = 0.0
var _resume_speed: float = 1.0


func _ready() -> void:
    _player = AudioStreamPlayer.new()
    add_child(_player)


func _create_generator() -> void:
    _generator = AudioStreamGenerator.new()
    _generator.mix_rate = audio_signal.SampleRate
    _generator.buffer_length = buffer_length

    _player.stream = _generator
    _player.play()

    _playback = _player.get_stream_playback()



func load_signal(new_signal: SignalResource) -> void:
    audio_signal = new_signal
    _create_generator()
    seek(0)
    stop()


func play() -> void:
    _speed = 1.0


func pause() -> void:
    _speed = 0.0


func stop() -> void:
    _speed = 0.0
    seek(0)


func is_playing() -> bool:
    return not is_zero_approx(_speed)


func set_loop(enabled: bool) -> void:
    looped = enabled


func seek(sample_index: int) -> void:
    var max_index: int = maxi(audio_signal.SampleCount - 1, 0)
    _position = clamp(sample_index, 0, max_index)


func seek_progress(progress: float) -> void:
    progress = clamp(progress, 0.0, 1.0)
    var max_index: int = maxi(audio_signal.SampleCount - 1, 0)
    _position = clamp(progress * max_index, 0, max_index)


func get_progress() -> float:
    if audio_signal.SampleCount <= 0:
        return 0.0
    return _position / float(audio_signal.SampleCount - 1)


func _process(_delta: float) -> void:
    if not _playback or audio_signal.Samples.is_empty() or is_zero_approx(_speed):
        return

    var frames: int = _playback.get_frames_available()
    if frames <= 0:
        return
    for i in range(frames):
        if not _wrap_or_stop():
            break
        var sample: float = _sample_linear(_position)
        _playback.push_frame(Vector2(sample, sample))
        _position += _speed


func begin_scrub() -> void:
    if audio_signal.SampleCount <= 0:
        return
    _resume_speed = _speed
    _speed = 0.0


func set_speed(speed: float) -> void:
    # speed is in samples per output frame
    # 1.0 = forward, -1.0 = reverse, 0.0 = static
    if abs(speed) < 0.02:
        speed = 0.0
    _speed = clamp(speed, -scrub_speed_limit, scrub_speed_limit)


func end_scrub() -> void:
    _speed = _resume_speed


func _wrap_or_stop() -> bool:
    var sample_count: int = audio_signal.SampleCount
    if sample_count <= 0:
        return false

    if looped:
        var length: float = float(sample_count)
        while _position < 0.0:
            _position += length
        while _position >= length:
            _position -= length
        return true

    if _position < 0.0:
        _position = 0.0
        _speed = 0.0
        return false

    if _position >= float(sample_count):
        _position = float(sample_count - 1)
        _speed = 0.0
        return false

    return true


func _sample_linear(position: float) -> float:
    return audio_signal.Samples[position]
    #* the following algorithm is for linear sampling 
    #* It is commented out because currently there is no use for it
    #! AND it introduces a weird big where cursor animation looks choppy
    # var sample_count: int = audio_signal.SampleCount
    # if sample_count <= 0:
    # 	return 0.0
    # if sample_count == 1:
    # 	return audio_signal.Samples[0]

    # position = clamp(position, 0.0, float(sample_count - 1))
    # var index_a: int = int(position)
    # var index_b: int = min(index_a + 1, sample_count - 1)
    # var fraction: float = position - float(index_a)

    # var sample_a: float = audio_signal.Samples[index_a]
    # var sample_b: float = audio_signal.Samples[index_b]

    # return lerpf(sample_a, sample_b, fraction)
