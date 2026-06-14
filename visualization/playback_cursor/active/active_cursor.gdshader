shader_type canvas_item;

uniform bool active = false; 
uniform vec4 active_color : source_color;

void fragment() {
    vec4 col = COLOR;

    if (active) {
        col.rgb = active_color.rgb;
    }

    COLOR = col;
}