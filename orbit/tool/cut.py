import json
import sys

import cv2
import numpy as np
import onnxruntime as ort

ROOT = r'C:/Users/shame/AppData/Local/Temp/claude/C--Users-shame-Desktop-Flutter-ZeepalmLabs-Health-Components/34b754ed-f258-488c-8db8-ce495094cd25/scratchpad/orbit'
MODEL = r'C:/Users/shame/.u2net/isnet-general-use.onnx'
K = 3

session = ort.InferenceSession(MODEL, providers=['CPUExecutionProvider'])


def segment(rgb):
    h, w = rgb.shape[:2]
    side = max(h, w)
    pad = np.zeros((side, side, 3), np.uint8)
    pad[(side - h) // 2:(side - h) // 2 + h, (side - w) // 2:(side - w) // 2 + w] = rgb
    x = cv2.resize(pad, (1024, 1024), interpolation=cv2.INTER_AREA).astype(np.float32) / 255.0
    x = (x - np.array([0.485, 0.456, 0.406], np.float32)) / np.array([1.0, 1.0, 1.0], np.float32)
    x = x.transpose(2, 0, 1)[None]
    y = session.run(None, {session.get_inputs()[0].name: x})[0][0, 0]
    y = (y - y.min()) / max(1e-6, y.max() - y.min())
    y = cv2.resize(y, (side, side), interpolation=cv2.INTER_CUBIC)
    return y[(side - h) // 2:(side - h) // 2 + h, (side - w) // 2:(side - w) // 2 + w]


def refine(rgb, alpha):
    try:
        guide = cv2.cvtColor(rgb, cv2.COLOR_RGB2GRAY)
        return np.clip(cv2.ximgproc.guidedFilter(guide, (alpha * 255).astype(np.uint8), 6, 60).astype(np.float32) / 255.0, 0, 1)
    except AttributeError:
        return alpha


def cut(screen, name, box, threshold=(0.25, 0.75), keep_largest=False):
    img = cv2.imread(f'{ROOT}/s{screen}_hd.png')[:, :, ::-1]
    x0, y0, x1, y1 = [int(round(v * K)) for v in box]
    crop = np.ascontiguousarray(img[y0:y1, x0:x1])
    a = segment(crop)
    a = refine(crop, a)
    lo, hi = threshold
    a = np.clip((a - lo) / (hi - lo), 0, 1)
    if keep_largest:
        m = (a > 0.5).astype(np.uint8)
        n, lab, stats, _ = cv2.connectedComponentsWithStats(m)
        if n > 1:
            big = 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])
            keep = cv2.dilate((lab == big).astype(np.uint8), np.ones((9, 9), np.uint8))
            a = a * keep
    rgba = np.dstack([crop, (a * 255).astype(np.uint8)])
    cv2.imwrite(f'{ROOT}/cut/{name}.png', cv2.cvtColor(rgba, cv2.COLOR_RGBA2BGRA))
    return a


if __name__ == '__main__':
    import os
    os.makedirs(f'{ROOT}/cut', exist_ok=True)
    jobs = json.load(open(sys.argv[1]))
    for j in jobs:
        cut(j['screen'], j['name'], j['box'], tuple(j.get('t', (0.25, 0.75))), j.get('largest', False))
        print(j['name'], flush=True)
