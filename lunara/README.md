# Lunara

A cycle companion that lives at night: an aurora of drifting light over deep
aubergine, a living moon ring, and a liquid bottom bar. Four screens —
welcome, home, day log, insights — plus a profile tab.

Everything is painted in Flutter. No image assets: the aurora, the moon, the
ring, the liquid blobs, the droplets, the mood faces, the chart and every icon
are drawn with `CustomPainter`.

## The look

- **Aurora backdrop.** Four radial blobs drift on their own periods over a
  deep aubergine gradient, with stars twinkling above and a horizon that sinks
  into deep night rather than washing out. The horizon sits low on Home and
  high on the other tabs, so cards always land on calm ground.
- **Type.** Poppins throughout, from the wordmark and the big day number down
  to the captions.
- **Palette.** Aubergine night throughout — every surface is dark glass over
  the aurora — with warm rose-to-peach accents and one colour per phase:
  menstrual rose, follicular mint, ovulation amber, luteal violet.

## The moon becomes the ring

Tapping **Get started** does not cut to the next screen. The welcome content
blurs and sinks, a circular reveal opens out of the button, and the crescent
moon flies from the sky into the middle of the home screen, shrinking and
turning as it goes. As it fades, the cycle ring draws itself around where it
landed: phase arcs sweep out one after another, day ticks pop in, the progress
track traces from day one to today, and the head of the track lands with a
pulsing halo.

## Motion

- **Liquid bar.** The selected blob's leading edge runs ahead and the trailing
  edge catches up, so it stretches then squashes between tabs. Icons are drawn
  twice — muted underneath, dark on top clipped to the blob — so each one
  inverts exactly where the blob covers it.
- **Liquid week strip.** The same blob logic across the seven days, with the
  weekday letter, date and phase dot all inverting under it.
- **Home.** The day number counts up to today, the phase chip springs in, the
  quick-log tiles rise on a stagger and bob on their own phases, and the
  avatar, bell and sparkle breathe.
- **Log.** Droplets fill with a live liquid wave and swell when chosen, mood
  faces morph their mouth curve and glow, the energy knob drags with a halo
  that tracks the value, symptom chips ripple from the point you touched, and
  "Save day" collapses into a check.
- **Insights.** The chart traces its own line with the area fading in beneath
  it, points pop in sequence, the tooltip floats, and each phase bar grows
  segment by segment.
- **Between tabs.** The outgoing screen blurs, scales back and slides while the
  incoming one rises through it.

## Layout and safe areas

- A 393-point-wide design canvas scaled to the screen; the canvas grows taller
  on taller phones and the aurora is painted edge to edge behind it. The system
  draws the status bar and home indicator — the app does not fake them.
- The liquid bar and the save button clear the home indicator or the Android
  navigation bar; the header clears the status bar or notch. The bar slides
  away while the day log is open.
- System font scaling is pinned so the layout cannot overflow.

## Structure

```
lib/
  core/       theme tokens, motion helpers, design canvas, SVG-path glyphs,
              aurora and moon painting
  data/       cycle phases, day maths, and the log state every screen shares
  features/   welcome, home, log, insights, you
  widgets/    cycle ring, liquid nav, liquid week strip, surfaces, transition
  app.dart    the reveal, the moon-to-ring morph, and the tab flow
test/         a full interaction pass (welcome through logging a day), every
              screen at 360x640 to 430x932, and a snapshot run (SNAP_DIR,
              SNAP_W/H, SNAP_ANDROID=1 for real insets)
```

## Run

```
flutter run
```

Font: Poppins (SIL Open Font License). Icons: Lucide (ISC).
