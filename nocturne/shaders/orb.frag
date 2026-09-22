#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform float uTime;
uniform float uKind;
uniform float uSeed;
uniform float uGlow;
uniform float uLife;
uniform vec3 uDeep;
uniform vec3 uMid;
uniform vec3 uHi;

out vec4 fragColor;

const float HALO = 1.42;

float sq(float x) {
  return x * x;
}

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

vec2 hash2(vec2 p) {
  float h = hash(p);
  return vec2(h, hash(p + h + 17.3));
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
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 4; i++) {
    v += a * noise(p);
    p = p * 2.07 + vec2(3.1, 7.7);
    a *= 0.5;
  }
  return v / 0.9375;
}

float stars(vec2 q, float density, float t, float size) {
  vec2 g = q * density;
  vec2 id = floor(g);
  vec2 f = fract(g);
  vec2 o = hash2(id + uSeed * 13.1);
  float keep = step(0.8, hash(id + 3.3 + uSeed));
  float d = length(f - (0.2 + 0.6 * o));
  float tw = 0.55 + 0.45 * sin(t * (1.5 + 2.5 * o.x) + o.y * 40.0);
  float px = density * 2.2 / (uSize.y / (2.0 * HALO));
  float s = max(size * 0.6, px * 0.8);
  return keep * tw * smoothstep(s, 0.0, d);
}

float line(float d, float w, float px) {
  return smoothstep(w + px, w * 0.2, abs(d));
}

vec3 rain(vec2 q, float t, vec3 col) {
  float px = 2.0 / (uSize.y / (2.0 * HALO));
  float fall = 0.0;
  for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float cols = 7.0 + fi * 4.0;
    float x = q.x * cols + fi * 0.37;
    float id = floor(x);
    float h = hash(vec2(id, fi + uSeed));
    float speed = 0.35 + 0.25 * h + fi * 0.08;
    float y = fract(q.y * (0.55 + 0.2 * fi) - t * speed + h * 9.0);
    float streak = smoothstep(0.0, 0.03, y) * smoothstep(0.34, 0.05, y);
    float lx = line(fract(x) - 0.5, 0.025, px * cols);
    fall += lx * streak * (0.55 - fi * 0.13) * step(0.35, h);
  }
  float drops = stars(q + vec2(0.0, -t * 0.02), 7.0, t, 0.06) * 1.2 + stars(q * 1.3 + 4.0, 11.0, t * 1.3, 0.05) * 0.7;
  float vein = line(q.x + 0.06 * sin(q.y * 6.0 + 1.3), 0.008, px) * smoothstep(0.9, 0.1, abs(q.y)) * 0.55;
  float mist = fbm(q * 2.4 + vec2(0.0, t * 0.08));
  col = mix(col, uMid, smoothstep(0.35, 0.9, mist) * 0.45);
  return col + uHi * (fall * 0.28 + drops * 0.9 + vein * 0.6);
}

vec3 waves(vec2 q, float t, vec3 col, float r) {
  float px = 2.0 / (uSize.y / (2.0 * HALO));
  vec3 c = mix(col, uMid, 0.55 + 0.25 * fbm(q * 2.0 + t * 0.05));
  for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float base = 0.12 + fi * 0.22;
    float peak = exp(-sq((q.x - 0.08 + fi * 0.18) * 2.4)) * (0.34 - fi * 0.1);
    float y = base - peak - 0.05 * sin(q.x * (3.0 + fi) + t * (0.5 + fi * 0.2) + fi * 1.9);
    float below = smoothstep(y - px * 2.0, y + 0.08, q.y);
    vec3 water = mix(uMid * 0.85, uDeep * 1.4, clamp((q.y - y) * 1.6, 0.0, 1.0));
    c = mix(c, water, below * 0.7);
    float foam = fbm(vec2(q.x * 7.0 - t * 0.3, q.y * 10.0 + fi * 3.0));
    float crest = smoothstep(0.07, 0.0, abs(q.y - y)) * (0.5 + 0.7 * foam);
    c += uHi * crest * (0.55 - fi * 0.12);
    c += uHi * smoothstep(0.55, 0.9, foam) * below * smoothstep(0.25, 0.0, q.y - y) * 0.35;
  }
  c += uHi * stars(q, 8.0, t, 0.05) * 0.6;
  return c;
}

vec3 fire(vec2 q, float t, vec3 col) {
  vec2 fq = q;
  float n = fbm(vec2(fq.x * 2.4, fq.y * 1.9 + t * 0.9));
  float n2 = fbm(vec2(fq.x * 4.0 + 2.0, fq.y * 3.0 + t * 1.4));
  float sway = 0.14 * sin(fq.y * 3.5 + t * 1.1) + 0.2 * (n - 0.5);
  float body = 1.0 - smoothstep(0.0, 0.5 + 0.35 * (0.45 - fq.y), abs(fq.x - sway));
  body *= smoothstep(-0.75, 0.0, fq.y) * smoothstep(0.85, 0.4, fq.y);
  float flame = smoothstep(0.15, 0.8, body + (n - 0.5) * 0.7);
  float core = smoothstep(0.55, 0.95, body + (n2 - 0.5) * 0.6) * smoothstep(-0.3, 0.5, fq.y);
  float tongue = smoothstep(0.03, 0.0, abs(fq.x - sway * 1.6 - 0.25 * sin(fq.y * 6.0 - t * 2.0) * (0.5 - fq.y)) - 0.012) * smoothstep(0.6, -0.6, fq.y) * smoothstep(-0.8, -0.3, fq.y);
  vec3 c = mix(col, uMid, 0.35 + flame * 0.6);
  c = mix(c, uHi, core * 0.8);
  c += uHi * tongue * 0.55;
  vec2 eq = q + vec2(0.0, t * 0.15);
  c += vec3(1.0, 0.85, 0.55) * stars(eq, 8.0, t * 2.0, 0.045) * 0.7;
  return c;
}

vec3 wind(vec2 q, float t, vec3 col) {
  float px = 2.0 / (uSize.y / (2.0 * HALO));
  vec2 w = q + 0.35 * vec2(fbm(q * 1.4 + t * 0.07), fbm(q * 1.4 + 5.0 - t * 0.06)) - 0.17;
  float c = 0.0;
  for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float y = -0.45 + fi * 0.28 + 0.16 * sin(w.x * (3.0 + fi * 0.5) + t * 0.35 + fi * 2.1);
    c += line(w.y - y, 0.01, px) * (0.45 - fi * 0.08);
    c += smoothstep(0.2, 0.0, abs(w.y - y)) * 0.22;
  }
  float haze = fbm(w * 2.0 + t * 0.04);
  vec3 base = mix(col, uMid, 0.3 + 0.35 * haze) * 0.82;
  return base + uHi * c * 0.42 + uHi * stars(q, 8.0, t, 0.04) * 0.4;
}

vec3 forest(vec2 q, float t, vec3 col) {
  vec2 w = q * 2.1 + 0.4 * vec2(fbm(q * 2.0 + t * 0.03), fbm(q * 2.0 + 9.0));
  float ridge = 1.0 - abs(fbm(w + vec2(0.0, t * 0.04)) - 0.5) * 2.0;
  float veins = pow(ridge, 7.0);
  float ridge2 = 1.0 - abs(fbm(w * 1.9 + 3.0) - 0.5) * 2.0;
  float leaves = smoothstep(0.55, 0.9, fbm(q * 3.0 + vec2(t * 0.02, 0.0)));
  vec3 c = mix(col, uMid, leaves * 0.45 + 0.1);
  c += uHi * veins * 0.35 + uHi * pow(ridge2, 12.0) * 0.18;
  c += uHi * stars(q, 9.0, t, 0.05) * 0.5;
  return c;
}

vec3 night(vec2 q, float t, vec3 col) {
  vec2 w = q + 0.3 * vec2(fbm(q * 1.6 + t * 0.03), fbm(q * 1.6 + 4.0));
  float cloud = fbm(w * 2.2 + vec2(t * 0.03, 0.0));
  float ridge = pow(1.0 - abs(fbm(w * 2.8 + 2.0) - 0.5) * 2.0, 6.0);
  vec3 c = mix(col, uMid, smoothstep(0.35, 0.85, cloud) * 0.8);
  c += uHi * ridge * 0.45;
  c += vec3(1.0) * stars(q, 10.0, t, 0.05) * 0.6 + uHi * stars(q * 1.7 + 2.0, 14.0, t * 1.2, 0.04) * 0.3;
  return c;
}

vec3 stream(vec2 q, float t, vec3 col) {
  float px = 2.0 / (uSize.y / (2.0 * HALO));
  float horizon = 0.08;
  float ridge = horizon - 0.05 - 0.12 * fbm(vec2(q.x * 2.4 + 1.0, 0.5)) - 0.06 * abs(sin(q.x * 3.0 + 1.0));
  vec3 c = col;
  float sky = smoothstep(horizon, -0.9, q.y);
  c = mix(c, uMid * 0.9, sky * 0.35);
  c = mix(c, uDeep * 1.2 + uMid * 0.15, smoothstep(ridge - px, ridge + px, q.y) * step(q.y, horizon));
  vec2 sp = q - vec2(0.02, horizon - 0.01);
  float sun = exp(-dot(sp * vec2(1.0, 1.6), sp * vec2(1.0, 1.6)) * 40.0);
  float band = exp(-sq((q.y - horizon) * 22.0)) * smoothstep(0.9, 0.0, abs(q.x));
  c += uHi * (sun * 1.2 + band * 0.55);
  float below = step(horizon, q.y);
  float shimmer = fbm(vec2(q.x * 3.0, q.y * 26.0 - t * 0.6));
  float glint = smoothstep(0.55, 0.85, shimmer) * exp(-q.x * q.x * 6.0) * exp(-(q.y - horizon) * 2.5);
  c += uHi * glint * below * 0.9;
  float ripple = line(fract(q.y * 7.0 - t * 0.25) - 0.5, 0.03, px * 7.0) * below * smoothstep(0.9, 0.2, abs(q.x)) * 0.18;
  c += uMid * ripple;
  c += uHi * stars(q, 9.0, t, 0.05) * 0.4;
  return c;
}

vec3 crickets(vec2 q, float t, vec3 col) {
  float px = 2.0 / (uSize.y / (2.0 * HALO));
  float glow = fbm(q * 2.3 + t * 0.03);
  vec3 c = mix(col, uMid, 0.35 + 0.45 * glow);
  float web = 0.0;
  for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float a = fi * 1.2566 + 0.3 + uSeed;
    vec2 dir = vec2(cos(a), sin(a));
    float d = dot(q, vec2(-dir.y, dir.x)) + 0.12 * sin(fi * 3.1 + t * 0.2);
    web += line(d, 0.006, px) * smoothstep(0.95, 0.2, length(q)) * (0.35 + 0.2 * sin(t * 1.3 + fi));
  }
  float arc = line(length(q - vec2(0.0, 0.12)) - 0.55, 0.008, px) * 0.45;
  c += uHi * (web + arc) * 0.35;
  c += uHi * stars(q, 7.0, t * 1.4, 0.07) * 1.2 + vec3(1.0) * stars(q * 1.5 + 7.0, 12.0, t * 2.0, 0.05) * 0.35;
  return c;
}

vec3 thunder(vec2 q, float t, vec3 col) {
  float px = 2.0 / (uSize.y / (2.0 * HALO));
  float smoke = fbm(q * 2.0 + vec2(t * 0.05, -t * 0.02));
  vec3 c = mix(col, uMid, smoothstep(0.3, 0.9, smoke) * 0.7);
  float cycle = fract(t * 0.11 + uSeed);
  float flash = exp(-cycle * 40.0) + 0.5 * exp(-abs(cycle - 0.05) * 60.0);
  float bx = 0.15 * sin(q.y * 7.0 + floor(t * 0.11 + uSeed) * 3.0) + 0.08 * (noise(vec2(q.y * 18.0, floor(t * 0.11)) ) - 0.5);
  float bolt = line(q.x - bx + 0.1, 0.012, px) * smoothstep(0.7, -0.6, q.y) * smoothstep(-0.9, -0.6, q.y);
  c += vec3(0.85, 0.9, 1.0) * bolt * flash * 1.6;
  c += uMid * flash * 0.5;
  c += uHi * stars(q, 8.0, t, 0.06) * 0.9 + uHi * stars(q * 1.4 + 3.0, 13.0, t * 1.3, 0.045) * 0.4;
  return c;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  float R = min(uSize.x, uSize.y) * 0.5 / HALO;
  vec2 p = (frag - uSize * 0.5) / R;
  float r = length(p);
  float px = 1.5 / R;
  float t = uTime + uSeed * 37.0;

  vec3 glowCol = mix(uMid, uHi, 0.35);
  float halo = exp(-max(r - 1.0, 0.0) * 4.2) * 0.42 + exp(-max(r - 1.0, 0.0) * 12.0) * 0.22;
  halo *= uGlow * smoothstep(HALO, HALO * 0.82, r);
  vec4 outside = vec4(glowCol * halo, halo);

  if (r > 1.0 + px) {
    fragColor = outside;
    return;
  }

  float rr = min(r, 0.9999);
  float z = sqrt(1.0 - rr * rr);
  vec2 q = p / (0.62 + 0.38 * z);
  vec3 base = mix(uDeep, uMid, 0.18 + 0.32 * smoothstep(-1.0, 1.0, p.y) + 0.25 * pow(rr, 2.5));

  vec3 col;
  int kind = int(uKind + 0.5);
  if (kind == 0) col = rain(q, t, base);
  else if (kind == 1) col = waves(q, t, base, rr);
  else if (kind == 2) col = fire(q, t, base);
  else if (kind == 3) col = wind(q, t, base);
  else if (kind == 4) col = forest(q, t, base);
  else if (kind == 5) col = night(q, t, base);
  else if (kind == 6) col = stream(q, t, base);
  else if (kind == 7) col = crickets(q, t, base);
  else col = thunder(q, t, base);

  col *= 0.78 + 0.34 * uLife;

  float fres = pow(1.0 - z, 2.2);
  col = mix(col, mix(uMid, uHi, 0.55), fres * 0.6);
  col *= 1.0 - 0.28 * smoothstep(0.2, -0.9, p.y) * (1.0 - fres);

  float rim = smoothstep(0.955, 1.0, rr) * smoothstep(1.0 + px, 1.0 - px * 0.5, r);
  col += mix(uHi, vec3(1.0), 0.2) * rim * 0.3;
  col += mix(uMid, uHi, 0.5) * smoothstep(0.7, 1.0, rr) * smoothstep(-0.2, 1.0, p.y) * 0.25;

  vec2 sp = p - vec2(-0.38, -0.48);
  float spec = exp(-dot(sp * vec2(1.0, 1.5), sp * vec2(1.0, 1.5)) * 9.0);
  col += vec3(1.0) * spec * 0.22;
  vec2 sp2 = p - vec2(-0.5, -0.56);
  col += vec3(1.0) * exp(-dot(sp2, sp2) * 90.0) * 0.35;
  float arc = smoothstep(0.08, 0.0, abs(r - 0.86)) * smoothstep(0.1, 0.7, p.x + p.y * 0.2) * smoothstep(-0.2, 0.6, p.y);
  col += mix(uHi, vec3(1.0), 0.5) * arc * 0.16;

  float edge = smoothstep(1.0 + px, 1.0 - px, r);
  vec3 outC = col;
  vec4 result = vec4(outC * edge, edge) + outside * (1.0 - edge);
  fragColor = vec4(min(max(result.rgb, vec3(0.0)), vec3(result.a)), result.a);
}
