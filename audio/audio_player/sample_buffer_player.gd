class_name SampleBufferPlayer extends Node

@export var buffer_length: float = 0.5
@export var looped: bool = false

var _player: AudioStreamPlayer
var _generator: AudioStreamGenerator
var _playback: AudioStreamGeneratorPlayback

var audio_signal: SignalResource = SignalResource.new()
var position: int = 0
var playing: bool = false


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
    seek(0)
    _create_generator()


func play() -> void:
    playing = true


func pause() -> void:
    playing = false


func stop() -> void:
    playing = false
    seek(0)


func is_playing() -> bool:
    return playing


func set_loop(enabled: bool) -> void:
    looped = enabled


func seek(sample_index: int) -> void:
    position = clamp(sample_index, 0, audio_signal.SampleCount - 1)


func get_progress() -> float:
    if audio_signal.SampleCount <= 0:
        return 0.0
    return float(position) / audio_signal.SampleCount


func _process(_delta: float) -> void:
    if not playing or audio_signal.Samples.is_empty():
        return
    
    var frames: int = _playback.get_frames_available()

    for i: int in range(frames):
        if position >= audio_signal.SampleCount:
            if not looped:
                stop()
                break
            # if was looped go back to the beginning
            seek(0)
        
        var sample: float = audio_signal.Samples[position]
        position += 1

        _playback.push_frame(Vector2(sample, sample))