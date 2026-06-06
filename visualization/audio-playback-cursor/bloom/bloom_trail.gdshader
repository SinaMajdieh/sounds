shader_type canvas_item;

uniform float playhead_pixel_x; // The actual X position in pixels
uniform float glow_pixel_width = 100.0; // The width of the glow in pixels
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 base_color : source_color = vec4(0.38, 0.77, 0.35, 1.0);

varying float world_x;

void vertex() {
    world_x = VERTEX.x;
}

void fragment() {
    float dist = abs(world_x - playhead_pixel_x);
    
    if (dist < glow_pixel_width) {
        float intensity = 1.0 - (dist / glow_pixel_width);
        intensity = pow(intensity, 2.5); // Sharpens the glow center
        
        vec3 final_rgb = mix(base_color.rgb, glow_color.rgb, intensity);
        // Additive boost for that bright 'center' look
        final_rgb += glow_color.rgb * intensity * 0.4;
        
        COLOR.rgb = final_rgb;
    } else {
        COLOR.rgb = base_color.rgb;
    }
}
