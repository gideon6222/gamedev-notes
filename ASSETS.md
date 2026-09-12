# ASSETS.md - where to get things we did not make, and how to use them well

Current state, not history. Edited only by `/digest`. Every source below was checked on
2026-09-10; `scripts/assets.py` is the fetcher and `/asset-hunt` is the skill that runs
the search. Re-check a source before trusting a claim that looks stale.

## The rule that decides what to import

**Import what the player reads at its real size. Model in code what is judged on silhouette
at thirty pixels, and anything whose shape IS game state.**

Type, UI, icons, sound, music, textures, skies and anything permanently on screen (a
first-person interior, the vehicle you sit in, the dock you tie up to, a shop room) are read
at full size and a better one is better immediately. A ship sprite thirty pixels tall is
read as a shape, and an imported model brings its own topology and scale that will not match
the rest. A candle whose radius is how much wax you have is a data structure being drawn,
not a mesh.

**Apply it as a measurement, not a habit.** If you cannot say roughly how many pixels tall
the thing will be and for how long it is on screen, you have not applied the rule. Under
about sixty pixels, model it. Over about two hundred and permanently on screen, import it,
and modelling it is what now needs justifying. Stillwater's bucket was four hundred pixels
tall in every frame and was modelled from habit.

**On a native APK, size is not the constraint it was on the web.** An HDRI plus a PBR set
cost 1.6 MB and took an APK from 27.1 to 29.7 MB, which is nothing. Nineteen generated
sounds including music beds came to 4 MB of WAV and +3% APK because Godot compresses on
export. The web-era caution ("nothing modelled has ever been worth importing") was written
when every kilobyte was mobile data. It is retired.

**Search before deciding a subject is unservable.** The hit rate is a property of the
subject, not the library. Wax and candles found nothing anywhere; a lake-and-boat game found
its whole set dressing on Poly Haven in two minutes (pier, boats, buoys, rocks, trees, hat,
knife, life jacket, bucket, basket, junk-catch table). The two-minute API query is the
research step. Record the misses too.

## What to use for what

| Need | First choice | Second | Notes |
|---|---|---|---|
| Stylised low-poly props, vehicles, buildings, kits | **Kenney** (CC0) | **KayKit** (CC0, GitHub) | Same palette-atlas approach, mix freely |
| Rigged, animated characters and creatures | **KayKit** Adventurers / Skeletons (CC0) | **Quaternius** (CC0 or QAL) | KayKit is humans and skeletons only - no creatures. Quaternius `animated-lowpoly-dinosaurs` is the one creature pack where all six models have a Run cycle. UAL 2 has 130+ humanoid animations. Mixamo needs a browser |
| Photoreal props, hero objects | **Poly Haven** (CC0, API) | Poly Pizza (per model) | 1k textures for a phone, 2k for a hero |
| PBR textures, materials | **ambientCG** (CC0, API) | Poly Haven textures | Take NormalGL. Take the map that holds the PATTERN, strip the map that carries the STYLE |
| Skies and lighting | **Poly Haven HDRIs** (CC0) | Godot `ProceduralSkyMaterial` | `puresky` variants for water horizons; a series from one location for a day cycle |
| Textures for a stylised game | Kenney pattern and texture packs | ambientCG normals only | A photograph is mostly grain; blur hard at full size, then downscale |
| 2D sprites, tiles, particles | **Kenney** (CC0) | OpenGameArt CC0 filter | Kenney Particle Pack: 80 x 512 px |
| UI: buttons, panels, sliders, input glyphs | **Kenney UI Pack**, **Input Prompts** (touch gestures included) | | Build one `Theme` with 9-slice `StyleBoxTexture` |
| Icons | **Lucide** (ISC), **Tabler** (MIT) for UI; **game-icons.net** (CC-BY 3.0) for RPG glyphs | | SVG, `stroke="currentColor"` renders black, tint with `modulate` |
| Fonts | **Google Fonts** (OFL) | Fontsource | The single highest-value import: two weights change every screen |
| Sound effects, recorded | **Kenney audio packs** (CC0), **Sonniss GDC bundles** (royalty-free) | **Freesound** CC0 filter (key) | |
| Sound effects, procedural | **jsfxr** (node, deterministic from a code) | our own WAV generators | For anything that must answer game state |
| Music loops | **Tallbeard / Abstraction Music Loop Bundle** (CC0, itch, 200+ loops) | Kevin MacLeod (CC-BY 4.0, direct mp3) | Kenney has jingles only |
| Music, generated | MIDI via python + FluidSynth and a free soundfont | `techniques/generated-audio.md` | Coherent by construction, tempo you can nod to |
| Menus, options, pause, credits, input remap | **Maaack's Godot Game Template** (`Maaack/Godot-Game-Template`, MIT) | our own shell | The thing `/game-scaffold` installs. "Maaack's Menus Template" is a different, smaller asset-library entry - do not name it |
| Camera | **Phantom Camera** (MIT) | hand-rolled | Follow modes, dead zones, transitions |
| Shaders | godotshaders.com (check each: CC0, MIT or GPL) | | Never ship a GPL shader |
| Godot addons | GitHub release zips by tag | legacy Asset Library API | The new Asset Store has no API; the old one is going read-only |

## Style families, and mixing

- **Kenney and KayKit match each other**: flat-shaded low-poly, one small colour atlas per
  pack, so recolouring to the game's palette is one PNG edit. Quaternius is the same family,
  rounder and slightly more detailed. Take environments from any of the three, keep all
  characters from one source.
- **Poly Haven and ambientCG are photoreal** and read as a different game leaking in next
  to a low-poly kit. Use them for a photoreal game, or take only their style-neutral half
  (normals, roughness, HDRI lighting with the panorama hidden or blurred).
- **Unify whatever you mix**: one key light, one tonemap, imported materials forced to
  roughness ~0.8 and metallic 0 unless they are metal, one outline or rim treatment, scale
  normalised on import, and the atlas recoloured to the game's palette.
- Within Kenney, the "Tiny", "Scribble" and "Pixel" series each share a line weight and
  palette with their own series only.
- For an icon family pick one: Lucide and Tabler match each other (2 px stroke, 24 px grid);
  game-icons are solid glyphs.

## Fetching, unattended

`scripts/assets.py` (python 3, requests) wraps every source that can be scripted. Keys live
in `C:\dev\.env` and are never committed.

```powershell
python C:\dev\gamedev-notes\scripts\assets.py search polyhaven models pier
python C:\dev\gamedev-notes\scripts\assets.py search ambientcg wood --limit 20
python C:\dev\gamedev-notes\scripts\assets.py search kenney         # lists packs by category
python C:\dev\gamedev-notes\scripts\assets.py search freesound "reel click" --license cc0
python C:\dev\gamedev-notes\scripts\assets.py search polypizza lantern --license cc0
python C:\dev\gamedev-notes\scripts\assets.py search kaykit              # lists the 10 repos
python C:\dev\gamedev-notes\scripts\assets.py search fonts chakra
python C:\dev\gamedev-notes\scripts\assets.py search opengameart water --type music
python C:\dev\gamedev-notes\scripts\assets.py sources                    # every source the script knows

python C:\dev\gamedev-notes\scripts\assets.py get polyhaven modular_wooden_pier --res 1k --into assets/models
python C:\dev\gamedev-notes\scripts\assets.py get ambientcg Wood095 --res 1K --maps NormalGL,Roughness --into assets/textures
python C:\dev\gamedev-notes\scripts\assets.py get kenney platformer-kit --into assets/kenney
python C:\dev\gamedev-notes\scripts\assets.py get kaykit KayKit-Character-Pack-Adventures-1.0 --into assets/kaykit
python C:\dev\gamedev-notes\scripts\assets.py get font "Chakra Petch" --weights 500,700 --into assets/fonts
python C:\dev\gamedev-notes\scripts\assets.py get icons lucide --names play,pause,settings --into assets/ui/icons
python C:\dev\gamedev-notes\scripts\assets.py get sfxr jump --seed 1234 --into assets/audio/sfx
python C:\dev\gamedev-notes\scripts\assets.py get addon ramokz/phantom-camera v0.11.0.3 --into addons
python C:\dev\gamedev-notes\scripts\assets.py get itch tallbeard/music-loop-bundle --into assets/audio/music
python C:\dev\gamedev-notes\scripts\assets.py get hdri kloppenheim_06 --res 1k --into assets/hdri
python C:\dev\gamedev-notes\scripts\assets.py get freesound 351376 --into assets/audio/sfx
python C:\dev\gamedev-notes\scripts\assets.py get polypizza <model-id> --into assets/models
python C:\dev\gamedev-notes\scripts\assets.py get opengameart <slug-or-url> --into assets/audio/music
python C:\dev\gamedev-notes\scripts\assets.py get sonniss 2024 --part 1 --into assets/audio/sfx
```

`get hdri` is `get polyhaven` under another name; `get sonniss` takes a YEAR (2024, 9 parts;
2023, 14) and a `--part`, not a filename. `sources` prints the script's own header, which is the
authoritative list when this one has drifted.

Every `get` appends a line to the game's `assets/CREDITS.md` (source, id, URL, licence, date)
and refuses a licence it does not recognise. The credits file feeds the credits screen.

**Run a positive control before writing down a miss.** A scraper that returns an empty list on
a markup change is indistinguishable from a source that has nothing, and the empty answer is
the one that gets believed - so a property of a regex gets recorded as a property of the
library. Before "no CC0 asset exists for X" goes into a plan, run one query whose answer is
known non-empty (`search kenney` with no query must list packs) and check it comes back.
Scrapers rot silently; the failure mode is always a confident empty result rather than an
error. This has now cost two asset hunts, and the same rule governs every source below.

Better than a control you have to remember to run: **make the tool itself distinguish "the
filter matched nothing" from "the scraper saw nothing".** `search_kenney` counts the slugs it
sees before filtering and exits non-zero naming the selector when that count is zero, so the
absence answer can no longer be produced silently. Verified by falsification - `search kenney
category:UI` exits 1 with the message, the default search lists packs and exits 0.

**And loud failure is not sufficient, because what a reader of a search looks for is ROWS.** The
KayKit 404 printed `HTTP 404 for .../orgs/...` at the top of three lines of output and the scout
still wrote down "KayKit has zero creature repos" - true, reached through a broken tool. An error
line above an empty table and a genuine zero look identical to anyone scanning for rows. So:
**check the exit status before writing down a miss, put the failure on the LAST line as well as
the first, exit non-zero, and re-run the query yourself before "nothing exists for X" goes into a
plan** rather than inheriting the conclusion.

How each source is reached, for when the script needs fixing:

- **Kenney**: the zip URL on `kenney.nl/assets/<slug>` contains a hash and a timestamp that
  change on re-upload. Fetch the page and regex `kenney\.nl/media/pages/assets/[^"']+\.zip`.
  **The four categories are `3D`, `2D`, `Audio` and `Textures` - there is no `UI` category.**
  `kenney.nl/assets/category:UI` is a real page that lists no packs, so for as long as it sat
  in the script's default list the UI quarter of every search returned nothing and read as
  "Kenney has no interface assets". Kenney has seven UI packs; they are a TAG, reached with
  `search kenney tag:interface` (`ui-pack-adventure`, `ui-pack-sci-fi`, `input-prompts`,
  `mobile-controls`, `crosshair-pack`, ...). Any selector containing `:` is passed through
  as-is. No JSON API.
  **The site emits single-quoted attributes**, so any slug regex must accept either quote:
  measured on `category:3D`, 55 single-quoted asset links against 6 double-quoted (M). While
  `search_kenney` matched double quotes only it saw a tenth of the library, found no rows,
  broke out of its paging loop, and returned an empty table for every query in two separate
  asset hunts - which both wrote down as "Kenney has nothing for this". The first re-run after
  the one-character fix surfaced `modular-cave-kit` for a game made of caves.
- **KayKit**: **KayKit-Game-Assets is a GitHub USER, not an org** - list its repos with
  `api.github.com/users/KayKit-Game-Assets/repos` (measured 2026-09-11: `orgs:` 404,
  `users:` 200 with 10 repos). `assets.py` called `/orgs/` from the day the source was added, so
  every KayKit search had 404'd for its whole life. Fetch a pack as a zip from
  `codeload.github.com/KayKit-Game-Assets/<repo>/zip/refs/heads/main`, already in an `addons/`
  layout. Packs not on GitHub are on `kaylousberg.itch.io`.
- **Poly Haven**: `api.polyhaven.com/assets?t=models|textures|hdris&c=<category>` then
  `api.polyhaven.com/files/<id>` for URLs and sizes. Send a `User-Agent`. glTF comes with an
  `include` map of relative texture paths; **preserve that layout or Godot imports a white
  model with no error**.
- **ambientCG**: `ambientcg.com/api/v2/full_json?type=Material&q=<q>&include=downloadData`
  then `ambientcg.com/get?file=<Id>_1K-JPG.zip`.
- **Quaternius**: pack pages link a Google Drive folder; `gdown --folder` works but is
  fragile and capped. Prefer KayKit or the Malcolmnixon Godot mirrors on GitHub.
- **Google Fonts**: `fonts.google.com/download/list?family=<Name>` returns JSON (strip the
  first `)]}'` line) with direct `fonts.gstatic.com` TTF URLs. No key.
- **Freesound**: `freesound.org/apiv2/search/text/?query=...&filter=license:"Creative Commons 0"&token=KEY`.
  The HQ OGG *preview* downloads with the token alone and is fine for a phone; the original
  needs OAuth, so the script takes the preview.
- **itch.io free packs**: `https://<user>.itch.io/<slug>/data.json` gives the game id;
  `itch.io/api/1/<KEY>/game/<id>/uploads` then `.../upload/<uid>/download` gives the CDN URL.
- **Poly Pizza**: `api.poly.pizza/v1.1/search/<q>?license=CC0` with header `x-auth-token`.
  Free tier is credit-limited; GLB with embedded textures.
- **Sonniss**: `downloads.sonniss.com/Sonniss.com-GDC2024-GameAudioBundle1of9.zip` through
  `9of9` (tens of GB, pro quality, royalty-free, no resale). Fetch one part, keep what fits.
- **OpenGameArt**: `opengameart.org/art-search-advanced?keys=<q>&field_art_type_tid[]=<type>&field_art_licenses_tid[]=4`
  (type 9 2D, 10 3D, 12 music, 13 SFX, 14 textures; licence 4 is CC0). Direct file links
  under `sites/default/files/`.
- **Godot addons**: `codeload.github.com/<owner>/<repo>/zip/refs/tags/<tag>`, copy
  `addons/*` in. The legacy Asset Library API (`godotengine.org/asset-library/api/asset?filter=`)
  still resolves a `download_url` but is being frozen.
- **Not fetchable unattended**: Mixamo (Adobe login), ZapSplat (forbids scripts), BBC SFX
  (non-commercial), Pixabay audio (no API), Free Music Archive (no new keys), Sketchfab
  (OAuth). Do not spend time on them.

## Bringing assets into Godot

- Folder per source under `assets/`: `assets/kenney/<pack>`, `assets/polyhaven/<id>`,
  `assets/textures/<Id>`, `assets/audio/{sfx,music,ambience}`, `assets/fonts`, `assets/ui`.
  Drop a `.gdignore` into `Previews/`, `Isometric/`, `Source/`, `Samples/` folders from a
  kit before importing, or the import cache fills with things nothing uses.
- Prefer **GLB** (embedded textures). For glTF keep `textures/` and the `.bin` where the
  file references them. Name suffixes work headless: `-col`, `-convcol`, `-noimp`, `-loop`.
- `godot --headless --path . --import` after adding files, and check the log for `ERROR`.
  Commit the `.import` files; `.godot/` is ignored.
- **Verify every conversion in the script that does it. An exit code proves nothing.**
  `sharp-cli` turned a 342 KB JPEG into a valid 342-byte solid-colour WebP and returned 0; use
  Python Pillow, which is already on this machine, and assert on the artefact:
  `ImageStat.Stat(Image.open(dst).convert('L')).stddev[0] > 3` rejects a flat fill. Baseline to
  compare against: **~38 KB for a 384 px normal map** (M). The check earned itself on its first
  run against ambientCG `Metal038`, which converted to 462 bytes at stddev 0.4 - not a broken
  conversion but a source with almost no relief, which is the wrong PICK and would otherwise
  have shipped as an invisible improvement.
- Write the `.import` before the first import for anything large:
  PBR albedo `compress/mode=2`, `compress/high_quality=true` (ASTC on the Mobile renderer),
  `mipmaps/generate=true`, `process/size_limit=1024`; normal maps `compress/normal_map=1`;
  HDR skies `compress/mode=2` and `process/size_limit=512`. `ls -laS .godot/imported` is the
  only place the real cost shows.
- **VRAM-compressed textures cost a fixed rate per pixel, so how well the source packs is
  irrelevant.** 39 new 1K maps are about 39 MB in the APK whatever they weigh on disk; the only
  lever is `process/size_limit` in the `.import`. Measured on Stillwater: a new room of nine
  imported props took the APK 35.62 MB to **64.58 MB**, and 512 across the room with 256 on five
  background-only props brought it to **43.71 MB** with a screenshot from where the player stands
  indistinguishable. Measured on Wildform: Godot's default for a plain texture is
  `compress/mode=0` (LOSSLESS) with `mipmaps/generate=false`, so each 1024x1024 landed at
  **1.33 MB and Godot generated both an `astc` and a `bptc` variant** - twelve textures were 34 MB
  imported, and `compress/mode=2` plus mipmaps plus a 512 limit plus deleting the roughness maps
  entirely took that to **7.2 MB**. Mipmaps are not optional on ground seen at a grazing angle
  from a chase camera; without them it shimmers, which reads as a rendering fault.
- Sizes for a 1080x2340 phone: props at 1k, a hero or terrain at 2k, UI at native design
  resolution, a sky at 512x256 to 1k. Size a tiled texture from the physical pixels it
  displays at, not from what the download offers: 384 px was native for a Coreward cell and
  1k was three quarters of a megabyte thrown away.
- Imported low-poly kits: leave the atlas Lossless with mipmaps. Recolour the atlas to the
  game's palette rather than tinting per material.
- **A skinned mesh does not know how big it is, and four ways of asking all lie.** Normalising
  four creature models to a size ladder: `mesh.get_aabb().size.y * model.scale` came out **100x
  too big** (the mesh sits under an Armature carrying the FBX's centimetre scale); the AABB
  transformed up the chain gave **40-49% of target**, differing per model, because Z-up models
  put their DEPTH in the local Y; and both `VisualInstance3D.get_aabb()` and an in-tree
  re-measure after a frame printed the targets to two decimals while the render showed a stage-1
  creature four times the size of the stage-4 one. **A probe that disagrees with a picture you
  are looking at is measuring the wrong quantity, and the picture wins.** So set the scale as a
  measured constant per model in the content table, checked by eye against something (the
  collision width: a 1.80-unit body on a 4.00-unit band should cover a little under half the
  road). The mesh AABB is still the right and only source for MODEL-SPACE extent - a uniform
  consumed in model space is tuned as `<features wanted across the body> / aabb.size.length()`,
  never against the node's world scale, and the assertion is on the feature COUNT (2 to 8 bands
  across a body), not on the frequency.
- **A pack's name and its preview say nothing about which models are animated.** Twenty lines
  that instantiate every file and print its animation list and height is the cheapest way to
  find out: Quaternius farm animals had 3 of 7 with a Run cycle and all three the same height;
  monsters 1 of 4; dinosaurs 6 of 6, CC0 by its own `License.txt`, silhouettes that genuinely
  differ. Delete the packs you did not choose in the same commit - two of those were 11 MB of
  Blends, OBJs and preview GIFs no build would ever have used.
- Fonts: TTF or WOFF2 both import. A variable font works through `FontVariation`. MSDF for
  UI that scales. Ship the OFL text with the font.
- Audio: OGG for music and ambience, WAV for short SFX. 22050 Hz mono is enough for water,
  wind, wood and low tones and halves the size. Do not pre-emptively trim to protect a size
  budget that is not under threat.

## Audio specifically

- **Sample where a sample is better, synthesise where the sound must answer the game.**
  Kenney's interface and impact packs beat a sine blip for a tap or a knock. A dip pitched by
  state, a reel whose buzz tracks tension, a music bed that crossfades on depth are generated.
- **Generate at build time and commit the files.** GDScript synthesis at runtime costs
  seconds of black screen on a phone. A `SceneTree` script writing 16-bit WAVs is thirty
  lines and deterministic. `techniques/generated-audio.md`.
- **Music needs a written theme**: a progression with a cadence, movement eight times a bar,
  a pulse. A drone reads as creepy. A fast attack on a high sine reads as a notification.
  When a loop from the Tallbeard bundle fits the brief, take it; it will be better than a
  first-attempt generated one and it is CC0.
- Round-robin players, pitch jitter on repeats, separate buses so the options screen can
  set Music, SFX and UI independently.

## What does not exist free (checked against working controls)

Record every miss; a miss shapes the design. Each of these was re-checked on 2026-09-11 with the
KayKit endpoint fixed and against a control query whose answer was known non-empty.

- **A rigged evolution or growth line of one creature identity.** Nothing anywhere. KayKit: 10
  repos, zero creature or monster packs. Kenney: no animal, creature or monster pack at all
  across 16 3D packs (`cube-pets` is a static voxel prop). Quaternius: three rigged animated
  packs with run cycles, each a bag of unrelated creatures, never a growth line. Poly Pizza
  surfaces individual Quaternius models and **does not guarantee animation survives its export**.
  **A game that needs visible growth stages of one identity is committing to curate or build
  them, and that belongs in the milestone list before the plan is approved.** The workable free
  route is a curated trio of separate CC0 creatures chosen by silhouette and unified by four
  cheap things: one palette per line, one signature accessory carried across all stages, a
  normalised import scale, and a dissolve transform hiding the swap. Defensible rather than a
  compromise: Pokemon's own lines change silhouette drastically (Charmander to Charizard), so
  what must stay continuous is the palette and one feature, not the topology.
- **Volcano or lava HDRIs on Poly Haven, and lava, basalt or obsidian materials on ambientCG.**
  Both absent against working controls (`forest`, `desert`, `beach` all returned rich results in
  the same call shape). A volcanic sky is a `ProceduralSkyMaterial` and lava cracks are an
  emissive shader over a dark rock base. Both are code, not imports.
- **Water, liquid or ripple materials on ambientCG.** Absent.
- **Wax and candles**, anywhere. By contrast a lake-and-boat game found its whole set dressing on
  Poly Haven in two minutes. The hit rate is a property of the SUBJECT, not the library.

## Licences and credits

- CC0 (Kenney, KayKit, Poly Haven, ambientCG, Tallbeard, Sonniss for our use): nothing
  required, but the credits screen lists them anyway because it is decent and free.
- CC-BY (game-icons, Kevin MacLeod, Freesound CC-BY sounds): the exact attribution string
  goes in `assets/CREDITS.md` and on the credits screen. Kevin MacLeod's is
  `"<Title>" Kevin MacLeod (incompetech.com), Licensed under Creative Commons: By Attribution 4.0`.
- OFL fonts: ship `OFL.txt` beside the font. Lucide (ISC) and Tabler (MIT): ship the notice.
- Quaternius QAL: free to use, no attribution, **do not redistribute the raw files**, which
  means do not commit them to a public repo. Keep QAL packs out of git or make the repo
  private.
- Never ship GPL code (some godotshaders entries). Never use FreePBR (non-commercial).
- The Play listing's Data safety form does not care about assets, but the credits screen and
  `CREDITS.md` are what let a game be published without a licence audit later.

## Measured facts worth keeping

- Two weights of a latin font subset: about 20 KB, and it changed every screen in the game.
- ambientCG rock normal at 384 px WebP q70: 45 KB, and flat facets became rock.
- A Poly Haven HDRI plus a concrete normal and roughness pair: 1.6 MB, APK 27.1 to 29.7 MB.
- Six 1k `.hdr` skies imported uncompressed: +14 MB. With `compress/mode=2` and a 512 limit:
  175 KB each, invisible difference on a sky.
- Nineteen generated sounds at 22050 Hz mono including four 16-second music beds: 4.0 MB,
  +3% APK.
- Two texture samples versus a 13-octave procedural surface over a third of the screen:
  0.82 ms versus 1.60 ms a frame, measured with vsync off. A texture can be the free thing.
