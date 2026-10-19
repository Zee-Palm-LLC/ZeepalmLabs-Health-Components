"""Trims every cut layer to its ink, writes webp assets and prints pt placement."""
import json
import os

import cv2
import numpy as np

ROOT = os.environ.get('STREAK_ROOT', '.')
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'art')
K = 3

os.makedirs(OUT, exist_ok=True)
here = os.path.dirname(__file__)
jobs = json.load(open(os.path.join(here, 'jobs.json'))) + json.load(open(os.path.join(here, 'icons.json')))
for j in jobs:
    a = cv2.imread(f'{ROOT}/cut/{j["name"]}.png', cv2.IMREAD_UNCHANGED)
    ys, xs = np.where(a[:, :, 3] > 6)
    y0, y1 = max(0, ys.min() - 2), min(a.shape[0], ys.max() + 3)
    x0, x1 = max(0, xs.min() - 2), min(a.shape[1], xs.max() + 3)
    t = a[y0:y1, x0:x1].copy()
    t[t[:, :, 3] == 0, :3] = 0
    cv2.imwrite(f'{OUT}/{j["name"]}.webp', t, [cv2.IMWRITE_WEBP_QUALITY, 92])
    bx, by = j['box'][0] + x0 / K, j['box'][1] + y0 / K
    print(f'{j["name"]:16s} s{j["screen"]}  x {bx:7.2f}  y {by:7.2f}  w {(x1 - x0) / K:7.2f}  h {(y1 - y0) / K:7.2f}')

for name in ('splash', 'onboard', 'home', 'workout_portrait'):
    p = cv2.imread(f'{ROOT}/plate/{name}.png')
    cv2.imwrite(f'{OUT}/bg_{name.split("_")[0]}.webp', p, [cv2.IMWRITE_WEBP_QUALITY, 86])
    print(f'bg_{name.split("_")[0]:12s} {p.shape[1] / K:.1f} x {p.shape[0] / K:.1f}')
