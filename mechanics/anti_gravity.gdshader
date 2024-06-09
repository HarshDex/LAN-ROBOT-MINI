shader_type canvas_item;

uniform vec4 color_top : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec4 color_stop1 : source_color = vec4(0.0, 0.125, 0.0, 1.0);
uniform vec4 color_stop2 : source_color = vec4(0.0, 0.0941, 0.0, 1.0);
uniform vec4 color_stop3 : source_color = vec4(0.0, 0.0667, 0.0, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.0, 0.0392, 0.0, 1.0);

uniform float stop1_position : hint_range(0.0, 1.0) = 0.0;
uniform float stop2_position : hint_range(0.0, 1.0) = 0.2;
uniform float stop3_position : hint_range(0.0, 1.0) = 0.3;
uniform float stop4_position : hint_range(0.0, 1.0) = 0.4;

uniform float glow_strength : hint_range(0.0, 1.0) = 0.5;
uniform float glow_radius : hint_range(0.0, 1.0) = 0.2;
uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);

void fragment() {
    vec2 uv = UV;
    
    vec4 color = color_top;
    
    if (uv.y > stop1_position) {
        color = mix(color_top, color_stop1, smoothstep(stop1_position, stop2_position, uv.y));
    }
    if (uv.y > stop2_position) {
        color = mix(color_stop1, color_stop2, smoothstep(stop2_position, stop3_position, uv.y));
    }
    if (uv.y > stop3_position) {
        color = mix(color_stop2, color_stop3, smoothstep(stop3_position, stop4_position, uv.y));
    }
    if (uv.y > stop4_position) {
        color = mix(color_stop3, color_bottom, smoothstep(stop4_position, 1.0, uv.y));
    }
    
    // Calculate the distance from the center of the ColorRect
    vec2 center = vec2(0.5, 0.5);
    float distance = length(uv - center);
    
    // Calculate the glow intensity based on the distance
    float glow = smoothstep(glow_radius, 0.0, distance);
    
    // Mix the glow color with the original color based on the glow intensity
    vec4 glow_color_mixed = mix(color, glow_color, glow * glow_strength);
    
    COLOR = glow_color_mixed;
}