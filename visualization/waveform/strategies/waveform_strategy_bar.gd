class_name WaveformBars
extends WaveformStrategy


func draw(canvas, cache, progress, width, height, color, line_width) -> void:

    var center_y: float = height * 0.5
    canvas.draw_line(Vector2(0, center_y), Vector2(width * progress, center_y), color, line_width)
    var visible_columns: int = int(cache.mins.size() * progress)

    if visible_columns <= 0:
        return
    var points: PackedVector2Array
    points.resize(visible_columns * 2)

    for i in range(visible_columns):
        var x: float = float(i) / float(cache.mins.size() - 1) * width
        var min_val: float = cache.mins[i]
        var max_val: float = cache.maxs[i]
        var amplitude: float = max(abs(min_val), abs(max_val))

        var y1: float = center_y - amplitude * center_y
        var y2: float = center_y + amplitude * center_y

        points[i * 2] = Vector2(x, y1)
        points[i * 2 + 1] = Vector2(x, y2)

    canvas.draw_multiline(points, color, line_width)
