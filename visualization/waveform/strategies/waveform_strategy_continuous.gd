class_name WaveformContinuous
extends WaveformStrategy


func draw(canvas, cache, progress, width, height, color, line_width) -> void:
	var center_y: float = height * 0.5
	var visible_columns: int = int(cache.mins.size() * progress)

	if visible_columns <= 1:
		return

	var points: PackedVector2Array
	points.resize(visible_columns)

	for i in range(visible_columns):
		var x: float = float(i) / float(cache.mins.size() - 1) * width
		var mid: float = (cache.mins[i] + cache.maxs[i]) * 0.5

		var peak: float = cache.maxs[i]
		if abs(cache.mins[i]) > abs(cache.maxs[i]):
			peak = cache.mins[i]

		var y_val: float = lerp(mid, peak, 0.4)
		var y: float = center_y - y_val * center_y

		points[i] = Vector2(x, y)

	canvas.draw_polyline(points, color, line_width)
