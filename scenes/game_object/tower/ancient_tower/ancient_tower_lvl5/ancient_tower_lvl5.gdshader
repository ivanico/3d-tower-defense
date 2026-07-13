shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform vec4 water_color : source_color = vec4(0.851, 1.0, 0.165, 1.0);

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    vec2 uv = UV;

    // layer 1: thin fast strands
    vec2 uv1 = uv * vec2(8.0, 20.0);
    uv1.y -= TIME * 10.0;
    float n1 = noise(uv1);

    // layer 2: thin slower strands, offset so they don't overlap identically
    vec2 uv2 = uv * vec2(10.0, 24.0) + vec2(3.7, 0.0);
    uv2.y -= TIME * 5.0;
    float n2 = noise(uv2);

    // layer 3: even slower, adds subtle variation
    vec2 uv3 = uv * vec2(6.0, 16.0) + vec2(7.1, 0.0);
    uv3.y -= TIME * 2.0;
    float n3 = noise(uv3);

    float combined = max(n1, max(n2, n3));
    float flow = smoothstep(0.55, 0.75, combined); // higher threshold = thinner lines

    ALBEDO = water_color.rgb;
    ALPHA = flow * 0.85;
}