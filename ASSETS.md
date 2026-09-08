# ASSETS.md

Where to get things we did not make, how to fetch them, how to shrink them, and — the part
that matters most — **when not to bother**.

**Current state, not history.** Rewrite in place. Every "verified" claim below was tested
from this machine on 2026-09-07; re-test before trusting one that looks stale.

---

## The rule that decides everything else

> **Import what the player reads at its real size. Model in code anything that is thirty
> pixels tall and judged on silhouette.**

Type, UI art, icons, sound, textures and music are read at full size — a better one is
better, immediately, on every screen. A ship sprite thirty pixels tall is read as a
*shape*, and a downloaded model brings its own topology, normals and sense of scale that
will not match hand-tuned flat shading. The join shows in the first frame.

This was learned the expensive way. Repainting Coreward's drill per upgrade tier was
correct, cost nothing, and was **completely invisible** at play scale; it had to be replaced
with a change to the *number* of sparks to read at all. Before importing a model, ask how
many pixels tall it will be. Under about sixty, the answer is usually to model it.

**The exception worth naming:** an object that is stationary, close to the camera, and
looked at while nothing else is happening. Coreward's landing pad qualifies. That is a
description of a *situation*, not of an object — look for the situation in a new game rather
than assuming "the pad".

---

## Sources, ranked by usefulness to us

| Source | Licence | Fetchable unattended? | Best for |
|---|---|---|---|
| **Google Fonts** | OFL | **Yes, verified** | Type. The highest-value import there is |
| **Poly Haven** | CC0 | **Yes, verified JSON API** | Photoreal props, textures, HDRIs |
| **ambientCG** | CC0 | **Yes, verified JSON API** | PBR textures |
| **Kenney** (kenney.nl) | CC0 | No — session redirect, needs a browser | Stylised 3D/2D/UI/audio kits, one consistent style |
| **Quaternius** | CC0 | No — HTML site, no API | Low-poly models, animated characters |
| **Poly Pizza / Icosa** | mostly CC-BY | API needs a key | The archived Google Poly library |
| **OpenGameArt** | mixed — check each | No | Odds and ends; licence per asset |

**For a stylised low-poly game, Kenney and Quaternius are the right style** and neither can
be fetched without a browser. Claude can drive one — but a download that needs babysitting
is a different kind of cost, so it is worth doing once for a whole kit rather than per
asset.

### Verified: Google Fonts, self-hosted

Do not link a font CDN from a PWA. An external stylesheet is a request that fails offline,
and a font that arrives late reflows the whole HUD on the first frame the player sees.

```bash
# 1. Ask for the CSS with a browser UA, or you get TTF instead of woff2
curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36" \
  "https://fonts.googleapis.com/css2?family=Chakra+Petch:wght@500;700&display=swap" > /tmp/f.css

# 2. The latin subset is the block above `unicode-range: U+0000-00FF`
grep -B7 "U+0000-00FF" /tmp/f.css | grep -E "font-weight|src: url" | paste - -
```

Then `@font-face` with a relative `src` in `public/fonts/`, and — the step that is easy to
miss — **add `woff2` to the Workbox glob**, or the installed app falls back to a system face
offline:

```js
globPatterns: ['**/*.{js,css,html,svg,webmanifest,woff2}']
```

Two weights of a latin subset is about **20 KB**, less than a third of Coreward's own code,
and it changes every screen in the game. This is the single best asset import available.

### Verified: Poly Haven

521 CC0 models plus textures and HDRIs, with a real API and no key:

```bash
curl -s "https://api.polyhaven.com/assets?t=models"      # list, ~520 entries
curl -s "https://api.polyhaven.com/files/Barrel_01"      # download URLs, per resolution
# -> https://dl.polyhaven.org/file/ph-assets/Models/gltf/1k/Barrel_01/Barrel_01_1k.gltf
```

Photoreal, so the wrong register for anything stylised — but it is the one 3D source that
can be scripted end to end, and its textures are useful regardless of art style.

### Verified: ambientCG

```bash
curl -s "https://ambientcg.com/api/v2/full_json?limit=1"
```

CC0 PBR textures, no key. Good when a procedural texture has stopped being convincing.

---

## Shrinking what you import

`gltf-transform` is the tool. **Verified working, v4.5.0 via npx**, no install needed:

```bash
npx @gltf-transform/cli optimize in.glb out.glb \
    --compress draco --texture-compress webp
```

- **Draco** compresses geometry; **Meshopt** compresses geometry, morph targets and
  animation. Meshopt if the model is animated.
- **WebP** for textures, or **KTX2/Basis** when VRAM matters more than file size.
- **Halve texture resolution for mobile.** A 4k texture on a phone is wasted bandwidth and
  wasted VRAM; 1k is usually indistinguishable at the sizes anything is viewed at.

Loading a `.glb` costs `GLTFLoader` in the bundle, an async fetch, and a precache entry.
That is a real cost — worth paying for a hero asset, not for scenery.

---

## Audio

**Everything so far has been synthesised at runtime with Web Audio, and it has been the
right call.** No files, no loading, no licensing, no precache entries, and the score can
respond to game state in ways a recording cannot — Coreward's music has layers that mix in
by depth, danger and zone off one scheduler.

Import audio only when a synthesised version has actually been tried and is not good enough.
If it comes to that: Kenney's audio packs are CC0, and freesound.org is a large mixed-licence
library that needs an API key.

Things worth knowing about Web Audio, learned rather than looked up:

- Chrome **refuses to create an `AudioContext` outside a user gesture**. Build the graph on
  first touch, and build it atomically — publish the whole graph or none of it, so one null
  check narrows everything.
- **Vertical layering needs one tempo, one key and one harmony.** A procedurally generated
  score gets that free, since it all comes off one scheduler.
- **Fade times should not match.** Places arrive slowly, about a second and a half. Alarms
  snap in over a quarter second and leave lazily — late is useless for an alarm, and one
  that vanishes the instant you fix the problem teaches nothing about how close it was.
- **Route an alarm past whatever is muffling everything else.** If a lowpass closes with
  depth, the danger layer has to bypass it, because the moment it needs to be heard is
  exactly the moment everything else is being darkened.

---

## What has actually been imported, ever

| Game | Asset | Size | Verdict |
|---|---|---|---|
| Coreward | Chakra Petch, 2 weights, self-hosted | 20 KB | Clear win. Changed every screen |

That is the whole list, and it is not an accident. Procedural generation plus flat-shaded
low-poly has carried two games to a finish. The right question is never "what can I import"
but "what is the player looking at long enough to notice".
