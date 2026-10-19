import cv2
import numpy as np

ROOT = r'C:/Users/shame/AppData/Local/Temp/claude/C--Users-shame-Desktop-Flutter-ZeepalmLabs-Health-Components/34b754ed-f258-488c-8db8-ce495094cd25/scratchpad/orbit'
K = 3


def push_pull(img, hole):
    levels = []
    cur = img.astype(np.float32) * (1 - hole[..., None])
    w = 1 - hole.astype(np.float32)
    while min(cur.shape[:2]) > 4:
        levels.append((cur, w))
        cur = cv2.pyrDown(cur * 1.0)
        w = cv2.pyrDown(w)
        cur_n = cur.copy()
        cur = cur_n
    filled = cur / np.maximum(w[..., None], 1e-6)
    for c, ww in reversed(levels):
        up = cv2.resize(filled, (c.shape[1], c.shape[0]), interpolation=cv2.INTER_LINEAR)
        known = c / np.maximum(ww[..., None], 1e-6)
        a = np.clip(ww * 4, 0, 1)[..., None]
        filled = known * a + up * (1 - a)
    return filled


def harmonic(img, hole, iters=60):
    out = push_pull(img, hole)
    m = hole.astype(bool)
    for _ in range(iters):
        blur = cv2.blur(out, (3, 3))
        out[m] = blur[m]
    return out


def rect(mask, x0, y0, x1, y1, r=0):
    p = [int(round(v * K)) for v in (x0, y0, x1, y1)]
    if r:
        cv2.rectangle(mask, (p[0] + r * K, p[1]), (p[2] - r * K, p[3]), 1, -1)
        cv2.rectangle(mask, (p[0], p[1] + r * K), (p[2], p[3] - r * K), 1, -1)
        for cx, cy in ((p[0] + r * K, p[1] + r * K), (p[2] - r * K, p[1] + r * K), (p[0] + r * K, p[3] - r * K), (p[2] - r * K, p[3] - r * K)):
            cv2.circle(mask, (cx, cy), r * K, 1, -1)
    else:
        cv2.rectangle(mask, (p[0], p[1]), (p[2], p[3]), 1, -1)


def circle(mask, cx, cy, r):
    cv2.circle(mask, (int(cx * K), int(cy * K)), int(r * K), 1, -1)


def layer(mask, name, box, grow=4):
    a = cv2.imread(f'{ROOT}/cut/{name}.png', cv2.IMREAD_UNCHANGED)[:, :, 3]
    x0, y0 = int(round(box[0] * K)), int(round(box[1] * K))
    m = (a > 20).astype(np.uint8)
    m = cv2.dilate(m, np.ones((grow * 2 + 1, grow * 2 + 1), np.uint8))
    h, w = m.shape
    mask[y0:y0 + h, x0:x0 + w] |= m


def frame(mask, r=60, edge=3):
    h, w = mask.shape
    keep = np.zeros_like(mask)
    rect(keep, edge, edge, 402 - edge, 874 - edge, r)
    mask |= (1 - keep).astype(np.uint8)


def plate(screen, build, name, feather=6):
    img = cv2.imread(f'{ROOT}/s{screen}_hd.png').astype(np.float32)
    mask = np.zeros(img.shape[:2], np.uint8)
    build(mask)
    frame(mask)
    out = harmonic(img, mask)
    grain = np.random.default_rng(screen).normal(0, 2.2, img.shape).astype(np.float32)
    soft = cv2.GaussianBlur(mask.astype(np.float32), (0, 0), feather)[..., None]
    result = img * (1 - soft) + (out + grain * soft) * soft
    cv2.imwrite(f'{ROOT}/plate/{name}.png', np.clip(result, 0, 255).astype(np.uint8))
    cv2.imwrite(f'{ROOT}/plate/{name}_mask.png', mask * 255)


def s0(m):
    rect(m, 0, 0, 402, 52)
    layer(m, 'logo', (25, 70), 16)
    cv2.ellipse(m, (int(200 * K), int(208 * K)), (int(150 * K), int(14 * K)), -4, 0, 360, 1, -1)
    rect(m, 40, 238, 365, 270)
    layer(m, 'egg', (40, 285), 6)
    layer(m, 'sun', (262, 295), 6)
    rect(m, 52, 722, 352, 804, 30)


def s1(m):
    rect(m, 0, 0, 402, 54)
    rect(m, 12, 56, 395, 140)
    layer(m, 'buddy', (0, 148), 6)
    rect(m, 102, 158, 308, 232, 20)
    layer(m, 'planet', (0, 225), 8)
    rect(m, 236, 228, 380, 302)
    rect(m, 30, 690, 375, 815)
    rect(m, 100, 812, 300, 850)


def s2(m):
    rect(m, 0, 0, 402, 48)
    rect(m, 85, 40, 320, 138)
    rect(m, 16, 140, 388, 218, 30)
    rect(m, 188, 228, 345, 282, 20)
    layer(m, 'runner', (90, 415), 6)
    for cx, cy, r in ((248, 601, 24), (250, 532, 19), (232, 466, 16), (278, 451, 14), (259, 413, 12), (230, 395, 12), (270, 360, 9)):
        circle(m, cx, cy, r)
    rect(m, 20, 755, 360, 845)


def s3(m):
    rect(m, 0, 0, 402, 50)
    rect(m, 340, 50, 388, 95)
    for b in ((28, 72, 125, 112), (272, 112, 370, 152), (152, 200, 236, 264), (22, 422, 110, 462), (298, 396, 385, 437)):
        rect(m, *b)
    for name, box in (('p_luna', (12, 105)), ('p_zane', (258, 145)), ('p_you', (75, 195)), ('p_kai', (12, 438)), ('p_maya', (268, 428))):
        layer(m, name, box, 6)
    rect(m, 10, 556, 395, 855)


if __name__ == '__main__':
    import os
    os.makedirs(f'{ROOT}/plate', exist_ok=True)
    for i, (fn, name) in enumerate(((s0, 'splash'), (s1, 'world'), (s2, 'run'), (s3, 'race'))):
        plate(i, fn, name)
        print(name, flush=True)
