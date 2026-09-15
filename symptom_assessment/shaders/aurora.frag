#version 460 core
#include <flutter/runtime_effect.glsl>

// The page background: a still mint-to-white wash with three slow, soft
// colour drifts in it. Quiet on purpose - it should be felt, not seen.

precision highp float;

uniform vec2  uSize;
uniform float uTime;
uniform float uMix;   // 0 = flat gradient only, 1 = full drift

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float t = uTime * 0.12;

  // Base wash, sampled from the reference page.
  vec3 top    = vec3(0.878, 0.949, 0.957);  // #E0F2F4
  vec3 mid    = vec3(0.945, 0.969, 0.953);  // #F1F7F3
  vec3 bottom = vec3(1.0, 1.0, 1.0);
  vec3 col = mix(top, mid, smoothstep(0.0, 0.42, uv.y));
  col = mix(col, bottom, smoothstep(0.42, 0.95, uv.y));

  // Three drifting blobs. Aspect-corrected so they stay round.
  vec2 a = vec2(uv.x, uv.y * uSize.y / uSize.x);
  vec2 c1 = vec2(0.20 + 0.10 * sin(t * 1.1), 0.30 + 0.08 * cos(t * 0.9));
  vec2 c2 = vec2(0.85 + 0.08 * cos(t * 0.8 + 2.0), 0.55 + 0.10 * sin(t * 1.3 + 1.0));
  vec2 c3 = vec2(0.50 + 0.12 * sin(t * 0.7 + 4.0), 1.10 + 0.06 * cos(t * 1.0 + 3.0));

  float b1 = exp(-dot(a - c1, a - c1) * 9.0);
  float b2 = exp(-dot(a - c2, a - c2) * 8.0);
  float b3 = exp(-dot(a - c3, a - c3) * 6.0);

  vec3 mint = vec3(0.80, 0.94, 0.86);
  vec3 sky  = vec3(0.82, 0.92, 0.97);
  vec3 leaf = vec3(0.86, 0.96, 0.88);

  vec3 drift = col;
  drift = mix(drift, mint, b1 * 0.55);
  drift = mix(drift, sky,  b2 * 0.45);
  drift = mix(drift, leaf, b3 * 0.50);

  col = mix(col, drift, uMix);
  fragColor = vec4(col, 1.0);
}
