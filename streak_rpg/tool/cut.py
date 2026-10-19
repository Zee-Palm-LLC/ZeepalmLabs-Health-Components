"""Cuts StreakRPG art layers out of the upscaled mockup screens.

Screens are the five phones from the mockup, cropped at their inner bezel and
upscaled to 3 px per pt (s1-s3 are 402 pt wide; s4/s5 keep the same pt scale).
`isnet` jobs use ISNet segmentation, `key` jobs key the icon off its flat tile.
"""
import json
import os
import sys

import cv2
import numpy as np
import onnxruntime as ort

ROOT = os.environ.get('STREAK_ROOT', '.')
MODEL = os.path.expanduser('~/.u2net/isnet-general-use.onnx')
K = 3

_session = None


def session():
    global _session
    if _session is None:
        _session = ort.InferenceSession(MODEL, providers=['CPUExecutionProvider'])
    return _session


def segment(rgb):
    h, w = rgb.shape[:2]
    side = max(h, w)
    pad = np.zeros((side, side, 3), np.uint8)
    oy, ox = (side - h) // 2, (side - w) // 2
    pad[oy:oy + h, ox:ox + w] = rgb
    x = cv2.resize(pad, (1024, 1024), interpolation=cv2.INTER_AREA).astype(np.float32) / 255.0
    x = (x - np.array([0.485, 0.456, 0.406], np.float32)).transpose(2, 0, 1)[None]
    s = session()
    y = s.run(None, {s.get_inputs()[0].name: x})[0][0, 0]
    y = (y - y.min()) / max(1e-6, y.max() - y.min())
    y = cv2.resize(y, (side, side), interpolation=cv2.INTER_CUBIC)
    return y[oy:oy + h, ox:ox + w]


def keyed(rgb, soft=(38.0, 70.0)):
    """Alpha from colour distance to the tile colour sampled on the crop border."""
    lab = cv2.cvtColor(rgb, cv2.COLOR_RGB2LAB).astype(np.float32)
    edge = np.concatenate([lab[:3].reshape(-1, 3), lab[-3:].reshape(-1, 3), lab[:, :3].reshape(-1, 3), lab[:, -3:].reshape(-1, 3)])
    ref = np.median(edge, 0)
    d = np.linalg.norm(lab - ref, axis=2)
    lo, hi = soft
    return np.clip((d - lo) / (hi - lo), 0, 1)


def largest(a, grow=9):
    m = (a > 0.5).astype(np.uint8)
    n, lab, stats, _ = cv2.connectedComponentsWithStats(m)
    if n <= 1:
        return a
    big = 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])
    keep = cv2.dilate((lab == big).astype(np.uint8), np.ones((grow, grow), np.uint8))
    return a * keep


def source(screen, raw=False):
    clean = f'{ROOT}/clean/s{screen}.png'
    return cv2.imread(clean if os.path.exists(clean) and not raw else f'{ROOT}/s{screen}_hd.png')[:, :, ::-1]


def cut(job):
    img = source(job["screen"], job.get("raw", False))
    x0, y0, x1, y1 = [int(round(v * K)) for v in job['box']]
    crop = np.ascontiguousarray(img[y0:y1, x0:x1])
    if job.get('mode', 'isnet') == 'key':
        a = keyed(crop, tuple(job.get('soft', (38.0, 70.0))))
    else:
        a = segment(crop)
        lo, hi = job.get('t', (0.25, 0.75))
        a = np.clip((a - lo) / (hi - lo), 0, 1)
    if job.get('largest', False):
        a = largest(a)
    if 'circle' in job:
        cx, cy, r = [v * K for v in job['circle']]
        yy, xx = np.mgrid[y0:y1, x0:x1]
        a = a * np.clip(r - np.hypot(xx - cx, yy - cy) + 0.5, 0, 1)
    rgba = np.dstack([crop, (a * 255).astype(np.uint8)])
    cv2.imwrite(f'{ROOT}/cut/{job["name"]}.png', cv2.cvtColor(rgba, cv2.COLOR_RGBA2BGRA))


if __name__ == '__main__':
    os.makedirs(f'{ROOT}/cut', exist_ok=True)
    jobs = json.load(open(sys.argv[1]))
    only = set(sys.argv[2:])
    for j in jobs:
        if only and j['name'] not in only:
            continue
        cut(j)
        print(j['name'], flush=True)
