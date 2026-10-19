#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uYaw;
uniform float uPitch;
uniform float uGlow;
uniform sampler2D uTex;

out vec4 fragColor;

float sq(float x) {
    return x * x;
}

void main() {
    vec2 frag = FlutterFragCoord().xy;
    vec2 p = frag / uSize * 2.0 - 1.0;
    float d2 = dot(p, p);
    float px = 2.0 / uSize.x;
    float edge = clamp((1.0 - sqrt(d2)) / (px * 1.5), 0.0, 1.0);
    if (d2 > 1.0) {
        float halo = clamp(1.0 - (sqrt(d2) - 1.0) / 0.06, 0.0, 1.0);
        fragColor = vec4(0.55, 0.75, 1.0, 1.0) * sq(halo) * 0.35 * uGlow;
        return;
    }
    float z = sqrt(max(0.0, 1.0 - d2));
    vec3 n = vec3(p.x, -p.y, z);

    float cy = cos(uYaw);
    float sy = sin(uYaw);
    float cp = cos(uPitch);
    float sp = sin(uPitch);
    vec3 a = vec3(n.x, n.y * cp + n.z * sp, -n.y * sp + n.z * cp);
    vec3 o = vec3(a.x * cy - a.z * sy, a.y, a.x * sy + a.z * cy);

    vec2 uv = vec2(o.x, -o.y) * 0.5 + 0.5;
    vec3 col = texture(uTex, uv).rgb;
    float back = smoothstep(0.15, -0.35, o.z);
    col = mix(col, col * vec3(0.82, 0.86, 1.0), back * 0.35);

    float rim = pow(1.0 - z, 3.0);
    col += vec3(0.55, 0.72, 1.0) * rim * 0.45 * uGlow;
    float light = clamp(dot(n, normalize(vec3(-0.45, 0.55, 0.7))), 0.0, 1.0);
    col *= 0.9 + 0.18 * light;

    fragColor = vec4(col * edge, edge);
}
