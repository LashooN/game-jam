shader_type canvas_item;

uniform float aspect_ratio = 2.0;
uniform float rotation_speed = 0.1;
uniform bool as_shadow = false;

// softened, more cohesive palette (shared blue-green base + controlled warm shift)
uniform vec3 color_ocean_deep   : source_color = vec3(0.08, 0.22, 0.40);
uniform vec3 color_ocean_shallow: source_color = vec3(0.20, 0.45, 0.65);
uniform vec3 color_land         : source_color = vec3(0.32, 0.55, 0.32);
uniform vec3 color_land_high    : source_color = vec3(0.48, 0.68, 0.42);
uniform vec3 color_desert       : source_color = vec3(0.70, 0.62, 0.42);
uniform vec3 color_ice          : source_color = vec3(0.80, 0.86, 0.88);

float color_dist(vec3 a, vec3 b) {
    vec3 d = a - b;
    return dot(d, d);
}

// softer nearest color selection (keeps identity but reduces harsh snapping)
vec3 nearest_palette(vec3 col) {
    vec3 palette[6];
    palette[0] = color_ocean_deep;
    palette[1] = color_ocean_shallow;
    palette[2] = color_land;
    palette[3] = color_land_high;
    palette[4] = color_desert;
    palette[5] = color_ice;

    float best_d = 1e9;
    vec3 best = palette[0];

    for (int i = 0; i < 6; i++) {
        float d = color_dist(col, palette[i]);
        if (d < best_d) {
            best_d = d;
            best = palette[i];
        }
    }
    return best;
}

void fragment() {
    float px = 2.0 * (UV.x - 0.5);
    float py = 2.0 * (UV.y - 0.5);

    float dist_sq = px * px + py * py;
    float inside = step(dist_sq, 1.0);

    float safe_denom = sqrt(max(1.0 - py * py, 0.0001));
    float mapped_x = asin(clamp(px / safe_denom, -1.0, 1.0)) * 2.0 / PI;
    float mapped_y = asin(clamp(py, -1.0, 1.0)) * 2.0 / PI;

    float u = fract(0.5 * (mapped_x + 1.0) / aspect_ratio - TIME * rotation_speed);
    float v = 0.5 * (mapped_y + 1.0);

    vec4 tex = texture(TEXTURE, vec2(u, v));

    // base + target palette color
    vec3 base_col = tex.rgb;
    vec3 target_col = nearest_palette(base_col);

    // smoother blending instead of full snap
    float strength = 0.65;
    vec3 palette_color = mix(base_col, target_col, strength);

    // subtle gamma balance so transitions don't look muddy
    palette_color = pow(palette_color, vec3(0.95));

    vec3 final_color = mix(vec3(0.0), as_shadow ? vec3(0.0) : palette_color, inside);
    float final_alpha = inside * (as_shadow ? tex.a * 0.9 : tex.a);

    COLOR = vec4(final_color, final_alpha);
}