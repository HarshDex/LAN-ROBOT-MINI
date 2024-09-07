shader_type canvas_item;


void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    // Called for every pixel the material is visible on.
    vec2 uv = vec2(UV.x + sin(TIME * 80.0) * 0.1, UV.y) - sin(TIME * 50.0) * 0.02; // Use the uniform time instead of TIME
    COLOR = texture(TEXTURE, uv);
}

//void light() {
// Called for every pixel for every light affecting the CanvasItem.
// Uncomment to replace the default light processing function with this one.
//}