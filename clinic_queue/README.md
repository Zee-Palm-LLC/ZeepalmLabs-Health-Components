# ClinicQueue

Take a token from home, watch the line move, and leave at the right minute.
A pixel-matched rebuild of the four-screen ClinicQueue reference: Take a
token, Live queue, Leave now, It's your turn.

## How it was matched

- Each phone in the reference was warped to an exact 393x852 pt canvas, and
  every position, size and radius was measured on that grid.
- Font sizes were calibrated by measuring text widths in the reference
  against Plus Jakarta Sans (the typeface named in the reference) inside a
  Flutter test.
- Colours were sampled from the reference. The palette tokens (`0F3B3A`,
  `0F766E`, `14B8A6`, `FF8A3D`, `4ADE80`, `FBBF24`, `EEF6F3`) live in `Hue`.
- Each screen was rendered in a widget test with real shadows and compared
  side by side against the reference until they matched.
- Every illustration is drawn with `CustomPainter`: the clinic scene, the
  queue path with its people, the door, the city map and the "your turn"
  scene. Icons are Lucide paths (ISC) drawn natively. The waving hand is
  Microsoft Fluent Emoji (MIT).

## Flow

1. **Home.** Pick a department and tap **Get my token**. A confirm sheet
   shows the clinic, doctor, token, estimated wait and turn time.
2. **Confirm token.** Your ticket prints out of a slot and gets stamped.
   Then the live queue opens.
3. **Live queue.** The line moves on its own. When you're 2nd, an "Almost
   your turn · plan route" prompt rises from the line; when you're next it
   reads "You're next · leave now".
4. **Leave now.** The route and the countdown ring. **Need more time? Swap
   spot** lets one or two people go ahead (your turn time moves back). The
   info button shows visit details, where you can also cancel your token.
5. **I'm on my way.** The button becomes a trip bar, the car drives the
   route, and the ring switches to "On the way" with your ETA. On arrival,
   the app goes to **It's your turn**.
6. **I'm here.** You're checked in, the visit closes, and you return Home
   with a confirmation toast.

Home, Queue and Me share a docked bottom bar. The Map tab opens Leave now.
Queue and Map ask for a token first. **Me** shows your active token (tap it
to open the queue), past visits and alert settings. Once you have a token,
Home turns the preview card into a live token card and the button into
**View live queue**. Android back closes an open sheet first, then steps
back through the flow.

## Live queue

"The line" is a live simulation, not a static picture. Every few seconds:
- The door to Room 3 swings open with a warm light spill, and the person in
  the doorway walks in and fades.
- Everyone steps forward along the path with a walking bob, one after the
  other, and a newcomer joins at the back.
- A "Now serving" toast drops in, and the Room 3 pill pings.
- Your bubble pops from "You · 4th" to "3rd" to "2nd" to "You're next!".
- The token card rolls to the new "Now serving" number. Your position and
  the estimated wait update, and the progress bar slides forward.

Between steps, chevrons flow toward the door, people breathe, a halo pulses
around you, and dust motes drift in the door light.

## Motion elsewhere

- **Every screen:** sections rise in on a stagger. Each section is built once
  and only moved, never rebuilt per frame.
- **Take a token:** the chips select with a spring, and the heart fills.
- **Leave now:** the car drives the dotted route, the ring draws itself, and
  a one-second timer counts down from 12:00 (no per-frame rebuilds).
- **It's your turn:** ripples, a ringing bell, confetti and Grace waving.
  "I'm here" checks you in and returns Home.
- **Bottom bar:** a docked bar shared by Home and Queue. The pill and icons
  slide between tabs, and the bar slides away on full-screen steps.

## Layout and safe areas

- The design is laid out on a 393-point-wide canvas scaled to the screen
  width. The canvas grows taller on taller phones.
- The docked bar and the "I'm here" card always sit above the home indicator
  or Android navigation bar, and the header clears the status bar or notch.
- System font scaling is fixed at 100%, so the layout never overflows.
- Android back steps back through the flow.

## Structure

```
lib/
  core/       theme tokens, motion, SVG-path glyphs, design canvas, docked nav bar,
              in-canvas sheets and toasts
  scenes/     clinic illustration
  data/       visit and queue state shared by every screen
  features/   home, queue, live queue simulation, leave now, your turn, profile,
              token / swap / visit sheets
  app.dart    flow between the four screens
test/         full flow with the live queue advancing, back navigation, every
              screen at 360x640 to 430x932, and a snapshot run (SNAP_DIR,
              SNAP_W/SNAP_H, SNAP_ANDROID=1 for real insets)
```
