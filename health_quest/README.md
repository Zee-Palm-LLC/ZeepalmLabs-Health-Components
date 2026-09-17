# Health Quest

A gamified wellness app built from one reference mockup and one supplied
avatar clip. Onboarding, sign-up and log-in, four tabs, the pages on top of
them, a victory screen, and a full set of synthesised sound effects.

The flow: **Onboarding → Sign up → Choose your main quest → the game.**
Log in is one tap from sign-up, and signing out lands there.

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

5. **Stats.** The character sheet: a four-axis power radar, each stat's level
   and progress, XP earned by day or by week with a tappable bar chart, and
   personal records.
6. **Profile.** The player card (level, XP, streak, quests, badges), a badge
   showcase fed by the vault, achievements in progress, a five-week activity
   heat map, and the way into the pages below.
7. **Leaderboard.** The weekly league, friends or global: a podium for the top
   three, a ranked list with your row lit, and a challenge on every rival.
8. **Notifications.** Today and earlier. Unread messages glow and pulse;
   opening one reads it, and there is a read-all key.
9. **Settings.** Sound on or off, a ten-step volume dial you set by ear, a
   fanfare to test it with, haptics, reminders, replay the intro, sign out.
10. **Victory.** Claiming a finished quest's XP: god rays, the trophy slams in,
    the XP counts up with the streak multiplier, and a level-up banner when
    it tips you over. The bell and the quest's options key are live too.

## Accounts

- **Sign up** is character creation, step 1 of 2: hero name, email, and a
  password rated like loot (weak, decent, strong, legendary) on a four-cell
  gauge, plus the terms. Google and Apple skip the form.
- **Choose your main quest** is step 2: Move more, Hydrate, Calm mind or
  Sleep well, each with its starter quest, and a difficulty from Casual to
  Legend. Begin adventure charges up, levels up, and opens the game with the
  hero's name on the dashboard and the path on the player card.
- **Log in**: email, password with a reveal toggle, remember me, providers,
  and a link to sign up.
- **Forgot password**: the email, a send key, then a confirmation that says
  where the link went, with resend.

Every field lights while focused and ticks when it takes focus. A refused
form shakes, plays the denied sound and says under each field what is wrong.
Nothing is sent anywhere: the forms validate locally and the flow is UI.

What the player earns and spends lives in `GameState`, not in any one screen,
so XP claimed on a quest is on the dashboard, and a badge bought in the vault
is on the profile.

## Sound

Every sound is synthesised by `tool/sfx/generate_sfx.py` from oscillators,
envelopes and filtered noise, in the register of an 8/16-bit arcade game.
Nothing is sampled or downloaded, so there is nothing to license. Retune a
sound there and run it again to regenerate `assets/sfx/`.

| Sound | When |
| --- | --- |
| `tap` | Any key, the moment it goes down |
| `nav` | Switching tabs or segments |
| `back` | Leaving a page |
| `open` | A page, sheet or dialog coming up |
| `toggle_on` / `toggle_off` | Switches |
| `tick` | Chart bars, the volume dial, reading a notification |
| `confirm` | Positive actions: challenges, read-all, dialog confirm |
| `coin` | XP changing hands: claiming a badge, the victory count landing |
| `denied` | A badge you cannot afford or have not unlocked |
| `charge` | The start button charging, exactly as long as its 1.2 s animation |
| `level_up` | The onboarding level-up, a real level-up, the settings test |
| `victory` | Cashing in a finished quest |

**Staying in sync.** A key's click and haptic fire on press-down, on the same
frame its spring starts pulling it in, not on release a finger-lift later.
Sounds tied to an animation are cued by that animation's controller, so the
coin lands as the XP counter stops rather than on a timer that could drift.

**Engines.** In the browser, sounds are decoded once into Web Audio buffers
and started on the audio clock, about 3 ms from press to sound. An `<audio>`
element per sound, which is what audioplayers uses on the web, starts 50 to
150 ms late and has to pause, seek and play to restart. On Android and iOS a
small pool of pre-loaded audioplayers voices per sound (SoundPool on
Android) mixes with the player's music and respects the silent switch.

All of it goes through `GameAudio.play`, which respects the sound setting
and volume. Tests swap in a `RecordingSfxEngine` and assert on what played.

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
| Every press | `Pressable`: a real spring on a `Ticker`. Release mid-press and it continues from the current velocity, which a tween cannot do. The sound and haptic land on press-down. |

## Bugs worth keeping in mind

- **`Pressable` created its ticker lazily.** For a button nobody ever pressed,
  first use was `dispose`, where `createTicker`'s lookup of the `TickerMode`
  ancestor is illegal. It is built in `initState` now.
- **No `Material` above a pushed route.** The dashboard and the quest detail
  are their own routes, and without a `Material` ancestor every `Text` renders
  with Flutter's yellow unmaterialised underline. Both are `Scaffold`s now.
- **Silent on the web after adding audioplayers.** The web plugin registrant
  was cached from before the package was added, so every call hit a missing
  plugin and nothing played. The tests could not see it: they run silent.
  After adding a plugin, `flutter clean` before `flutter build web`.

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

## App Store screenshots

Eight store screenshots live in `store/app_store/`: `iphone_6_9` at
1290 x 2796 for the 6.9" slot and `iphone_6_5` at 1242 x 2688 for the 6.5"
slot, flattened to RGB because App Store Connect rejects PNGs with alpha.
`preview.jpg` shows the set side by side.

They are rendered from the real screens rather than mocked: each one mounts the
app in a phone frame on a nebula backdrop with a headline and floating HUD
badges, drives it into the right state (the victory claimed, Hydrate picked),
and captures it at 3x. Change the copy, badges or order in
`tool/store_screenshots/store_screenshots_test.dart`, then:

```bash
flutter test tool/store_screenshots/store_screenshots_test.dart
python tool/store_screenshots/finish.py
```

The waving-hand emoji is drawn with Windows' Segoe UI Emoji, so render on
Windows or point `emojiFont` at another colour emoji font.

## Structure

```
lib/
  core/            design tokens, palette, type, settings, shader loader
  core/audio/      Sfx, GameAudio, Web Audio and audioplayers engines
  core/motion/     Pressable, entrance helpers, routes, the idle clock
  data/            stats, quests, rewards, player, game state, progress, social
  features/        onboarding, auth, home, quest, rewards, stats,
                   profile, leaderboard, notifications, settings, shell
  widgets/         hud kit, nav bar, progress ring, stardust, painters
shaders/           stardust.frag
assets/            video (the clip), hero (matted layers), sfx, fonts
tool/sfx/          the sound synthesiser
test/              42 tests: data, geometry, entrances, sign-up and log-in,
                   navigation, every page, claiming, settings, and which
                   sound played when
```

Third-party: `video_player` for the intro clip, `audioplayers` for sound on
phones, `shared_preferences` so settings survive a relaunch, `web` for Web
Audio in the browser.
