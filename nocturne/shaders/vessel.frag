#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform vec2 uCenter;
uniform float uRadius;
uniform float uTime;
uniform float uMode;
uniform float uFill;
uniform float uEnergy;
uniform vec4 uWeights;
uniform vec3 uC0;
uniform vec3 uC1;
uniform vec3 uC2;
uniform vec3 uC3;

out vec4 fragColor;

const float LIP_Y = -0.815;
const float LIP_TOP = -0.885;
const float LIP_W = 0.575;

float sq(float x) {
  return x * x;
}

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

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 5; i++) {
    v += a * noise(p);
    p = p * 2.03 + vec2(1.7, 9.2);
    a *= 0.5;
  }
  return v / 0.96875;
}

mat2 rot(float a) {
  float c = cos(a);
  float s = sin(a);
  return mat2(c, -s, s, c);
}

float starField(vec2 q, float density, float t, float px) {
  vec2 g = q * density;
  vec2 id = floor(g);
  vec2 f = fract(g);
  float h = hash(id);
  float h2 = hash(id + 7.7);
  vec2 o = vec2(h, h2) * 0.7 + 0.15;
  float d = length(f - o) / density;
  float tw = 0.5 + 0.5 * sin(t * (1.0 + 3.0 * h2) + h * 50.0);
  float s = min(max(0.004 + 0.006 * h2, px * 1.2), 0.3 / density);
  return step(0.62, h) * tw * smoothstep(s, s * 0.2, d);
}

vec3 nebula(vec2 q, float t, float energy, out float density) {
  vec4 w = uWeights;
  float total = max(w.x + w.y + w.z + w.w, 0.001);

  vec2 warp = vec2(fbm(q * 1.6 + vec2(t * 0.02, 0.0)), fbm(q * 1.6 + vec2(5.2, 1.3) - t * 0.018)) - 0.5;
  vec2 d = q + warp * 0.35;

  vec2 src0 = vec2(-0.55, 0.15) + 0.06 * vec2(sin(t * 0.21), cos(t * 0.17));
  vec2 src1 = vec2(0.52, -0.02) + 0.06 * vec2(cos(t * 0.19), sin(t * 0.23));
  vec2 src2 = vec2(-0.45, -0.35) + 0.06 * vec2(sin(t * 0.15 + 1.0), cos(t * 0.2));
  vec2 src3 = vec2(-0.15, 0.62) + 0.06 * vec2(cos(t * 0.18 + 2.0), sin(t * 0.16));
  float spread = 4.6;
  float k0 = w.x * exp(-dot(d - src0, d - src0) * spread / (0.3 + w.x));
  float k1 = w.y * exp(-dot(d - src1, d - src1) * spread / (0.3 + w.y));
  float k2 = w.z * exp(-dot(d - src2, d - src2) * spread / (0.3 + w.z));
  float k3 = w.w * exp(-dot(d - src3, d - src3) * spread / (0.3 + w.w));
  float ks = k0 + k1 + k2 + k3 + 0.0001;
  vec3 avg = (uC0 * w.x + uC1 * w.y + uC2 * w.z + uC3 * w.w) / total;
  vec3 local = mix(avg, (uC0 * k0 + uC1 * k1 + uC2 * k2 + uC3 * k3) / ks, smoothstep(0.0, 0.2, ks));

  vec2 c = d - vec2(0.02, 0.12);
  float r = length(c);
  float th = atan(c.y, c.x);
  float phase = 2.0 * th + 1.9 * log(r + 0.06) - t * 0.12 + (fbm(d * 1.4 + 3.0) - 0.5) * 1.1;
  float arm = 0.5 + 0.5 * cos(phase);
  float fall = smoothstep(0.08, 0.4, r) * smoothstep(1.15, 0.6, r);
  float core = pow(arm, 10.0) * fall;
  float body = pow(arm, 3.2) * fall;
  float fineN = fbm(d * 3.0 + vec2(t * 0.05, 0.0));
  float fine = pow(0.5 + 0.5 * cos(phase * 7.0 + fineN * 4.0), 14.0) * pow(arm, 1.6) * fall;
  float fine2 = pow(0.5 + 0.5 * cos(phase * 15.0 - fineN * 6.0 + 1.3), 22.0) * pow(arm, 1.2) * fall;

  float f1 = d.y - (0.3 - 0.8 * d.x * d.x + 0.12 * d.x) + 0.04 * sin(d.x * 5.0 + t * 0.3);
  float env1 = exp(-f1 * f1 * 9.0) * smoothstep(1.05, 0.55, length(d));
  float core1 = exp(-f1 * f1 * 160.0) * smoothstep(1.0, 0.4, length(d));
  float strandsU = pow(0.5 + 0.5 * cos(f1 * 42.0 + fineN * 3.0), 10.0) * env1;
  vec2 m = d - vec2(0.0, -0.3);
  float intake = 0.0;
  for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float x = (fi - 1.5) * 0.07 + 0.08 * sin(m.y * 4.0 + fi * 1.7 + t * 0.4) * (0.6 + m.y);
    intake += exp(-sq((m.x - x) * 70.0)) * smoothstep(-0.65, -0.2, m.y) * smoothstep(0.55, 0.0, m.y) * (0.5 + 0.5 * dot(w, vec4(step(abs(fi - 0.0), 0.1), step(abs(fi - 1.0), 0.1), step(abs(fi - 2.0), 0.1), step(abs(fi - 3.0), 0.1))));
  }

  float gasA = fbm(d * 1.8 + vec2(11.0, t * 0.015));
  float gasB = fbm(d * 3.6 + vec2(4.0, -t * 0.02) + gasA * 1.2);
  float gas = smoothstep(0.28, 0.78, gasA * 0.65 + gasB * 0.45);
  float cloud = smoothstep(0.4, 0.8, fbm(d * 2.3 + 11.0));
  float hue = fbm(d * 1.2 + 7.0);
  float inner = smoothstep(1.02, 0.35, length(d));

  float wisp1 = pow(1.0 - abs(fbm(vec2(phase * 0.9, r * 3.0) + fineN) - 0.5) * 2.0, 12.0);
  float wisp2 = pow(1.0 - abs(fbm(vec2(f1 * 6.0, d.x * 1.5) + 2.0 + fineN * 0.6) - 0.5) * 2.0, 14.0);
  float wisp3 = pow(0.5 + 0.5 * cos(phase * 4.0 + gasB * 6.0), 18.0) * fall;
  float strandsU2 = pow(0.5 + 0.5 * cos(f1 * 64.0 + fineN * 7.0), 16.0) * exp(-f1 * f1 * 26.0) * inner;
  float wisps = (wisp1 * (0.35 + body) + wisp2 * (0.35 + env1 * 1.5) + wisp3 * 0.8) * inner;

  vec3 violet = vec3(0.36, 0.2, 0.95);
  vec3 deep = mix(vec3(0.03, 0.05, 0.22), vec3(0.1, 0.05, 0.28), smoothstep(0.35, 0.75, hue));
  vec3 gasCol = mix(mix(local, violet, 0.35), avg, 0.2);
  vec3 col = deep;
  col += gasCol * gas * inner * 0.32;
  col += violet * smoothstep(0.45, 0.8, hue) * inner * 0.18;
  col += local * body * 0.4;
  col += uC1 * k1 * smoothstep(0.2, 0.9, gasA + body * 0.4) * 0.35;
  col += local * cloud * 0.18;
  col += local * ks * ks * 0.3;
  col += local * core * 0.8;
  col += local * (env1 * 0.12 + core1 * 0.75) + mix(local, vec3(1.0), 0.1) * (strandsU * 1.3 + strandsU2 * 0.9);
  col += mix(local, vec3(1.0), 0.55) * pow(core1, 3.0) * 0.5;
  col += mix(local, vec3(0.95, 0.97, 1.0), 0.12) * (fine * 0.85 + fine2 * 0.55);
  col += mix(local, vec3(0.9, 0.93, 1.0), 0.15) * wisps * 0.75;
  col += mix(local, vec3(1.0), 0.5) * pow(core, 4.0) * 0.6;
  col += mix(avg, vec3(1.0), 0.3) * intake * 0.7;
  col += mix(local, vec3(1.0), 0.4) * exp(-r * r * 30.0) * 0.25;

  float px = 1.5 / uRadius;
  float stars = starField(q + vec2(0.0, t * 0.004), 26.0, t, px)
      + starField(q * 1.7 + 3.0, 38.0, t * 1.3, px) * 0.8
      + starField(q * 2.3 + 9.0, 60.0, t * 0.9, px) * 0.6
      + starField(q * 3.1 + 17.0, 85.0, t * 1.7, px) * 0.45 * (gas + body);
  col += mix(vec3(1.0), local, 0.35) * stars * (0.55 + body + gas * 0.6);
  float dust = smoothstep(0.62, 1.0, noise(d * 70.0 + t * 0.2)) * (gas + body) * inner;
  col += local * dust * 0.35;

  float structure = clamp(body * 0.8 + core + env1 * 0.6 + wisps + strandsU + gas * 0.35, 0.0, 1.0);
  col *= mix(0.5, 1.05, structure);
  col *= 0.65 + 0.5 * energy;
  float peak = max(max(col.r, col.g), max(col.b, 0.0001));
  col *= (1.0 - exp(-peak * 1.35)) / peak;
  col += vec3(1.0) * smoothstep(1.3, 2.2, peak) * 0.12;
  density = clamp(body + core + intake + env1 + gas * 0.5, 0.0, 1.0);
  return col;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  float t = uTime;
  float px = 1.5 / uRadius;

  if (uMode > 0.5) {
    vec2 q = (frag - uSize * 0.5) / (min(uSize.x, uSize.y) * 0.5);
    float dens;
    vec3 c = nebula(q * 0.9, t, uEnergy, dens);
    c += vec3(0.06, 0.05, 0.14) * (1.0 - length(q) * 0.5);
    fragColor = vec4(c, 1.0);
    return;
  }

  vec2 p = (frag - uCenter) / uRadius;
  float r = length(p);

  float inBody = smoothstep(1.0 + px, 1.0 - px, r) * smoothstep(LIP_Y - px, LIP_Y + px, p.y);
  float neckHalf = LIP_W - 0.02 * smoothstep(LIP_TOP, LIP_Y, p.y);
  float inNeck = smoothstep(neckHalf + px, neckHalf - px, abs(p.x)) * smoothstep(LIP_TOP - px, LIP_TOP + px, p.y) * step(p.y, LIP_Y + px);
  float inside = max(inBody, inNeck);

  vec3 outCol = vec3(0.0);
  float outA = 0.0;

  vec4 w = uWeights;
  float total = max(w.x + w.y + w.z + w.w, 0.001);
  vec3 avg = (uC0 * w.x + uC1 * w.y + uC2 * w.z + uC3 * w.w) / total;
  vec3 lav = vec3(0.72, 0.7, 1.0);

  float floorY = 1.0;
  vec2 fp = vec2(p.x / 1.28, (p.y - floorY + 0.02) / 0.13);
  float pool = exp(-dot(fp, fp) * 1.6);
  float plane = smoothstep(0.8, 0.94, p.y) * smoothstep(1.32, 1.02, p.y) * smoothstep(1.45, 0.6, abs(p.x));
  vec3 floorCol = mix(vec3(0.2, 0.26, 0.7), avg, 0.25);
  outCol += floorCol * pool * 0.85 * (0.5 + 0.5 * uFill) + vec3(0.1, 0.11, 0.3) * plane * 0.4;
  outA += pool * 0.75 + plane * 0.3;

  float spill = exp(-max(r - 1.0, 0.0) * 4.0) * (1.0 - inside) * smoothstep(-1.2, 0.2, p.y);
  outCol += mix(avg, lav, 0.4) * spill * 0.16 * uFill * uEnergy;
  outA += spill * 0.16 * uFill * uEnergy;

  vec3 col = vec3(0.0);
  float alpha = 0.0;

  if (inside > 0.0) {
    float rr = min(r, 0.999);
    float z = sqrt(1.0 - rr * rr);
    vec2 q = p / (0.66 + 0.34 * z);
    q.y -= 0.05;

    float dens;
    vec3 neb = nebula(q, t, uEnergy, dens);

    float level = mix(1.2, -1.05, uFill);
    float wave = 0.03 * sin(p.x * 6.0 + t * 1.2) + 0.02 * sin(p.x * 11.0 - t * 1.7);
    float filled = smoothstep(level - 0.08, level + 0.08, p.y + wave);
    float topFade = smoothstep(-0.92, -0.35, p.y);
    float intake = exp(-sq(p.x * 3.2 + 0.25 * sin(p.y * 4.0 + t * 0.6))) * smoothstep(-0.95, -0.2, p.y) * smoothstep(0.35, -0.5, p.y);
    float margin = smoothstep(0.985, 0.9, rr);
    float fillMask = (filled * mix(0.72, 1.0, topFade) + intake * 0.55 * uFill) * mix(0.25, 1.0, margin);
    fillMask = clamp(fillMask, 0.0, 1.0) * inBody + inNeck * (1.0 - inBody) * intake * 0.3 * uFill;

    vec3 glass = vec3(0.1, 0.11, 0.26);
    col = mix(glass, neb, fillMask);
    float a = mix(0.3, 0.97, fillMask);

    float fres = pow(1.0 - z, 3.0) * inBody;
    col += mix(lav, avg, 0.3) * fres * 0.3;
    a = max(a, fres * 0.5);
    float band = smoothstep(0.86, 0.97, rr) * inBody;
    col += mix(vec3(0.45, 0.5, 1.0), avg, 0.2) * band * 0.3;
    a = max(a, band * 0.55);

    float lowerGlow = smoothstep(0.45, 1.0, p.y) * smoothstep(0.85, 1.0, rr);
    col += mix(lav, vec3(1.0, 0.75, 0.95), 0.4) * lowerGlow * 0.45;

    float leftStreak = exp(-sq((atan(p.y, p.x) - 2.55) * 3.2)) * smoothstep(0.78, 0.9, rr) * smoothstep(0.99, 0.92, rr);
    float rightStreak = exp(-sq((atan(p.y, p.x) - 0.25) * 4.0)) * smoothstep(0.82, 0.92, rr) * smoothstep(0.99, 0.93, rr);
    float shoulder = exp(-sq((atan(p.y, p.x) + 2.25) * 4.0)) * smoothstep(0.84, 0.95, rr) * smoothstep(1.0, 0.95, rr);
    col += vec3(0.92, 0.94, 1.0) * (leftStreak * 0.6 + rightStreak * 0.4 + shoulder * 0.45);
    vec2 hp = p - vec2(-0.62, -0.3);
    col += vec3(1.0) * exp(-dot(hp * vec2(5.0, 1.4), hp * vec2(5.0, 1.4)) * 3.0) * 0.1;

    float neckGlass = inNeck * (1.0 - inBody);
    col = mix(col, col + lav * 0.12, neckGlass);

    alpha = a * inside;
    col *= inside;
  }

  float ring = exp(-sq((r - 1.0) / 0.011)) * step(LIP_Y - 0.02, p.y);
  float ringInner = exp(-sq((r - 0.972) / 0.008)) * step(LIP_Y + 0.03, p.y);
  float ang = atan(p.y, p.x);
  float ringLight = 0.55 + 0.45 * abs(cos(ang)) + 0.35 * smoothstep(0.3, 1.0, p.y);
  vec3 rimCol = mix(vec3(0.62, 0.64, 1.0), vec3(1.0), 0.25);
  col += rimCol * (ring * 0.6 + ringInner * 0.3) * ringLight;
  alpha = max(alpha, clamp(ring * 0.6 * ringLight + ringInner * 0.3, 0.0, 1.0));

  vec2 e = vec2(p.x / LIP_W, (p.y - LIP_TOP) / 0.055);
  float el = length(e);
  float lipOuter = exp(-sq((el - 1.0) / 0.05));
  vec2 e2 = vec2(p.x / (LIP_W - 0.035), (p.y - LIP_TOP - 0.004) / 0.045);
  float lipInner = exp(-sq((length(e2) - 1.0) / 0.05)) * step(0.0, -p.y + LIP_TOP + 0.01);
  vec2 e3 = vec2(p.x / (LIP_W - 0.005), (p.y - LIP_Y + 0.02) / 0.05);
  float lipBottom = exp(-sq((length(e3) - 1.0) / 0.06)) * step(LIP_Y - 0.02, p.y);
  float lipSide = exp(-sq((abs(p.x) - neckHalf) / 0.01)) * step(LIP_TOP, p.y) * step(p.y, LIP_Y + 0.02);
  float lip = lipOuter * 0.7 + lipInner * 0.35 + lipBottom * 0.55 + lipSide * 0.6;
  float lipLight = 0.6 + 0.4 * abs(e.x);
  col += rimCol * lip * lipLight;
  alpha = max(alpha, clamp(lip * lipLight, 0.0, 1.0));

  vec3 finalCol = col + outCol * (1.0 - alpha);
  float finalA = clamp(alpha + outA * (1.0 - alpha), 0.0, 1.0);
  fragColor = vec4(min(max(finalCol, vec3(0.0)), vec3(finalA)), finalA);
}
