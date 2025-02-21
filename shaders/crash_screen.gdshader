shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float glitch_intensity : hint_range(0.0, 1.0);
uniform float time_offset;
uniform float scanline_speed : hint_range(0.0, 10.0);
uniform float scanline_intensity : hint_range(0.0, 1.0);
uniform float time_factor : hint_range(0.0, 1.0) = 1.0; // Controls time flow (0 = paused, 1 = normal)

void fragment() {
    vec2 uv = SCREEN_UV;

    // **Apply time factor for pausing effect**
    float current_time = TIME * time_factor;

    // **Introduce horizontal distortion**
    float shift = sin(current_time * 15.0 + time_offset) * 0.01 * glitch_intensity;
    uv.x += shift * (fract(sin(current_time * 5.0) * 43758.5453) - 0.5);

    // **Get screen texture**
    vec4 col = texture(SCREEN_TEXTURE, uv);

    // **Glitch corruption (red/blue flicker)**
    float noise = fract(sin(dot(uv * current_time, vec2(12.9898, 78.233))) * 43758.5453);
    if (noise < glitch_intensity * 0.5) {
        float glitch_color = step(0.5, fract(sin(current_time * 100.0 + uv.y * 10.0) * 43758.5453));
        col.rgb = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), glitch_color); // Flicker between red/blue
    }

    // **Scanlines for a horror CRT feel**
    float scanline = sin((uv.y + current_time * scanline_speed) * 200.0) * scanline_intensity;
    col.rgb -= vec3(scanline);

    // **Dark tint but still visible**
    col.rgb *= vec3(0.3, 0.1, 0.2); // Dark purple tint, but NOT full black

    COLOR = col;
}
