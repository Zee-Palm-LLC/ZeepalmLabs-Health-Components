# PocketChef

Small bites, big smiles. A playful recipe app starring a furry red chef mascot, rebuilt pixel for pixel from a four-screen mockup (splash, home, recipe detail, profile).

## Run

```
flutter pub get
flutter run
```

## How it was matched

- Each phone in the mockup was located from the bezel edges, upscaled 4x with EDSR and warped onto a 393 pt grid, so every position in the code is a measured point value.
- The layout lives on a fixed 393 pt design canvas scaled to the device width. Top content follows the real top inset, while CTAs and the nav bar sit on the bottom inset, about 10 pt clear of it. On shorter phones the content scrolls, and the splash mascot scales to fit.
- Fonts: Inter for the UI, Sour Gummy ExtraBold for the headline and Outfit SemiBold for the wordmark. Sizes and weights were fitted with HarfBuzz against the measured ink widths. The mockup headline is tilted about 3° and stretched vertically about 17%; the code reproduces both.
- Assets were cut from the screenshot: the mascots with u2net segmentation plus texture mattes, icons with difference mattes against fitted backgrounds, and photos and plates with harmonic inpainting. The flying vegetables were split into nine separate pieces so each one can juggle on its own. UI icons are vendored Phosphor glyphs; the chef hats are vector painters.

## Motion

- Splash: the hat drops in and squashes on landing, letters pop in on springs with a travelling ripple, the red accents draw themselves, and the subtitle is revealed with a wipe. The mascot leaps in with squash and stretch, then floats. Nine vegetables burst out of the pan and keep juggling, sparks and steam rise from the pan, and the CTA has a breathing glow, a sheen and a nudging arrow. Tapping it opens a circular red reveal into the app.
- Home: the bell rings and its dot pulses. The search bar springs open and types its placeholder. The Today's Pick card flips up in 3D, tilts with parallax when dragged, and has drifting clouds, rising steam and popping sparkles. Category bubbles pop in, jiggle when tapped and each has its own idle loop. The heart button bursts when liked. Cards and View Recipe open the detail page with a container-transform morph.
- Detail: the hero image zooms in and stretches when you pull down. The sheet rises with a wobble that settles like liquid. Cheese and pepper fall from the grinder and steam rises from the bowl. The nutrition numbers count up. Ingredients can be ticked off with a strike-through and a check badge. Start Cooking opens a step sheet with a progress ring.
- Profile: decorations fly in and float, the red accents pulse, and a halo turns around the avatar. The stats count up. The premium card swings in with a sheen, and its gold coin flips and twinkles. Menu rows stagger in and wiggle when tapped, and the gear spins.
- Shell: tab switches fade through, the selected nav icon jelly-bounces, and the FAB rotates into a radial quick-action menu that sits above the nav bar and its veil.

## Reel

`reel/pocket_chef_reel.mp4` is a 30 s, 1080x1920 showcase at 30 fps with a music bed. It is rendered frame by frame from the real app by `test/reel/reel_test.dart`, which drives scripted taps and drags through every screen inside a phone frame (`test/reel/reel_stage.dart`). To render the frames again, run `flutter test test/reel/reel_test.dart --dart-define=REEL_DIR=<folder> --timeout none`, then encode them with ffmpeg at 30 fps.

## Tests

`flutter test` runs the layout test (every screen at 360x640, 360x740, 393x852, 412x915 and 430x932, with various insets). To write rendered frames to a folder for side-by-side checks, run `flutter test test/snapshot_test.dart --dart-define=SNAP_DIR=<folder>`.
