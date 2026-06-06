extends ToggleIconButton

@export var audio_player: RealtimeAudioPlayer
@export var frequency_tuners: Array[FrequencyDataTuner]

var oscillator: CosGenerator

func _ready() -> void:
    super()
    toggled.connect(_on_toggled)
    for tuner in frequency_tuners:
        tuner.frequency_data_changed.connect(_on_frequency_data_changed)
    oscillator = CosGenerator.new()
    oscillator.set_waves(get_all_frequency_data(), 44100)
    audio_player.set_generator(oscillator.next_sample)


func get_all_frequency_data() -> Array[FrequencyData]:
    var data: Array[FrequencyData] = []
    for tuner in frequency_tuners:
        data.append(tuner.frequency_data)
    return data


func _on_toggled(is_toggled: bool) -> void:
    if is_toggled:
        play()
    else:
        stop()


func _on_frequency_data_changed(_new_frequency: FrequencyData) -> void:
    oscillator.update_waves(get_all_frequency_data())
    if not button_pressed:
        return
    audio_player.set_generator(oscillator.next_sample)



func play() -> void:
    audio_player.set_generator(oscillator.next_sample)
    audio_player.play()


func stop() -> void:
    audio_player.stop()
