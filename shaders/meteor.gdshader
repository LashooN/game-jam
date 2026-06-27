shader_type canvas_item;

uniform vec2 origin_offset = vec2(0.0);
uniform vec4 base_color : source_color = vec4(0.36, 0.34, 0.32, 1.0);
uniform float seed = 0.0;

uniform float crack_intensity : hint_range(0.0, 1.0) = 0.45;
uniform float roughness : hint_range(0.0, 1.0) = 0.65;

uniform float scale = 18.0;
uniform float crater_scale : hint_range(0.5, 8.0) = 2.8;
uniform float glow_strength : hint_range(0.0, 2.0) = 0.85;
uniform vec2 light_dir_2d = vec2(-0.65, -0.85);

uniform bool debris = false;
uniform float debris_count : hint_range(3.0, 20.0) = 8.0;
uniform float debris_coverage : hint_range(0.1, 0.9) = 0.2;

uniform float collect_glow_speed = 4.0;
uniform vec3 collect_glow_color : source_color = vec3(1.0, 0.55, 0.15);
uniform float collect_glow_width : hint_range(0.0, 1.0) = 0.4;

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

float sat(float x) {
	return clamp(x, 0.0, 1.0);
}

float hash(vec2 p) {
	return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453123);
}

float hash2(vec2 p, float offset) {
	return fract(sin(dot(p + seed + offset, vec2(311.7, 127.1))) * 12345.6789);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	float frequency = 1.0;

	for (int i = 0; i < 5; i++) {
		value += amplitude * noise(p * frequency);
		frequency *= 2.0;
		amplitude *= 0.5;
	}
	return value;
}

float ridged(vec2 p) {
	float n = noise(p);
	n = abs(n * 2.0 - 1.0);
	return 1.0 - n;
}

float crack_layer(vec2 p) {
	vec2 q = p;
	q += vec2(fbm(p * 0.9 + vec2(11.2, 4.7)), fbm(p * 0.9 + vec2(3.6, 19.4))) * 1.5;

	float v = 1.0 - abs(noise(q * 5.0 + fbm(q * 2.0) * 3.0) * 2.0 - 1.0);
	v = pow(sat(v), 14.0);
	return v;
}

float crater_layer(vec2 p) {
	vec2 g = floor(p);
	vec2 f = fract(p);

	float h = 0.0;

	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 cell = g + vec2(float(x), float(y));
			vec2 o = vec2(hash(cell), hash(cell + vec2(13.1, 7.7)));
			vec2 d = vec2(float(x), float(y)) + o - f;

			float r = mix(0.16, 0.44, hash(cell + vec2(9.3, 2.1))) * crater_scale;
			float l = length(d);

			float center = 1.0 - smoothstep(0.0, r * 0.72, l);
			float rim = smoothstep(r * 0.68, r * 0.92, l) - smoothstep(r * 0.92, r * 1.12, l);

			h += (-center * 0.45) + (rim * 0.18);
		}
	}

	return h;
}

float height_map(vec2 p) {
	vec2 warp = vec2(
		fbm(p * 1.6 + vec2(3.1, 7.7)),
		fbm(p * 1.6 + vec2(8.6, 2.1))
	);

	vec2 q = p + (warp - 0.5) * (0.9 + roughness * 1.5);

	float base = fbm(q * 1.25) * 0.55;
	base += ridged(q * 2.1) * 0.28;
	base += fbm(q * 5.4) * 0.10;

	float craters = crater_layer(q * 1.9);
	float cracks = crack_layer(q * 3.2) * crack_intensity;

	return base + craters - cracks * 0.85;
}

vec2 voronoi(vec2 p, float count) {
	vec2 scaled = p * count;
	vec2 g = floor(scaled);
	vec2 f = fract(scaled);

	float min_dist = 8.0;
	vec2 min_cell = vec2(0.0);

	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 cell = g + vec2(float(x), float(y));
			vec2 jitter = vec2(hash(cell), hash2(cell, 1.0));
			vec2 to_cell = vec2(float(x), float(y)) + jitter - f;
			float d = length(to_cell);
			if (d < min_dist) {
				min_dist = d;
				min_cell = cell;
			}
		}
	}

	return vec2(min_dist, hash(min_cell));
}

void fragment() {
	vec2 p = (local_pos + origin_offset) / scale;

	float h = height_map(p);
	float e = 0.03;
	float hx = height_map(p + vec2(e, 0.0));
	float hy = height_map(p + vec2(0.0, e));

	vec2 grad = vec2(hx - h, hy - h);
	vec3 n = normalize(vec3(-grad.x * 4.0, -grad.y * 4.0, 1.0));

	vec3 light_dir = normalize(vec3(light_dir_2d, 0.85));

	float diff = max(dot(n, light_dir), 0.0);
	float ambient = 0.22 + h * 0.14;
	float rim = pow(1.0 - max(dot(n, vec3(0.0, 0.0, 1.0)), 0.0), 2.5);

	float crack_mask = crack_layer(p * 3.2) * crack_intensity;
	float cavity = sat(0.5 - h * 0.75);
	float tone = sat(h * 0.85 + 0.5);

	vec3 dark_rock = base_color.rgb * 0.38;
	vec3 mid_rock = base_color.rgb * 0.92;
	vec3 light_rock = mix(base_color.rgb, vec3(1.0, 0.93, 0.84), 0.22);

	vec3 albedo = mix(dark_rock, mid_rock, tone);
	albedo = mix(albedo, light_rock, diff * 0.25);

	float grain = noise(p * 8.0 + vec2(2.7, 9.1)) - 0.5;
	albedo += grain * 0.06;

	float crack_glow = pow(crack_mask, 1.8);
	vec3 glow_color = vec3(1.0, 0.42, 0.08);

	vec3 color = albedo;
	color *= ambient + diff * 1.25;
	color *= mix(1.0, 0.72, cavity);
	color += glow_color * crack_glow * glow_strength;
	color += rim * vec3(0.10, 0.08, 0.06);
	color = clamp(color, 0.0, 1.0);

	float alpha = base_color.a;

	if (debris) {
		vec2 uv = local_pos / scale;
		vec2 vor = voronoi(uv, debris_count);
		float cell_dist = vor.x;
		float cell_id = vor.y;

		float is_fragment = step(cell_id, debris_coverage);
		float edge = smoothstep(0.0, 0.08, cell_dist);
		float fragment_alpha = is_fragment * edge;

		float brightness_vary = mix(0.7, 1.15, hash(vec2(cell_id, cell_id * 3.7)));
		color *= brightness_vary;

		float fracture = (1.0 - edge) * is_fragment;
		color = mix(color, base_color.rgb * 1.4, fracture * 0.4);

		alpha *= fragment_alpha;

		float pulse = sin(TIME * collect_glow_speed) * 0.5 + 0.5;
		float glow_mask = (1.0 - smoothstep(0.0, collect_glow_width, cell_dist)) * is_fragment;
		vec3 glow = collect_glow_color * glow_mask * pulse * 1.5;
		color += glow;
		alpha = max(alpha, glow_mask * pulse * 0.5);
	}

	COLOR = vec4(color, alpha);
}