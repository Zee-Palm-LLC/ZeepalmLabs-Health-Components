# Fitzi

A pixel-matched Flutter build of the four-screen Fitzi fitness mockup
(onboarding, home, workout detail, progress), plus the Workouts and Profile
tabs and a workout player that the mockup implies but does not show.

## Running

```
flutter pub get
flutter run
```

`flutter test` renders every screen at 360x640 up to 430x932 and fails on any
layout exception. Pass `--dart-define=SNAP_DIR=<folder>` to write PNG frames
for side-by-side checks against the reference.

## How it matches the mockup

- Every screen is laid out on a fixed 393 pt design canvas (`core/canvas.dart`)
  scaled to the device width. Positions come from the reference, measured on
  EDSR-upscaled, perspective-free crops of each phone.
- Font sizes and tracking were fitted with HarfBuzz ink boxes: Nunito 880 for the
  rounded headline, Inter (variable weight + optical size) everywhere else.
  Text is placed by cap height and left bearing, so glyph ink lands on the
  measured pixel rather than on a line box.
- The mascots, thumbnails, avatar, logo and the 3D stat icons are cut out of the
  mockup itself (U2-Net human segmentation for the characters, difference
  matting for the icons). Blobs, the lime arc, bars, buttons and cards are drawn
  in code from fitted circles, Bezier curves and sampled gradients, so they stay
  sharp and can move.
- Reference glitches were corrected rather than copied: "Begimer" reads
  "Beginner".

## Motion

- Onboarding: blobs grow in and keep morphing; the headline lines flip up out
  of a clip, "fun!" springs in with a travelling sheen and a hopping "!", the
  lime and purple sparks draw on and pulse, and the mascot drops in with squash
  and stretch, then breathes. Drag anywhere for parallax. Tap the mascot to make
  it jump. Get Started fills the button with liquid from the arrow orb, then
  opens Home with a circular reveal.
- Home: staged entrance, an aurora gradient drifting behind the hero card, speed
  streaks behind the running mascot, a shimmering goal bar, rolling counters,
  a swinging bell, a waving hand, quick tiles that pop and animate their icons
  when idle, and a nav bar with a sliding glow and springy icon fills.
- Workout: the thumbnail flies into the detail mascot as a shared-element hero,
  the arc draws itself, the sheet rises, the stats icons tick and flicker, and
  the steps pop in. Start Workout opens a player with a 3-2-1 countdown, a
  sweep-gradient timer ring and step controls.
- Progress: bars rise on springs, lime liquid sloshes inside them, bubbles
  drift up, and the tooltip glides to whichever bar you tap or drag across.
