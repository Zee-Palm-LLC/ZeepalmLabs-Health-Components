# Nocturne

Soundscapes for a calmer you. A Flutter recreation of the Nocturne sleep sound mixer: four screens, living shader orbs, a glass vessel that holds a nebula built from your mix, and real synthesized audio.

## Run

```bash
flutter pub get
flutter run
```

On web the app draws an iPhone status bar, Dynamic Island and home indicator so it can be compared with the reference. On a device the system draws them.

## Screens

- **Welcome.** A night bedroom plate with a crisp painted crescent moon, twinkling stars and a flickering lantern. Staged entrance, then a soft fade-and-scale into the app.
- **Home (sound selection).** Nine shader orbs. Each one has its own interior: falling rain, cresting waves, rising flame, drifting wind bands, forest veins, a violet night sky, a stream horizon, a golden cricket constellation, and grey storm glass that flashes with lightning. Tap an orb to add it to or remove it from your mix (up to four). The category chips and the search field filter the grid with animated reflow. Long-press an orb to open the mix straight away.
- **Mix (dreamscape).** The orbs fly in as heroes, luminous streams pour from each one into the vessel, and the nebula rises inside the glass. Every sound owns a region of the nebula, and its volume sets how strong that colour is. Tap an orb to focus it: the slider then sets that sound's volume, and a × removes it. With nothing focused, the slider is the master volume, which also sets the nebula's energy. Other controls:
  - **Reset** pours the mix again.
  - **Add** opens a picker.
  - **Timer** sets the sleep timer.
  - **Save Mix** adds the mix to the Library.
  - **Ambient** flies the nebula into Sleep mode.
- **Sleep mode.** A lake plate with its own moon, stars and moonlight shimmer on the water, and a frosted card with the mix artwork, rendered live by the same nebula shader. The card also has the timer progress, play/pause, previous/next through the Library, a per-sound blend sheet, and a moon button that dims everything to near-black ("Tap to wake").
- **Library.** Saved and preset mixes, each with its own live nebula thumbnail.

## Flow

Welcome → Home → Mix → Sleep, with Library as the second tab.

- **Home:** tap orbs to build your mix. Each change shows a toast with an **Open Mix** button, and the Mix tab badge shows how many sounds are in the mix. Long-pressing an orb opens the mix straight away.
- **Mix:** tap the vessel (or **Ambient**) to go to Sleep. The back button returns to Home.
- **Sleep:** the chevron at the top left, a swipe down (it follows your finger and springs back if you let go early) or the system back gesture returns you to where you came from.
- **Library:** tap a mix to open it in Mix. From the Library tab, Android back returns to Home first.

## Motion

Page transitions are GPU-cheap fades and scales, with no full-screen blur over the live shaders. Orb heroes fly on arcs into the Mix row, and the nebula stays round as it flies into the Sleep artwork, becoming a rounded square only at the end. Every idle animation runs off a single ticker.

## How it is built

- `shaders/orb.frag`: one program with nine interiors, selected by `uKind`. Glass shading comes from fresnel, a thin rim, a specular spot and an arc reflection. The halo glow is drawn by the shader too, so no blur layers are needed.
- `shaders/vessel.frag`: the bowl is a signed-distance shape: a truncated sphere plus a neck and lip. The nebula combines two-arm spiral strands with a U-shaped flow band, filaments and stars, with hue-preserving tone mapping. Colour sources drift, and their weights come from the sound volumes. The shader also draws the fill level with a moving surface, the intake wisps under the mouth, the glass band and reflections, and the floor light pool. Mode 1 renders the square artwork.
- `lib/scene/clock.dart`: one app-level ticker drives every painter through `SceneClock`, so no screen rebuilds per frame; painters repaint through `super(repaint:)`.
- `lib/scene/streams.dart`: the pour streams are cubic paths extracted by progress, with a blurred glow pass, a gradient core and particles travelling along the path metric.
- `lib/sound`: `Mixer` holds the mix state. `LoopEngine` plays looping audio with `audioplayers`, with smooth per-sound gain ramps and a 30-second fade at the end of the timer. Tests use `SilentEngine`.
- `tool/synth_sounds.py`: generates the nine 16-second loops. They are synthesized in the frequency domain, so every loop is seamless: rain drops, ocean swells, fire crackle, wind bands, birdsong, a night drone, stream bubbles, cricket chirps and thunder rumbles.

## Fidelity process

- Each phone in the reference (`reference/nocturne.webp`) was detected, then perspective-warped to an exact 393×852 pt screen (`reference/screen*_2x.png`). All positions come from those warps.
- All text is set in Poppins (Light, Regular, Medium and SemiBold). Sizes were calibrated so that each line keeps the width measured in the reference, using `TextPainter`.
- The Welcome and Sleep photo plates were cropped from the reference and upscaled 4× with EDSR super-resolution. The baked-in UI was removed by inpainting, and the moon areas were feathered so the painted moon sits cleanly on top.
- `test/snapshot_test.dart` renders real frames (set `SNAP_DIR`). `tool/compare.py` builds side-by-side sheets against the reference.
- `test/flow_test.dart` runs the whole journey at 360×640, 360×740, 393×852, 412×915 and 430×932, and asserts that nothing throws.
