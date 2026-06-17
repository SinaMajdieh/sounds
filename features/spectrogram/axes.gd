extends Node

@export_category("Elements")
@export var frequency_axis: Axis
@export var time_axis: Axis


func _ready() -> void:
    frequency_axis.orientation = Orientation.VERTICAL
    frequency_axis.value_formatter = frequency_formatter
    time_axis.orientation = Orientation.HORIZONTAL
    time_axis.value_formatter = time_formatter


func update_time_axis(max_time: float, num_ticks: int = 5) -> void:
    time_axis.update_axis(0.0, max_time, num_ticks)


func update_frequency_axis(max_frequency: float, num_ticks: int = 5) -> void:
    frequency_axis.update_axis(0.0, max_frequency, num_ticks)


func frequency_formatter(value: float) -> String:
    return "%.0fHz" % value if value < 1000 else "%.1fkHz" % (value / 1000.0)


func time_formatter(value: float) -> String:
    return "%.2fs" % value