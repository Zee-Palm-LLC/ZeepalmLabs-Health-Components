# Ascend

A habit tracker onboarding: level up with XP, keep a 100-day streak, and climb a weekly leaderboard with friends.

It recreates the layout and motion of a three-screen onboarding video, measured point by point on a 402 x 874 pt canvas (iPhone 16 Pro). The brand, copy, palette, badge and avatars are new.

## Run

```
flutter pub get
flutter run
```

## Screens

1. **Level:** a glowing level ring fills from two ends while the level counts up to 24. A violet habit card flies in tilted and springs into place, gets its check, and is swept by a sheen. Fainter cards stack behind it.
2. **Streak:** a hexagon badge spins in from the right and grows, counting from 0 to 100. Laurels grow leaf by leaf, then a frosted "100-day streak" pill rises with a flickering flame.
3. **Crew:** three podium columns rise in turn, then the avatars drop onto them with springy name tags. Chevrons climb the winner's column. Apple and Google sign-in buttons light up one after another.

Every headline resolves out of a blur. Buttons brighten from grey to white as they arrive, and particles drift behind each hero. Pages slide with parallax. Back, a swipe, or the system back gesture returns to the previous page, and that page replays its entrance.

## How it was matched

- The video was downloaded at full quality (1236x1740) and split into frames. The phone screen was located from its bezel and warped onto a 3x point grid.
- Ring geometry, card positions, the badge box, column tops, avatar centres and button frames are measured point values.
- Text uses Inter. Sizes come from measured cap heights, and tracking from the measured ink widths, fitted with HarfBuzz.
- Hero sections follow the top inset and text blocks sit on the bottom inset. On short phones the hero scales down so nothing collides.

## Reel

The reel (`ascend_reel.mp4`, kept in Downloads) is a 30-second, 1080x1920 showcase at 30 fps with a soundtrack. `test/reel/reel_test.dart` renders it frame by frame from the real app, driving scripted taps through every screen inside a phone frame (`test/reel/reel_stage.dart`), and `tool/reel_audio.py` synthesizes the matching music and sound effects.

- Render frames: `flutter test test/reel/reel_test.dart --dart-define=REEL_DIR=<folder> --timeout none`
- Make the soundtrack: `python tool/reel_audio.py <out.wav>`
- Encode the frames at 30 fps with the wav, then normalize to -14 LUFS.

## Tests

`flutter test` walks the whole flow at 360x640, 360x740, 393x852, 402x874 and 430x932 and fails on any exception. `flutter test test/snapshot_test.dart --dart-define=SNAP_DIR=<folder>` writes 3x renders of each screen and of the key transitions.

## Credits

3D avatars and habit icons are from Microsoft Fluent Emoji (MIT). UI icons are Phosphor (MIT). The brand mark, ring, badge, laurels, podium and Google mark are drawn in code.
