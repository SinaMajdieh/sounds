class_name Axis extends Control

@export_category("Axis Data")
@export var min_value: float = 0.0
@export var max_value: float = 100.0

@export_category("Style")
@export var orientation: Orientation = Orientation.HORIZONTAL
@export var axis_color: Color = Color.WHITE
@export_subgroup("Tick")
@export var num_ticks: float = 0.0
@export var tick_length: int = 8
@export var tick_thickness: float = 1.5
@export_subgroup("Label")
@export var label_font_size: int = 12
@export var label_margin: float = 4.0

@export var value_formatter: Callable


func update_axis(p_min: float, p_max: float, p_tick: int) -> void:
    min_value = p_min
    max_value = p_max
    num_ticks = p_tick
    queue_redraw()


func _draw() -> void:
    if num_ticks < 2 or max_value <= min_value:
        return
    
    var tick_interval: float = (max_value - min_value) / (num_ticks - 1)

    for i in range(num_ticks):
        var value: float = min_value + i * tick_interval
        var norm: float = float(i) / (num_ticks - 1)

        if orientation == Orientation.HORIZONTAL: _draw_horizontal(norm, value)
        else: _draw_vertical(norm, value)


func _draw_horizontal(norm: float, value: float) -> void:
    var x: float = (norm * size.x) - (tick_thickness * 0.5)
    var y_end: float = tick_length

    draw_line(
        Vector2(x, 0), 
        Vector2(x, y_end), 
        axis_color, 
        tick_thickness
    )

    var label: String = _format_value(value)
    var font: Font = get_theme_default_font()
    var label_size: Vector2 = font.get_string_size(
        label, 
        HORIZONTAL_ALIGNMENT_LEFT, 
        -1, 
        label_font_size
    )
    var label_position: Vector2 = Vector2(
        x - label_size.x / 2,
        label_size.y + tick_length + label_margin
    )

    draw_string(
        get_theme_default_font(),
        label_position,
        label,
        HORIZONTAL_ALIGNMENT_LEFT,
        -1,
        label_font_size,
        axis_color
    )


func _draw_vertical(tick: float, value: float) -> void:
    # Inverted: 0 at bottom
    var y: float = (size.y - tick * size.y) + (tick_thickness * 0.5)
    var x_start: float = size.x - tick_length

    draw_line(
        Vector2(x_start, y), 
        Vector2(size.x, y), 
        axis_color, 
        tick_thickness
    )

    var label: String = _format_value(value)
    var font: Font = get_theme_default_font()
    var label_size: Vector2 = font.get_string_size(
        label, 
        HORIZONTAL_ALIGNMENT_LEFT, 
        -1, 
        label_font_size
    )
    var label_position: Vector2 = Vector2(
        size.x - label_size.x - tick_length - label_margin,
        y + label_size.y / 4
    )
    draw_string(
        get_theme_default_font(),
        label_position,
        label,
        HORIZONTAL_ALIGNMENT_LEFT,
        -1,
        label_font_size,
        axis_color
    )


func _format_value(value: float) -> String:
    if value_formatter.is_valid():
        return value_formatter.call(value)

    # Default formatting
    if abs(value) >= 1000.0:
        return "%.1fk" % (value / 1000.0)
    elif abs(value) < 1.0:
        return "%.2f" % value
    else:
        return "%.1f" % value