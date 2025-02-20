shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float distortion_strength : hint_range(0.0, 0.02) = 0.005;
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.2;
uniform vec3 color_boost = vec3(1.1, 1.05, 1.2);

void fragment() {
    vec2 uv = SCREEN_UV;

    float scanline = 1.0 - scanline_intensity * sin(uv.y * 500.0 + TIME * 3.0);

    float distortion = sin(TIME * 2.0 + uv.y * 10.0) * distortion_strength;

    float noise = (fract(sin(dot(uv * TIME, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * noise_intensity;

    vec4 base_color = texture(SCREEN_TEXTURE, uv + vec2(distortion, 0.0));

    base_color.rgb = mix(base_color.rgb, base_color.rgb * color_boost, 0.7);

    base_color.rgb *= scanline;
    base_color.rgb += noise;

    COLOR = base_color;
}