shader_type canvas_item;
// Overlay layar penuh: scanline, vignette, sedikit chromatic aberration & flicker.
// Dipasang sekali di autoload Game, jadi berlaku untuk semua scene.

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.16;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.40;
uniform float aberration : hint_range(0.0, 3.0) = 0.6;
uniform float flicker : hint_range(0.0, 0.1) = 0.010;

void fragment() {
	vec2 texel = 1.0 / vec2(textureSize(screen_texture, 0));
	vec2 uv = SCREEN_UV;
	vec2 c = uv - 0.5;
	float edge = dot(c, c) * 4.0; // 0 di tengah, 2 di pojok

	float off = aberration * texel.x * edge;
	float r = texture(screen_texture, uv + vec2(off, 0.0)).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - vec2(off, 0.0)).b;
	vec3 col = vec3(r, g, b);

	float row = mod(floor(FRAGCOORD.y), 2.0);
	col *= 1.0 - scanline_strength * row;
	col *= 1.0 - vignette_strength * smoothstep(0.4, 2.0, edge);
	col *= 1.0 + flicker * sin(TIME * 40.0);

	COLOR = vec4(col, 1.0);
}
