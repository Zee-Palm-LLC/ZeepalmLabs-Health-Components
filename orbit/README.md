# Orbit

Move. Grow. Build your world. A playful fitness app where your steps grow a little planet, runs earn rewards, and friends race you in a weekly orbit.

Recreated from the four-screen Orbit mockup on a 402 x 874 pt canvas, using the design's own art.

## Run

```
flutter pub get
flutter run
```

## How it was matched

- Each tilted phone in the mockup was found from its bezel edges, perspective-corrected onto the 402 x 874 pt grid and upscaled 4x with EDSR.
- The art was cut into layers. ISNet segmentation was used for the egg, both mascots, the logo, the runner, the chest and the five friend planets. Colour keys were used for the crown and flame, and fitted circles for the icons, avatars and coins. The background plates had all UI and moving art removed, and the holes filled with a harmonic fill.
- All UI is rebuilt in Flutter: stat pills, speech bubble, timer, vital pills, reward tag, boost bar, name tags, leaderboard and buttons. Text is Baloo 2, with each size fitted with HarfBuzz against the measured ink widths. Labels land within about 1-2 pt of the mockup.
- The layout always fits the whole 874 pt design. On wider or taller phones the background extends to fill the screen, so there are no bars.

## 3D planet

The main planet is a live fragment shader (`shaders/planet.frag`). The mockup's planet is unprojected onto a real sphere and wraps round the back as a mirror, so it stays seamless at the edge. Drag it to spin and tilt it in real time; fling it and it coasts, then springs back to the exact mockup pose. At rest it shows the original artwork pixel for pixel.

## Motion and interactions

- **Splash:** the egg rises on a spring, the logo drops in, the sun buddy flies in, sparkles twinkle and the button breathes with a sheen. Tapping the egg or "Start my planet" makes the egg pulse, bursts it into gold particles and flashes into the world.
- **Your World:** the stat pills drop in and count up, the buddy floats, and the speech bubble types its tip. The planet spins under your finger, the volcano smokes and sparks, and comets travel the orbit rings.
  - Moon toggles night mode.
  - Sprout grows a forest: +800 steps, a burst and a new tip, and the planet spins on its own.
  - Heart opens the run.
  - Star opens the race.
- **Run (playable game, Flame):** an endless three-lane runner on a pseudo-3D road that scrolls toward the volcano.
  - **Controls:** swipe left/right or use the arrow keys / A-D to change lanes. Swipe up, tap, space or W to jump.
  - **Pickups:** coins build combos and fill the boost bar. Gems are worth +10, hearts give an extra life, magnets pull coins in, and shields block one hit.
  - **Hazards:** rocks block a lane, so you must change lanes. Fire and logs must be jumped.
  - **Boost:** when the bar is full, tap the rocket (or press B) for 5 s of speed, during which you smash through rocks.
  - **Checkpoints:** every 500 m you get a slow-mo volcano reward (+25 coins).
  - **Game over:** losing all three lives shows a results card with stars, score, distance, coins, best, "Run again" and "Back to world".
  - **Juice:** screen shake, hit flashes, invulnerability blink, squash on landing, dust, sparkle bursts, floating "+1 / COMBO / SMASH" text, speed lines while boosting, a 3-2-1-GO countdown, a pause menu and haptics.
  - **Art:** the runner is a Blender character (`tool/blender/runner.py`) rendered as a 12-frame run cycle plus 3 jump frames with toon outlines. Props are Microsoft Fluent 3D emoji (MIT).
- **Weekly Orbit Race:** the planets float in, name tags pop, the crown sways and comets streak by. Leaderboard bars and scores fill in a stagger. "Challenge a friend" fires a rocket with a trail to the next friend's planet and shows a confirmation. The gear spins.
- **Navigation:** Run and Race have a back chevron, and Android back works on both. Run zooms in from the world; Race drops in from space.

## Tests

`flutter test test/game_test.dart --dart-define=SNAP_DIR=<folder>` plays about 20 s of the runner with scripted swipes, jumps and a boost, then writes gameplay frames and the results screen.


`flutter test` runs the whole flow (splash, world taps, spin, run boost, race challenge, back) at 360x640, 360x740, 393x852, 402x874 and 430x932, and fails on any exception. `flutter test test/snapshot_test.dart --dart-define=SNAP_DIR=<folder>` writes 3x renders of every screen, plus a mid-spin frame of the planet.

## Tools

`tool/cut.py` (segmentation) and `tool/plates.py` (background plates) rebuild the art from the perspective-corrected screens.
