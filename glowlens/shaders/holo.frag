#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;
uniform float uTime;
uniform vec2 uTilt;
uniform float uDots;
uniform vec3 uColorA;
uniform vec3 uColorB;
uniform vec3 uColorC;
uniform float uSeed;

out vec4 fragColor;

float blob(vec2 p, vec2 centre, float radius) {
    vec2 d = p - centre;
    return exp(-dot(d, d) / (radius * radius));
}

void main() {
    vec2 frag = FlutterFragCoord().xy;
    vec2 uv = frag / uSize;
    float aspect = uSize.x / uSize.y;
    vec2 p = vec2(uv.x * aspect, uv.y);
    float t = uTime * 0.35 + uSeed * 6.2831;

    vec3 base = vec3(0.975, 0.965, 0.99);

    vec2 a = vec2((0.08 + 0.06 * sin(t * 0.9)) * aspect, 0.55 + 0.12 * cos(t * 0.7)) + uTilt * 0.08;
    vec2 b = vec2((0.92 + 0.05 * cos(t * 0.8)) * aspect, 0.12 + 0.1 * sin(t * 1.1)) - uTilt * 0.06;
    vec2 c = vec2((0.85 + 0.07 * sin(t * 0.6 + 1.3)) * aspect, 0.95 + 0.08 * cos(t * 0.9)) + uTilt.yx * 0.07;
    vec2 d = vec2((0.5 + 0.2 * sin(t * 0.5 + 2.0)) * aspect, 0.5 + 0.2 * cos(t * 0.4));

    float r = 0.42 * max(aspect, 1.0) + 0.3;
    float wa = blob(p, a, r * 0.95);
    float wb = blob(p, b, r * 0.85);
    float wc = blob(p, c, r * 0.8);
    float wd = blob(p, d, r * 0.4) * 0.12;

    vec3 col = base;
    col = mix(col, uColorA, clamp(wa, 0.0, 1.0) * 0.95);
    col = mix(col, uColorB, clamp(wb, 0.0, 1.0) * 0.95);
    col = mix(col, uColorC, clamp(wc, 0.0, 1.0) * 0.9);
    col = mix(col, vec3(1.0), wd);

    float band = uv.x * 0.8 + uv.y * 0.55 + uTilt.x * 0.25 - fract(uTime * 0.06 + uSeed) * 3.0 + 1.0;
    float sheen = exp(-band * band * 18.0) * 0.12;
    col += vec3(sheen);

    float iris = sin((uv.x + uv.y) * 7.0 + uTime * 0.8 + uTilt.x * 3.0) * 0.5 + 0.5;
    col += vec3(0.02, -0.01, 0.03) * (iris - 0.5);

    vec2 cell = mod(frag, 7.0) - 3.5;
    float speck = 1.0 - smoothstep(0.55, 1.15, length(cell));
    col = mix(col, vec3(1.0), speck * uDots * 0.55);

    fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
