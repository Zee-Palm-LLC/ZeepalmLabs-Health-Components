# Momo

A pocket food diary with a living peach companion. Snap a meal, tell Momo what it was, and it estimates the calories, keeps your day on a calendar, and answers questions like "how much protein".

Rebuilt from a 20-second screen recording of an AI meal-log chat, measured on the reference's own 402 x 874 pt grid and then redesigned so it is not a copy.

## Run

```
flutter pub get
flutter run
```

## How it was matched

- All 617 frames of the recording were extracted. The phone screen was located from the bezel profile (371.5 x 808.9 px, an iPhone 16 Pro at 402 x 874 pt), and key frames were warped onto a 3x point grid. Every position in the code is a measured point value.
- Element edges were found with gradient profiles across the true centre of each shape (pills and chips measured near their rounded ends look too short), and text was placed by baseline.
- Type is Inter with its optical-size axis. Each style's size comes from the measured cap or x height, and its tracking from the measured ink width, fitted with HarfBuzz. A test renders every screen, downsamples it to the video's resolution and compares each text ink box with the reference; everything sits within about 1 pt.
- The layout is a fixed 402 pt canvas scaled to the device width. The header follows the top inset, the composer sits on the bottom inset and rides above the keyboard, and the calendar sheet adapts on short phones.

## What changed from the reference

- Zest the lemon became **Momo**, a peach drawn entirely in code: gradients, blush, a swaying leaf, eyes that follow your finger, blinks, brows, a talking mouth, a wave, and squash and stretch on every jump.
- New warm palette: peach and coral accents, a cocoa user bubble, and a sage and amber calorie gauge.
- The composer has a peach aurora that drifts and glows with a travelling border while Momo is thinking, and the stop button gets an orbiting arc.
- New photography (CC0/CC BY from Wikimedia Commons) and Fluent 3D food illustrations (MIT) in place of the flat drawings. The protein card pairs a 3D egg with a code-painted halved egg whose yolk wobbles.
- The camera has a handheld drift, a tap-to-focus reticle, a "Spaghetti bolognese" detection chip, a flip-camera button and a shutter flash.

## Motion

- Launch: Momo drops in with a squash, waves, the greeting resolves out of a blur word by word, the pill springs in with a sheen, and the composer rises.
- Log a meal: the menu blooms from the pill with staggered rows, and the camera sheet slides up.
- Use photo: the photo lifts off the sheet and flies along an arc, tilting in 3D, into its chat bubble while the sheet drops away. Momo hops from the centre to the corner.
- Typing dots morph into the question card, which types itself, and the four meal tiles pop in one by one. Picking a tile pulses it, and a copy of the photo peels off the chat bubble and flies into the card. The calories roll in like a slot machine with motion blur, then the note types out and the My day chip pops.
- My day: the chat blurs back, the calendar sheet springs up and carries Momo onto its top edge. Months slide in a diagonal cascade, the selection pill stretches between days, totals roll, gauge bars fill one by one, and the meals of the selected day pop in. Momo reacts to empty and full days.
- Ask: the question flies up from the composer into a bubble, Momo thinks (eyes up, brow raised) while the composer glows, then talks while the answer card expands and counts up.

## Reel

The reel (`momo_reel.mp4`, kept in Downloads) is a 30-second, 1080x1920 showcase at 30 fps with a soundtrack. `test/reel/reel_test.dart` renders it frame by frame from the real app, driving scripted taps and typing through every screen inside a phone frame (`test/reel/reel_stage.dart`). The beats are: meet Momo, snap, count, my day, ask, then a lockup where Momo drops in and waves.

- Render frames: `flutter test test/reel/reel_test.dart --dart-define=REEL_DIR=<folder> --timeout none`. Add `--dart-define=REEL_EVERY=15` for a quick probe.
- Soundtrack: `tool/reel_audio.py <out.wav>` synthesizes the music bed and sound effects with numpy. They are timed to the same timeline: taps, shutter, photo whoosh and landing, reveal chimes, key ticks and the closing chord.
- Encode the frames at 30 fps together with the wav, then loudness-normalize to -14 LUFS.

## Tests

`flutter test` runs the full flow (menu, camera, flight, picking, calendar, question, start over) at 360x640, 360x740, 393x852, 402x874, 412x915 and 430x932 with different insets, and fails on any exception.

- `flutter test test/snapshot_test.dart --dart-define=SNAP_DIR=<folder>` writes 3x renders of every key state on a fixed date (Oct 4, 19:30).
- `flutter test test/motion_test.dart --dart-define=SNAP_DIR=<folder>` writes frame strips of every transition.

## Credits

- Photos from Wikimedia Commons: "Healthy Spaghetti bolognese" (CC BY-SA), "Avocado toast with pickled onion and greens - Massachusetts" (CC0), "Healthy Vegan Buddha Bowl" (CC BY-SA).
- Food illustrations: Microsoft Fluent Emoji 3D (MIT).
- Icons: Phosphor (MIT), vendored as fonts.
