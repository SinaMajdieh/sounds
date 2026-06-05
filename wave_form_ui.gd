class_name WaveFormUI
extends Node2D

enum DrawStyle {
	CONTINUOUS,
	BARS
}

@export var resolution: int = 1
@export var draw_style: DrawStyle = DrawStyle.BARS
@export var scale_height: bool = false
@export var color: Color = Color("a6e3a1")
@export var line_width: float = 2.0
@export var transition: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

var _width: float = 0.0
var _height: float = 0.0
var _center_y: float = 0.0

var _samples: PackedFloat32Array = PackedFloat32Array()
var _num_samples: int = 0

var _max_amplitude: float = 1.0

var _tween: Tween = null
var _progress: float = 0.0:
	set = _set_progress

var _draw_method: Callable = _draw_bars

func _set_progress(value: float) -> void:
	_progress = clamp(value, 0.0, 1.0)
	queue_redraw()


func set_display(width: float, height: float) -> void:
	_width = width
	_height = height
	_center_y = height * 0.5
	queue_redraw()


func set_samples(samples: PackedFloat32Array) -> void:
	_samples = samples
	_num_samples = ceili(samples.size() / float(resolution))
	print("Number of samples: %d" % _num_samples)
	_max_amplitude = max.callv(samples)
	if _max_amplitude == 0.0 or not scale_height:
		_max_amplitude = 1.0


func draw(samples: PackedFloat32Array) -> void:
	set_samples(samples)
	_update_draw_method()
	_progress = 1.0


func animate_draw(samples: PackedFloat32Array, duration: float) -> void:
	set_samples(samples)
	_update_draw_method()

	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(self, "_progress", 1.0, duration).from(0.0)\
		.set_trans(transition)\
		.set_ease(ease_type)


func _update_draw_method() -> void:
	match draw_style:
		DrawStyle.BARS: _draw_method = _draw_bars
		DrawStyle.CONTINUOUS: _draw_method = _draw_continuous
		_: return


func _draw() -> void:
	if _samples.is_empty() or _progress <= 0.0:
		return
	_draw_method.call()


func _draw_bars() -> void:
	draw_line(
		Vector2(0.0, _center_y),
		Vector2(_width * _progress, _center_y),
		color,
		line_width
	)
	
	var num_visible_samples: int = int(_num_samples * _progress)

	if num_visible_samples <= 1:
		return

	var points: PackedVector2Array = PackedVector2Array()
	points.resize(num_visible_samples * 2)

	for i: int in range(0, num_visible_samples):
		var sample_index: int = i * resolution
		var x: float = float(i) / float(_num_samples - 1) * _width
		var amplitude: float = abs(_samples[sample_index]) / _max_amplitude * _center_y

		points[i * 2] = Vector2(x, _center_y + amplitude)
		points[i * 2 + 1] = Vector2(x, _center_y - amplitude)

	draw_multiline(points, color, line_width)


func _draw_continuous() -> void:
	var num_visible_samples: int = int(_num_samples * _progress)
	
	if num_visible_samples <= 1:
		return

	var points: PackedVector2Array = PackedVector2Array()
	points.resize(num_visible_samples)

	for i: int in range(0, num_visible_samples):
		var sample_index: int = i * resolution
		var x: float = float(i) / float(_num_samples - 1) * _width
		var y: float = _center_y - (_samples[sample_index] / _max_amplitude) * _center_y
		points[i] = Vector2(x, y)

	draw_polyline(points, color, line_width)
