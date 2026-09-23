# Ember Journal

A reflective journal built around one question at a time. Shake the phone for a
prompt, answer it, tag how you felt, and watch the entry fly into the journal.

Three screens, rebuilt from a reference mockup:

| Screen | File |
| --- | --- |
| Random question | `lib/features/ask_screen.dart` |
| Your reflection | `lib/features/reflect_screen.dart` |
| Journal | `lib/features/journal_screen.dart` |

## Matching the reference

The mockup rendered each phone at roughly 229 px wide, so every measurement was
taken from an upscaled, perspective-corrected plate rather than by eye:

1. The three device screens were located in the mockup from the home-indicator
   bar (139 pt wide, centred, 8 pt from the bottom) plus the bezel edges, then
   EDSR-upscaled 4x and warped to an exact 393 x 852 pt plate.
2. Text extents were measured by scanning ink rows and columns on the plate, and
   font sizes were solved by binary search against Poppins' real advance widths.
   That is where the type scale comes from: 37 hero, 27 large title, 26.5 quote,
   19.5 card title, 16.5 nav title, 15.3 date, 13.7 body, 11.6 meta.
3. Background colours were sampled on a grid. The field is an ellipse centred
   near (0.205, 0.50) that falls from #F7A02B through #D96714 to near black, with
   a strong top vignette, a softer bottom one and a right-hand falloff — that is
   what produces the amber-left / maroon-right split in the reference.

Everything is laid out on a fixed 393 pt-wide design canvas (`core/canvas.dart`)
scaled with `FittedBox`, so absolute positions map 1:1 to those measurements. The
canvas height follows the real screen aspect instead of being letterboxed, and
`CanvasScope` exposes `top` / `floor`, so top chrome hangs off the safe-area top
and the CTA and nav bar hang off the safe-area bottom on any device.

## Drawn, not imported

There are no image assets. Every mark is a path:

- `core/glyphs.dart` — all icons on a 24 pt grid, strokable and self-drawing via
  `PathMetric.extractPath`.
- `widgets/mood_faces.dart` — the five faces are one painter parameterised by
  eye squint, mouth curve, mouth opening and a sad/happy eye flip, so they blink
  and morph instead of being five bitmaps.
- `widgets/shake_phone.dart` — the 3D handset, its case, buttons, speaker grille
  and the question cards inside its screen, under a real perspective matrix.
- `core/glow.dart` — the ember field, drifting blobs, vignettes and film grain
  (grain is a precomputed `Float32List` drawn with `drawRawPoints`).

## Motion

One `Ticker` on the shell drives every idle animation; controllers handle the
discrete ones.

- **Shake.** Drag the handset and it tilts with your finger and springs back.
  Three direction reversals inside 620 ms counts as a shake: the phone jolts with
  a damped oscillation, the question cards tumble, and the next prompt is drawn.
- **Question reveal.** Ask to Reflect is a circular reveal growing from the
  handset, with the outgoing screen scaling back behind it.
- **Shuffle.** The card flips on Y, and the new question resolves letter by
  letter out of scrambled text.
- **Mood.** Selecting a face pops it, pulses a halo, crossfades the label upward,
  moves the waveform's focus to sit under it, and re-tints the background glow.
- **Add to Journal.** The button fills with a liquid wave, draws its check, and
  bursts; meanwhile the answer card detaches and flies along an arc into the
  journal list, which opens a slot for it and glows in the entry's mood colour.
- **Week strip and nav bar.** Both selections are liquid: the leading edge of the
  capsule eases out faster than the trailing one, so it stretches on the way and
  settles at the target. Nav icons are drawn twice, the second pass clipped to
  the capsule, so they invert as it passes.

Two wrappers are deliberately shape-stable: `Staged` and `ScreenSwap` always
return the same widget tree, only with different transform values. Collapsing to
the bare child once an animation finished was destroying the subtree's state —
which, mid-press, cancelled the save button's own animation.

## Running

```bash
flutter run
```

```bash
flutter test
```

`test/snapshot_test.dart` renders each stage to PNG when given a directory:

```bash
flutter test test/snapshot_test.dart --dart-define=SNAP_DIR=/path/to/shots
```

It loads the real Poppins files first (the test font is monospaced and would
rewrap every line) and turns `debugDisableShadows` off so blurs and shadows show
up the way they do on device.
