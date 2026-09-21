#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform float uTime;
uniform float uLevel;
uniform float uSeed;

out vec4 fragColor;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
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

float fbm2(vec2 p) {
  float v = 0.5 * noise(p);
  v += 0.25 * noise(p * 2.03 + vec2(1.7, 9.2));
  return v / 0.75;
}

float fbm4(vec2 p) {
  float v = 0.5 * noise(p);
  p = p * 2.03 + vec2(1.7, 9.2);
  v += 0.25 * noise(p);
  p = p * 2.01 + vec2(8.3, 2.8);
  v += 0.125 * noise(p);
  p = p * 2.02 + vec2(4.1, 6.5);
  v += 0.0625 * noise(p);
  return v / 0.9375;
}

vec3 blob(vec3 col, vec2 p, vec2 c, float radius, vec3 tint, float strength) {
  float w = 1.0 - smoothstep(0.2, 1.0, length(p - c) / radius);
  return mix(col, tint, clamp(w * strength, 0.0, 1.0));
}

vec3 palette(float v) {
  vec3 c0 = vec3(0.13, 0.02, 0.0);
  vec3 c1 = vec3(0.50, 0.12, 0.01);
  vec3 c2 = vec3(0.87, 0.36, 0.04);
  vec3 c3 = vec3(0.97, 0.60, 0.20);
  vec3 c4 = vec3(0.98, 0.86, 0.58);
  vec3 c5 = vec3(1.0, 0.97, 0.86);
  vec3 col = mix(c0, c1, smoothstep(0.0, 0.25, v));
  col = mix(col, c2, smoothstep(0.22, 0.45, v));
  col = mix(col, c3, smoothstep(0.45, 0.64, v));
  col = mix(col, c4, smoothstep(0.64, 0.82, v));
  col = mix(col, c5, smoothstep(0.84, 1.0, v));
  return col;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = frag / uSize * 2.0 - 1.0;
  float r = length(uv);
  float edge = 2.4 / uSize.x;
  float mask = 1.0 - smoothstep(1.0 - edge, 1.0 + edge * 0.5, r);
  if (mask <= 0.0) {
    fragColor = vec4(0.0);
    return;
  }

  float detail = clamp(uSize.x / 220.0, 0.25, 1.0);
  float t = uTime * 0.5 + uSeed * 20.0;
  float swirl = 0.1 + uLevel * 0.1;
  vec2 w = uv;
  w += swirl * vec2(sin(w.y * 2.7 + t * 0.9), cos(w.x * 2.3 - t * 1.1));
  w += swirl * 0.35 * vec2(sin(w.y * 3.4 - t * 1.3 + 1.7), cos(w.x * 3.1 + t * 0.7));
  w += 0.05 * (fbm2(w * 1.6 + t * 0.2) - 0.5);

  vec3 col = vec3(0.88, 0.38, 0.05);
  col = blob(col, w, vec2(-0.8, 0.2) + 0.1 * vec2(sin(t * 0.7), cos(t * 0.5)), 0.5, vec3(0.96, 0.52, 0.1), 0.9);
  col = blob(col, w, vec2(0.42, -0.62) + 0.1 * vec2(cos(t * 0.8 + 1.0), sin(t * 0.6)), 0.55, vec3(1.0, 0.6, 0.15), 0.9);
  col = blob(col, w, vec2(-0.3, -0.32) + 0.14 * vec2(sin(t * 0.45 + 0.6), cos(t * 0.55 + 1.2)), 0.74, vec3(1.0, 0.95, 0.75), 1.0);
  col = blob(col, w, vec2(-0.06, 0.2) + 0.12 * vec2(cos(t * 0.65 + 2.4), sin(t * 0.5 + 0.3)), 0.5, vec3(1.0, 0.86, 0.58), 0.95);
  col = blob(col, w, vec2(0.66, 0.26) + 0.12 * vec2(cos(t * 0.6), sin(t * 0.8)), 0.62, vec3(0.13, 0.015, 0.0), 1.0);
  col = blob(col, w, vec2(0.2, 0.92) + 0.1 * vec2(sin(t * 0.5 + 2.0), cos(t * 0.7)), 0.7, vec3(0.18, 0.025, 0.0), 1.0);
  col = blob(col, w, vec2(-0.56, 0.74) + 0.08 * vec2(cos(t * 0.4 + 1.0), sin(t * 0.9)), 0.42, vec3(0.42, 0.08, 0.0), 0.85);
  col = blob(col, w, vec2(0.36, -0.12) + 0.1 * vec2(sin(t * 0.9 + 4.0), cos(t * 0.75)), 0.3, vec3(0.78, 0.22, 0.02), 0.6);
  col *= 1.0 + uLevel * 0.12;

  float shade = 1.0 - 0.2 * smoothstep(0.2, 1.1, dot(uv, vec2(0.55, 0.75)));
  col *= shade;

  vec2 dir = uv / max(r, 0.0001);
  float rimBand = smoothstep(0.955, 0.995, r);
  float rimSide = smoothstep(-0.1, 0.8, dot(dir, vec2(0.85, 0.5)));
  col += vec3(1.0, 0.55, 0.18) * rimBand * rimSide * 0.7;

  float spec = smoothstep(0.55, 0.0, length(uv - vec2(-0.35, -0.45)));
  col += vec3(1.0, 0.92, 0.76) * spec * mix(0.5, 0.0, detail);

  float small = 1.0 - smoothstep(0.12, 0.4, uSize.x / 220.0);
  if (small > 0.0) {
    float light = smoothstep(0.85, 0.0, length(uv - vec2(-0.3, -0.38)));
    vec3 sphere = mix(vec3(0.9, 0.36, 0.04), vec3(1.0, 0.86, 0.58), light);
    sphere *= 1.0 - 0.62 * smoothstep(-0.1, 1.0, dot(uv, vec2(0.35, 0.85)));
    sphere += vec3(1.0, 0.55, 0.2) * smoothstep(0.7, 1.0, r) * smoothstep(0.0, 0.9, dot(dir, vec2(0.3, 0.95))) * 0.5;
    col = mix(col, mix(sphere, col, 0.3), small);
  }

  col = clamp(col, 0.0, 1.0);
  fragColor = vec4(col * mask, mask);
}
