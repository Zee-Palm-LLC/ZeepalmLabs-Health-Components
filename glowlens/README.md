# GlowLens

A skincare app that maps your face, detects wrinkles and recommends
treatments. Rebuilt from a three-screen reference (Products, Wrinkle
Detection, Analytic), then extended with a splash, product detail, bag,
profile and a lot of motion.

## Screens and motion

**Splash.** A gradient ring draws around the sparkle mark as it spins in on
an elastic curve, "GlowLens" rises letter by letter, then the app opens
through a circular reveal.

**Home**
- A dashboard, not the scanner: greeting, a holographic Skin Health Score
  card with a live mini face-scan preview and a **Start Face Scan** button,
  detected-area cards (tap for detail), today's routine with steps you tick
  off, and recommended products.

**Face Scan** (opens from Start Face Scan, the centre sparkle button, or
Upload Photo on Analytic, through a circular reveal)
- The face mesh (65 points, 170 edges measured on the photo) draws itself
  outward from the nose: points pop, edges grow between them, and the corner
  brackets breathe.
- Idle: points twinkle, light comets run along random edges, a pastel aura
  breathes behind the head and sparkles drift up around it.
- Drag or hover to tilt the portrait in 3D; the mesh moves with depth. Tap
  the face and a ripple travels through the mesh.
- **Scan Your Face**: a laser beam sweeps down and back up, lighting nodes
  as it passes, the button fills with progress, then the forehead, frown and
  crow's-feet zones glow with dashed rotating rings and labelled chips pop in.
  The button becomes **View Analysis**, which closes the scanner and opens
  the Analytic tab.
- **Upload Photo** opens a blurred sheet (selfie or gallery); choosing blurs
  the photo out and back in, redraws the mesh and scans.
- The buttons sit in a frosted glass panel anchored to the bottom of the
  screen at any height.

**Analytic**
- The pastel cards are a fragment shader (`shaders/holo.frag`): drifting
  colour blobs, a moving sheen, a dot grid, and a hue shift that follows your
  finger like holographic foil.
- The camera badge floats with ripples; glints twinkle on the upload card.
- Detected-area cards flip in one by one; tap one for a sheet that zooms into
  that area of the face with a scanning ring, a severity meter, a tip and a
  recommended product.
- Score rings sweep in with a gradient, a travelling glint and a count-up.
  Total Skin Health has animated metric bars. The Wrinkle Trend chart draws
  its line, fills the area and shows a tooltip wherever you touch it.

**Products**
- The filter selector is a liquid gradient blob that stretches between All,
  Morning and Evening; labels turn white exactly where it covers them.
- Filtering reflows the grid: cards slide to their new slots, and leaving
  ones shrink out.
- Cards tilt in 3D toward your finger. **+** flies the product image along
  an arc into the cart, which bounces as its badge counts up.
- Tapping a card opens a detail page through a shared-element hero, with
  stretch-on-pull, staggered text, star pop-ins and an add-to-bag bar.
- The bag sheet has steppers, an animated subtotal and a confetti checkout.

**Shell.** A frosted nav bar with a gradient indicator that slides between
tabs, icons that squash and bounce when selected, and a centre sparkle
button with a rotating gradient ring that opens the scanner from anywhere.
Headers turn to frosted glass as content scrolls under them.

## Assets

| Asset | Source |
|---|---|
| Inter (variable) | Google Fonts, OFL; copied from `health_quest` |
| `face.webp` | Unsplash `BOW0zIGpUGI` by Gus Tu Njana; background removed with GrabCut |
| `avatar.webp` | Unsplash `zV8CcP9Hzts` by Gursimrat Ganda |
| Product photos | Unsplash `GApPGzbUEDY` (Mockup Free), `3zULXSLyCTo` (zeliang xiao), `jnnSoT7jhBU` (Ksenia Pixelesse), `ZVKNUMXS6IA` (pmv chamara), `fffc_ysUcv4` (Trần Văn Sơn), `OPBcNzhBHxw` (Pragati Choudhari) |
| `wave.png` | Microsoft Fluent UI Emoji, MIT |

The images inside the reference screenshot are about 100 px wide, far too
small for a 3x phone, so matching high-resolution photos were used instead.
Icons, the sparkle mark, the mesh, rings and charts are drawn in code.

## Structure

```
lib/
  core/        theme, motion, routes, glyph icons, shaders, shared widgets
  data/        catalog, analysis areas, bag, scan results, face mesh
  features/
    splash/    animated intro
    home/      dashboard
    scan/      face scan screen, face mesh painter
    analytic/  cards, score ring, area sheet, trend chart
    products/  grid, card, detail, bag sheet
    profile/   profile and settings
    shell/     tabs and nav bar
shaders/       holo.frag
test/          12 tests: data, home to scanner to analytic, routine ticks,
               the area sheet, filtering and adding to bag, the sparkle
               button, every tab at 360x640, 360x740 and 412x915 with no
               overflow, and scanner buttons on a short phone
```
