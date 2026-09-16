# MediWise onboarding

Three-page animated onboarding for a healthcare app, in Flutter. The layout
follows a travel-app reference design; the content is medical. Everything is
laid out on a 375 x 812 artboard, so positions match the reference 1:1 and
scale uniformly to any phone.

1. **Your Health, Perfectly Planned.** A featured appointment with a doctor
   and an upcoming visit list: cardiology, a blood test, an eye exam and a
   vaccination.
2. **Consult Doctors Anywhere.** Three consultation cards over a dotted world
   map, with a doctor's "online now" chip.
3. **Stay Updated with Top Clinics.** Rated clinic cards with a specialty tag,
   a consultation fee and a "Verified by MediWise" badge.

## Run

The folder is still named `wayfarer_onboarding` (the Dart package name); the
app shows as MediWise on every platform.

```
flutter pub get
flutter test
flutter run
```

Requires Flutter 3.32+ (Dart 3.8).

## Assets

Everything non-photographic is drawn in code and stays sharp at any density:
the dotted world map, specialty icons, dashed orbits, dot clusters, tags, chips
and the brand mark. Photos and avatars load from `assets/images/`; see the
README there for filenames, export sizes and sources. Missing files show a
neutral placeholder.

The brand name lives in `lib/core/brand.dart` and the mark (a stethoscope tube
rising into a medical cross) in `lib/core/painting/brand_mark_painter.dart`.
All copy and showcase content is in `lib/features/onboarding/data/`.

## Fonts

Typography uses Figtree via `google_fonts`. For release builds, bundle the font
files under `assets/google_fonts/` and set `GoogleFonts.config.allowRuntimeFetching = false`
so text never renders in a fallback face on first launch.

## Motion

- Each page runs one intro timeline when it becomes the current page and replays when revisited.
- Looping ambient motion (floating avatars, pulsing pins, heartbeat, twinkling dots) runs only on the visible page.
- Illustration and copy move at different parallax rates during swipes; indicator dots interpolate with the scroll position.
- With the OS "reduce motion" setting on, scenes render in their final state with no loops.

## Structure

```
lib/
  core/
    layout/      artboard scaling
    motion/      MotionStage, Reveal, Floating, PulseRing, page value
    painting/    dashed paths, dot world map, brand mark
    theme/       colors, shadows, typography, theme
    widgets/     PhotoTile, AvatarBadge, SurfaceCard, SpecialtyTile, DotCluster
  features/onboarding/
    data/           page copy and showcase content
    presentation/   screen, page, indicator, button, illustrations
```

`Get Started` advances to the next page and calls `OnboardingScreen.onCompleted`
on the last one.
