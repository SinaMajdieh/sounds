extends Control

@export_subgroup("Labels")
@export var samples_per_segment_label: Label
@export var segment_duration_label: Label
@export var frequency_per_segment_label: Label
@export var frequency_spacing_label: Label

func update_info(
    stft: StftResultResource
    ) -> void:
    if not stft:
        return

    var segment_duration_ms: int = int(stft.SegmentDuration * 1000.0)
    segment_duration_label.text = "%d ms" % segment_duration_ms

    var nyquist: int = int(stft.SampleRate / 2.0 + 1)
    frequency_per_segment_label.text = str(nyquist)

    frequency_spacing_label.text = "%d Hz" % stft.FrequencySpacing