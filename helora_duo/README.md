# Helora Duo

A calm health dashboard that reflows between a phone and an open iPhone Duo (book-style foldable).

- **Phone (narrower than 720 pt):** one Today column with a tab bar (Today, Trends, Meds, Profile). Medication names are veiled until you tap "Show names".
- **Open Duo, tablet or wide window:** Today on the left, Trends on the right. On a foldable the split follows the hinge the OS reports (`MediaQuery.displayFeatures`); elsewhere it is a centred 40 pt gutter. Content keeps 24 pt clear of the seam on both sides, and Trends slides in from the right as the spread opens.

Demo data lives in `lib/core/data.dart` (the same 62 bpm everywhere). Icons are Phosphor line paths drawn by `lib/core/glyphs.dart`.

```bash
flutter test
flutter test --dart-define=SNAP_DIR=<folder>   # also writes PNG snapshots
```
