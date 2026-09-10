# Aegis

Flutter implementation of the Aegis emergency flow: SOS home, responder
tracking and arrival confirmation.

## Running

```sh
flutter pub get
flutter run
```

Hold SOS for three seconds. The tracking screen then plays the journey out —
the ambulance crosses the map, the ETA counts down, the timeline advances — and
hands over to the arrival screen when the responder gets there, about six
seconds later.

To open a screen directly for review:

```sh
flutter run --dart-define=AEGIS_SCREEN=/tracking
flutter run --dart-define=AEGIS_SCREEN=/arrived
```

### Satellite map

The tracking map uses Esri World Imagery through ArcGIS Location Platform,
which requires an access token:

```sh
flutter run --dart-define=ARCGIS_API_KEY=your_token
```

Without a key the map shows a plain dark surface with the route and markers;
everything else on the screen behaves the same.

## Structure

```
lib/
  app.dart                 routes, and the transition each one arrives with
  theme/
    aegis_theme.dart       colours, fonts, shared text styles
    motion.dart            durations, curves, the reduced-motion check
  emergency/
    models.dart            immutable data passed into screens
    formatting.dart        coordinates, distance, ETA, clock times
    route_path.dart        a polyline measured by distance
    preview_data.dart      stand-in values from the design reference
    sos_home_screen.dart
    responder_tracking_screen.dart
    arrival_screen.dart
    widgets/               pieces shared between screens, plus the SOS
                           control, map and progress stepper
```

Screens take plain data and callbacks. Nothing reads from a service directly,
so real sources can be connected in `app.dart` without touching UI code.

## Motion

Timings and curves live in `theme/motion.dart`; nothing hardcodes its own.

Each screen owns a single controller and staggers its contents off it through
`Reveal`, rather than giving every element a ticker of its own.

Decorative loops — the SOS button's breathing, the beating heart, the blinking
GPS dot, the map's radar sweep — check `reduceMotion(context)` and park
themselves when the platform asks for reduced motion. Feedback the user is
waiting on, like the hold ring and the countdown, always plays.

Because the idle loops never stop, **`pumpAndSettle` will time out** on these
screens. Tests pump explicit durations instead; see
`test/sos_hold_button_test.dart`.

### The journey

`ResponderTrackingScreen` simulates the dispatch itself, which is what makes
the flow reviewable end to end without a backend. `RoutePath` measures the
polyline so the vehicle moves a fraction of its *length* rather than a fraction
of its points, and the road behind it fills in solid while the road ahead stays
dashed.

To drive it from a real feed instead, pass `autoAdvance: false` and rebuild with
a `Dispatch` from the wire. The screen then renders exactly what it is given and
never calls `onArrived`.

## Open items

- **Data.** Heart rate, location, contacts and dispatch all come from
  `PreviewData`. Replace with the wearable, location and dispatch sources.
- **Contact photos.** `PreviewData._portrait` points at `i.pravatar.cc` so the
  review build shows faces. Swap it for the real source — `PersonAvatar` only
  needs an `ImageProvider`, so a bundled `AssetImage` or a signed URL drops
  straight in, and anything that fails to load falls back to an initials tile.
  Note this means the review build fetches portraits over the network.
- **Logo.** `AegisLogo` is a painted approximation of the mark. Swap in the
  real SVG when available.
- **Unwired actions.** Settings, the more menu, calling the responder and
  "You're in good hands" have no destination yet. Their buttons render as in
  the design but are disabled.
- **Fonts.** Source Serif 4 (display optical size) and Inter, bundled as static
  instances under the SIL Open Font License (see `assets/fonts/`).
