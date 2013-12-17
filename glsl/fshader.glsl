#version 330 core

uniform mat4 model, view;
uniform vec3 light_pos;
uniform float light_ambient;

uniform vec4 fog_color;
uniform float fog_mag;

uniform vec4 blend_color;
uniform vec4 blend_factor;

in vec4 fPos;
in vec4 fColor;
in vec3 fNormal;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

    mat3 N = mat3((model));
    mat3 M = inverse(N);
    // light
    float diff = max(0, dot(normalize(N * light_pos), normalize(N * fNormal)))
               + light_ambient;
    vec4 color = vec4((diff * fColor).xyz, fColor.w);

    // blend
    vec4 oldColorHSV = vec4(rgb2hsv(color.rgb), fColor.a);
    vec4 newColorHSV = vec4(rgb2hsv(blend_color.rgb), blend_color.a);
    vec4 mixColorHSV = mix(oldColorHSV, newColorHSV, blend_factor);
    vec4 mixColorRGB = vec4(hsv2rgb(mixColorHSV.xyz), mixColorHSV.a);
    //vec4 mixColorRGB = vec4(1, 1, 1, 1);


    // fog
    vec4 afterFog = mix(mixColorRGB, fog_color, clamp(fog_mag * fPos.z, 0, 1));

    gl_FragColor = afterFog;
}