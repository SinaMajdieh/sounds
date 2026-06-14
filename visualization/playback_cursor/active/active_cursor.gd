class_name ActiveCursor extends AudioPlaybackCursor

@export_subgroup("References")
@export var player: Node
@export var waveform_renderer: WaveformRenderer
@export_subgroup("Appearance")
@export var shader: ShaderMaterial
@export var active_color : Color = Color("f2d5cf"):
	set = set_active_color

func bind_player(new_player: Node) -> void:
	if not new_player.has_method("get_progress"):
		push_error("player does not implement 'get_progress'")
		return
	player = new_player


func _ready() -> void:
	waveform_renderer.material = shader
	shader.set_shader_parameter("active_color", active_color)


func _process(_delta):
	if not player or not waveform_renderer:
		return
	shader.set_shader_parameter("active", player.is_playing())


func set_active_color(new_color: Color) -> void:
	active_color = new_color
	shader.set_shader_parameter("active_color", active_color)
