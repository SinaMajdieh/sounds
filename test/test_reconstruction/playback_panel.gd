class_name PlaybackPanel extends Control

@export_subgroup("Elements")
@export var wave_form_draw: WaveformRenderer
@export var buffer_player: SampleBufferPlayer
@export_subgroup("Buttons")
@export var play_button: CheckButton
@export var render_button: Button

var audio: SignalResource = SignalResource.new()


func _ready() -> void:
    play_button.toggled.connect(toggle_play_back)
    render_button.pressed.connect(render_waveform)
    render_waveform()


func open(new_signal: SignalResource) -> void:
    if not new_signal:
        return
    if new_signal.SampleCount <= 0:
        return
    audio = new_signal
    buffer_player.load_signal(new_signal)
    render_waveform()


func render_waveform() -> void:
    wave_form_draw.animate_draw(audio.Samples, 1.618)


func toggle_play_back(toggled: bool) -> void:
    if toggled:
        buffer_player.play()
    else:
        buffer_player.pause()
