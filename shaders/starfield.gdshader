shader_type canvas_item;
// Latar retro: gradasi dithering (matriks Bayer 4x4) + 3 lapis bintang pixel
// yang bergeser pelan & berkedip + dua "bulan" pixel dengan shading bertingkat.

uniform vec2 resolution = vec2(640.0, 360.0);
uniform vec4 color_top : source_color = vec4(0.027, 0.027, 0.086, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.145, 0.082, 0.30, 1.0);
uniform float bands = 7.0;

const float BAYER[16] = float[16](
	0.0, 8.0, 2.0, 10.0,
	12.0, 4.0, 14.0, 6.0,
	3.0, 11.0, 1.0, 9.0,
	15.0, 7.0, 13.0, 5.0
);

float bayer4(vec2 p) {
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	return (BAYER[y * 4 + x] + 0.5) / 16.0;
}

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

vec3 star_layer(vec2 px, float cell, float speed, float star_size, float seed, vec3 tint) {
	vec2 p = floor(vec2(px.x + TIME * speed, px.y));
	vec2 id = floor(p / cell);
	vec2 local = p - id * cell;
	float h = hash21(id + seed);
	if (h < 0.55) {
		return vec3(0.0);
	}
	vec2 sp = floor(vec2(hash21(id + seed + 1.7), hash21(id + seed + 3.1)) * (cell - star_size));
	vec2 d = local - sp;
	if (d.x < 0.0 || d.y < 0.0 || d.x >= star_size || d.y >= star_size) {
		return vec3(0.0);
	}
	float tw = 0.5 + 0.5 * sin(TIME * (0.8 + h * 2.5) + h * 40.0);
	tw = floor(tw * 3.0 + 0.5) / 3.0; // kedip bertahap, bukan halus
	return tint * (0.35 + 0.65 * tw);
}

vec4 planet(vec2 px, vec2 c, float r, vec3 lit_col, vec3 dark_col) {
	vec2 d = px - c;
	if (dot(d, d) > r * r) {
		return vec4(0.0);
	}
	vec2 q = d / r;
	vec3 n = vec3(q, sqrt(max(1.0 - dot(q, q), 0.0)));
	float lit = clamp(dot(n, normalize(vec3(-0.65, -0.55, 0.55))), 0.0, 1.0);
	lit = floor(lit * 4.0) / 4.0; // 4 tingkat bayangan
	return vec4(mix(dark_col, lit_col, lit), 1.0);
}

void fragment() {
	vec2 px = floor(UV * resolution);

	// Gradasi dithering
	float t = (px.y + 0.5) / resolution.y * bands;
	float level = floor(t) + (fract(t) > bayer4(px) ? 1.0 : 0.0);
	vec3 col = mix(color_top.rgb, color_bottom.rgb, clamp(level / bands, 0.0, 1.0));

	// Bintang (jauh -> dekat)
	col += star_layer(px, 14.0, 2.0, 1.0, 1.0, vec3(0.65, 0.7, 1.0));
	col += star_layer(px, 22.0, 5.0, 1.0, 7.0, vec3(0.9, 0.9, 1.0));
	col += star_layer(px, 38.0, 9.0, 2.0, 13.0, vec3(1.0, 0.85, 0.95));

	// Dua bulan: "Between Us"
	vec2 pc = px + 0.5;
	vec4 moon_a = planet(pc, vec2(548.0, 74.0), 30.0, vec3(0.82, 0.84, 1.0), vec3(0.14, 0.14, 0.34));
	col = mix(col, moon_a.rgb, moon_a.a);
	vec4 moon_b = planet(pc, vec2(92.0, 286.0), 11.0, vec3(1.0, 0.6, 0.82), vec3(0.28, 0.12, 0.36));
	col = mix(col, moon_b.rgb, moon_b.a);

	COLOR = vec4(col, 1.0);
}
