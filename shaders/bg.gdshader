shader_type canvas_item;

uniform float star_density : hint_range(0.0, 1.0) = 0.02;
uniform float star_size : hint_range(0.0, 1.0) = 0.3;
uniform float twinkle_speed = 1.5;
uniform float twinkle_strength : hint_range(0.0, 1.0) = 0.4;
uniform vec2 parallax_offset = vec2(0.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV + parallax_offset;

	// Tile space into cells, one potential star per cell
	vec2 cell_size = vec2(1.0 / 80.0);
	vec2 cell = floor(uv / cell_size);
	vec2 local = fract(uv / cell_size);

	// Random values per cell
	float rand = hash(cell);
	float rand2 = hash(cell + vec2(7.3, 13.1));
	float rand3 = hash(cell + vec2(3.7, 19.4));

	// Only some cells have stars
	float has_star = step(1.0 - star_density, rand);

	// Star position within cell — jittered
	vec2 star_pos = vec2(0.3 + rand2 * 0.4, 0.3 + rand3 * 0.4);
	float dist = length(local - star_pos);

	// Star size varies
	float size = star_size * (0.4 + rand2 * 0.6) * cell_size.x * 80.0;

	// Twinkle — each star has its own phase
	float phase = rand * TAU;
	float twinkle = 1.0 - twinkle_strength * (sin(TIME * twinkle_speed + phase) * 0.5 + 0.5);

	// Sharp core + soft glow
	float core = 1.0 - smoothstep(0.0, size * 0.3, dist);
	float glow = (1.0 - smoothstep(size * 0.3, size, dist)) * 0.3;
	float star = (core + glow) * has_star * twinkle;

	// Occasional slightly blue or warm tint
	float tint = hash(cell + vec2(1.1, 2.2));
	vec3 star_color = mix(vec3(0.8, 0.9, 1.0), vec3(1.0, 0.95, 0.85), step(0.5, tint));
	star_color = mix(vec3(1.0), star_color, 0.4);

	COLOR = vec4(star_color * star, star);
}