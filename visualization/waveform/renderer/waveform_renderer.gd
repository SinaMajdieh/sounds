class_name WaveformRenderer
extends Control

signal animation_finished()

@export_range(0.0, 1.0) var resolution_scale: float = 1.0
@export var normalize: bool = false
@export var color: Color = Color("a6e3a1")
@export var line_width: float = 2.0

@export var strategy: WaveformStrategy = WaveformBars.new()
@export var transition: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

var cache: WaveformCache = WaveformCache.new()
var _range_begin: int = 0
var _range_end: int = 0

var _tween: Tween

var progress: float = 0.0:
	set = _set_progress


func _ready() -> void:
	resized.connect(_on_resized)


func _set_progress(v: float) -> void:
	if v == progress:
		return
	progress = clamp(v, 0.0, 1.0)
	queue_redraw()


func set_renderer(r: WaveformStrategy) -> void:
	strategy = r
	queue_redraw()


func _on_resized() -> void:
	_rebuild_cache()


func _rebuild_cache() -> void:
	cache.build(int(size.x * resolution_scale), normalize, _range_begin, _range_end)
	queue_redraw()


func set_samples(samples: PackedFloat32Array, begin: int = 0, end: int= -1) -> void:
	var source_changed: bool = samples != cache.samples
	var range_changed: bool = begin != _range_begin or end != _range_end
	
	if not source_changed and not range_changed:
		return
	
	if source_changed:
		cache.set_samples(samples)
	
	_range_begin = begin
	_range_end = end

	if size.x < 0:
		return
	
	_rebuild_cache()



func draw(samples: PackedFloat32Array, begin: int = 0, end: int = -1) -> void:
	set_samples(samples, begin, end)
	progress = 1.0


func animate_draw(samples: PackedFloat32Array, duration: float, begin: int = 0, end: int = -1) -> void:

	set_samples(samples, begin, end)

	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()

	_tween.tween_property(self, "progress", 1.0, duration).from(0.0)\
		.set_trans(transition)\
		.set_ease(ease_type)
	
	_tween.finished.connect(func (): animation_finished.emit())


func _draw() -> void:

	if cache.mins.is_empty() or progress <= 0.0:
		return

	strategy.draw(
		self,
		cache,
		progress,
		size.x,
		size.y,
		color,
		line_width
	)
