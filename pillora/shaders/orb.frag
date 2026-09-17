#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform float uTime;
uniform float uEnergy;
uniform float uRadius;
uniform vec2 uTilt;
uniform float uPulse;

out vec4 fragColor;

float hash(vec2 p) {
    vec3 q = fract(vec3(p.xyx) * 0.1031);
    q += dot(q, q.yzx + 33.33);
    return fract((q.x + q.y) * q.z);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p);
        p = p * 2.03 + vec2(1.7, 9.2);
        amplitude *= 0.5;
    }
    return value;
}

float lens(vec2 p, vec2 centre, vec2 radii, float softness) {
    float d = length((p - centre) / radii);
    return 1.0 - smoothstep(1.0 - softness, 1.0, d);
}

void main() {
    vec2 frag = FlutterFragCoord().xy;
    float side = min(uSize.x, uSize.y);
    float radiusPx = side * uRadius;
    vec2 p = (frag - 0.5 * uSize) / radiusPx;
    float r = length(p);
    float aa = 1.4 / radiusPx;
    float energy = clamp(uEnergy, 0.0, 1.0);
    float pulse = clamp(uPulse, 0.0, 1.0);

    vec3 mint = vec3(0.66, 0.89, 0.83);
    vec3 deep = vec3(0.31, 0.56, 0.52);
    vec3 rim = vec3(0.43, 0.61, 0.58);
    vec3 glow = vec3(0.68, 0.89, 0.84);

    float inside = 1.0 - smoothstep(1.0 - aa, 1.0 + aa, r);
    float rr = min(r, 1.0);
    float z = sqrt(max(1.0 - rr * rr, 0.0));
    float fresnel = pow(1.0 - z, 2.2);

    vec2 q = p * (0.72 + 0.28 * z);
    float t = uTime * (0.16 + energy * 0.55);
    float angle = t * 0.9;
    mat2 spin = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 swirl = spin * q * 1.7;
    float n1 = fbm(swirl + vec2(t, -t * 0.6));
    float n2 = fbm(swirl * 1.35 - n1 * 1.9 + vec2(-t * 0.5, t * 0.7));
    float core = exp(-dot(q, q) * (2.7 - energy * 1.3));

    vec3 body = mix(deep, mint, clamp(core * 0.95 + n2 * 0.5 - 0.12, 0.0, 1.0));
    body += vec3(0.55, 0.95, 0.86) * core * core * (0.22 + energy * 0.5);
    body = mix(body, rim, fresnel * 0.72);

    vec2 tilt = uTilt * 0.14;
    float topLens = lens(p, vec2(0.0, -0.63) + tilt, vec2(0.52, 0.23), 0.6);
    float bottomLens = lens(p, vec2(0.0, 0.66) + tilt * 0.5, vec2(0.47, 0.19), 0.65);
    body = mix(body, vec3(0.93, 0.985, 0.97), topLens * 0.62);
    body = mix(body, vec3(0.88, 0.97, 0.95), bottomLens * 0.48);

    float band = exp(-pow((r - 0.9) * 20.0, 2.0));
    float sides = smoothstep(0.6, 0.05, abs(p.y + tilt.y));
    body += vec3(0.9, 1.0, 0.97) * band * sides * 0.42;

    vec2 spec = p - vec2(-0.36, -0.44) - tilt;
    body += vec3(1.0) * exp(-dot(spec, spec) * 38.0) * 0.32;
    body *= 1.0 - smoothstep(0.84, 1.0, r) * 0.1;

    float reach = 0.5 / uRadius;
    float halo = exp(-max(r - 0.94, 0.0) * (3.1 - energy * 1.3));
    halo *= 0.42 + energy * 0.3 + pulse * 0.12;
    halo *= smoothstep(reach, 1.0, r);

    float ringT = fract(uTime * 0.6);
    float ringA = exp(-pow((r - (1.02 + ringT * 0.55)) * 16.0, 2.0)) * (1.0 - ringT);
    float ringU = fract(uTime * 0.6 + 0.5);
    float ringB = exp(-pow((r - (1.02 + ringU * 0.55)) * 16.0, 2.0)) * (1.0 - ringU);
    float rings = (ringA + ringB) * pulse * 0.55 * smoothstep(reach, reach - 0.2, r);

    float sphereAlpha = inside * (0.94 + 0.06 * z);
    float haloAlpha = clamp(halo + rings, 0.0, 1.0) * (1.0 - inside);
    vec3 color = body * sphereAlpha + glow * haloAlpha;
    fragColor = vec4(color, sphereAlpha + haloAlpha);
}
