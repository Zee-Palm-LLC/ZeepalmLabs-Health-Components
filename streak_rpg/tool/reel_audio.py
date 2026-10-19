"""Synthesizes the soundtrack for a StreakRPG reel: an original heroic synth bed
(D minor, 120 BPM) plus sound effects locked to the reel's taps and bursts.

  python reel_audio.py app out.wav
  python reel_audio.py tutorial out.wav
"""
import sys
import wave

import numpy as np

SR = 44100
BPM = 120.0
BEAT = 60.0 / BPM
BAR = BEAT * 4
rng = np.random.default_rng(11)

# Dm - Bb - F - C: (bass root, chord voicing)
CHORDS = [
    (38, [62, 65, 69, 74]),
    (34, [62, 65, 70, 74]),
    (41, [60, 65, 69, 72]),
    (36, [60, 64, 67, 72]),
]

REELS = {
    'app': dict(length=32.0, outro=28.6, lockup=28.95, groove=1.2, drums=3.6, hats=9.5),
    'tutorial': dict(length=34.5, outro=31.3, lockup=31.65, groove=1.2, drums=2.9, hats=7.0),
}


def midi(m):
    return 440.0 * 2 ** ((m - 69) / 12)


class Mix:
    def __init__(self, length):
        self.n = int(SR * length)

    def track(self):
        return np.zeros(self.n)

    def place(self, buf, start, sig, gain=1.0):
        i = int(start * SR)
        if i >= self.n or i < 0:
            return
        j = min(self.n, i + len(sig))
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


def saw(freq, dur, attack=0.01, decay=None, release=0.08, voices=3, spread=0.12):
    n = int(dur * SR)
    t = np.arange(n) / SR
    sig = np.zeros(n)
    for v in range(voices):
        f = freq * 2 ** ((v - (voices - 1) / 2) * spread / 12)
        ph = (t * f + rng.random()) % 1
        sig += 2 * ph - 1
    sig /= voices
    env = np.minimum(1, t / max(attack, 1e-4))
    if decay:
        env *= np.exp(-t / decay)
    return sig * env * np.clip((dur - t) / release, 0, 1)


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


def music(mx, cfg):
    groove, outro, lockup = cfg['groove'], cfg['outro'], cfg['lockup']

    def chord_at(t):
        k = int(max(0, t - groove) // BAR) % len(CHORDS)
        return CHORDS[k]

    pad, arp, bass, lead, drums = mx.track(), mx.track(), mx.track(), mx.track(), mx.track()
    t = 0.0
    while t < lockup:
        root, notes = chord_at(t + 0.01)
        dur = BAR if t >= groove else groove
        for m in notes:
            mx.place(pad, t, saw(midi(m - 12), dur + 0.5, attack=0.4, release=0.5), 0.035)
        t += dur
    pad = band(pad, 90, 2600)

    # Plucked arpeggio in 16ths.
    step = BEAT / 4
    t, i = groove, 0
    while t < outro - 0.05:
        _, notes = chord_at(t + 0.01)
        pattern = [0, 2, 3, 1, 2, 3, 0, 2]
        m = notes[pattern[i % 8]] + (12 if (i // 8) % 4 == 3 else 0)
        accent = 1.0 if i % 4 == 0 else 0.6
        mx.place(arp, t, tone(midi(m), 0.32, ((1, 1), (2, 0.4), (3, 0.18), (5, 0.06)), attack=0.002, decay=0.11), 0.075 * accent)
        t += step
        i += 1

    # Driving octave bass in 8ths after the drums arrive.
    t = cfg['drums']
    t = groove + np.ceil((t - groove) / BEAT) * BEAT
    j = 0
    while t < outro - 0.05:
        root, _ = chord_at(t + 0.01)
        m = root + (12 if j % 2 else 0)
        mx.place(bass, t, tone(midi(m), BEAT / 2 * 0.9, ((1, 1), (2, 0.5), (3, 0.2)), attack=0.004, decay=0.22), 0.2)
        t += BEAT / 2
        j += 1

    # A heroic lead line once the hats come in: the chord's top note, held.
    t = groove + np.ceil((cfg['hats'] - groove) / BAR) * BAR
    phrase = [0, 3, 2, 1]
    k = 0
    while t < outro - BAR * 0.5:
        _, notes = chord_at(t + 0.01)
        m = notes[phrase[k % 4]] + 12
        mx.place(lead, t, saw(midi(m), BAR * 0.9, attack=0.05, decay=1.6, release=0.3, voices=2, spread=0.08), 0.03)
        t += BAR
        k += 1
    lead = band(lead, 300, 4200)

    def kick():
        n = int(0.4 * SR)
        tt = np.arange(n) / SR
        f = 46 + 120 * np.exp(-tt * 28)
        return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-tt * 8)

    def clap():
        n = band(noise(0.24), 900, 6500)
        tt = np.arange(len(n)) / SR
        return n * (np.exp(-tt * 20) + 0.6 * np.exp(-np.abs(tt - 0.012) * 300))

    def hat(open_=False):
        n = band(noise(0.25 if open_ else 0.06), 7000, 16000)
        tt = np.arange(len(n)) / SR
        return n * np.exp(-tt * (13 if open_ else 70))

    b = int(np.ceil((cfg['drums'] - groove) / BEAT))
    while True:
        t = groove + b * BEAT
        if t >= outro:
            break
        k = b % 4
        mx.place(drums, t, kick(), 0.5 if k in (0, 2) else 0.0)
        if k in (1, 3):
            mx.place(drums, t, clap(), 0.15)
        if t >= cfg['hats']:
            mx.place(drums, t + BEAT / 2, hat(), 0.06)
            mx.place(drums, t + BEAT / 4, hat(), 0.025)
            mx.place(drums, t + BEAT * 3 / 4, hat(), 0.025)
            if k == 3:
                mx.place(drums, t + BEAT / 2, hat(True), 0.05)
        b += 1
    return pad + arp + bass + lead + drums


class Sfx:
    def __init__(self, mx):
        self.mx = mx
        self.out = mx.track()

    def click(self, t, g=0.16, pitch=1900):
        sig = tone(pitch, 0.06, ((1, 1), (2.3, 0.3)), attack=0.001, decay=0.012)
        self.mx.place(self.out, t, sig, g)

    def pop(self, t, g=0.18, f=560):
        n = int(0.18 * SR)
        tt = np.arange(n) / SR
        freq = f * (1 + 0.9 * np.exp(-tt * 40))
        self.mx.place(self.out, t, np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.exp(-tt * 18), g)

    def whoosh(self, t, dur, g=0.16, up=True):
        n = noise(dur)
        tt = np.arange(len(n)) / dur / SR
        env = np.sin(np.pi * np.clip(tt, 0, 1)) ** 2
        lo, hi = band(n, 300, 1600), band(n, 1500, 7000)
        w = tt if up else 1 - tt
        self.mx.place(self.out, t, (lo * (1 - w) + hi * w) * env, g)

    def riser(self, t, dur, g=0.1):
        n = int(dur * SR)
        tt = np.arange(n) / SR
        f = 200 * 2 ** (tt / dur * 3)
        sig = np.sin(2 * np.pi * np.cumsum(f) / SR) * (tt / dur) ** 2
        self.mx.place(self.out, t, sig + band(noise(dur), 2000, 9000) * (tt / dur) ** 3 * 0.5, g)

    def chime(self, t, notes, g=0.08, gap=0.06):
        for i, m in enumerate(notes):
            self.mx.place(self.out, t + i * gap, tone(midi(m), 1.6, ((1, 1), (2.76, 0.4), (5.4, 0.15)), attack=0.002, decay=0.55), g)

    def thud(self, t, g=0.3):
        n = int(0.35 * SR)
        tt = np.arange(n) / SR
        self.mx.place(self.out, t, np.sin(2 * np.pi * np.cumsum(70 + 140 * np.exp(-tt * 22)) / SR) * np.exp(-tt * 10), g)

    def boom(self, t, g=0.45):
        self.thud(t, g)
        self.mx.place(self.out, t, band(noise(1.4), 40, 900) * np.exp(-np.arange(int(1.4 * SR)) / SR * 3.5), g * 0.35)

    def ticks(self, t0, t1, every, g=0.03, pitch=2600):
        t = t0
        while t < t1:
            self.click(t, g, pitch)
            t += every

    def boing(self, t, g=0.14):
        n = int(0.4 * SR)
        tt = np.arange(n) / SR
        freq = 330 + 140 * np.sin(tt * 38) * np.exp(-tt * 6) + 160 * tt
        self.mx.place(self.out, t, np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.exp(-tt * 7), g)

    def burst(self, t, g=0.1):
        self.pop(t, g * 1.4, 760)
        self.chime(t + 0.04, [81, 86, 88, 93], g, 0.045)
        self.mx.place(self.out, t, band(noise(0.5), 4000, 14000) * np.exp(-np.arange(int(0.5 * SR)) / SR * 7), g * 0.5)

    def portal(self, t):
        self.whoosh(t, 1.2, 0.18)
        self.riser(t, 1.1, 0.06)
        self.chime(t + 0.9, [74, 77, 81, 86], 0.06, 0.05)

    def warp(self, t):
        self.whoosh(t, 0.9, 0.2)
        self.riser(t - 0.1, 0.5, 0.07)
        self.boom(t + 0.35, 0.25)

    def rep(self, t):
        self.thud(t, 0.18)
        self.click(t, 0.05, 1200)

    def banner(self, t):
        self.whoosh(t, 0.6, 0.18)
        self.boom(t + 0.22, 0.35)
        self.chime(t + 0.3, [74, 81, 86], 0.06, 0.04)

    def step(self, t, typing=1.6):
        self.chime(t, [86, 93], 0.045, 0.05)
        self.whoosh(t - 0.05, 0.35, 0.06)
        self.ticks(t + 0.25, t + 0.25 + typing, 0.055, 0.012, 3200)


def app_sfx(s):
    s.whoosh(0.05, 1.0, 0.12)
    s.boom(0.55, 0.4)
    s.chime(0.6, [74, 81, 86], 0.06, 0.04)
    s.boing(1.35, 0.1)
    s.chime(1.4, [86, 90, 93], 0.06, 0.05)
    s.click(3.6)
    s.portal(3.65)
    for k in range(4):
        s.pop(4.95 + k * 0.28, 0.1, 600 + k * 140)
    s.burst(6.0, 0.09)
    for t in (6.1, 7.6):
        s.rep(t)
    s.click(8.4)
    s.warp(8.45)
    s.riser(9.7, 1.1, 0.07)
    s.thud(10.9, 0.3)
    s.click(12.9)
    s.ticks(12.95, 13.8, 0.06, 0.03, 2400)
    s.burst(13.8, 0.11)
    s.click(14.6)
    s.warp(14.65)
    for t in (17.85, 19.55, 21.25, 22.95):
        s.rep(t)
    s.click(20.6)
    s.whoosh(20.65, 0.9, 0.08)
    s.burst(21.7, 0.12)
    s.click(23.4)
    s.whoosh(23.45, 0.7, 0.14, up=False)
    s.click(24.4)
    s.boing(24.5, 0.14)
    s.click(26.4)
    s.burst(26.45, 0.11)
    s.whoosh(28.6, 0.8, 0.16, up=False)


def tutorial_sfx(s):
    s.whoosh(0.05, 1.0, 0.12)
    s.riser(0.3, 1.0, 0.06)
    s.thud(1.35, 0.28)
    s.banner(2.9)
    s.step(4.6, 1.8)
    for t in (7.0, 9.2, 11.4, 13.4, 15.4):
        s.click(t)
        s.step(t + 0.05)
    s.click(17.6)
    s.ticks(17.65, 18.5, 0.06, 0.03, 2400)
    s.burst(18.5, 0.11)
    s.step(17.9)
    s.click(20.1)
    s.step(20.15)
    s.click(22.3)
    s.banner(22.4)
    s.chime(22.7, [62, 69, 74, 78, 81, 86], 0.07, 0.06)
    s.warp(22.5)
    s.banner(25.9)
    s.step(27.6, 1.6)
    s.click(29.8)
    s.step(29.85, 1.0)
    for t in (27.3, 29.0, 30.7):
        s.rep(t)
    s.whoosh(31.3, 0.8, 0.16, up=False)


def main(name, path):
    cfg = REELS[name]
    mx = Mix(cfg['length'])
    bed = reverb(music(mx, cfg), 1.6, 0.2)
    s = Sfx(mx)
    (app_sfx if name == 'app' else tutorial_sfx)(s)
    s.boom(cfg['lockup'], 0.5)
    s.chime(cfg['lockup'] + 0.15, [62, 65, 69, 74, 77, 81, 86], 0.08, 0.07)
    fx = reverb(s.out, 1.0, 0.15)
    end = mx.track()
    for m in (38, 50, 57, 62, 65, 69, 74, 77):
        mx.place(end, cfg['lockup'], tone(midi(m), cfg['length'] - cfg['lockup'], ((1, 1), (2, 0.3), (3, 0.1)), attack=0.02, decay=1.6, release=0.6), 0.07)
    end = reverb(end, 2.2, 0.35)
    t = np.arange(mx.n) / SR
    left = bed * 0.85 + fx + end
    right = bed * 0.85 + fx + end
    width = 0.08 * np.sin(2 * np.pi * t * 0.13)
    left *= 1 + width
    right *= 1 - width
    fade = np.clip((cfg['length'] - t) / 0.8, 0, 1) * np.clip(t / 0.05, 0, 1)
    stereo = np.stack([left * fade, right * fade], 1)
    stereo /= np.abs(stereo).max() / 0.89
    with wave.open(path, 'wb') as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((stereo * 32767).astype(np.int16).tobytes())


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
