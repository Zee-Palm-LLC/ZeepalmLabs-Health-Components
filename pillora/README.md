# Pillora

A medication reminder app with an AI helper, rebuilt from a three-screen
reference design (onboarding, dashboard, AI helper) and pushed further with
custom painting, fragment shaders and choreographed motion.

The flow: **Onboarding → Dashboard → AI helper**, plus Plan and Profile tabs
reachable from the floating nav bar.

## What moves, and how

### Onboarding
- **The pill city is painted, not an image.** `PillCityPainter` draws the sky,
  light bands, tablets, clouds, five capsules, doors, ladders, the fire truck
  and the tiny staff in code, so every piece can animate on its own.
- **Intro, 3.4 s:** the ground rises; the capsules grow out of it one after
  another with a back-out curve; each cap hovers and then snaps on with an
  elastic settle; the doors slide open and staff pop out; the ladders extend;
  the truck drives in with suspension bounce and raises its ladder.
- **Idle:** clouds and tablets drift, glints move across the caps, doors
  flicker, the beacon blinks, dust motes rise, one worker climbs the ladder and
  another paces the lawn.
- **Parallax:** layers sit at depths from 0.12 to 1 and follow the pointer (or
  a finger) plus a slow idle camera sway.
- **Film grain** comes from `shaders/grain.frag`, blended as an overlay.
- **Copy:** words rise out of a blur one by one, the pill emoji spins in on an
  elastic curve, and a light sweep crosses *Get started* every few seconds.
- **Get started** zooms the scene and opens the dashboard through a circular
  reveal that grows from the button.

### Dashboard
- **Aurora header:** four drifting radial blobs, shared with the AI helper
  through a `Hero`, so the header stays put when the page changes.
- **Week strip:** the selected-day blob is liquid. Its leading edge runs ahead
  and its trailing edge catches up, so it stretches and squashes between days.
  The white numbers are a second layer clipped to the blob, so a digit turns
  white exactly where the blob covers it. Past days are hatched.
- **Dose card** swaps days with a perspective turn in the direction you moved.
- **Taken:** a liquid wave fills the button, the check draws itself, the label
  rolls to *Dose taken at 9:41*, the pill hops and spins, a burst of tiny
  capsules and sparks flies out, and the time chip flips to *Done*.
- **Dose Schedule cards** swipe left to mark a dose taken: the check draws as
  you pull, the card clicks with a haptic when armed, then springs back with a
  badge. The first card nudges once to teach the gesture.
- **Bell** swings and opens a blurred sheet with today's reminder timeline.
- **Floating nav** uses the same liquid blob with clipped dark icons. It hides
  while you scroll down and returns when you scroll up.

### AI helper
- **The orb is a fragment shader** (`shaders/orb.frag`): a refracting glass
  sphere with swirling fbm fog inside, fresnel rim, two window reflections,
  rim arcs, a specular spot and a soft halo. It takes energy, pulse and tilt
  uniforms.
- **Orb input:** hover or drag and the reflections follow; tap it and it
  squishes and starts listening.
- **Voice mode:** mic turns into stop, rings pulse out of the button and the
  orb, live bars run in the field, then the transcript types itself and sends.
- **Chat:** the first message collapses the subtitle, grows the card to full
  height and flies the orb into the corner as an avatar. The send icon flies
  out and back, user bubbles spring from their corner, a thinking indicator
  waves, and replies fade in word by word while the orb brightens.
- Greeting words darken in sequence to the reference's two-tone state.
- Topic chips spin their emoji and send a question; the menu offers a new
  chat or a daily summary.

Replies come from `AssistantBrain`, a local keyword matcher with medication
answers. Nothing is sent anywhere.

## Assets

| Asset | Source |
|---|---|
| Poppins Regular, Medium, SemiBold | Google Fonts (OFL), copied from `adhd_mood_tracker` |
| Pill, brain and heart 3D emoji | Microsoft Fluent UI Emoji (MIT), copied from `symptom_assessment` |
| `avatar_robert.jpg` | Unsplash photo `TMt3JGoVlng` by Irene Strong (Unsplash License), cropped to 360 px |

Everything else — illustration, icons, capsules, tablets, status bar — is
drawn in code.

## Structure

```
lib/
  core/            palette, text styles, motion helpers, routes, shaders, glyph icons, aurora
  data/            medications, week plan, assistant replies
  features/
    onboarding/    screen and the pill city painter
    home/          dashboard, week strip, dose card, schedule card, reminder sheet
    assistant/     AI helper screen, orb painter, chat bubbles
    plan/          adherence ring and today's timeline
    profile/       settings rows, liquid switch, sign out
    shell/         tab stage and liquid nav bar
shaders/           orb.frag, grain.frag
test/              8 tests: data, onboarding to dashboard, taking a dose,
                   switching days, nav, chat streaming, voice input
```

## Run

```
flutter pub get
flutter run
```

On web, the app renders inside a 390 × 844 phone frame with a status bar, so
it matches the reference at desktop sizes.
