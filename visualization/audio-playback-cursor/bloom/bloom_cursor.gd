class_name BloomCursor extends AudioPlaybackCursor

@export_subgroup("References")
@export var player: Node
@export var waveform_renderer: WaveformRenderer
@export_subgroup("Appearance")
@export var shader: ShaderMaterial
@export var glow_width : int = 100:
	set = set_glow_width
@export var glow_color : Color = Color("f2d5cf"):
	set = set_glow_color

var pixel_progress : float = 0.0

func bind_player(new_player: Node) -> void:
	if not new_player.has_method("get_progress"):
		push_error("player does not implement 'get_progress'")
		return
	player = new_player


func _ready() -> void:
	waveform_renderer.material = shader
	shader.set_shader_parameter("base_color", waveform_renderer.color)


func _process(_delta):
	if not player or not waveform_renderer:
		return
	if not player.is_playing():
		return

	var progress: float = clamp(player.get_progress(),0.0,1.0)
	pixel_progress = progress * waveform_renderer.size.x

	shader.set_shader_parameter("base_color", waveform_renderer.color)
	shader.set_shader_parameter("playhead_pixel_x", pixel_progress)


func set_glow_width(new_width: int) -> void:
	glow_width = new_width
	shader.set_shader_parameter("glow_pixel_width", glow_width)


func set_glow_color(new_color: Color) -> void:
	glow_color = new_color
	shader.set_shader_parameter("glow_color", glow_color)
