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

**The other rule that decides it: if the object's shape is gameplay state, it must be code.**
Wick's candle cannot be a model under any circumstances - its radius is how much wax you have,
its bands are what you dipped in and in what order, and a blade shaving one side has to expose
the colour underneath. That is not a mesh with a skin, it is a data structure being drawn.
Before asking how many pixels tall a thing is, ask whether the game changes its shape. If it
does, the question is closed.

## The exception finally happened, and it is a PLACE

The rule at the top has held for three games: model anything judged on
silhouette at thirty pixels. Wrecking Crew's basement is the first thing here
that is genuinely the exception the rule names - "stationary, close to the
camera, and looked at while nothing else is happening" turns out to describe an
**interior you drive around inside**, every surface of it, for the whole level.

What went in, and what each one is actually doing:

- **A Poly Haven HDRI** (`abandoned_parking_1k.hdr`, 1.6 MB). Three jobs at
  once, which is why it earns its place over a light rig: it lights the room,
  it gives the wrecking ball something to REFLECT - a metal has no diffuse term
  and renders as hotspots on black with nothing to reflect - and it is what you
  see through the exit, which is the only daylight in the level and therefore
  the thing the player drives toward. Fetchable unattended:
  `https://dl.polyhaven.org/file/ph-assets/HDRIs/hdr/1k/<name>_1k.hdr`.
- **An ambientCG concrete normal + roughness**, 512px WebP, 41 KB the pair.
  Same rule as before - take the normal, leave the colour map - and the
  roughness is the other half that is also style-neutral.

The whole import is **1.6 MB and took the APK from 27.1 to 29.7**, which on a
native build is nothing. That is worth stating plainly: on the web stack every
kilobyte was a download over mobile data, and the caution around imports came
from there. **A native app does not have that constraint**, and the asset rules
written under it need re-reading rather than re-applying.

### Poly Haven's API, searched by keyword

`curl -s "https://api.polyhaven.com/assets?t=hdris"` returns 994 HDRIs and
`?t=models` returns 521, both as one JSON object keyed on the asset id - so a
keyword filter over the keys and names is the whole search. For a basement:
`abandoned_parking`, `abandoned_garage`, `concrete_tunnel`,
`debris_basement_corridor`, `empty_warehouse_01`. For props:
`concrete_road_barrier`, `Barrel_01`, `caged_hanging_light`,
`modular_industrial_pipes_01`, `fire_hydrant`. `api.polyhaven.com/files/<id>`
gives the download URLs and exact byte sizes per resolution.

### Audio is still the gap, and the answer is probably to GENERATE it

Checked again on 2026-09-08: **Kenney's asset URLs are not guessable** (every
attempt 404s; the site needs a browser session), and **freesound still requires
an API key**. So the two CC0 audio libraries worth having are both unavailable
unattended.

For a Godot game the web stack's answer - synthesise at runtime through Web
Audio - does not carry over cleanly, and writing a synth against
`AudioStreamGenerator` in GDScript is real work for a phone's CPU. **The better
route is to generate the WAVs offline with a short Python script and commit
them**: a concrete impact is a filtered noise burst with a fast attack over a
low thump, rubble is layered short grains, a collapse is a descending rumble.
Deterministic, no licensing, no runtime cost, and the pitch jitter that stops a
repeated sound becoming a machine happens at playback.

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

### Verified: ambientCG, end to end

CC0 PBR textures, no key, and the one source that goes from search to a shipped file without
a browser. This is the whole pipeline, run on 2026-09-07 to put real rock into Coreward:

```bash
# 1. search (displayData gives you tags to choose on)
curl -s "https://ambientcg.com/api/v2/full_json?type=Material&q=rock&limit=40&include=displayData"

# 2. the download is one zip of the whole PBR set - 9 MB at 1K-JPG
curl -sL "https://ambientcg.com/get?file=Rock035_1K-JPG.zip" -o r.zip && unzip -q r.zip -d r

# 3. take the ONE map you want and shrink it. three.js wants NormalGL, not NormalDX
npx sharp-cli -i r/Rock035_1K-JPG_NormalGL.jpg -o out.webp resize 384 384 -- webp -q 70
```

**Take the normal map and leave the colour map.** This is the rule that lets a photographed
texture into a stylised game at all: a normal map carries no colour, so every surface keeps the
hand-tuned palette it already had and gains relief. The colour map from the same download would
drop a photograph into the middle of a flat-shaded low-poly world, which is the join that shows
in the first frame. Half of a photoreal asset is style-neutral; ship that half.

**Size it from physical pixels, not from what the download offers.** On an S26 Ultra at a pixel
ratio capped to 2 a Coreward cell is about 118 physical pixels. Tiling one texture across four
cells means it is displayed at roughly 470 px, so **384 x 384 is native** and 1K is three
quarters of a megabyte thrown away. Measured WebP sizes for that normal map: 256 q82 **26 KB**,
384 q70 **45 KB**, 512 q70 **84 KB**. Do this arithmetic before downloading, not after.

**A normal map is already compressed; gzip does nothing.** Coreward's code and HTML gzip to
161 KB and the 46 KB texture is 46 KB on the wire - a 29% bigger download for the largest
surface in the game. That is worth knowing before adding the second one.

**`sharp` is the tool and it does not need to be a repo dependency.** The conversion is run by
hand once; install it in a scratch directory, commit the output. Windows has no ImageMagick, and
`C:\Windows\system32\convert` is a disk utility that will happily not be what you meant.

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

**On Godot, generate at BUILD time and commit the WAVs.** The web stack synthesises at
runtime because Web Audio does the arithmetic in C++; GDScript does it in GDScript, at about
a million samples a second. Stillwater's four music beds alone are four million samples,
which is four seconds of a black screen on the phone. A `SceneTree` script that writes
16-bit mono WAVs by hand is thirty lines, runs headless, and is deterministic - same seed,
same bytes - so re-running it and getting a diff means something actually changed.

Two measurements from doing it:

- **22050 Hz mono is enough** for water, wind, wood and low sine tones, and it halves a
  library that would otherwise be most of the APK. Nineteen sounds, including three
  eight-second ambience loops and four sixteen-second music beds, came to 4.0 MB.
- **That 4 MB cost +3% APK, not +14%.** Godot compresses WAVs on export: 27.80 MB against a
  26.98 MB budget, inside tolerance without a re-record. Do not pre-emptively downsample or
  trim loops to protect a size budget that is not actually under threat.

### The Godot .hdr import default is a TRAP, and it cost 14 MB

Measured on Stillwater, 2026-09-09. Godot imports `.hdr` **uncompressed** by
default (`compress/mode=0`): a 1024x512 panorama becomes a 2.1 MB `.ctex`, and six
of them took the APK from 27.8 MB to **41.7 MB** - a 55% jump against a 10% size
budget. The `.hdr` files on disk are only 1 MB each, so nothing in the repo looks
wrong; the growth is entirely in `.godot/imported`.

The fix is two lines per `.import` file:

```
compress/mode=2          # VRAM compressed - ASTC on Android, BPTC on desktop
process/size_limit=512
```

**2.1 MB becomes 175 KB, and on a sky it is invisible.** A game sky is tinted,
greyed, darkened and fogged before anyone sees it, and the water reflecting it
blurs it further - 512x256 is plenty. Final APK 29.2 MB, +8.3%, inside budget.

Check `ls -laS .godot/imported` after any import. It is the only place the real
cost shows.

### For a game with a day cycle, take a SERIES from one location

Poly Haven's `qwantani_*` set is dawn / morning / afternoon / dusk / night from
one spot, all `puresky`. Because the cloud structure is consistent between them
they crossfade cleanly, which a set assembled from five different locations does
not.

Two things worth knowing:

- **`puresky` variants are sky only** - no terrain, no horizon clutter. Essential
  wherever the horizon is water, because anything baked into the lower half of
  the panorama gets reflected in it. The first attempt used a non-puresky dawn
  and put African savanna hills across a drowned English valley.
- **A panorama is one fixed photograph.** If the game's look is a continuous
  curve - time of day, weather, depth - `PanoramaSkyMaterial` fights it, because
  swapping panoramas at each step is exactly the hard cut the curve exists to
  avoid. A ~20-line `shader_type sky` that samples TWO panoramas and crossfades
  them, then applies the same tint and darkening everything else gets, keeps both.
  Multiply a separate cloud panorama in for weather rather than blending toward
  it, so a storm at dusk stays lit dusk-coloured.

**Generated also beats downloaded on COHERENCE, which is the argument that matters.** A
fishing game needs about twenty sounds that belong to each other - the reel click and the
drag buzz are the same mechanism, the calm pad and the deep pad are the same chord - and an
asset pack gives you twenty that belong to twenty other games. Generated, the whole set
shares one key, one sample rate and one family of envelopes and is coherent by construction.
It also turns the brief into a parameter: "happy but eerie, then worse" is a detune value
rather than a second shopping trip.

---

## Search the libraries before deciding a game is unservable — the hit rate is per-SUBJECT

Wick found nothing (no wax, no candles) and the conclusion drifted toward "these libraries
never have what we want". That is wrong, and it is worth stating as a rule: **the hit rate is a
property of the subject, not of the library.** Queried on 2026-09-08 for a lake-and-boat
fishing game, Poly Haven alone covers most of the set dressing:

- `modular_wooden_pier` — a dock, and modular, so a whole shoreline is one import
- `ship_pinnace`, `dutch_ship_medium` — a small boat, and a wreck
- `ocean_buoy`, `lateral_sea_marker` — the only things on open water that are not water
- `coast_rocks_01`–`05`, `coastal_cliff_01/02/04`, `coast_line_01/02` — shoreline and cliffs
- `fir_tree_01`, `pine_tree_01`, `island_tree_01`–`03`, `dead_tree_trunk`, `tree_stump_01`
- `fishermans_hat`, `fish_knife`, `life_jacket`, `wooden_bucket_01`, `wicker_basket_01`
- `treasure_chest`, `can_rusted`, `metal_detector`, `rubber_duck_toy`, `old_military_crate` —
  a junk-catch table straight off the shelf, which is a *mechanic* fed entirely by imports

And ambientCG has `Rope001` and `Net002A/003A/004A` — actual rope and netting as PBR sets.

**The two-minute API query is the research step and it is cheap.** Do it before designing the
art direction around what you assume is unavailable, and record the misses too: neither
library has a single fish, and ambientCG still has no water, liquid or ripple material.

## The exception is a SITUATION, and "the vehicle you sit in" is one of them

The rule at the top has now named three: Wrecking Crew's basement (an interior you drive
around inside), Coreward's landing pad, and — from the fishing game's design pass — **the
dock you tie up to every session and the boat you sit in for the entire game**. All three are
the same description: stationary, close to the camera, and looked at while nothing else is
happening.

The useful sharpening is that **a first-person or near-camera vehicle is automatically the
exception**, because it is the one object on screen for one hundred per cent of play time at
one hundred per cent of its real size. Ask how many pixels tall a thing is *and for how long*.

## What has actually been imported, ever

| Game | Asset | Size | Verdict |
|---|---|---|---|
| Coreward | Chakra Petch, 2 weights, self-hosted | 20 KB | Clear win. Changed every screen |

Checked again on 2026-09-07 for Wick, a candle game, and the sources are exactly as useful as
the table above says: Google Fonts fetched cleanly (8 woff2 faces for a warm rounded family,
~20 KB), **Poly Haven's model API has nothing candle-related beyond a lantern and a shelf** and
is photoreal anyway, and **ambientCG returns `numberOfResults: 0` for wax**. Both APIs work;
neither had anything to sell. The thing that made that game look finished was not an asset at
all - it was making the avatar a real light source in a dark room.
| Coreward | ambientCG Rock035, **normal map only**, 384², WebP | 46 KB | Clear win. Flat facets became rock |

Both are things the player reads at full size, which is the rule at the top of this file doing
its job. Nothing modelled has ever been worth importing. Procedural generation plus flat-shaded
low-poly has carried two games to a finish. The right question is never "what can I import"
but "what is the player looking at long enough to notice".
