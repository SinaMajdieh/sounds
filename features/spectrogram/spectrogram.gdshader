shader_type canvas_item;

uniform float display_seconds;
uniform float display_frequency;
uniform float total_seconds;
uniform float max_frequency;
uniform float max_amplitude;
uniform bool normalize = false;

uniform sampler2D spectrogram_texture;
uniform sampler2D gradient_texture;

void fragment() {
    float time_fraction = display_seconds / total_seconds;
    float freq_fraction = display_frequency / max_frequency;

    vec2 remapped_uv = vec2(
        UV.x * time_fraction,
        1.0 - (1.0 - UV.y) * freq_fraction
    );

    float amplitude = texture(spectrogram_texture, remapped_uv).r;
	if (normalize) {
		amplitude /= max_amplitude;
	}
    COLOR = texture(gradient_texture, vec2(amplitude, 0.5));
}
