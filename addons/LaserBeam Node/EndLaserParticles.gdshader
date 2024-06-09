shader_type canvas_item;

void vertex() {
	VERTEX.y += sin(TIME * 30.0) * 200.0 * (UV.x - 1.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
