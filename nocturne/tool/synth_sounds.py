import io
import os
import wave

import numpy as np

RATE = 22050
SECONDS = 16
N = RATE * SECONDS
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
rng = np.random.default_rng(7)
freqs = np.fft.rfftfreq(N, 1 / RATE)
t = np.arange(N) / RATE


def shaped_noise(gain_fn):
    spectrum = np.fft.rfft(rng.standard_normal(N))
    g = gain_fn(np.maximum(freqs, 1.0))
    return np.fft.irfft(spectrum * g, N)


def band(lo, hi, slope=2.0):
    def g(f):
        low = 1 / (1 + (lo / f) ** (2 * slope))
        high = 1 / (1 + (f / hi) ** (2 * slope))
        return np.sqrt(low * high)
    return g


def pink(f):
    return 1 / np.sqrt(f)


def brown(f):
    return 1 / f


def norm(x):
    return x / (np.sqrt(np.mean(x ** 2)) + 1e-9)


def lfo(cycles, phase=0.0):
    return 0.5 + 0.5 * np.sin(2 * np.pi * cycles * t / SECONDS + phase)


def place(signal, grain, at):
    n = len(grain)
    idx = (np.arange(n) + at) % N
    np.add.at(signal, idx, grain)


def filtered(x, gain_fn):
    return np.fft.irfft(np.fft.rfft(x) * gain_fn(np.maximum(freqs, 1.0)), N)


def rain():
    bed = norm(shaped_noise(lambda f: pink(f) * band(400, 9000)(f)))
    drops = np.zeros(N)
    for _ in range(2600):
        n = int(rng.uniform(0.002, 0.012) * RATE)
        env = np.exp(-np.linspace(0, 6, n))
        grain = rng.standard_normal(n) * env * rng.uniform(0.2, 1.0) ** 2
        place(drops, grain, int(rng.integers(0, N)))
    drops = norm(filtered(drops, band(1500, 7000)))
    swell = 0.85 + 0.15 * lfo(2)
    return (bed * 0.8 + drops * 0.35) * swell


def waves():
    body = norm(shaped_noise(lambda f: brown(f) ** 0.7 * band(60, 900)(f)))
    hiss = norm(shaped_noise(lambda f: band(1200, 6000)(f)))
    swell = np.zeros(N)
    for k, off in enumerate([0.0, 0.33, 0.61, 0.84]):
        centre = off * N
        d = (np.arange(N) - centre + N / 2) % N - N / 2
        width = RATE * rng.uniform(2.2, 3.0)
        rise = np.exp(-(np.maximum(-d, 0) / width) ** 2 * 1.4)
        fall = np.exp(-(np.maximum(d, 0) / (width * 1.6)) ** 2)
        swell += rise * fall * (0.8 + 0.2 * k % 2)
    swell = swell / swell.max()
    return body * (0.25 + 0.75 * swell) + hiss * 0.28 * swell ** 2


def fire():
    rumble = norm(shaped_noise(lambda f: brown(f) * band(30, 400)(f)))
    hiss = norm(shaped_noise(lambda f: band(2000, 8000)(f))) * 0.06
    crackle = np.zeros(N)
    for _ in range(900):
        n = int(rng.uniform(0.001, 0.006) * RATE)
        env = np.exp(-np.linspace(0, 8, n))
        grain = rng.standard_normal(n) * env * rng.pareto(2.5) * 0.4
        place(crackle, grain, int(rng.integers(0, N)))
    for _ in range(40):
        n = int(0.03 * RATE)
        env = np.exp(-np.linspace(0, 5, n))
        grain = rng.standard_normal(n) * env * rng.uniform(1.5, 3.0)
        place(crackle, grain, int(rng.integers(0, N)))
    crackle = norm(filtered(crackle, band(900, 6000)))
    flicker = 0.8 + 0.2 * lfo(3, 1.0) * lfo(5, 2.0)
    return rumble * 0.55 * flicker + crackle * 0.45 + hiss


def wind():
    out = np.zeros(N)
    for lo, hi, cyc, ph, amp in [(150, 500, 1, 0.0, 1.0), (300, 900, 2, 1.7, 0.7),
                                 (600, 1600, 3, 3.1, 0.45), (80, 260, 1, 4.2, 0.8)]:
        layer = norm(shaped_noise(band(lo, hi, 3.0)))
        out += layer * amp * (0.15 + 0.85 * lfo(cyc, ph) ** 2)
    return out


def chirp_bird(dur, f0, f1):
    n = int(dur * RATE)
    tt = np.arange(n) / RATE
    f = np.linspace(f0, f1, n)
    ph = 2 * np.pi * np.cumsum(f) / RATE
    env = np.sin(np.pi * tt / dur) ** 2
    return (np.sin(ph) + 0.25 * np.sin(2 * ph)) * env


def forest():
    rustle = norm(shaped_noise(lambda f: pink(f) * band(300, 5000)(f)))
    rustle *= 0.35 + 0.65 * lfo(2, 0.5) * lfo(3, 2.0)
    birds = np.zeros(N)
    for _ in range(14):
        start = int(rng.integers(0, N))
        base = rng.uniform(2200, 4200)
        for k in range(int(rng.integers(2, 5))):
            g = chirp_bird(rng.uniform(0.07, 0.16), base * rng.uniform(0.9, 1.1), base * rng.uniform(1.1, 1.5))
            place(birds, g * rng.uniform(0.4, 1.0), start + int(k * 0.18 * RATE))
    return rustle * 0.6 + norm(birds) * 0.22


def cricket_voice(rate_hz, carrier, pulses, gap):
    out = np.zeros(N)
    period = int(RATE / rate_hz)
    pulse_len = int(0.012 * RATE)
    tt = np.arange(pulse_len) / RATE
    env = np.sin(np.pi * tt / tt[-1]) ** 2
    tone = np.sin(2 * np.pi * carrier * tt) * env
    pos = int(rng.integers(0, period))
    while pos < N + period:
        for k in range(pulses):
            place(out, tone, pos + k * int(gap * RATE))
        pos += period
    return out


def crickets():
    out = np.zeros(N)
    for rate_hz, carrier, pulses, amp in [(1.6, 4600, 3, 1.0), (1.25, 4200, 4, 0.6), (2.1, 5100, 2, 0.45),
                                          (0.9, 3900, 5, 0.35)]:
        out += cricket_voice(rate_hz, carrier, pulses, 0.022) * amp
    air = norm(shaped_noise(lambda f: pink(f) * band(200, 3000)(f))) * 0.08
    return norm(out) * 0.5 + air


def night():
    drone = np.zeros(N)
    for f, a in [(55, 0.5), (82.5, 0.35), (110.3, 0.25), (164.7, 0.12), (220.4, 0.06)]:
        cyc = round(f * SECONDS) / SECONDS
        drone += a * np.sin(2 * np.pi * cyc * t) * (0.6 + 0.4 * lfo(1 + int(f) % 3, f))
    air = norm(shaped_noise(lambda f: pink(f) * band(100, 2500)(f))) * 0.25
    far = norm(sum(cricket_voice(r, c, 3, 0.02) for r, c in [(1.1, 4300), (1.5, 4800)])) * 0.08
    return norm(drone) * 0.55 + air + far


def stream():
    bed = norm(shaped_noise(lambda f: pink(f) * band(250, 4000)(f)))
    bubbles = np.zeros(N)
    for _ in range(1400):
        dur = rng.uniform(0.01, 0.04)
        n = int(dur * RATE)
        tt = np.arange(n) / RATE
        f0 = rng.uniform(500, 1800)
        f = f0 * (1 + 1.5 * tt / dur)
        ph = 2 * np.pi * np.cumsum(f) / RATE
        env = np.exp(-tt / (dur * 0.35))
        place(bubbles, np.sin(ph) * env * rng.uniform(0.1, 1.0), int(rng.integers(0, N)))
    return bed * (0.7 + 0.3 * lfo(3, 0.3)) * 0.6 + norm(bubbles) * 0.3


def thunder():
    rain_bed = norm(shaped_noise(lambda f: pink(f) * band(500, 7000)(f))) * 0.35
    rumble = np.zeros(N)
    for start in (0.12, 0.62):
        n = int(6.5 * RATE)
        tt = np.arange(n) / RATE
        env = (1 - np.exp(-tt * 9)) * np.exp(-tt * 0.55) * (0.7 + 0.3 * np.sin(tt * 5.1) * np.sin(tt * 2.3))
        grain = rng.standard_normal(n) * env
        place(rumble, grain, int(start * N))
    rumble = norm(filtered(rumble, lambda f: brown(f) ** 0.8 * band(25, 240)(f)))
    return rain_bed + rumble * 0.75


def write(name, x):
    x = x - x.mean()
    x = x / (np.sqrt(np.mean(x ** 2)) + 1e-9) * 0.16
    x = np.tanh(x * 1.6) / 1.6
    peak = np.abs(x).max()
    if peak > 0.95:
        x = x * 0.95 / peak
    pcm = (x * 32767).astype('<i2')
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, f'{name}.wav'), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(pcm.tobytes())


for name, fn in [('rain', rain), ('waves', waves), ('fire', fire), ('wind', wind), ('forest', forest),
                 ('night', night), ('stream', stream), ('crickets', crickets), ('thunder', thunder)]:
    write(name, fn())
    print(name)
