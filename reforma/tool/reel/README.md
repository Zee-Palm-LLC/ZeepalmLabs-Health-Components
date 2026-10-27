# Reforma showcase reel

A 30 s, 1920×1440, 60 fps showcase (ZeepalmLabs showcase format) recorded from
the real app screens — not a screen capture. A Flutter test drives the app with
an exact 1/60 s clock and a scripted finger, so every frame is evenly spaced
regardless of machine speed.

1. **Render frames** (≈1800 PNGs, a few minutes):

   ```bash
   REEL_OUT=build/reel/frames flutter test tool/reel/render_reel_test.dart
   ```

   4:5 Instagram cuts (1080×1350): `REEL_FORMAT=4x5-phone` (phone only, no text) or
   `REEL_FORMAT=4x5` (captions above the phone).
   Quick preview of every 30th frame: add `REEL_EVERY=30`. Stop early: `REEL_UNTIL=12`.
   Inter is fetched by google_fonts during the run (network needed once).

2. **Encode** (H.264 High + AAC, synthesized soundtrack timed to the script's cues):

   ```bash
   node tool/reel/server.js build/reel/frames
   ```

   Open http://localhost:8771 in Chrome/Edge and press **Encode**. The MP4 is
   written to `build/reel/Reforma-Showcase-30s.mp4`.

Files: `lib/reel/reel_stage.dart` (stage, captions, finger, intro/outro),
`tool/reel/render_reel_test.dart` (script + frame capture),
`tool/reel/encoder.html` (WebCodecs encoder, soundtrack, MP4 muxer).
