"""Builds clean screens (UI removed) and background plates (UI and cut art removed).

  python plates.py clean   -> clean/s{n}.png, the screens with all UI filled
  python plates.py plates  -> plate/{name}.png, clean screens with cut layers filled
"""
import os
import sys

import cv2
import numpy as np

ROOT = os.environ.get('STREAK_ROOT', '.')
K = 3


def push_pull(img, hole):
    levels = []
    cur = img.astype(np.float32) * (1 - hole[..., None])
    w = 1 - hole.astype(np.float32)
    while min(cur.shape[:2]) > 4:
        levels.append((cur, w))
        cur = cv2.pyrDown(cur)
        w = cv2.pyrDown(w)
    filled = cur / np.maximum(w[..., None], 1e-6)
    for c, ww in reversed(levels):
        up = cv2.resize(filled, (c.shape[1], c.shape[0]), interpolation=cv2.INTER_LINEAR)
        known = c / np.maximum(ww[..., None], 1e-6)
        a = np.clip(ww * 4, 0, 1)[..., None]
        filled = known * a + up * (1 - a)
    return filled


def harmonic(img, hole, iters=80):
    out = push_pull(img, hole)
    m = hole.astype(bool)
    for _ in range(iters):
        blur = cv2.blur(out, (5, 5))
        out[m] = blur[m]
    return out


def rect(mask, x0, y0, x1, y1, r=0):
    p = [int(round(v * K)) for v in (x0, y0, x1, y1)]
    if r:
        rr = int(r * K)
        cv2.rectangle(mask, (p[0] + rr, p[1]), (p[2] - rr, p[3]), 1, -1)
        cv2.rectangle(mask, (p[0], p[1] + rr), (p[2], p[3] - rr), 1, -1)
        for cx, cy in ((p[0] + rr, p[1] + rr), (p[2] - rr, p[1] + rr), (p[0] + rr, p[3] - rr), (p[2] - rr, p[3] - rr)):
            cv2.circle(mask, (cx, cy), rr, 1, -1)
    else:
        cv2.rectangle(mask, (p[0], p[1]), (p[2], p[3]), 1, -1)


def circle(mask, cx, cy, r):
    cv2.circle(mask, (int(cx * K), int(cy * K)), int(r * K), 1, -1)


def layer(mask, name, box, grow=5):
    a = cv2.imread(f'{ROOT}/cut/{name}.png', cv2.IMREAD_UNCHANGED)[:, :, 3]
    x0, y0 = int(round(box[0] * K)), int(round(box[1] * K))
    m = (a > 16).astype(np.uint8)
    m = cv2.dilate(m, np.ones((grow * 2 + 1, grow * 2 + 1), np.uint8))
    h, w = m.shape
    mask[y0:y0 + h, x0:x0 + w] |= m[:mask.shape[0] - y0, :mask.shape[1] - x0]


def fill(src, build, out, feather=4, seed=0):
    img = cv2.imread(src).astype(np.float32)
    mask = np.zeros(img.shape[:2], np.uint8)
    build(mask)
    done = harmonic(img, mask)
    grain = np.random.default_rng(seed).normal(0, 2.0, img.shape).astype(np.float32)
    soft = cv2.GaussianBlur(mask.astype(np.float32), (0, 0), feather)[..., None]
    soft = np.maximum(soft, mask[..., None].astype(np.float32))
    result = img * (1 - soft) + (done + grain * soft) * soft
    cv2.imwrite(out, np.clip(result, 0, 255).astype(np.uint8))


# --- UI removal -------------------------------------------------------------

def c1(m):
    rect(m, 0, 0, 402, 44)
    rect(m, 88, 193, 322, 276)
    rect(m, 64, 635, 344, 718, 37)
    rect(m, 168, 730, 238, 752)


def c2(m):
    rect(m, 0, 0, 402, 44)
    rect(m, 40, 66, 368, 206)
    rect(m, 164, 652, 238, 674)
    rect(m, 108, 682, 295, 743, 25)
    rect(m, 176, 750, 228, 780)


def c3(m):
    rect(m, 0, 0, 402, 46)
    rect(m, 12, 50, 392, 130)
    rect(m, 14, 136, 388, 231, 20)
    rect(m, 14, 378, 168, 582, 18)
    rect(m, 68, 602, 336, 675, 32)
    rect(m, 0, 674, 402, 783)


def c4(m):
    rect(m, 0, 0, 635, 44)
    rect(m, 30, 38, 612, 82)
    rect(m, 34, 80, 407, 188, 16)
    circle(m, 541, 160, 66)
    circle(m, 541, 262, 31)
    rect(m, 50, 322, 588, 402, 14)
    rect(m, 94, 413, 582, 482, 22)


def c5(m):
    rect(m, 0, 0, 648, 44)
    rect(m, 222, 44, 627, 96)
    rect(m, 48, 60, 190, 162)
    rect(m, 222, 96, 648, 440)
    rect(m, 0, 424, 648, 503)


# --- Plates: the clean screen with every animated layer lifted out ----------

def frame(m, r=50, edge=4):
    h, w = m.shape
    keep = np.zeros_like(m)
    rect(keep, edge, edge, w / K - edge, h / K - edge, r)
    m |= (1 - keep).astype(np.uint8)


def p1(m):
    frame(m)
    layer(m, 'logo', (85, 30), 6)
    layer(m, 'hero_splash', (14, 290), 4)


def p2(m):
    layer(m, 'hero_pushup', (0, 318), 4)
    frame(m)
    for cx, cy, r in ((88, 302, 47), (315, 285, 41), (348, 367, 41)):
        circle(m, cx, cy, r)
    rect(m, 138, 212, 282, 336, 30)


def p3(m):
    frame(m)
    layer(m, 'hero_home', (168, 232), 4)
    layer(m, 'gift', (320, 516), 6)


def p4(m):
    frame(m, 46)
    layer(m, 'hero_workout', (130, 176), 4)


def portrait_workout():
    """Re-frames the landscape workout plate for a phone: the 402 pt window over the
    hero keeps scale 1, so the hero art lands exactly on its own hole, and the
    neon ceiling and floor are stretched to fill a tall screen."""
    src = cv2.imread(f'{ROOT}/plate/workout.png').astype(np.float32)
    x0, top, bottom, shift = 92, 44, 490, 177
    win = src[top * K:bottom * K, x0 * K:(x0 + 402) * K]
    H = 1000
    out = np.zeros((H * K, 402 * K, 3), np.float32)
    y = (top + shift) * K
    out[y:y + win.shape[0]] = win
    head = cv2.resize(win[:30 * K], (402 * K, y), interpolation=cv2.INTER_LINEAR)
    out[:y] = cv2.GaussianBlur(head, (0, 0), 18)
    tail_h = H * K - (y + win.shape[0])
    tail = cv2.resize(win[-24 * K:], (402 * K, tail_h), interpolation=cv2.INTER_LINEAR)
    out[y + win.shape[0]:] = cv2.GaussianBlur(tail, (0, 0), 14)
    for edge, length in ((y, 26 * K), (y + win.shape[0], 20 * K)):
        a, b = max(0, edge - length), min(H * K, edge + length)
        band = out[a:b].copy()
        out[a:b] = cv2.GaussianBlur(band, (0, 0), 10)
    cv2.imwrite(f'{ROOT}/plate/workout_portrait.png', np.clip(out, 0, 255).astype(np.uint8))


def p5(m):
    layer(m, 'chest_pedestal', (20, 140), 4)


if __name__ == '__main__':
    what = sys.argv[1]
    if what == 'clean':
        os.makedirs(f'{ROOT}/clean', exist_ok=True)
        for i, fn in enumerate((c1, c2, c3, c4, c5), 1):
            fill(f'{ROOT}/s{i}_hd.png', fn, f'{ROOT}/clean/s{i}.png', seed=i)
            print('clean', i, flush=True)
    else:
        os.makedirs(f'{ROOT}/plate', exist_ok=True)
        for i, fn, name in ((1, p1, 'splash'), (2, p2, 'onboard'), (3, p3, 'home'), (4, p4, 'workout'), (5, p5, 'quests')):
            fill(f'{ROOT}/clean/s{i}.png', fn, f'{ROOT}/plate/{name}.png', seed=10 + i)
            print('plate', name, flush=True)
        portrait_workout()
        print('plate workout_portrait', flush=True)
