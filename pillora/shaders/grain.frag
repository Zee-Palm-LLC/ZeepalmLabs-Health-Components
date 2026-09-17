#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;
uniform float uSeed;
uniform float uStrength;

out vec4 fragColor;

float hash(vec2 p) {
    vec3 q = fract(vec3(p.xyx) * 0.1031);
    q += dot(q, q.yzx + 33.33);
    return fract((q.x + q.y) * q.z);
}

void main() {
    vec2 cell = floor(FlutterFragCoord().xy / 1.2);
    float n = hash(cell + uSeed);
    float speck = step(0.82, hash(cell * 1.7 + uSeed + 11.0));
    float value = mix(n, 1.0, speck * 0.6);
    float alpha = uStrength;
    fragColor = vec4(vec3(value) * alpha, alpha);
}
