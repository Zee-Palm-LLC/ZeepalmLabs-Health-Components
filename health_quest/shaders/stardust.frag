#version 460 core
#include <flutter/runtime_effect.glsl>

// Atmosphere over the hero plate: twinkling motes, two slow volumetric light
// shafts, and a nebula shimmer. Drawn additively, so it only ever adds light.
//
// No derivatives anywhere - SkSL (the web backend) has no fwidth, and a shader
// that uses one fails to compile for web while still working on mobile, which
// is a nasty way to find out.

precision highp float;

uniform vec2  uSize;      // canvas size, logical px
uniform float uTime;      // seconds
uniform vec2  uParallax;  // -1..1, from drag / tilt
uniform float uIntensity; // 0 off .. 1 full; also the entrance fade
uniform float uSurge;     // 0 rest .. 1 the CTA charge-up

out vec4 fragColor;

const vec3 VIOLET = vec3(0.62, 0.36, 1.00);
const vec3 CYAN   = vec3(0.42, 0.78, 1.00);
const vec3 ROSE   = vec3(0.95, 0.45, 0.85);

float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

// Value noise, cheap and smooth enough for drifting haze.
float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  float a = hash21(i);
  float b = hash21(i + vec2(1.0, 0.0));
  float c = hash21(i + vec2(0.0, 1.0));
  float d = hash21(i + vec2(1.0, 1.0));
  return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float amp = 0.5;
  for (int i = 0; i < 4; i++) {
    v += amp * noise(p);
    p *= 2.03;
    amp *= 0.5;
  }
  return v;
}

// One layer of motes. Cells of the grid each hold a single point of light that
// rises, twinkles on its own phase, and wraps.
vec3 motes(vec2 uv, float cells, float speed, float seed, vec3 tint) {
  vec2 g = uv * cells;
  g.y -= uTime * speed;
  vec2 id = floor(g);
  vec2 f = fract(g) - 0.5;

  float r = hash21(id + seed);
  float r2 = hash21(id + seed + 7.77);
  // Only a fraction of cells hold a mote, so the field does not look like a grid.
  if (r > 0.20) return vec3(0.0);

  vec2 jitter = vec2(r2 - 0.5, hash21(id + seed + 3.3) - 0.5) * 0.7;
  float d = length(f - jitter);

  float twinkle = 0.45 + 0.55 * sin(uTime * (1.4 + r2 * 2.6) + r * 30.0);
  float size = mix(0.012, 0.038, r2) * (1.0 + uSurge * 0.8);
  float core = size / max(d, 1e-4);
  core = pow(clamp(core, 0.0, 1.0), 2.4);

  return tint * core * twinkle;
}

// A soft shaft of light, angled, breathing.
float shaft(vec2 p, float angle, float width, float phase) {
  float c = cos(angle), s = sin(angle);
  vec2 q = vec2(p.x * c - p.y * s, p.x * s + p.y * c);
  float band = exp(-(q.x * q.x) / (width * width));
  float breathe = 0.55 + 0.45 * sin(uTime * 0.35 + phase);
  // fade out toward the bottom so shafts read as coming from above
  float fade = smoothstep(1.1, -0.3, q.y);
  return band * breathe * fade;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float aspect = uSize.x / max(uSize.y, 1.0);
  vec2 p = (uv - 0.5) * vec2(1.0 / max(aspect, 1e-4), 1.0);

  vec3 col = vec3(0.0);

  // Three mote layers at different depths; the near ones parallax more.
  col += motes(uv + uParallax * 0.010, 9.0,  0.012, 1.0,  VIOLET * 0.42);
  col += motes(uv + uParallax * 0.022, 14.0, 0.026, 17.0, CYAN   * 0.28);
  col += motes(uv + uParallax * 0.040, 20.0, 0.045, 41.0, ROSE   * 0.18);

  // Volumetric shafts from the upper left and upper right.
  vec2 sp = p + uParallax * 0.03;
  float sh = shaft(sp - vec2(-0.16, 0.0), 0.32, 0.085, 0.0) * 0.55
           + shaft(sp - vec2( 0.20, 0.0), -0.26, 0.065, 2.1) * 0.40;
  col += mix(VIOLET, CYAN, 0.35) * sh * 0.20;

  // Nebula shimmer: a slow haze that keeps the plate from ever looking frozen.
  vec2 np = uv * vec2(2.2, 1.4) + vec2(uTime * 0.008, -uTime * 0.012)
          + uParallax * 0.015;
  float haze = fbm(np * 2.0);
  haze = smoothstep(0.45, 0.95, haze);
  col += mix(VIOLET, ROSE, 0.4) * haze * 0.035;

  // The CTA charge-up: a ring of light sweeping outward from the platform.
  if (uSurge > 0.001) {
    vec2 c = vec2(0.0, -0.06);
    float d = length((p - c) * vec2(1.0, 1.25));
    float ring = exp(-pow((d - uSurge * 0.85) * 9.0, 2.0));
    col += mix(CYAN, VIOLET, 0.5) * ring * uSurge * 0.85;
    col += VIOLET * exp(-d * 4.0) * uSurge * 0.25;
  }

  col *= uIntensity;

  // Additive: alpha carries the light so the plate underneath shows through.
  float a = clamp(max(col.r, max(col.g, col.b)), 0.0, 1.0);
  fragColor = vec4(col, a);
}
