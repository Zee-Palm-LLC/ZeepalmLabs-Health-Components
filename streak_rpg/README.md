# StreakRPG

Train. Level up. Explore. A fitness RPG where your workouts become an adventure: earn XP, keep your streak and open quest chests.

It recreates the five-screen StreakRPG mockup on a 402 x 784 pt canvas, using the mockup's own art. The Workout and Quests mocks were drawn as tablet layouts, so they are rebuilt here as phone screens.

## Run

```
flutter pub get
flutter run
```

## How it was matched

- Each phone in the mockup was cropped at its inner bezel and upscaled to 3 px per pt.
- The hero (four poses), logo, chest, gift, shields and icons were cut out with ISNet segmentation or colour keys. The background plates had the UI and the cut art removed, and the holes filled with a harmonic fill.
- For the phone Workout screen, the plate is reframed so the hero keeps scale 1 and sits exactly on his own hole. The neon ceiling and floor are stretched to fill a tall screen.
- Text is set in Poppins, with each size fitted to the mockup's measured text widths and placed by baseline. Overlays of the renders on the mockup line up within about 1 to 2 pt.
- Top content is pinned to the safe top and scenes to the safe bottom, so taller phones open up the middle. Screens shorter than 768 pt scale down instead of letting content collide.

## Motion and interactions

- **Splash:** the scene fades up from night as the hero rises with a light wash, and he keeps breathing with a glowing smartwatch. The logo slams in from blur with a camera shake and a double shockwave, and the crown drops on and bursts into sparkles. A beam of light wipes on the tagline. Castle windows flicker, and stars and magic dust drift. Drag anywhere to tilt the scene in depth. "Get Started" opens a burning portal into the next page.
- **Adventure:** the titles flip in and "Adventure Awaits" shimmers. The hex badge spins in on god rays and levels up from Lv. 1 to Lv. 5, with a pulse and a burst on every level, while a spark runs around its rim. The three orbs fly out of the badge along arcs and bob (tap one for a burst). The hero does real push-ups on a platform circled by energy arcs. Each rep sends a shockwave across the platform and floats XP. "Next" warps into the app with speed lines and a flash.
- **Home:** the hero beams down in a teleport column, scans in from the feet up and lands with a shockwave. The avatar ring rotates and the online dot pulses. The streak flame flickers, throws embers and flares when tapped. The level card flips in, the shield spins with a glint, and the XP pours in while the numbers count up. The stat cards cascade in on a 3D swing and count up. The gift drops, bounces and hops impatiently; tap it to burst it open for +50 XP, which really fills the level bar. "Start Workout" warps into the workout.
- **Workout:** the timer is a counter-clockwise gold-to-teal ring with a glowing head, and its digits roll like an odometer. Pause and play morph into each other. The hero does continuous push-ups: every rep thumps the floor rings, pops "+1", counts the quest from 8 / 20, pours its bar and rolls the reps and calories. At 20 reps the chest rattles and bursts open on god rays for +200 XP. "Complete Set" pours light across the button, draws its check, throws confetti and moves sets from 1 / 3 to 2 / 3. Neon signs flicker, and fog and sparks drift.
- **Quests:** the tab pill slides between Quests, Achievements and Rewards, and the lists swap. The chest floats on turning god rays and its lid hops; tap it to rattle it. The speech bubble pops and types. Tapping a quest advances it, and finishing one turns its bar gold, stamps a check, flips the XP badge and flies the XP to your level.
- **Dock:** a floating glass bar with a faint hex-grid texture and a gold edge that brightens near the active tab, where a socket is carved into the top. A glowing orb with a rotating rune ring sits in that socket. Picking a tab makes the orb hop to the new socket along an arc, trailing sparks, and squash on landing. Quests has a pulsing count badge and Friends has an online dot. Tabs swap with a 3D depth slide in the direction of travel.

## Tutorial showcase

Each area has a game-style guided tour that plays on the first visit. "Training Grounds" on Home has 8 steps, "Arena of Iron" in the Workout has 7 and "Quest Board" has 5. The "?" button on Home replays the tour.

- A chapter banner sweeps in on speed streaks and the title slams in with a shine.
- The screen is veiled, and a spotlight glides from target to target on a spring. It is framed by marching gold dashes, targeting brackets that snap in, and a light sweep.
- Coach Kai's dialog has an ornate frame and a portrait in a turning rune ring. It shows a step counter and stretching progress pips, and types each line (tap to finish it). The dialog flips above or below the target to stay on screen.
- On "try it" steps you have to tap the real thing: open the gift, press Start Workout, bank a set or log a quest. These steps add ripple rings and a bouncing arrow. Tapping elsewhere shakes the dialog with a hint.
- Finishing a chapter bursts confetti and shows "Chapter complete" with its XP reward, which really fills the level bar. Skipping is always one tap away.

## Extra HUD detail

- **Home:** a WARRIOR rank chip, a next-level chip, a Hero Status unit frame (stamina and focus bars) beside the hero, and the tutorial button.
- **Workout:** a live heart-rate pod (the heart beats at the shown BPM), a "SET TIME / SET 1 OF 3" readout in the ring, a combo meter that pops on every rep and drops when you pause, a quest reward chip that turns to CLAIMED, and units on the stats.
- **Quests:** a Daily Chest tracker with one gem per finished quest and a live countdown to midnight, EASY/MED/HARD tags on quests, and a badge on Achievements.

## Tests

`flutter test` runs the whole flow at 402x784, 360x640, 393x852 and 430x932, and fails on any exception or overflow. The flow covers splash, portal, adventure, warp, the home tutorial (including the gift and Start Workout steps), the workout tutorial and a set, back, the quests tutorial, and the tabs. `--dart-define=SNAP_DIR=<folder>` also writes 3x renders of every screen and mid-animation frames.

## Tools

`tool/plates.py` (clean screens and background plates), `tool/cut.py` with `tool/jobs.json` and `tool/icons.json` (segmentation), and `tool/export.py` (trimmed webp assets with their pt rects) rebuild the art from the upscaled screens. Set `STREAK_ROOT` to the folder that holds the screens.

## Social reels

`test/reel` renders two 1080 x 1920 vertical reels frame by frame. Each one has a phone mockup, kinetic captions, tap markers, a camera that punches in on key moments and follows the tutorial spotlight, and a logo lockup. The app reel is 32 s and the tutorial reel is 34.5 s.

```
flutter test test/reel -j 2 --dart-define=REEL_DIR=<frames>
python tool/reel_audio.py app app.wav
python tool/reel_audio.py tutorial tutorial.wav
python tool/reel_mux.py <frames>/app app.wav StreakRPG_App_Showcase.mp4
python tool/reel_mux.py <frames>/tutorial tutorial.wav StreakRPG_Tutorial_Showcase.mp4
```

`reel_audio.py` synthesizes an original soundtrack (no samples) with sound effects locked to each reel's taps, bursts, warps and level-ups. `reel_mux.py` encodes H.264 with AAC audio normalized to -14 LUFS. Add `--dart-define=REEL_EVERY=30` to render a quick one-frame-per-second preview.
