# Health Quest

A gamified wellness app built from one reference mockup and one supplied
avatar clip. Four screens, pure Flutter, one third-party package.

```bash
flutter run
```

## The screens

1. **Onboarding.** The supplied clip plays full-bleed: the character drops out
   of the sky, lands on the floating rock and stands up. The interface is timed
   against the clip's own playback position, so the headline strikes while he is
   still falling and the controls arrive as he gets to his feet. As the clip
   ends it folds onto a still composition and dissolves, leaving the same
   character, cut out of the same frame, now breathing and parallaxing under
   your thumb.
2. **Quests dashboard.** Player header, level and XP, the daily health score,
   and the three quests for today. Every number dials up from zero on arrival.
3. **Quest detail.** One quest in full: the ring, the count, what it pays, and
   the milestone rail. Reached milestones are lit, the next one is gold and
   pulsing, the rest are locked.
4. **Rewards vault.** The fourth screen, in the same language. Badges are
   claimed, affordable or locked, and each state is legible from across the
   room. Claiming one spends XP and the balance rolls down.

`STATS` and `PROFILE` are level-gated rather than dead: each states its
requirement and shows how far off you are.

## The avatar

The clip is the source for everything the character appears in.

| Asset | How |
| --- | --- |
| `assets/video/intro.mp4` | The supplied clip, trimmed to 6.45 s — just before its own built-in stat labels appear, since those are drawn here as live badges — muted, and re-encoded to 540x960 at CRF 27. |
| `assets/hero/hero.png` | The character and his rock, matted out of the frame at 6.39 s. |
| `assets/hero/plate.png` | The same frame with him inpainted away, then defocused. |
| `assets/hero/face.png` | His head, cropped from the same matte, for the dashboard avatar. |

**On the matte.** The first attempt keyed the aura out by colour: bright and
purple meant glow. That also described his right sneaker, which is purple and
is the brightest thing on him, so the shoe and the calf above it were deleted.
Colour cannot tell a purple glow from a purple-lit object; texture can. The
matte is now built from local standard deviation and edge energy, because the
aura is smooth and a shoe has laces, a sole and a seam. Colour is not consulted.

**On the plate.** It is deliberately defocused. That gives the depth of field
the design calls for, it makes the character the only sharp thing on the
screen, and it means the inpainted patch behind him is indistinguishable from
bokeh. The stars it loses come back as live twinkles from the shader.

**Registration.** Both hero layers and the clip come from one 720x1280 frame,
and `heroFrameRect` maps that frame onto the screen for a blend between
"covering it" and "sitting exactly on the cut-out". The clip is animated
through that blend as it cross-fades, which is why the character does not
change size under the dissolve.

## The gaming UI kit

`lib/widgets/hud.dart` holds the pieces every screen is built from.

- **`HudPanel`** — a chamfered plate with a lit edge, a coloured rail down one
  side, corner brackets and a faint scanline weave. A rounded rectangle reads
  as software; a plate with cut corners reads as machined.
- **`SegmentedMeter`** — an energy bar of leaning cells rather than one smooth
  fill, with the partial cell at the head drawn at fractional width and lit.
- **`BevelButton`** — chamfered, with a hard top highlight and a bottom shade
  like moulded plastic, and a sheen that crosses on its own schedule.
- **`HudHeading`** — a section title with a leading accent blade and a rule
  that fades out to the right.
- **`polygonPath`** — the hexagons and octagons. Vertices are normalised to the
  box rather than inscribed in it, so a badge asked for at 52 wide is 52 wide.

### The bottom bar

The plate carries a notch in its top edge, and the notch travels to whichever
tab is selected. The active tab's hexagon rises out of that notch and sits
proud of the bar, lit in its own colour, on a blade of light — and its icon
leaves the slot below, so the bar never shows the same glyph twice. A charge
line runs the length of the plate on a slow loop. Each tab owns a colour, so
the bar's accent changes with the destination.

## The animations

Every screen has one entrance controller and every element reads its own
`Interval` of it. All of the tokens are in `lib/core/design.dart`.

| What | How |
| --- | --- |
| Intro | The real clip, driving the interface's entrance from its playback position. A stall detector hands over to a timed entrance if playback never starts — autoplay refused, codec missing, tab backgrounded all look the same from here. |
| Atmosphere | A fragment shader: drifting motes in three parallax layers, two volumetric shafts, a nebula shimmer, and a ring that sweeps out when the CTA charges. |
| Character | Breathes four pixels over four seconds. Drag or hover tilts the diorama; the plate, the aura, the motes and the character each take a different share. |
| Headline | Struck in one word at a time behind a travelling wipe, not faded. |
| Stat badges | Land one at a time with a ring that snaps outward, then idle on their own phase. Tapping one floods its colour into the character and swaps the supporting line for its blurb. |
| Dashboard | The health score dials up, the XP bar fills, each quest's meter runs out and its percentage ticks alongside. The finished quest's check draws itself on. |
| Quest detail | The ring dials from zero and the step count runs with it, so opening a quest shows the progress being made rather than a number that was already there. The milestone rail fills, then the nodes pop in along it. |
| Vault | The balance rolls down when you spend. Affordable badges pulse; the claim tick draws on the first time you see it. |
| Every press | `Pressable`: a real spring on a `Ticker`. Release mid-press and it continues from the current velocity, which a tween cannot do. |

## Two bugs worth keeping in mind

- **`Pressable` created its ticker lazily.** For a button nobody ever pressed,
  first use was `dispose`, where `createTicker`'s lookup of the `TickerMode`
  ancestor is illegal. It is built in `initState` now.
- **No `Material` above a pushed route.** The dashboard and the quest detail
  are their own routes, and without a `Material` ancestor every `Text` renders
  with Flutter's yellow unmaterialised underline. Both are `Scaffold`s now.

## Fidelity, and where it stops

Distances were measured off the reference: screen one on a 450 px wide phone,
screens two and three on a 467 px one, all scaled to a 393-wide canvas. Type is
Saira for display and Inter for body, both variable, both OFL; the mockup's
fonts were not named. Text scaling is honoured to 1.15x and then held, because
the display type is measured tightly.

Two places deviate on purpose. The reference's dashboard reads "3/3 Completed"
above quests at 70%, 76% and 100%; the count here is computed, so it says
"1/3 DONE". And the reference's milestone rail shows 5,000 steps reached at
3,842 steps; here it is locked until you get there.

## Structure

```
lib/
  core/            design tokens, palette, type, shader loader
  core/motion/     Pressable, entrance helpers, the idle clock
  data/            stats, quests, rewards, the player
  features/        onboarding, home, quest, rewards, shell
  widgets/         hud kit, nav bar, progress ring, stardust, painters
shaders/           stardust.frag
assets/            video (the clip), hero (matted layers), fonts
test/              20 tests: data, geometry, entrances, navigation, claiming
```

Third-party: `video_player` only, for the intro clip.
