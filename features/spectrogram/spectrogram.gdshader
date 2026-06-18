shader_type canvas_item;

uniform float display_seconds;
uniform float display_frequency;
uniform float total_seconds;
uniform float max_frequency;
uniform float max_amplitude;

// dB range for perceptual mapping
uniform float min_db = -80.0;
uniform float max_db = 0.0;

uniform sampler2D spectrogram_texture;
uniform sampler2D gradient_texture;

float to_decibel(float amplitude) {
	return 20.0 * log(amplitude + 1e-10) / log(10.0);
}

void fragment() {
    float time_fraction = display_seconds / total_seconds;
    float freq_fraction = display_frequency / max_frequency;

    vec2 remapped_uv = vec2(
        UV.x * time_fraction,
        1.0 - (1.0 - UV.y) * freq_fraction
    );

    float amplitude = texture(spectrogram_texture, remapped_uv).r;
	float db = to_decibel(amplitude);
	float normalized = clamp((db - min_db) / (max_db - min_db), 0.0, 1.0);
    COLOR = texture(gradient_texture, vec2(normalized, 0.5));
}
