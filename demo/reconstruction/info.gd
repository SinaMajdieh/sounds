extends Control

@export_subgroup("Labels")
@export var samples_per_segment_label: Label
@export var segment_duration_label: Label
@export var frequency_per_segment_label: Label
@export var frequency_spacing_label: Label

func update_info(
    source_signal: SignalResource,
    samples_per_segment,
    num_segments
    ) -> void:
    if not source_signal:
        return

    var segment_duration_ms: int = int(
        samples_per_segment / float(source_signal.SampleRate) * 1000.0
    )

    samples_per_segment_label.text = str(samples_per_segment)
    segment_duration_label.text = "%d ms" % segment_duration_ms

    var nyquist: int = int(source_signal.SampleRate / 2.0 + 1)
    frequency_per_segment_label.text = str(nyquist)

    frequency_spacing_label.text = "%d Hz" % num_segments