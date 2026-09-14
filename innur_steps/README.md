# innur — health tracker

A recreation of the reference recording: a splash whose mark draws itself, and
a today screen with activity, goals and a leaderboard.

Content is health-app English rather than the Portuguese step app in the clip,
and the leaderboard names and faces are placeholders — the recording was
somebody's real leaderboard and none of those people are reproduced.

## The mark draws itself

`innur_mark.dart`. The figure is not an asset: it is two polylines and a circle
on a 100 × 100 grid, which is what makes the splash animation possible at all.

- Each stroke gets a slice of the timeline **proportional to its own length**,
  so the pen moves at constant speed instead of racing through the short
  strokes and crawling through the long one.
- The strokes overlap by 8%, so the next limb starts before the last finishes
  and the mark never reads as three separate events.
- Partial strokes come from `ui.PathMetric.extractPath`.
- The head is a sweep, not a pop: an arc at half the radius, stroked at the
  full radius, fills the disc as it goes round.
- The trailing end of the upper chevron is cut flat rather than capped round —
  it reads as speed. That cut is a `BlendMode.dstOut` rectangle rather than a
  clip, so it follows the stroke *while it is still drawing* instead of
  snapping in at the end.

Because it is geometry, the same mark is the splash hero at 168 units and the
splash hero at 168 units and stays available at any size, with no second copy.

## The today screen

```
Today  ⌃⌄                                   🔥 6
M  T  W  T  F  S  S     ← seven progress rings, swept in
You're #3 of 12
8,412 steps             ← counts up
6.24 km · 412 kcal · 84% of goal
● Synced from Health · 2 min ago
[ Global ] [ My team ] [ + ]
Today's rank  ›                            🌐 Global
        🥈 2   🥇 1   🥉 3      ← gold / silver / bronze
        4  Leo Marchetti          7,980
        …  down to 10th
```

Laid out at a fixed 440 width and uniformly scaled, so every measured offset
holds. Vertically it flows and **scrolls** — the leaderboard runs to tenth
place, which is past the bottom of any phone. There is no bottom bar.

**Spacing is deliberately tight.** Sections are expressed as gaps rather than
absolute tops, and the gaps are small: 16, 14, 18, 14, 14, 24, 24, 24. Dead
space between sections reads as an unfinished screen, not as breathing room.
The podium scores sit 5 units above their blocks — the two belong together, and
any more reads as two separate things stacked.

## The podium

Each place gets its own metal, as a **pair** of colours rather than a flat
fill — a lit top and a darker body, because a single tone at this size reads as
coloured card, not as metal. The ring round each avatar is brighter than either
so it survives against a photograph, and *every* place is ringed, not just the
winner: that is what makes the top three read as a set.

Places four to ten are rows below. The user's own row is lifted — brighter
fill, blue edge, full-weight ink — because finding yourself in a list of ten is
the single thing anyone does on this screen.

`ranked` re-orders the podium from *layout* order (2, 1, 3) into finishing
order, since those are not the same thing and the list has to start at four
without repeating anybody.

## The animations

One `AnimationController` drives the entire entrance; each section reads its
own `Interval` of it. That shared clock is what makes the page arrive as a
single considered move rather than eleven widgets each doing their own thing.

| | what it does |
|---|---|
| Header, stats, note, chips, rank title | fade up 16 units |
| Week rings | arcs **sweep** from zero, staggered left to right, all finishing together — a stagger that also delayed the end would drag |
| The step count | **counts up** from zero. It is the one figure the user opened the app for, and a number that climbs says "today, so far" in a way a static one cannot |
| Podium blocks | grow **out of the floor** — scaled about their own base, third then second then first, so the eye is walked up to the winner instead of being shown the answer. The numeral is counter-scaled so it does not squash while the slab is rising |
| Contenders | drop in just after their own block lands |
| Rows 4–10 | slide in from the right, staggered, so the column deals itself out |

Chip selection animates its fill and its text colour together.

## Network avatars

`avatar.dart`. Every state — loading, loaded, failed — renders the same circle
at the same size, so a slow or dead network shifts nothing on the page. Behind
the image sits the person's own tint with their initial on it, which means a
failed load still reads as *them* rather than as a broken tile. Images fade in
over that rather than popping.

Two things worth knowing if you swap the host:

- **CORS matters on web only.** CanvasKit fetches image bytes over XHR, so a
  host without `Access-Control-Allow-Origin` works on Android and iOS and fails
  silently in a browser. The first host tried here (`i.pravatar.cc`) does
  exactly that; the images come from Unsplash, which sends the header.
- **Android release needs the permission explicitly.** Flutter only adds
  `INTERNET` to the debug and profile manifests; it is added to
  `android/app/src/main/AndroidManifest.xml` here so release builds can load.

## Everything is drawn

No icon font and no image assets beyond the typeface: the flame, the globe, the
stat icons, the podium slabs and the progress rings are all
`CustomPainter`. That keeps the set visually consistent with the mark instead
of borrowing shapes from somewhere else.

## Structure

```
lib/
  core/
    design.dart        every offset, size and motion interval
    palette.dart       the ground gradient, ink, accents, medals
  data/
    today.dart         the screen's content, and `ranked`
  features/
    splash/
      innur_mark.dart  the figure and its draw animation
      splash_screen.dart
    home/
      home_screen.dart
      widgets/
        avatar.dart        network image with a stable fallback
        week_strip.dart    seven swept rings
        rank_podium.dart   gold / silver / bronze, grown from the floor
        rank_row.dart      places 4 to 10
        flame.dart         the streak mark, shared
```

## Running

```bash
flutter pub get
flutter run
```

Inter is bundled as a variable font, so weights come from `fontVariations`
rather than from separate files.

## Tests

```bash
flutter test
```

Seventeen, covering the draw animation's timing and one-shot handover, the mark
staying inside its box at every size, the count-up actually climbing, the podium
growing from the floor in the right order, the list running 4→10 without
repeating the podium, the field being correctly ordered, and the avatars holding
their place when every image load fails — which is what the test binding does by
default, so that path is exercised on every run.

## On "pixel perfect"

The reference is a screen recording of an iPhone mirrored into a Mac window:
the phone screen is 239 px wide in the source for a 440-unit layout. Positions
were measured off it and are accurate to roughly ±2 design units, which is the
limit of what that source can tell you. Colours were sampled and then lifted a
few percent, because the mirrored panel reads darker than the real screen.
