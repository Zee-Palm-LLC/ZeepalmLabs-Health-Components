#version 460 core
#include <flutter/runtime_effect.glsl>

// Liquid-glass lens. Refracts a snapshot of the scene beneath it: a
// magnifying dome in the middle, rim refraction that wraps and mirrors the
// content, per-channel dispersion (chromatic fringes), Fresnel brightening,
// a soft specular and an anti-aliased edge.

uniform vec2 uCenter;    // lens centre (logical px)
uniform vec2 uRadius;    // ellipse radii (logical px)
uniform vec2 uSample;    // scene point seen through the lens centre
uniform float uMag;      // magnification at the centre
uniform float uDisp;     // dispersion strength
uniform float uRimWrap;  // how strongly the rim mirrors content (0..1)
uniform float uScale;    // texture px per logical px
uniform vec2 uTexSize;   // texture size (px)
uniform vec4 uBg;        // scene background colour (for samples off the texture)
uniform vec2 uOrigin;    // top-left of the captured region (logical px)
uniform sampler2D uTex;

out vec4 fragColor;

vec3 scene(vec2 p) {
  vec2 uv = (p - uOrigin) * uScale / uTexSize;
  if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) return uBg.rgb;
  return texture(uTex, uv).rgb;
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 q = (p - uCenter) / uRadius;
  float r = length(q);
  float px = 1.5 / min(uRadius.x, uRadius.y);
  if (r > 1.0 + px) {
    fragColor = vec4(0.0);
    return;
  }
  r = min(r, 1.0);
  vec2 dir = r > 1e-4 ? q / r : vec2(0.0);

  // Lens profile: flat magnification inside, then a steep refraction ramp in
  // the outer band that runs past zero so content near the rim is mirrored.
  float edge = smoothstep(0.55, 1.0, r);
  float bend = (1.0 / uMag) * (1.0 + 0.35 * r * r) - uRimWrap * 2.4 * edge * edge * edge;
  float disp = uDisp * (0.25 + 2.5 * edge * edge);

  vec2 off = dir * r * uRadius;
  vec3 col;
  col.r = scene(uSample + off * (bend * (1.0 + disp))).r;
  col.g = scene(uSample + off * bend).g;
  col.b = scene(uSample + off * (bend * (1.0 - disp))).b;

  // Glass body: slightly brighter, Fresnel rim light (top), soft lower shade.
  // Clear glass: barely brighter, with Fresnel light along the upper rim and
  // a faint shade along the lower one.
  float fres = pow(r, 6.0);
  col = mix(col, vec3(1.0), 0.025 + 0.16 * fres * clamp(0.6 - dir.y, 0.0, 1.0));
  col *= 1.0 - 0.07 * fres * clamp(dir.y + 0.2, 0.0, 1.0);
  // Thin bright rim line.
  float rim = smoothstep(0.94, 0.985, r) * (1.0 - smoothstep(0.985, 1.0, r));
  col = mix(col, vec3(1.0), 0.32 * rim);
  // Iridescent lower rim: thin-film rainbow that drifts with the angle.
  float ang = atan(dir.y, dir.x) / 6.2831853;
  vec3 film = 0.5 + 0.5 * cos(6.2831853 * (ang * 2.0 + vec3(0.0, 0.33, 0.67)));
  float band = smoothstep(0.8, 0.95, r) * (1.0 - smoothstep(0.97, 1.0, r)) * clamp(dir.y + 0.15, 0.0, 1.0);
  col = mix(col, film, 0.22 * band);
  // Small specular glint, upper left.
  vec2 g = q - vec2(-0.45, -0.58);
  col += vec3(0.05) * exp(-dot(g, g) * 40.0);

  float a = 1.0 - smoothstep(1.0 - px, 1.0 + px, length((p - uCenter) / uRadius));
  fragColor = vec4(col * a, a);
}
