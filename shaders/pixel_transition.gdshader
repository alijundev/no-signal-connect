shader_type canvas_item;
// Transisi antar scene: layar tertutup/terbuka per blok pixel acak (8x8)
// dengan sapuan diagonal. progress 0 = terbuka, 1 = tertutup.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 resolution = vec2(640.0, 360.0);
uniform float cell = 8.0;
uniform vec4 fade_color : source_color = vec4(0.02, 0.02, 0.05, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 grid = resolution / cell;
	vec2 id = floor(UV * grid);
	float sweep = (id.x / grid.x + id.y / grid.y) * 0.25;
	float t = hash(id) * 0.75 + sweep;
	COLOR = vec4(fade_color.rgb, step(t, progress * 1.25 - 0.001));
}
