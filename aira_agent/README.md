# Aira

A voice-first AI agent builder, rebuilt from a three-screen reference
(Home, Voice, Chat) and animated as one continuous scene.

## Screens and motion

The three screens share one living background: an orange sky with a soft
dark "void" whose shape, blur and red fringe were fitted numerically to the
reference. It never cuts between screens. It morphs, so the void grows under
the orb when you start talking and stretches into a column when the chat
opens.

**Home**
- On launch the logo draws itself stroke by stroke as it spins in, the
  greeting slides in, the header buttons pop, the headline rises word by
  word, the suggestion cards sweep in from the right, the input panel rises
  and the mic springs in.
- Sparkles on the cards twinkle in turn, the bell swings now and then, and
  the mic breathes a soft glow.
- Tap a card: it morphs into your chat bubble (dark card to orange bubble,
  old label out, new text in) and the chat opens.
- Type in the panel: the mic turns into a send arrow, and sending flies your
  text into the first bubble.
- Popovers spring out of their buttons: alerts (bell), recent chats (menu)
  and the model picker (Opus 4.8), whose chevron flips.

**Voice** (tap the mic)
- The orb blooms out of the mic button while the mic arcs to the centre, the
  controls spread out from behind it and a ring draws around it.
- The orb is a fragment shader (`shaders/orb.frag`): soft molten blobs of
  cream, amber and ember swirl inside a sphere with a rim light, and they
  churn harder while you speak.
- Words arrive as they are heard in grey and turn white once confirmed,
  exactly the grey/white split in the reference. Ripples leave the mic in
  time with the voice level.
- Pause (or tap the orb or mic) freezes the transcript and calms the orb.
  Send, or two seconds of silence, sends it.

**Chat**
- The transcript morphs into the first orange bubble while the orb shrinks
  and curves down into the avatar slot, where it becomes Aira's avatar. The
  mic drops into the input bar.
- Aira thinks (bouncing dots in a small bubble), then the bubble springs to
  full size and the reply streams in word by word. Avatars keep swirling
  while Aira is speaking.
- In the demo Aira's follow-up question gets typed and sent for you, which
  lands exactly on the reference screen, ending with a shimmering
  "Aira is working...". Type anything yourself and Aira replies instead.
- **Close chat** cascades the messages away and brings Home back.

## Performance

- One `AnimationController` drives every screen transition. Each screen reads
  it directly instead of pushing routes, so there is no route overlay cost.
- The background repaints only during transitions. At rest it is a cached
  picture: one gradient and two blurred rounded rects that the engine blurs
  analytically.
- The film grain is a 128 px tile generated once and drawn as a repeating
  image shader in its own layer.
- No `BackdropFilter` anywhere. Glass surfaces are translucent fills.
- The orb shader is cheap (a few blobs plus two noise lookups). Chat avatars
  stop ticking once Aira finishes speaking.
- Every animated piece (orb, ring, sparkles, mic, dots, shimmer) sits in its
  own `RepaintBoundary`. The chat's top fade mask only exists when the list
  can scroll.

## Layout

- Measured from the reference at 393x852. The top is anchored to the status
  bar inset and the bottom to the system inset: the home dock, the voice
  controls and the chat input all sit above the home indicator or gesture
  bar.
- On short screens the orb shrinks so nothing collides. The keyboard lifts
  the home panel and the chat input bar.
- Font sizes were calibrated by measuring text widths in the reference
  against Inter's metrics. The headline uses Inter's display optical size.
- The mic and speech recognition are simulated. Swap `Director._listen` for a
  speech-to-text stream to make them real.

## Structure

```
lib/
  core/       theme, motion helpers, glyph icons and logo, shared widgets
  data/       conversation model and script
  scene/      stage (scene state + shared-element flights), director
              (voice simulation, replies), atmosphere, orb, frame geometry
  features/
    home/     home screen and popovers
    voice/    listening screen
    chat/     chat layout engine and chat screen
shaders/      orb.frag
test/         flows, popovers, model picker, every scene at 360x640,
              360x740, 393x852 and 412x915, and a frame-by-frame snapshot run
```

Set `SNAP_DIR` (and optionally `SNAP_W`/`SNAP_H`) when running
`test/snapshot_test.dart` to write every scene and transition frame as PNG.
