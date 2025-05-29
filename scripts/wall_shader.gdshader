shader_type canvas_item;

uniform int direction : hint_range(0, 8); // 0=center, 1–8 for 8 directions

float get_angle(int dir) {
	if (dir == 0) return 0.0;
	return float(dir - 1) * 45.0 * (3.14159265 / 180.0); // Manual deg to rad
}

void fragment() {
	float angle = get_angle(direction);
	vec2 center = vec2(0.5);
	vec2 uv = UV - center;

	// Apply rotation
	float cos_a = cos(angle);
	float sin_a = sin(angle);
	vec2 rotated_uv = vec2(
		uv.x * cos_a - uv.y * sin_a,
		uv.x * sin_a + uv.y * cos_a
	) + center;

	// Sample rotated texture
	COLOR = texture(TEXTURE, rotated_uv);
}
