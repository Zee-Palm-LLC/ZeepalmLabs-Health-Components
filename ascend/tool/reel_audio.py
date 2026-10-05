import sys
import wave

import numpy as np

SR = 44100
LENGTH = 30.0
BPM = 118.0
BEAT = 60.0 / BPM
BAR = BEAT * 4
N = int(SR * LENGTH)
rng = np.random.default_rng(7)


def midi(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def track():
    return np.zeros(N)


def place(buf, start, sig, gain=1.0):
    i = int(start * SR)
    if i >= N:
        return
    j = min(N, i + len(sig))
    buf[i:j] += sig[: j - i] * gain


def tone(freq, dur, partials=((1, 1.0),), attack=0.005, decay=None, release=0.05):
    n = int(dur * SR)
    t = np.arange(n) / SR
    sig = sum(a * np.sin(2 * np.pi * freq * k * t) for k, a in partials)
    env = np.minimum(1, t / max(attack, 1e-4))
    if decay:
        env *= np.exp(-t / decay)
    tail = np.clip((dur - t) / release, 0, 1)
    return sig * env * tail


def noise(dur):
    return rng.standard_normal(int(dur * SR))


def band(sig, lo, hi):
    spec = np.fft.rfft(sig)
    f = np.fft.rfftfreq(len(sig), 1 / SR)
    mask = np.clip((f - lo * 0.7) / (lo * 0.3 + 1e-9), 0, 1) if lo > 0 else np.ones_like(f)
    mask *= 1 / (1 + (f / hi) ** 4)
    return np.fft.irfft(spec * mask, len(sig))


def reverb(sig, seconds=1.8, mix=0.25):
    m = int(seconds * SR)
    t = np.arange(m) / SR
    ir = rng.standard_normal(m) * np.exp(-t * 3.2)
    ir = band(ir, 200, 7000)
    ir /= np.sqrt((ir ** 2).sum())
    size = 1 << int(np.ceil(np.log2(len(sig) + m)))
    wet = np.fft.irfft(np.fft.rfft(sig, size) * np.fft.rfft(ir, size), size)[: len(sig)]
    return sig * (1 - mix) + wet * mix * 1.6


CHORDS = [
    (38, [62, 65, 69, 72]),
    (46, [62, 65, 70, 74]),
    (41, [60, 65, 69, 72]),
    (45, [61, 64, 69, 73]),
]
GROOVE = 1.15
OUTRO = 27.7
LOCKUP = 28.05


def chord_at(t):
    k = int(max(0, t - GROOVE) // BAR) % len(CHORDS)
    return CHORDS[k]


def music():
    pad, arp, bass, drums = track(), track(), track(), track()
    t = 0.0
    while t < LOCKUP:
        root, notes = chord_at(t + 0.01)
        dur = BAR if t >= GROOVE else GROOVE
        for m in notes:
            for detune in (-0.12, 0.12):
                place(pad, t, tone(midi(m - 12) * 2 ** (detune / 12), dur + 0.4, ((1, 1), (2, 0.35), (3, 0.15)), attack=0.35, release=0.4), 0.05)
        t += dur
    pad = band(pad, 80, 2200)

    step = BEAT / 2
    t = GROOVE
    i = 0
    while t < OUTRO - 0.05:
        root, notes = chord_at(t + 0.01)
        pattern = [0, 2, 1, 3, 2, 1, 3, 2]
        m = notes[pattern[i % 8]] + (12 if i % 16 >= 12 else 0)
        accent = 1.0 if i % 2 == 0 else 0.7
        place(arp, t, tone(midi(m), 0.5, ((1, 1), (4, 0.25), (9.2, 0.06)), attack=0.002, decay=0.16), 0.11 * accent)
        t += step
        i += 1

    t = GROOVE + BAR
    j = 0
    while t < OUTRO - 0.05:
        root, _ = chord_at(t + 0.01)
        for off, length in ((0, 0.9), (1.5, 0.4), (2, 0.9), (3.5, 0.4)):
            start = t + off * BEAT
            if start < OUTRO:
                place(bass, start, tone(midi(root - 12), length * BEAT, ((1, 1), (2, 0.25)), attack=0.008, decay=0.5), 0.2)
        t += BAR
        j += 1

    def kick():
        n = int(0.35 * SR)
        tt = np.arange(n) / SR
        f = 48 + 110 * np.exp(-tt * 30)
        return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-tt * 9)

    def clap():
        n = band(noise(0.22), 900, 6000)
        tt = np.arange(len(n)) / SR
        return n * (np.exp(-tt * 22) + 0.6 * np.exp(-np.abs(tt - 0.012) * 300))

    def hat(open_=False):
        n = band(noise(0.25 if open_ else 0.06), 7000, 16000)
        tt = np.arange(len(n)) / SR
        return n * np.exp(-tt * (14 if open_ else 70))

    beat_start = 5.7
    b = int(np.ceil((beat_start - GROOVE) / BEAT))
    while True:
        t = GROOVE + b * BEAT
        if t >= OUTRO:
            break
        k = b % 4
        if k in (0, 2):
            place(drums, t, kick(), 0.5)
        if k in (1, 3):
            place(drums, t, clap(), 0.16)
        if t >= 11.4:
            place(drums, t + BEAT / 2, hat(), 0.07)
            place(drums, t, hat(), 0.035)
        b += 1
    k = kick()
    for t in (11.4 - 0.02, 18.1 - 0.02, 23.5 - 0.02):
        place(drums, t, k, 0.3)

    mix = pad + arp + bass + drums
    return mix


def sfx():
    out = track()

    def click(t, g=0.18, pitch=1800):
        sig = tone(pitch, 0.06, ((1, 1), (2.3, 0.3)), attack=0.001, decay=0.012)
        grit = band(noise(0.03), 2000, 9000) * np.exp(-np.arange(int(0.03 * SR)) / SR * 140) * 0.3
        sig[: len(grit)] += grit
        place(out, t, sig, g)

    def pop(t, g=0.2, f=520):
        n = int(0.18 * SR)
        tt = np.arange(n) / SR
        freq = f * (1 + 0.9 * np.exp(-tt * 40))
        place(out, t, np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.exp(-tt * 18), g)

    def whoosh(t, dur, g=0.16, up=True):
        n = noise(dur)
        tt = np.arange(len(n)) / dur / SR
        env = np.sin(np.pi * np.clip(tt, 0, 1)) ** 2
        lo = band(n, 300, 1600)
        hi = band(n, 1500, 6000)
        mixw = tt if up else 1 - tt
        place(out, t, (lo * (1 - mixw) + hi * mixw) * env, g)

    def chime(t, notes, g=0.09, gap=0.06):
        for i, m in enumerate(notes):
            place(out, t + i * gap, tone(midi(m), 1.6, ((1, 1), (2.76, 0.4), (5.4, 0.15)), attack=0.002, decay=0.55), g)

    def shutter(t):
        place(out, t, band(noise(0.05), 1200, 9000) * np.exp(-np.arange(int(0.05 * SR)) / SR * 90), 0.45)
        place(out, t + 0.09, band(noise(0.06), 800, 6000) * np.exp(-np.arange(int(0.06 * SR)) / SR * 70), 0.35)

    def boing(t, g=0.18):
        n = int(0.4 * SR)
        tt = np.arange(n) / SR
        freq = 330 + 140 * np.sin(tt * 38) * np.exp(-tt * 6) + 120 * tt
        place(out, t, np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.exp(-tt * 7), g)

    def ticks(t0, t1, every, g=0.05, pitch=2600):
        t = t0
        while t < t1:
            click(t, g, pitch)
            t += every

    def thud(t, g=0.3):
        n = int(0.25 * SR)
        tt = np.arange(n) / SR
        place(out, t, np.sin(2 * np.pi * np.cumsum(90 + 120 * np.exp(-tt * 25)) / SR) * np.exp(-tt * 14), g)

    for t in [5.6, 11.4, 15.4, 18.1, 20.7, 23.5, 25.6]:
        click(t)

    def level(t0):
        whoosh(t0 + 0.1, 0.8, 0.12)
        ticks(t0 + 0.2, t0 + 1.3, 0.05, 0.03, 2400)
        whoosh(t0 + 0.3, 0.5, 0.12)
        thud(t0 + 0.75, 0.2)
        pop(t0 + 1.55, 0.12, 900)
        chime(t0 + 1.95, [86, 90, 93], 0.05, 0.04)

    def streak(t0):
        whoosh(t0 + 0.03, 0.55, 0.16, up=False)
        whoosh(t0 + 0.1, 0.7, 0.14)
        ticks(t0 + 0.25, t0 + 1.2, 0.04, 0.03, 2800)
        thud(t0 + 0.75, 0.26)
        chime(t0 + 1.25, [74, 78, 81, 86], 0.09)
        pop(t0 + 1.45, 0.12, 620)
        boing(t0 + 1.55, 0.08)

    def crew(t0):
        whoosh(t0 + 0.03, 0.55, 0.16, up=False)
        for k, d in enumerate((0.25, 0.45, 0.6)):
            pop(t0 + d, 0.1, 380 + k * 120)
        for k, d in enumerate((0.75, 0.9, 1.05)):
            boing(t0 + d, 0.12)
        chime(t0 + 1.25, [69, 74, 78, 81, 86], 0.08, 0.05)

    whoosh(0.05, 1.0, 0.12)
    level(0.15)
    streak(5.6)
    crew(11.4)
    chime(15.5, [81, 86, 90], 0.08, 0.06)
    whoosh(18.12, 0.5, 0.14)
    streak(18.1)
    whoosh(20.72, 0.5, 0.14)
    level(20.7)
    streak(23.5)
    crew(25.6)
    whoosh(OUTRO, 0.8, 0.16, up=False)
    boing(LOCKUP + 0.15, 0.2)
    chime(LOCKUP + 0.2, [62, 65, 69, 74, 77, 81, 86], 0.08, 0.07)
    return out


def ending():
    out = track()
    for m in (38, 50, 57, 62, 65, 69, 74, 77):
        place(out, LOCKUP, tone(midi(m), LENGTH - LOCKUP, ((1, 1), (2, 0.3), (3, 0.1)), attack=0.02, decay=1.4, release=0.6), 0.07)
    return out


def main(path):
    bed = music()
    bed = reverb(bed, 1.6, 0.2)
    fx = reverb(sfx(), 1.0, 0.15)
    end = reverb(ending(), 2.2, 0.35)
    left = bed * 0.9 + fx + end
    right = bed * 0.9 + fx + end
    t = np.arange(N) / SR
    width = 0.08 * np.sin(2 * np.pi * t * 0.13)
    left *= 1 + width
    right *= 1 - width
    fade = np.clip((LENGTH - t) / 0.8, 0, 1) * np.clip(t / 0.05, 0, 1)
    stereo = np.stack([left * fade, right * fade], 1)
    stereo /= np.abs(stereo).max() / 0.89
    data = (stereo * 32767).astype(np.int16)
    with wave.open(path, 'wb') as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())


if __name__ == '__main__':
    main(sys.argv[1])
