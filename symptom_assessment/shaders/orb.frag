#version 460 core
#include <flutter/runtime_effect.glsl>

// A glass orb, rendered live.
//
// One outer sphere and two inner bubbles, shaded with Fresnel rims, a key light
// from the top-left and a soft bounce from below. The inner bubbles drift on
// their own, and everything parallaxes when the orb is tilted, so it reads as
// a thing with volume rather than a picture of one.
//
// No derivatives: SkSL (the web backend) has no fwidth, so every edge is
// anti-aliased analytically from the size of one device pixel.

precision highp float;

uniform vec2  uSize;     // canvas size in logical px
uniform float uTime;     // seconds
uniform vec2  uTilt;     // -1..1, from drag
uniform float uSquash;   // 0 rest .. 1 fully pressed
uniform float uAlpha;    // global opacity

out vec4 fragColor;

const vec3 LIGHT = normalize(vec3(-0.55, 0.65, 0.55));

// Colours lifted from the reference orb.
const vec3 GLASS_LIGHT = vec3(0.905, 0.955, 0.905);
const vec3 GLASS_MID   = vec3(0.780, 0.885, 0.780);
const vec3 GLASS_RIM   = vec3(0.420, 0.600, 0.420);
const vec3 BUBBLE_RIM  = vec3(0.250, 0.380, 0.250);
const vec3 BUBBLE_FILL = vec3(0.930, 0.970, 0.930);

float sat(float x) { return clamp(x, 0.0, 1.0); }

// Shades one bubble sitting inside the orb. Returns rgb + coverage.
// `px` is the width of one device pixel in orb units.
vec4 bubble(vec2 p, vec2 c, float r, float depth, vec3 base, float px) {
  vec2 q = (p - c) / r;
  float d = length(q);
  float aa = (px / r) * 1.2;
  float cov = 1.0 - smoothstep(1.0 - aa, 1.0 + aa, d);
  if (cov <= 0.0) return vec4(0.0);
  float z = sqrt(max(0.0, 1.0 - d * d));
  vec3 n = normalize(vec3(q.x, -q.y, z));
  float fres = pow(1.0 - z, 1.6);
  // the inside of a bubble is a little brighter than the glass around it,
  // and its edge is a thick, dark refracting rim
  vec3 col = mix(mix(base, BUBBLE_FILL, 0.55), BUBBLE_RIM, smoothstep(0.35, 1.0, fres));
  float rimBand = smoothstep(0.62, 0.86, d) * (1.0 - smoothstep(0.86, 1.0, d));
  col = mix(col, BUBBLE_RIM, rimBand * 0.85);
  // key highlight and a small counter-light
  float spec = pow(sat(dot(reflect(-LIGHT, n), vec3(0.0, 0.0, 1.0))), 60.0);
  float spec2 = pow(sat(dot(reflect(-normalize(vec3(0.6, -0.5, 0.5)), n), vec3(0.0, 0.0, 1.0))), 40.0);
  col += vec3(1.0) * (spec * 0.95 + spec2 * 0.35);
  // deeper bubbles are hazier
  col = mix(col, base, depth * 0.25);
  return vec4(col, cov);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 p = (uv - 0.5) * 2.0;
  p.y = -p.y;

  // Press squashes the orb: wider than tall, about its base.
  float sq = uSquash;
  p.x /= (1.0 + 0.12 * sq);
  p.y  = (p.y + 0.10 * sq) * (1.0 + 0.16 * sq);

  // Leave room for the shadow and the fresnel glow.
  p /= 0.86;

  // One device pixel, in these units.
  float px = 2.0 / (min(uSize.x, uSize.y) * 0.86);

  float d = length(p);
  float aa = px * 1.2;

  vec3 col = vec3(0.0);
  float alpha = 0.0;

  // Soft contact shadow under the orb.
  float shadow = 1.0 - smoothstep(0.75, 1.15, length((p - vec2(0.0, -0.22)) * vec2(0.85, 1.25)));
  shadow *= 0.16 * (1.0 - 0.35 * sq);

  float cov = 1.0 - smoothstep(1.0 - aa, 1.0 + aa, d);

  if (cov > 0.0) {
    float z = sqrt(max(0.0, 1.0 - d * d));
    vec3 n = normalize(vec3(p.x, p.y, z));

    // Glass body: light at the top, a little deeper at the bottom, dark rim.
    float fres = pow(1.0 - z, 2.2);
    float vert = smoothstep(-1.0, 1.0, p.y);
    vec3 base = mix(GLASS_MID, GLASS_LIGHT, vert * 0.8 + 0.1);
    base = mix(base, GLASS_RIM, fres * 0.95);

    // The bottom of the sphere catches a bounce light - glass glows there.
    float bounce = smoothstep(0.35, 1.0, -p.y) * (1.0 - fres);
    base = mix(base, vec3(0.82, 0.93, 0.82), bounce * 0.5);

    // Inner bubbles. Positions drift on their own, and shift with tilt by depth.
    float t = uTime;
    vec2 tilt = uTilt;
    vec2 cA = vec2(0.28 + 0.06 * sin(t * 0.7), 0.08 + 0.05 * cos(t * 0.9)) + tilt * 0.18;
    vec2 cB = vec2(-0.30 + 0.05 * cos(t * 0.6 + 1.3), -0.14 + 0.06 * sin(t * 0.8 + 0.4)) + tilt * 0.30;
    float rA = 0.46 + 0.015 * sin(t * 1.3);
    float rB = 0.30 + 0.012 * cos(t * 1.1 + 2.0);

    vec4 bB = bubble(p, cB, rB, 0.7, base, px);
    vec4 bA = bubble(p, cA, rA, 0.2, base, px);

    col = base;
    col = mix(col, bB.rgb, bB.a * 0.95);
    col = mix(col, bA.rgb, bA.a * 0.95);

    // Overlapping bubble edges read darker where they cross - glass does that.
    col = mix(col, BUBBLE_RIM, bA.a * bB.a * 0.35 * smoothstep(0.75, 1.0, length((p - cB) / rB)));

    // Outer highlights: a broad key light and a sharp spot, both top-left.
    float spec = pow(sat(dot(reflect(-LIGHT, n), vec3(0.0, 0.0, 1.0))), 28.0);
    float broad = pow(sat(dot(n, LIGHT)), 6.0);
    col += vec3(1.0) * (spec * 0.85 + broad * 0.22);

    // Thin bright rim opposite the light, the way a sphere reads its edge.
    float edge = smoothstep(0.88, 0.99, d) * (1.0 - smoothstep(0.99, 1.0, d));
    col += vec3(0.95, 1.0, 0.95) * edge * 0.35 * sat(-dot(n.xy, LIGHT.xy) + 0.4);

    alpha = cov;
  }

  // Composite the shadow beneath the orb (only where the orb is not).
  vec3 shadowCol = vec3(0.35, 0.50, 0.42);
  float outA = alpha + shadow * (1.0 - alpha);
  vec3 outC = (col * alpha + shadowCol * shadow * (1.0 - alpha));

  fragColor = vec4(outC, outA) * uAlpha;
}
