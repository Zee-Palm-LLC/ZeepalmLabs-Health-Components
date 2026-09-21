# CareCircle

Share health, meds and moments with your family circle. Rebuilt from a
four-screen reference (Welcome, Home, Member, Medication) with a cleaner,
warmer design system and a lot of motion.

## Design changes from the reference

- **No navy.** Text is a warm plum ink (`#2A2230`) with soft warm greys. Violet
  is kept only as the brand accent, and status colours carry meaning: sage
  for good, coral for missed, honey for needs attention.
- **Plus Jakarta Sans** (rounded and friendly) replaces the default font, with
  one consistent type scale.
- **Consistent cards.** Every stat and quick action has the same hierarchy:
  icon chip, value, caption. The reference mixed three layouts.
- **Timeline** status sits on the time line ("9:00 AM · Missed"), so titles are
  never truncated. The rail sits outside the cards and draws itself.
- **Assignee picker** has one radio per person instead of the reference's
  duplicated radios.
- **Photos.** High-resolution portraits replace the tiny faces in the
  screenshot, decoded once at one shared size so Hero flights never flash
  blank.

## Screens and motion

**Welcome**
- Avatars burst out of the centre on elastic springs into a floating orbit
  with glowing halos.
- Dashed rings draw themselves and keep flowing, and satellites travel
  around them.
- Icon bubbles bob, the headline rises word by word with a gradient accent,
  the button shimmers with a nudging arrow, and meadow plants sway.
- **Create your circle** flies every avatar (Hero) into its seat on the Home
  orbit.

**Home**
- A living family orbit: a dashed ellipse flows, satellites circle, members
  bob, and the Family core breathes with a rotating sheen (tap it for a
  ripple).
- Grandpa pulses with coral rings and signal waves while he needs a nudge.
- Stats count up, quick actions pop in, the sun turns, the heart beats and
  the bell rings.
- A floating nav bar has a sliding indicator and a raised + button that opens
  an add sheet.

**Member** (tap anyone)
- The avatar flies in as a Hero with a pulsing halo, and the status chip
  springs in.
- Vitals count up and the heart icon beats at the member's real bpm.
- The timeline rail draws itself and cards slide in. Tapping a heart or thumb
  pops it with a particle burst.
- **Nudge Grandpa**: hearts float up, the button morphs to a sage "Nudge
  sent", the chip becomes "Nudged just now" and his halo turns from coral to
  honey everywhere.

**Medication sheet** (tap the missed Metformin card)
- The dose ring draws segment by segment around a floating 3D capsule.
- **Mark as taken** spins the capsule, bursts confetti, turns the morning
  segment green and updates the legend, the schedule, the timeline card,
  Home's "5 of 5" and "12/12", and Grandpa's halo.
- Choosing who's on it animates the selection, and **Send gentle reminder**
  morphs into "Reminder sent to Dad".

**Tabs:** a family timeline with filter chips, a medications overview with a
progress ring, and a profile with animated toggles.

## Performance

- No `BackdropFilter`. Glows are blurred circles painted once inside
  `RepaintBoundary`s.
- Every avatar is its own repaint boundary, so orbit motion only moves
  cached layers.
- Scenery (wash, landscape) is static and cached. Only the welcome meadow
  sways.
- Hidden tabs are wrapped in `TickerMode(enabled: false)`, so their
  animations stop.

## Structure

```
lib/
  core/       theme, motion, SVG-path glyphs and logo, shared widgets, scenery
  data/       members, doses, timeline store
  features/
    welcome/  orbit hero
    shell/    tabs, nav bar, add sheet
    home/     header, family orbit, stats, quick actions
    member/   member detail, timeline list
    meds/     medication sheet, meds tab
    timeline/ family timeline tab
    profile/  profile tab
test/         flows (nudge, sheet, assign, remind, mark taken, reactions,
              tabs) and every screen at 360x640, 360x740, 393x852, 412x915
```

## Credits

- Plus Jakarta Sans, OFL.
- Icon shapes follow Lucide (ISC).
- Portraits from Unsplash: `1558919047-c9b36c16009e`, `1665062173657-3912ae7991e0`,
  `1701096351544-7de3c7fa0272`, `1758874574397-e56dfcfc116d`,
  `1552873816-636e43209957`, `1758691463393-a2aa9900af8a`,
  `1494790108377-be9c29b29330`.

Set `SNAP_DIR` when running `test/snapshot_test.dart` to render every screen
to PNG.
