shader_type canvas_item;

uniform float speed = 1.0;
uniform float scale = 20.0;
uniform float ray_count : hint_range(1, 20) = 8;
uniform float ray_width : hint_range(0.0, 1.0) = 0.1;
uniform float disc_size : hint_range(0.0, 1.0) = 0.6;
uniform float disc_thickness : hint_range(0.0, 1.0) = 0.1;
uniform float glow_strength : hint_range(0.0, 1.0) = 0.5;
uniform vec4 color1 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color2 : source_color = vec4(0.0, 0.5, 1.0, 1.0);
uniform vec4 color3 : source_color = vec4(0.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 centered_uv = UV - vec2(0.5);
    float dist = length(centered_uv);
    float angle = atan(centered_uv.y, centered_uv.x);
    
    // Create an accretion disc effect
    float disc = smoothstep(disc_size, disc_size + disc_thickness, dist);
    disc *= smoothstep(disc_size + disc_thickness + 0.05, disc_size + disc_thickness, dist);
    
    // Apply a time-based sinusoidal wave pattern
    float wave = sin(dist * scale - TIME * speed) * 0.5 + 0.5;
    
    // Mix the colors based on the wave pattern
    vec4 disc_color = mix(color2, color3, wave);
    
    // Create rotating rays
    float ray = smoothstep(0.0, ray_width, sin(angle * ray_count + TIME * speed));
    
    // Create a glow effect
    float glow = 1.0 - smoothstep(0.0, disc_size, dist);
    
    // Combine the accretion disc, rays, glow, and black hole center
    vec4 final_color = mix(color1, disc_color, disc * ray) + glow * glow_strength * color3;
    
    // Set the fragment color if inside the circle
    if (dist <= 0.5) {
        COLOR = final_color;
    } else {
        COLOR = vec4(0.0);
    }
}