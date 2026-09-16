import os
import wave

import numpy as np

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "sfx")
rng = np.random.default_rng(7)


def seconds(duration):
    return np.arange(int(SR * duration)) / SR


def phase(freq):
    freq = np.asarray(freq, dtype=float)
    return 2 * np.pi * np.cumsum(freq) / SR


def glide(start, end, duration, curve="exp"):
    t = seconds(duration) / max(duration, 1e-9)
    if curve == "exp":
        return start * (end / start) ** t
    return start + (end - start) * t


def square(freq, drive=4.0, duty_bias=0.0):
    return np.tanh(drive * (np.sin(phase(freq)) + duty_bias)) / np.tanh(drive)


def triangle(freq):
    return 2 / np.pi * np.arcsin(np.sin(phase(freq)))


def sine(freq):
    return np.sin(phase(freq))


def envelope(n, attack=0.002, decay=0.08, sustain=0.0, release=0.0, hold=0.0):
    t = np.arange(n) / SR
    env = np.where(t < attack, t / max(attack, 1e-9), 1.0)
    after = np.clip(t - attack - hold, 0, None)
    env = env * (sustain + (1 - sustain) * np.exp(-after / max(decay, 1e-9)))
    if release > 0:
        tail = np.clip((t - (n / SR - release)) / release, 0, 1)
        env = env * (1 - tail)
    return env


def lowpass(signal, cutoff):
    a = np.exp(-2 * np.pi * cutoff / SR)
    out = np.empty_like(signal)
    y = 0.0
    for i, x in enumerate(signal):
        y = (1 - a) * x + a * y
        out[i] = y
    return out


def highpass(signal, cutoff):
    return signal - lowpass(signal, cutoff)


def noise(duration):
    return rng.uniform(-1, 1, int(SR * duration))


def place(canvas, sound, at):
    start = int(SR * at)
    end = min(len(canvas), start + len(sound))
    canvas[start:end] += sound[: end - start]
    return canvas


def echo(signal, delay=0.085, feedback=0.28, taps=3):
    out = np.concatenate([signal, np.zeros(int(SR * delay * taps))])
    for k in range(1, taps + 1):
        place(out, signal * feedback ** k, delay * k)
    return out


def note(name):
    names = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}
    semis = names[name[0]] + (1 if "#" in name else 0)
    octave = int(name[-1])
    return 440.0 * 2 ** ((semis + (octave - 4) * 12) / 12)


def fade_edges(signal, ms=3):
    n = int(SR * ms / 1000)
    signal[:n] *= np.linspace(0, 1, n)
    signal[-n:] *= np.linspace(1, 0, n)
    return signal


def write(name, signal, peak_db):
    signal = fade_edges(highpass(signal.astype(float), 25))
    signal = signal / (np.max(np.abs(signal)) + 1e-9) * 10 ** (peak_db / 20)
    pcm = (np.clip(signal, -1, 1) * 32767).astype("<i2")
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name + ".wav")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print(f"{name:10s} {len(signal) / SR * 1000:6.0f} ms  {os.path.getsize(path):7d} bytes")


def tap():
    d = 0.06
    body = square(glide(1500, 820, d), drive=3) * envelope(int(SR * d), 0.001, 0.016)
    click = highpass(noise(d), 2500) * envelope(int(SR * d), 0.0005, 0.003)
    return lowpass(body + 0.35 * click, 7000)


def tick():
    d = 0.035
    return sine(np.full(int(SR * d), 2100.0)) * envelope(int(SR * d), 0.001, 0.008)


def nav():
    canvas = np.zeros(int(SR * 0.16))
    for at, f in ((0.0, note("E5")), (0.045, note("B5"))):
        d = 0.09
        tone = 0.6 * square(np.full(int(SR * d), f), drive=2.5) + 0.4 * triangle(np.full(int(SR * d), f * 2))
        place(canvas, tone * envelope(int(SR * d), 0.002, 0.03), at)
    air = lowpass(highpass(noise(0.16), 1800), 6000) * envelope(int(SR * 0.16), 0.02, 0.05)
    return lowpass(canvas + 0.18 * air, 8000)


def back():
    canvas = np.zeros(int(SR * 0.15))
    for at, f in ((0.0, note("B5")), (0.045, note("E5"))):
        d = 0.09
        tone = square(np.full(int(SR * d), f), drive=2.5)
        place(canvas, tone * envelope(int(SR * d), 0.002, 0.03), at)
    return lowpass(canvas, 7000)


def open_panel():
    d = 0.24
    n = int(SR * d)
    sweep = sine(glide(260, 1100, d)) * envelope(n, 0.03, 0.09)
    air = noise(d)
    cutoff_track = np.linspace(700, 5200, n)
    shaped = np.empty(n)
    y = 0.0
    for i in range(n):
        a = np.exp(-2 * np.pi * cutoff_track[i] / SR)
        y = (1 - a) * air[i] + a * y
        shaped[i] = y
    shaped = highpass(shaped, 400) * envelope(n, 0.07, 0.07)
    return 0.55 * sweep + 1.4 * shaped


def toggle(on):
    d = 0.12
    n = int(SR * d)
    a, b = (520, 1040) if on else (900, 430)
    chirp = square(glide(a, b, d * 0.6).tolist() + [b] * (n - int(SR * d * 0.6)), drive=2.5)
    chirp = np.asarray(chirp) * envelope(n, 0.002, 0.045)
    if on:
        pip = sine(np.full(int(SR * 0.05), 1560.0)) * envelope(int(SR * 0.05), 0.001, 0.015)
        chirp = place(chirp, 0.5 * pip, 0.06)
    return lowpass(chirp, 7500)


def confirm():
    canvas = np.zeros(int(SR * 0.34))
    for i, name in enumerate(("C6", "E6", "G6")):
        d = 0.2
        f = np.full(int(SR * d), note(name))
        tone = 0.7 * square(f, drive=2.2, duty_bias=0.35) + 0.3 * triangle(f)
        place(canvas, tone * envelope(int(SR * d), 0.002, 0.06), i * 0.055)
    return lowpass(canvas, 7500)


def coin():
    canvas = np.zeros(int(SR * 0.42))
    first = square(np.full(int(SR * 0.07), note("B5")), drive=3)
    place(canvas, first * envelope(len(first), 0.001, 0.2), 0.0)
    second = square(np.full(int(SR * 0.35), note("E6")), drive=3)
    place(canvas, second * envelope(len(second), 0.001, 0.11), 0.065)
    return lowpass(canvas, 8000)


def denied():
    canvas = np.zeros(int(SR * 0.28))
    for at in (0.0, 0.13):
        d = 0.11
        f = glide(185, 140, d)
        saw = 2 * ((np.cumsum(f) / SR) % 1.0) - 1
        buzz = 0.6 * saw + 0.4 * square(f, drive=5)
        place(canvas, buzz * envelope(int(SR * d), 0.003, 0.06, release=0.02), at)
    return lowpass(canvas, 2400)


def charge():
    d = 1.2
    n = int(SR * d)
    t = seconds(d)
    vibrato = 1 + (0.01 + 0.05 * (t / d) ** 2) * np.sin(2 * np.pi * (6 + 18 * t / d) * t)
    f = glide(170, 1250, d) * vibrato
    body = 0.65 * square(f, drive=2.5) + 0.35 * square(f * 1.5, drive=2)
    swell = (t / d) ** 1.6
    riser = highpass(noise(d), 3000) * swell * 0.25
    return lowpass((body * swell + riser) * envelope(n, 0.05, 99, release=0.09), 6500)


def level_up():
    run = ("C5", "E5", "G5", "C6", "E6", "G6", "C7")
    canvas = np.zeros(int(SR * 1.45))
    for i, name in enumerate(run):
        d = 0.18
        f = np.full(int(SR * d), note(name))
        tone = 0.7 * square(f, drive=2.2, duty_bias=0.3) + 0.3 * triangle(f)
        place(canvas, tone * envelope(int(SR * d), 0.002, 0.07), i * 0.06)
    chord_at = len(run) * 0.06
    d = 0.95
    t = seconds(d)
    for name in ("C6", "E6", "G6", "C7"):
        f = note(name) * (1 + 0.006 * np.sin(2 * np.pi * 5.5 * t))
        place(canvas, 0.33 * triangle(f) * envelope(len(t), 0.01, 0.38), chord_at)
    sparkle = np.zeros(len(canvas))
    for k in range(9):
        at = chord_at + 0.04 + k * 0.075 + rng.uniform(0, 0.02)
        pip = sine(np.full(int(SR * 0.04), rng.uniform(2600, 4200))) * envelope(int(SR * 0.04), 0.001, 0.01)
        place(sparkle, pip * (1 - k / 10), at)
    return echo(lowpass(canvas + 0.35 * sparkle, 9000), delay=0.09, feedback=0.25)


def victory():
    canvas = np.zeros(int(SR * 1.2))
    for at, name, d in ((0.0, "G5", 0.1), (0.09, "C6", 0.1), (0.18, "E6", 0.1), (0.27, "G6", 0.14)):
        f = np.full(int(SR * d), note(name))
        tone = 0.75 * square(f, drive=2.4, duty_bias=0.3) + 0.25 * triangle(f)
        place(canvas, tone * envelope(int(SR * d), 0.002, 0.08, sustain=0.3), at)
    d = 0.62
    t = seconds(d)
    f = note("C7") * (1 + 0.008 * np.sin(2 * np.pi * 6 * t))
    held = 0.6 * square(f, drive=2, duty_bias=0.3) + 0.4 * triangle(f)
    place(canvas, held * envelope(len(t), 0.004, 0.22, sustain=0.25, release=0.2), 0.42)
    bass = triangle(np.full(int(SR * 0.62), note("C4"))) * envelope(int(SR * 0.62), 0.004, 0.25, sustain=0.2, release=0.15)
    place(canvas, 0.55 * bass, 0.42)
    return echo(lowpass(canvas, 8500), delay=0.08, feedback=0.22)


if __name__ == "__main__":
    write("tap", tap(), -9)
    write("tick", tick(), -13)
    write("nav", nav(), -6)
    write("back", back(), -8)
    write("open", open_panel(), -7)
    write("toggle_on", toggle(True), -7)
    write("toggle_off", toggle(False), -8)
    write("confirm", confirm(), -5)
    write("coin", coin(), -4)
    write("denied", denied(), -6)
    write("charge", charge(), -5)
    write("level_up", level_up(), -3)
    write("victory", victory(), -3)
