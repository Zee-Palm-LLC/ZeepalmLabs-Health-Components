# Trailglow

A premium night-running UI prototype: real Mapbox map, glowing mock routes,
simulated run telemetry. Four screens — Pre-Run, Live Run, Run Summary and the
Lifetime Heatmap — sharing one persistent map that flies between them.

## Mapbox token

The token is never committed. Copy the example file and drop your **public**
token in:

```bash
cp mapbox.example.json mapbox.json
```

```bash
flutter run --dart-define-from-file=mapbox.json
```

`mapbox.json` is gitignored. `MAPBOX_STYLE_URI` is optional and defaults to
Mapbox Standard, which the app then reconfigures at runtime: `lightPreset:
night`, monochrome theme, 3D objects on, POI and road labels off.

Without a token the app runs on a built-in vector renderer that draws the same
city, routes and heatmap from the same scene description, and shows a small
`VECTOR PREVIEW` badge. That path also covers web, desktop and widget tests,
where the Mapbox SDK (iOS/Android only) cannot run.

## Running

```bash
flutter run --dart-define-from-file=mapbox.json
```

```bash
flutter test
```

## How the map works

Both renderers consume one immutable `MapScene` (`lib/services/map_scene.dart`):
trail lines with a progress value, markers, optional heatmap data and a camera
request. Controllers build scenes; screens never talk to Mapbox.

- `lib/services/mapbox_renderer.dart` turns a scene into GeoJSON sources plus
  layered `LineLayer`s — a wide blurred halo, a mid glow and a sharp core with a
  `line-gradient` along `line-progress` and `line-trim-offset` for live
  progress — plus a `HeatmapLayer` for the lifetime view.
- `lib/services/painted_map/` is the fallback: a web-Mercator projection, a
  painted Manhattan (water, park, block extrusions, road hierarchy, labels) and
  the same layered trail drawn with `Canvas`.

Camera padding is measured from the real panel heights at runtime, so a fitted
route is always framed in the visible slice of map rather than behind the glass.

## Routes

Routes are not random polylines. `lib/data/mock/city_grid.dart` reconstructs the
Manhattan street grid — origin at Columbus Circle, 29° rotation, 80.5 m blocks,
real avenue offsets — so a route authored as `[street, avenue]` pairs lands on
actual streets and matches the Mapbox basemap underneath. The reconstruction is
accurate to within about 45 m against the real corners of Central Park.

Distances and elevation gain are computed from the geometry, so the numbers on
screen agree with the line on the map.

## Simulation

The live run is a `Ticker`-driven simulation at 12x wall clock, so a 45-minute
run reads in a few minutes. Pace modulates progress (warm-up, mid-run drift,
finishing kick); heart rate, calories and splits derive from it. Nothing touches
GPS, HealthKit, Health Connect or a network.

Finishing the default Riverside Loop lands on the designed reference numbers
(8.42 km, 44:41, 5:18 /km, 154 bpm, 612 kcal, 84 m). Finish early and the
summary derives consistent numbers for the distance actually covered.

## Structure

```
lib/
  app/        config, routes, theme
  controllers/ map, pre-run, live run, summary, heatmap
  data/       models + mock city, routes, runs, heatmap
  services/   map scene, Mapbox renderer, painted renderer
  screens/    one folder per screen with its own components/
  widgets/    shared glass, chrome, buttons, charts
  utils/      geo maths, formatters
```

## Android toolchain

`mapbox_maps_flutter` 2.31 does not build under AGP 9 with Flutter's built-in
Kotlin, so `android/` is pinned to AGP 8.11.1 / Kotlin 2.2.20 / Gradle 8.14.
