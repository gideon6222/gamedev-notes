# Free asset sources for unattended fetching — Godot 4.7 mobile (+ three.js)

Researched 2026-09-10. Target: solo dev, Claude Code on Windows (curl / PowerShell / git / node / python), Godot 4.7.2-stable (current stable, released 2026-08-18 — VERIFIED via GitHub releases).

**Legend:** **VERIFIED** = I fetched the URL/API/repo during this research and saw the result. **UNVERIFIED** = from search snippets or memory; check before relying on it.
Verification environment note: my sandbox proxy only allowed raw `curl` to raw.githubusercontent.com, registry.npmjs.org and pypi.org; everything else was verified with a web-fetch tool (which sees the real page/JSON, but I could not inspect HTTP headers or binary payloads byte-by-byte). Where a fetch returned "binary data" I say so.

---

## 0. TL;DR — the "unattended-friendly" shortlist

| Need | Best unattended source | How | Licence |
|---|---|---|---|
| 3D props / kits / characters | **KayKit GitHub org** (`KayKit-Game-Assets/*`) | `git clone` / codeload zip | CC0 (VERIFIED) |
| 3D props / kits | **Kenney** | scrape asset page → `kenney.nl/media/pages/assets/<slug>/<hash>-<ts>/kenney_<slug>.zip` | CC0 (VERIFIED) |
| Photoreal props / PBR textures / HDRIs | **Poly Haven API** (`api.polyhaven.com`) → `dl.polyhaven.org` | JSON, no key | CC0 (VERIFIED) |
| PBR textures | **ambientCG API v2** (`ambientcg.com/api/v2/full_json`) → `ambientcg.com/get?file=…zip` | JSON, no key | CC0 (VERIFIED) |
| Low-poly models search | **Poly Pizza API** (`api.poly.pizza/v1.1`) | JSON, free key, `x-auth-token` | CC0 / CC-BY per model |
| Icons | **Lucide** / **Tabler** (GitHub releases, jsDelivr) ; **game-icons** (GitHub) | zip / git | ISC / MIT / CC-BY 3.0 |
| Fonts | **Google Fonts** `fonts.google.com/download/list?family=X` or `github.com/google/fonts` ; **Fontsource** `api.fontsource.org/v1/download/<id>` | direct | OFL mostly |
| SFX (procedural) | **jsfxr** npm — generates WAVs headless in Node (I ran it) | `node` | MIT-ish (verify) |
| SFX (recorded) | **Kenney audio packs** (CC0), **Sonniss GDC bundles** (direct zips, royalty-free), **Freesound API** (free key; original download needs OAuth2, previews need only key) | direct / API | mixed |
| Music | **Abstraction / Tallbeard "Music Loop Bundle"** (itch, CC0), **Kenney Music Jingles** (CC0), **Kevin MacLeod** (CC-BY 4.0, direct mp3s) | itch (semi-manual) / direct | CC0 / CC-BY |
| Godot addons | Maaack's Game Template, Phantom Camera, GUT, gdUnit4 — all have GitHub release tags → `codeload.github.com/<o>/<r>/zip/refs/tags/<tag>` | git | MIT |
| Godot ↔ Claude | `@coding-solo/godot-mcp` (npx), `tugcantopaloglu/godot-mcp` (tested with 4.7) | npx / node | MIT |

Things that **do NOT** work unattended: Mixamo (browser + Adobe login, no API), ZapSplat (login, scraping forbidden), Sketchfab download (OAuth2/user auth), Pixabay audio (API is images/video only), Free Music Archive (no new API keys), itch.io free downloads (possible but needs an itch API key + 3-step dance, see §3.7), Quaternius (Google Drive folders → `gdown`, fragile).

---

## 1. 3D models & characters

### 1.1 Kenney (kenney.nl) — VERIFIED

| Item | Detail |
|---|---|
| Licence | **CC0** on every pack page ("Creative Commons CC0") — VERIFIED on platformer-kit, particle-pack, ui-pack, input-prompts. Assets in his GitHub starter kits also stated CC0; the starter-kit code is MIT — VERIFIED (README). |
| Style | Chunky, clean, flat-coloured low-poly. Every 3D kit uses a single small colour-palette texture (UV'd to colour swatches) so recolouring is a texture swap. Best for: prototypes, casual/mobile, city/platformer/space/racing kits, all UI, input prompts, particles, audio. |
| Fetch without browser | **Yes, but the zip URL contains an unpredictable hash+timestamp**, e.g. `https://kenney.nl/media/pages/assets/platformer-kit/1585cf62b4-1775122253/kenney_platformer-kit.zip` (VERIFIED), `…/input-prompts/8de120163f-1783763952/kenney_input-prompts_1.5.zip`, `…/particle-pack/f8fe0f8cb8-1677578741/kenney_particle-pack.zip`, `…/ui-pack/f651646eab-1718203990/kenney_ui-pack.zip`. The timestamp changes on every re-upload (the platformer-kit one is dated 2026-04, so the older URL pattern you quoted is stale). **Procedure: fetch `https://kenney.nl/assets/<slug>` and regex `https://kenney\.nl/media/pages/assets/[^"']+\.zip`** — the link is in the page as "Continue without donating…" (VERIFIED). |
| Index / discovery | `https://kenney.nl/assets?page=N` (14 pages, ~16 per page) and category pages `https://kenney.nl/assets/category:3D`, `category:2D`, `category:Audio`, `category:UI` (VERIFIED). RSS feed `https://kenney.nl/feed` (25 latest, VERIFIED). No JSON API (`/data/assets.json` is 404 — VERIFIED). |
| API key | None. |
| GitHub | `github.com/KenneyNL` — 13 repos: `Starter-Kit-3D-Platformer`, `Starter-Kit-City-Builder`, `Starter-Kit-FPS`, `Starter-Kit-Racing` (2026), `Starter-Kit-Match-3` (2026), `Starter-Kit-Basic-Scene`, `Godot-SplashScreens`, `KayKit-Hexagons` (VERIFIED). The starter kits are Godot 4.6 projects containing CC0 models/sprites/sounds — cloneable, ready-made Godot import layout. **No repo mirrors the kenney.nl packs.** |
| All-in-1 bundle | itch, $19.95+, 60 000+ assets, 516 MB, CC0 (VERIFIED) — a one-time buy that removes all scraping. |
| Formats | 3D kits ship GLB (+ FBX/OBJ/DAE); 2D ship PNG (+ SVG, spritesheets with XML); audio OGG (from bundle page; per-pack format list not shown on kenney.nl pages — UNVERIFIED per pack). |
| Gotchas | Textures in 3D kits are a shared `Textures/colormap.png`; GLB embeds them so nothing else is needed in Godot. Many kits ship "Isometric/Previews" folders you should exclude. Attribution not required (CC0). |

PowerShell fetch:
```powershell
$slug='platformer-kit'
$html = (Invoke-WebRequest "https://kenney.nl/assets/$slug" -UseBasicParsing).Content
$zip  = [regex]::Match($html,'https://kenney\.nl/media/pages/assets/[^"''\s]+\.zip').Value
Invoke-WebRequest $zip -OutFile "$slug.zip"; Expand-Archive "$slug.zip" -DestinationPath "assets/kenney/$slug"
```

### 1.2 KayKit (Kay Lousberg) — VERIFIED

| Item | Detail |
|---|---|
| Licence | **CC0 1.0** (LICENSE.txt in each repo; README: "Free for personal and commercial use, no attribution required") — VERIFIED. |
| Style | Stylised low-poly, single 1024² gradient-atlas texture ("can be downsampled to 128×128"), same colour-swatch approach as Kenney → **mixes very well with Kenney**. Rigged & animated characters (75 animations in Adventurers). Best for: RPG/dungeon/fantasy, hex-tile strategy, city builder, prototype bits. |
| Fetch without browser | **GitHub org `KayKit-Game-Assets`** (10 repos, VERIFIED): `KayKit-Character-Pack-Adventures-1.0`, `KayKit-Character-Pack-Skeletons-1.0`, `KayKit-Dungeon-Remastered-1.0`, `KayKit-Medieval-Hexagon-Pack-1.0`, `KayKit-City-Builder-Bits-1.0`, `KayKit-Prototype-Bits-1.0`, `KayKit-Restaurant-Bits-1.0`, `KayKit-Halloween-Bits-1.0`, `KayKit-Furniture-Bits-1.0`, `KayKit-Space-Base-Bits-1.0`. `git clone https://github.com/KayKit-Game-Assets/<repo>` or `https://codeload.github.com/KayKit-Game-Assets/<repo>/zip/refs/heads/main`. (`github.com/KayLousberg` has no public repos — VERIFIED.) |
| Repo layout | Already a Godot addon layout: `addons/kaykit_character_pack_adventures/{Assets,Characters,Samples,Textures,LICENSE.txt}` (VERIFIED). Copy the `addons/<pack>` folder into your project. Files are `.FBX` + `.GLTF` (README); GLB-with-embedded-textures not confirmed — UNVERIFIED. Note: uses Git LFS? — `.gitattributes` present; if clones come back as LFS pointers, run `git lfs pull` (UNVERIFIED). |
| Not on GitHub | Platformer Pack, Forest Nature Pack, Character Animations, Board Game Bits, Fantasy Weapons Bits, RPG Tools Bits, Holiday Bits, Resource Bits, Block Bits — free on `kaylousberg.itch.io` only (VERIFIED list; itch download is "name your price", see §3.7 for scripted itch download). Paid: Complete KayKit $150, Series bundles $19.99. |
| Gotchas | Godot glTF import of KayKit characters: animations are in the character `.gltf`; use the "Character Animations" pack for the shared rig. Textures folder must sit where the `.gltf` references it (repo layout is correct as-is). |

### 1.3 Quaternius — VERIFIED (partly)

| Item | Detail |
|---|---|
| Licence | **Mixed.** Newer packs (e.g. Bestiary Dungeon Monsters Kit, Downtown City Mega Kit) use the custom **Quaternius Asset License (QAL) v1.0**: free for personal/commercial, *no attribution required*, may not redistribute the raw assets — VERIFIED at quaternius.com/license.html. Older packs (Ultimate Nature, Universal Animation Library 2) still labelled **CC0** on their pages — VERIFIED. Check the label per pack. |
| Style | Stylised low-poly, flat colours, slightly more "rounded/cartoony" and mid-poly than Kenney; many rigged characters/animals/monsters, animation libraries (UAL2: 130+ humanoid animations, FBX/GLB, "universal rig", free tier is 60-70 % of content — VERIFIED). |
| Fetch without browser | **No direct zip on quaternius.com.** Site source is `github.com/Quaternius/quaternius.github.io` (VERIFIED); each `packs/<name>.html` has a "Just give me the Download" button that opens a **Google Drive folder** (e.g. `https://drive.google.com/drive/folders/1-Kl0L_Jg8awbh0S5T-z3zxh4mVlnxTpa` for Ultimate Nature — VERIFIED) and an itch "buy button" widget. So: `curl https://raw.githubusercontent.com/Quaternius/quaternius.github.io/main/packs/<pack>.html | grep -o 'drive.google.com/drive/folders/[^'"'"']*'` then `pip install gdown && gdown --folder <url>`. `gdown` 6.2.0 is on PyPI (VERIFIED); folder downloads are capped at 50 files per folder and Drive sometimes rate-limits — UNVERIFIED in this sandbox (Drive blocked). |
| Pack list | 82 pack pages in the repo (VERIFIED): `ultimatenature`, `ultimatemodularcharacters`, `universalanimationlibrary2`, `bestiarydungeonmonsterskit`, `cyberpunkgamekit`, `medievalvillagemegakit`, `stylizednaturemegakit`, `toonshootergamekit`, `zombieapocalypsekit`, `ultimatespaceships`, `cars`, `farmanimal`, … |
| Formats | FBX, OBJ, glTF/GLB; `.blend` only in paid "Source" tier (VERIFIED on Bestiary page). |
| Godot-ready mirrors | `Malcolmnixon/Quaternius-Modular-Scifi-Pack`, `Malcolmnixon/Quaternius-Ultimate-Spaceships-Pack`, `Malcolmnixon/QuaterniusModularPeople` (Godot asset conversions, VERIFIED exist; licence of the repo — check). |

### 1.4 Poly Haven — VERIFIED

| Item | Detail |
|---|---|
| Licence | **CC0** for all assets. API terms: no key, but "All requests to the API require a unique User-Agent header" and if you use the live API in a product you must tell users assets came from Poly Haven — VERIFIED (polyhaven.com/our-api). |
| Style | Photoreal / photogrammetry props (chairs, barrels, rocks, plants), 4k–8k PBR. **Not** low-poly; poly counts 2 k–6 k+ (VERIFIED: ArmChair_01 5 626 tris). Best for: realistic mobile scenes, hero props, all HDRIs and PBR ground/wall textures. |
| API | `GET https://api.polyhaven.com/assets?t=models|textures|hdris[&c=<category>]` → JSON keyed by asset id (VERIFIED, `c=terrain` works, `c=ground` returns `{}` — category names come from `GET /categories/<type>`, e.g. textures: outdoor, floor, wall, wood, terrain, rock, brick, concrete, sand… VERIFIED). `GET https://api.polyhaven.com/files/<id>` → per-map/per-resolution/per-format URLs with size + md5 (VERIFIED). Other endpoints: `/types`, `/info/<id>`, `/categories/<type>`, `/authors/<id>`. |
| Direct file URLs (VERIFIED) | Model glTF: `https://dl.polyhaven.org/file/ph-assets/Models/gltf/1k/ArmChair_01/ArmChair_01_1k.gltf` (the JSON entry lists `include` = `textures/Armchair_01_diff_1k.jpg`, `…_nor_gl_1k.jpg`, `…_arm_1k.jpg`, `ArmChair_01.bin` — **you must download those into the same relative paths** or the glTF will not load). Texture: `https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/rocky_terrain_02/rocky_terrain_02_diff_1k.jpg` (maps: Diffuse, nor_gl, nor_dx, Rough, AO, Displacement, arm, Mask, spec; 1k/2k/4k/8k; jpg/png/exr). HDRI: `https://dl.polyhaven.org/file/ph-assets/HDRIs/hdr/2k/kloofendal_48d_partly_cloudy_puresky_2k.hdr` (1k…16k; hdr/exr). |
| Gotchas | Use 1k for mobile props (2k max). Prefer the `arm` map (AO/Rough/Metal packed) — Godot's StandardMaterial3D needs ORM textures: enable "Use ORM" material or set roughness/metallic texture channels. glTF variant already wires the maps. |

Python example:
```python
import requests, os
H={'User-Agent':'my-godot-fetcher/1.0'}
files=requests.get('https://api.polyhaven.com/files/ArmChair_01',headers=H).json()
g=files['gltf']['1k']['gltf']
os.makedirs('ArmChair_01/textures',exist_ok=True)
open('ArmChair_01/ArmChair_01_1k.gltf','wb').write(requests.get(g['url'],headers=H).content)
for rel,inc in g['include'].items():
    open(f'ArmChair_01/{rel}','wb').write(requests.get(inc['url'],headers=H).content)
```

### 1.5 Poly Pizza — PARTLY VERIFIED

| Item | Detail |
|---|---|
| Licence | Per-model: CC0, CC-BY, CC-BY-SA, … (7 CC types, VERIFIED via MCP README). Filter with `license=CC0`. |
| Style | Aggregator of low-poly models (Google Poly rescue, Kenney, Quaternius, KayKit, community). Best for: quick one-off low-poly props; quality varies. |
| API | Base `https://api.poly.pizza/v1.1`, header `x-auth-token: <key>` (VERIFIED from `MatthewHallCom/Poly-Pizza-MCP` source). Endpoints (VERIFIED in source): `GET /search/{keyword}?category=&license=&animated=&limit=&page=`, `GET /search?category=…` (needs ≥1 filter), `GET /model/{id}`. Response fields (UNVERIFIED, memory): `{ "total", "results":[{ "ID","Title","Attribution","Thumbnail","Download" (GLB URL),"Tri Count","Creator":{"Username","DPURL"},"Category","Tags","Licence","Animated" }] }`. |
| API key | Free after login at `https://poly.pizza/settings/api` (VERIFIED URL exists, login-gated). Support page mentions "Extra API credits" for subscribers and "Unlimited API access" for Brand Sponsors → **free tier is rate/credit-limited** (VERIFIED wording; exact quota UNVERIFIED). Docs page `poly.pizza/docs/api/v1.1` is JS-rendered (fetch returned only a shell — VERIFIED). |
| Gotcha | Downloads are GLB with embedded textures; check `Licence` per model and keep `Attribution` text for CC-BY. |

### 1.6 Sketchfab — MOSTLY UNVERIFIED

- Still online in 2026 with Download API docs ("© 2026", VERIFIED page exists). Sketchfab is owned by Epic; a Fab migration portal exists (search snippet). Free downloads remain.
- Download API: "Downloading models requires users to be authenticated with a Sketchfab account" — OAuth2 flow; server-side downloads without a user require contacting Sketchfab (VERIFIED wording). In practice many scripts use a personal API token (`Authorization: Token <token>` from account settings) against `GET /v3/models/{uid}/download` and it works — UNVERIFIED (memory). Search: `GET https://api.sketchfab.com/v3/search?type=models&downloadable=true&licenses=<uid>&q=…` (UNVERIFIED; CC0 licence uid from memory `7c23a1ba438d4306920229c12afcb5f9`). Formats via API: glTF/GLB/USDZ only.
- Verdict: usable but needs an account token; use Poly Pizza/Poly Haven first.

### 1.7 OpenGameArt (OGA) — VERIFIED

- Licence per submission (CC0, CC-BY 3.0/4.0, OGA-BY, CC-BY-SA, GPL). Advanced search URL is scriptable: `https://opengameart.org/art-search-advanced?keys=<q>&field_art_type_tid[]=<type>&field_art_licenses_tid[]=<lic>&sort_by=count&sort_order=DESC&page=N`. IDs (VERIFIED): art type 9 = 2D Art, 10 = 3D Art, 14 = Textures, 12 = Music, 13 = Sound Effects, 11 = Documents, 7273 = Concept Art; licence **4 = CC0** (other licence IDs not captured — UNVERIFIED; commonly 17 = CC-BY 3.0, 2 = CC-BY-SA 3.0).
- Downloads are **direct, no login**: `https://opengameart.org/sites/default/files/<file>` (VERIFIED, e.g. `lpc_base_assets.zip`). Scrape the content page for `sites/default/files/` hrefs.
- No official API (VERIFIED: `/content/oga-api` 404, FAQ silent). Quality highly variable; great for LPC sprites, some CC0 music/SFX (e.g. Kenney, Juhani Junkala, "Bart" packs).

### 1.8 itch.io free asset packs — VERIFIED mechanism

- Discovery: `https://itch.io/game-assets/free/tag-low-poly`, `…/tag-cc0` etc. (HTML). Every project page has `https://<user>.itch.io/<slug>/data.json` giving the game id (VERIFIED via itch forum thread).
- Unattended download of a **free** asset pack (VERIFIED thread, itch staff answer): needs a **real itch.io API key** (free, `https://itch.io/api-keys`, VERIFIED). Then `GET https://itch.io/api/1/<API_KEY>/game/<GAME_ID>/uploads` → upload ids, then `GET https://itch.io/api/1/<API_KEY>/upload/<UPLOAD_ID>/download` → JSON with a CDN URL. Official server-side docs don't list these but staff confirmed they work for free games. OAuth keys do not work for this.
- npm `itchio-downloader` 1.2.0 (VERIFIED on npm; README says it works with 4 plain HTTP requests: CSRF token → download page → CDN; documented for "games", asset packs are the same object type — UNVERIFIED for packs). `npx itchio-downloader --url https://kaylousberg.itch.io/kaykit-platformer`.
- "Name your price" packs: the download flow above yields the free tier files.

### 1.9 Mixamo — VERIFIED (limited)

- Adobe FAQ (last updated 2021, still live): free, royalty-free for commercial games (VERIFIED). No API; the well-known "download all animations" gist works by clicking through the UI in a logged-in browser tab (VERIFIED). **Needs browser + Adobe ID → not unattended.** Alternative with the same value: **Quaternius Universal Animation Library 2** (130+ animations, CC0, FBX/GLB, Godot-compatible rig — VERIFIED page) and KayKit Character Animations.

### 1.10 Godot Asset Library / Asset Store — VERIFIED

- **Old Asset Library** (`godotengine.org/asset-library`) is still online and its JSON API still works: `GET https://godotengine.org/asset-library/api/asset?godot_version=4.7&filter=<q>&max_results=N&sort=updated` (VERIFIED; 3 400 items) and `GET https://godotengine.org/asset-library/api/asset/<id>` → `download_url` (a GitHub commit zip, e.g. `https://github.com/ramokz/phantom-camera/archive/<sha>.zip`), `browse_url`, `version_string`, `cost` (= licence, e.g. MIT) (VERIFIED). Being made read-only "in the near future".
- **New Godot Asset Store** `https://store.godotengine.org/` launched May 2026, integrated in Godot 4.7 (VERIFIED article). Godot 4.7's editor no longer accepts the legacy API URL (VERIFIED issue #119578). **No public API documented** (`/api/` 404 — VERIFIED). For scripting, fetch addons straight from their GitHub repos instead.

---

## 2. Textures / materials / HDRIs

| Source | Licence | Unattended? | URL pattern | Notes |
|---|---|---|---|---|
| **Poly Haven** | CC0 (VERIFIED) | Yes, no key | see §1.4; `api.polyhaven.com/assets?t=textures&c=<cat>` → `files/<id>` → `dl.polyhaven.org/file/ph-assets/Textures/<fmt>/<res>/<id>/<id>_<map>_<res>.<fmt>` (VERIFIED) | Best quality; 1k jpg per map is ~0.3–0.6 MB — mobile-friendly. HDRIs: use 1k–2k `.hdr` for a phone sky. |
| **ambientCG** | CC0 (VERIFIED docs.ambientcg.com/license) | Yes, no key, no documented rate limit (VERIFIED) | `https://ambientcg.com/api/v2/full_json?type=Material&q=wood&limit=50&offset=0&sort=Popular&include=downloadData,tagData,imageData` → `foundAssets[].downloadFolders.default.downloadFiletypeCategories.zip.downloads[]` with `attribute` (`1K-JPG` … `16K-PNG`) and `downloadLink` = `https://ambientcg.com/get?file=Wood095_1K-JPG.zip` (VERIFIED). `nextPageHttp` for paging. Types: Material, HDRI, 3DModel, Decal, Atlas, PlainTexture, Terrain, Substance (VERIFIED). | Zip contains `<Name>_1K-JPG_Color.jpg`, `_NormalGL.jpg`, `_NormalDX.jpg`, `_Roughness.jpg`, `_AmbientOcclusion.jpg`, `_Displacement.jpg`, `.mtlx`, `.usdc` (naming UNVERIFIED but standard). Use NormalGL in Godot. |
| **3dtextures.me** | CC0 (VERIFIED) | Semi — individual posts link zips, WordPress site; bulk needs Ko-fi | scrape post page for `.zip` href (UNVERIFIED pattern) | Older/smaller; 1 300+ textures. |
| **ShareTextures** | CC0 (VERIFIED) | Unknown — no download pattern found (UNVERIFIED) | — | Skip unless needed. |
| **FreePBR** | **Custom: free for non-commercial; $21 for commercial rights** (VERIFIED) — not CC0 | No | — | Avoid for a commercial mobile game unless you pay. |
| **cc0-textures** | Was the old name of ambientCG (UNVERIFIED) | → use ambientCG | | |
| **Kenney "Textures"/Pattern/Skyboxes packs** | CC0 | Yes (§1.1 scrape) | `kenney.nl/assets/pattern-pack-extra`, `skyboxes` (VERIFIED in RSS) | Stylised, matches Kenney 3D. |

---

## 3. 2D sprites / tilesets / UI / icons

| Source | Licence | Unattended | Notes |
|---|---|---|---|
| **Kenney 2D/UI** | CC0 | Yes (§1.1) | `ui-pack` (430 files, VERIFIED), `ui-pack-pixel-adventure`, `input-prompts` (1 500 glyphs: Xbox, PS, Switch/Switch 2, Steam Deck/Frame, Quest, keyboard/mouse, **touch gestures** — PNG+SVG 64×64 + spritesheets + fonts, VERIFIED), `particle-pack` (80 × 512² PNG, VERIFIED), `crosshair-pack`, `tiny-town/tiny-farm/tiny-factory/tiny-dungeon`, `scribble-platformer-expansion`, `new-platformer-pack`, `desert-shooter-pack` (VERIFIED in listings). |
| **Kenney UI packs in Godot** | | | Zips include `Vector/*.svg` and `PNG/`; there is no `.tres` theme — build a `Theme` with `StyleBoxTexture` 9-slice from the PNGs (margins ≈ 8 px for the Grey/Blue sets — UNVERIFIED). |
| **OpenGameArt** | mixed | Yes (§1.7) | LPC sprites are CC-BY-SA/GPL (copyleft — careful for a closed-source game). Filter licence 4 = CC0. |
| **itch.io** | mixed | semi (§1.8) | Tags `tag-cc0`, `tag-pixel-art`, `tag-ui`. |
| **game-icons.net** | **CC BY 3.0**, attribution "Icons made by {author}. Available on https://game-icons.net" (VERIFIED) | Yes | `git clone https://github.com/game-icons/icons` — folders per author (`lorc/`, `delapouite/`, `skoll/`…) of SVGs, plus `rasterize-svgs.sh` (VERIFIED). The site's zip generator URL you quoted was not fetchable (blocked host) — use the repo. 4 000+ game-specific glyphs (swords, potions, buffs) — ideal RPG/UI icons. |
| **Lucide** | ISC (memory, UNVERIFIED) | Yes | Release **1.43.0** (2026-09-08) assets: `https://github.com/lucide-icons/lucide/releases/download/1.43.0/lucide-icons-1.43.0.zip` (1.3 MB SVGs) and `lucide-font-1.43.0.zip` (VERIFIED). npm `lucide-static` 1.43.0 → `node_modules/lucide-static/icons/*.svg` (VERIFIED on npm). jsDelivr `https://cdn.jsdelivr.net/npm/lucide-static@1.43.0/icons/<name>.svg` (returns an SVG image — VERIFIED as image). Clean 24 px stroke icons for settings/menus. |
| **Tabler Icons** | MIT (VERIFIED npm description) | Yes | v3.46.0 (2026-07-28, VERIFIED); npm `@tabler/icons` 3.46.0 → `icons/outline/*.svg`, `icons/filled/*.svg`; or `codeload.github.com/tabler/tabler-icons/zip/refs/tags/v3.46.0`. 5 900+ icons. |
| Godot SVG import | | | Godot 4 imports SVG via ThorVG; set `svg/scale` (e.g. 2–4) in the `.import` for crisp HiDPI icons; Lucide/Tabler use `stroke="currentColor"` — Godot renders them black; use `modulate`/`self_modulate` or a `CanvasItem` material to tint. |

---

## 4. Fonts

| Source | Licence | Unattended | Pattern |
|---|---|---|---|
| **Google Fonts – no-key list endpoint** | OFL / Apache / UFL per family | Yes | `https://fonts.google.com/download/list?family=Inter` → JSON prefixed with `)]}'` (strip first line) containing `manifest.fileRefs[]{filename,url}` with direct `fonts.gstatic.com/s/<family>/<ver>/<file>.ttf` URLs (VERIFIED). Multiple families: `family=Inter|Roboto`. |
| **Google Fonts Developer API** | — | Yes, **free API key** from Google Cloud Console | `https://www.googleapis.com/webfonts/v1/webfonts?key=KEY&family=Inter&capability=VF&capability=WOFF2` → `items[].files{variant:url}` (VERIFIED docs). |
| **github.com/google/fonts** | per-folder `OFL.txt` | Yes | `git clone --depth 1 https://github.com/google/fonts` (large, ~1 GB) or raw file: `https://raw.githubusercontent.com/google/fonts/main/ofl/inter/Inter%5Bopsz%2Cwght%5D.ttf` (path pattern; raw host is reachable — VERIFIED host; exact filename UNVERIFIED). |
| **Fontsource** | OFL etc. per font | Yes, no key | `https://api.fontsource.org/v1/fonts?subsets=latin&category=display` (VERIFIED), `…/v1/fonts/inter` → `variants[weight][style][subset].{woff2,woff,ttf}` e.g. `https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/latin-400-normal.woff2` (VERIFIED); `https://api.fontsource.org/v1/download/inter` returns a binary (zip) (VERIFIED binary, content-type not inspected). npm `@fontsource/inter` 5.3.0 (VERIFIED). **Godot needs TTF/OTF/WOFF2** — all present. |
| **itch.io fonts** | mixed | semi | e.g. "m5x7", "m3x6" by Daniel Linssen (free, attribution requested — UNVERIFIED), Kenney Fonts pack on kenney.nl (CC0, scrape). |
| Godot gotcha | | | Google Fonts variable `[wght]` TTFs import fine; set `Font > Variation` axes or use a `FontVariation` resource. For pixel fonts disable antialiasing + set hinting none, and use MSDF for UI that scales. Include the OFL.txt in your credits screen (OFL requires the licence to accompany the font, not on-screen credit). |

---

## 5. Sound effects

| Source | Licence | Key? | Unattended | Details |
|---|---|---|---|---|
| **jsfxr (npm) — procedural sfxr** | jsfxr repo licence (MIT per memory — UNVERIFIED; generated sounds are yours) | No | **Yes — VERIFIED by running it**: `npm i jsfxr@1.4.1`; `const {sfxr}=require('jsfxr'); const s=sfxr.generate('jump'); s.sample_size=16; s.sample_rate=44100; fs.writeFileSync('jump.wav',Buffer.from(sfxr.toWave(s).dataURI.split(',')[1],'base64'))` produced valid 16-bit 44.1 kHz mono RIFF WAVs. Presets: `pickupCoin, laserShoot, explosion, powerUp, hitHurt, jump, blipSelect, synth, tone, click, random`. Also ships a CLI `sfxr-to-wav <b58-string|JSON via stdin> out.wav` (VERIFIED: `npx -p jsfxr sfxr-to-wav <b58> test.wav` works). Design a sound at sfxr.me, copy the serialized b58 string, regenerate deterministically. `params.mutate()` for variations. | Best for: UI blips, pickups, jumps, hits, retro. Post-process with `ffmpeg`/`sox` for pitch/reverb. |
| **Python alternatives** | | | UNVERIFIED: `pyxel` has an sfx synth but needs its runtime; simpler to use numpy + `scipy.io.wavfile` to synthesise; no maintained Python sfxr port I could verify. Use Node. |
| Bfxr / ChipTone | | | Browser/Flash apps, no CLI (UNVERIFIED). |
| **Kenney audio packs** | CC0 | No | Yes (§1.1 scrape) | `impact-sounds`, `interface-sounds`, `ui-audio`, `sci-fi-sounds`, `rpg-audio`, `digital-audio`, `casino-audio`, `voiceover-pack`, `voiceover-pack-fighter`, `music-jingles` (VERIFIED list). OGG (+ some WAV — UNVERIFIED). Consistent, clean, mobile-perfect. |
| **Sonniss GDC bundles** | Royalty-free, commercial OK, no attribution, **no resale, no AI training** (VERIFIED) | No | **Yes — direct URLs** (VERIFIED on page): `https://downloads.sonniss.com/Sonniss.com-GDC2024-GameAudioBundle1of9.zip` … `9of9.zip`; 2023: `…GDC2023-GameAudioBundle1of14.zip` … `14of14.zip`; torrents `https://sonniss.com/GameAudioGDCPart8.torrent` (2024), `Part7` (2023). Years 2015–2024 (VERIFIED). | Tens of GB per year, pro quality (WAV 96k/24-bit mostly). Downsample to 44.1k/16-bit OGG for mobile. |
| **Freesound API** | per-sound CC0 / CC-BY / CC-BY-NC (filter!) | **Yes, free** (`freesound.org/apiv2/apply`, login required; apply page is robots-blocked to bots but is a normal form) | Partly: `GET https://freesound.org/apiv2/search/text/?query=jump&filter=license:"Creative Commons 0"&fields=id,name,previews,license,username&page_size=150&token=KEY` (VERIFIED param names; licence filter values `"Creative Commons 0"`, `"Attribution"` — UNVERIFIED exact strings). `previews.preview-hq-mp3` / `preview-hq-ogg` (VERIFIED field) are downloadable with just the token; **`GET /apiv2/sounds/<id>/download/` (original WAV) requires OAuth2** (VERIFIED). | For unattended use, the HQ OGG preview (~128 kbps) is usually good enough for mobile SFX. Rate limit ≈ 60 req/min, 2 000/day (UNVERIFIED memory). Attribution needed for CC-BY. |
| **Pixabay SFX** | Pixabay Content License: no attribution, commercial OK, no standalone resale (VERIFIED) | — | **No — the API only covers images and videos** (VERIFIED docs); audio download is web-only, JS-driven. |
| **BBC Sound Effects (RemArc)** | RemArc licence = personal/educational/research **non-commercial** only; commercial needs a paid licence (memory — UNVERIFIED; site blocked from my sandbox) | — | No API; JSON catalogue existed (`…/api/sfx/search`) UNVERIFIED. **Not for a commercial game.** |
| **ZapSplat** | Standard licence: free users **must credit "ZapSplat"**, MP3 only, daily limits; **"Automated access (bots, scrapers, scripts) is prohibited"** (VERIFIED) | account | **No** | Skip. |
| **OpenGameArt SFX** | mixed | No | Yes (§1.7 type 13, licence 4) | e.g. "512 Sound Effects (8-bit style)" by Juhani Junkala CC0 (UNVERIFIED id). |

---

## 6. Music

| Source | Licence | Unattended | Details |
|---|---|---|---|
| **Abstraction (Benjamin Burnes) / Tallbeard Studios "Music Loop Bundle"** | **CC0** (creator requests optional credit; asks not to use for NFT/AI) (VERIFIED) | semi (itch, §1.8) | `https://tallbeard.itch.io/music-loop-bundle` — 200+ seamless loops, ~540 MB, organised by quarter 2024–2026 + chiptune + pre-2023 (VERIFIED). Best single free game-music source. |
| **Kenney Music Jingles** | CC0 | Yes | `kenney.nl/assets/music-jingles` (VERIFIED exists) — short stingers only (win/lose/level-up), not loops. The paid All-in-1 bundle adds "music loops" (VERIFIED wording). |
| **Kevin MacLeod / Incompetech** | **CC-BY 4.0**, required credit text: `"<Title>" Kevin MacLeod (incompetech.com) Licensed under Creative Commons: By Attribution 4.0 https://creativecommons.org/licenses/by/4.0/` (VERIFIED) | Yes | Direct MP3 pattern `https://incompetech.com/music/royalty-free/mp3-royaltyfree/<Title With Spaces>.mp3` — fetch returned binary data (VERIFIED as binary; not header-inspected). Catalogue JSON used by the search page — UNVERIFIED. A no-attribution licence is purchasable. |
| **Free Music Archive** | per-track CC | **No — "we are no longer granting API keys"** (VERIFIED) | Web only. |
| **Pixabay Music** | Pixabay licence (no attribution) | No API for audio (VERIFIED) | Web only. |
| **Soundimage.org (Eric Matyas)** | Free with **mandatory attribution** (VERIFIED) | semi | WordPress pages per genre with mp3/ogg links (pattern UNVERIFIED, typically `soundimage.org/wp-content/uploads/<year>/<month>/<Track>.mp3`). Huge catalogue, quality variable. |
| **Joth** | CC0 packs on itch (memory — UNVERIFIED; itch profile fetch returned only shell) | semi | `joth.itch.io` redirects to `itch.io/profile/joth` (VERIFIED). |
| **OpenGameArt music** | mixed; filter CC0 | Yes (§1.7 type 12) | |
| **Generate offline** | | | **Strudel** (`@strudel/core` 1.2.6 on npm, VERIFIED) — Tidal-style patterns in JS; rendering to WAV offline needs a Web-Audio shim (`node-web-audio-api`) — UNVERIFIED feasibility. **Tone.js** 15.1.22 (VERIFIED on npm) has `Tone.Offline()` rendering but also needs a Web Audio implementation in Node. **Sonic Pi** has no headless CLI renderer (UNVERIFIED). Practical unattended path: write MIDI with Python `mido`/`pretty_midi`, render with **FluidSynth** + a free SF2 soundfont (`fluidsynth -ni font.sf2 song.mid -F out.wav`) — all CLI, deterministic (UNVERIFIED in this sandbox but standard tooling). |

---

## 7. Shaders / VFX

| Source | Licence | Unattended | Notes |
|---|---|---|---|
| **godotshaders.com** | Per shader: **CC0, MIT or GPLv3** (VERIFIED about page) — read each page's licence box | Scrape (HTML) — no API (VERIFIED absence) | Watch GPLv3 ones (viral). Good: outline, dissolve, water, screen-shake/chromatic-aberration, toon. |
| **Kenney Particle Pack** | CC0 | Yes | 80 × 512² PNG sprites (smoke, fire, spark, star, circle, muzzle…) (VERIFIED). Use as `GPUParticles2D/3D` textures; for mobile prefer `CPUParticles` or GPU with low counts on Compatibility renderer. |
| **Godot Asset Library VFX addons** | check `cost` field | Yes via legacy API (§1.10) | e.g. filter `particle`, `vfx`, `shake`. Specific 4.7-compatible names not verified. |
| Built-ins | | | Godot 4 ships `ProceduralSkyMaterial`, `FogVolume`, glow/bloom in `Environment` (Mobile renderer supports glow; Compatibility limited). |

---

## 8. Godot addons for polish (all VERIFIED via GitHub releases unless noted)

| Addon | Repo | Latest | Licence | Godot 4.7? | Notes |
|---|---|---|---|---|---|
| **Maaack's Game Template** | `github.com/Maaack/Godot-Game-Template` | **v1.7.0** (2026-09-09) | MIT | **Yes** — README: "Godot 4.7 (4.4+ compatible)" | Main/options/pause/credits menus, scene loader, input remapping, accessibility, 640×360→4K, 2D/3D agnostic. v1.7 split Scene Loader, Music Controller, UI Sound Controller into separate plugins — install those too. Asset Library ids 2703 (template) / 2709 (plugin); also on the new Asset Store. |
| **Phantom Camera** | `github.com/ramokz/phantom-camera` | **v0.11.0.3** (2026-07-19) | MIT | **Yes** — release notes fix a 4.7.1 autoload issue; note about a pending Godot PR #121509 for a `PhantomCameraManager` not-found error | 2D/3D camera follow/look-at/tween host. Zip: `https://codeload.github.com/ramokz/phantom-camera/zip/refs/tags/v0.11.0.3` → copy `addons/phantom_camera`. |
| **GUT** | `github.com/bitwes/Gut` | **v9.6.1** (2026-07-09) | MIT | Yes (4.x line; 4.7 not explicitly stated — UNVERIFIED) | CLI: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit`. |
| **gdUnit4** | `github.com/godot-gdunit-labs/gdUnit4` (moved from MikeSchulze) | **v6.2.1** (2026-08-20) | MIT | Yes (4.x; explicit 4.7 UNVERIFIED) | Headless runner `runtest.cmd`/`runtest.sh`; GitHub Action available. Pick one of GUT/gdUnit4; gdUnit4 has mocks/spies + C#. |
| **godot-mcp (Coding-Solo)** | `github.com/Coding-Solo/godot-mcp` | 5.6k★ | MIT | 4.4+ | `claude mcp add godot -e GODOT_PATH="C:\godot\godot.exe" -- npx @coding-solo/godot-mcp` (VERIFIED README). Launch editor, run project, capture output, scene ops. |
| **godot-mcp (tugcantopaloglu)** | `github.com/tugcantopaloglu/godot-mcp` | 453★ | MIT | **"Tested with Godot 4.7"**, needs 4.4+ | 157 tools incl. `run_project`, `game_screenshot`, `read_scene`, resource creation; clone + `npm run build`, run via `node build/index.js` (no npx). |
| **godot-ai (hi-godot)** | `github.com/hi-godot/godot-ai` | 2.3k★ | MIT | **Requires 4.7+** | Editor plugin + Python server over WebSocket, 46 tools; needs running editor (not headless). Snap/Linux-first; Windows support unclear (UNVERIFIED). |
| **GoPeak** | `github.com/HaD0Yun/Doyunha-Gopeak` | 250★ | see LICENSE | 4.x | `npx gopeak`; 95+ tools incl. LSP/DAP, screenshots, input injection, and a "CC0 asset library" tool (VERIFIED description only). |
| **godot-mcp-enhanced** | `github.com/wgt19861219/godot-mcp-enhanced` | 91★ | — | "4.5-4.7" | headless + editor + game bridge. |
| **SafeAreaX** | `github.com/godot-x/safe-area` | — | MIT | 4.x (UNVERIFIED for 4.7) | `addons/godotx_safe_area`, wraps `DisplayServer.get_display_safe_area()`; 9★ — small, read it before trusting. |
| **godot-haptic-feedback** | `github.com/zfr/godot-haptic-feedback` | 2026-05 | — | GDExtension 4.x | iOS `UIFeedbackGenerator` + Android `VibrationEffect` (0★, new — UNVERIFIED quality). |
| **Built-in haptics** | — | — | — | — | `Input.vibrate_handheld(duration_ms:=500, amplitude:=-1.0)` — Android (needs **VIBRATE permission** in export preset), iOS (duration on iOS 13+), Web (no amplitude; Safari/Firefox-Android unsupported) (VERIFIED docs). For "tick" haptics use 10–30 ms with amplitude 0.3–0.6. |
| **Built-in safe area** | — | — | — | — | `DisplayServer.get_display_safe_area()` → `Rect2i` (Android + iOS; others fall back to usable rect) and `DisplayServer.get_display_cutouts()` → `Array[Rect2]` (Android only) (VERIFIED docs). Apply as margins on a root `MarginContainer` in `_ready()` and on `size_changed`. |

Fetching any addon unattended:
```powershell
$o='ramokz'; $r='phantom-camera'; $tag='v0.11.0.3'
Invoke-WebRequest "https://codeload.github.com/$o/$r/zip/refs/tags/$tag" -OutFile "$r.zip"
Expand-Archive "$r.zip" -DestinationPath tmp; Copy-Item "tmp\$r-*\addons\*" ".\addons\" -Recurse
```
(Or use the legacy Asset Library API `download_url` — it is the same GitHub archive zip.)

---

## 9. Style consistency & mixing rules

- **Kenney + KayKit: near-perfect match.** Both are flat-shaded low-poly with a single colour-swatch/gradient atlas texture, similar chunky proportions (KayKit characters ≈ 1.8 units tall, Kenney kits are 1-unit grid based — UNVERIFIED exact numbers). Kenney's own `KayKit-Hexagons` repo mixes them (VERIFIED repo exists). Kenney documented that both use "texture maps that include all colours used in the pack" so you can recolour by editing one PNG (VERIFIED thread titles; text not retrieved).
- **Quaternius: same family, slightly different flavour** — rounder, more "toon", sometimes gradient/vertex-coloured; characters are taller/more realistic proportioned than Kenney's blocky ones. Mixes fine for environments; keep characters from one source (Quaternius or KayKit) for consistency. Community advice: Kenney for breadth/UI/audio, Quaternius for rigged characters & creatures (VERIFIED 3dxdev article).
- **Poly Haven / ambientCG: do not mix with the above** unless deliberately (photoreal vs flat). Do use Poly Haven HDRIs as light/sky for low-poly scenes — works great with flat shading; blur them or use `ProceduralSkyMaterial` to avoid photo backgrounds.
- **Practical unifying tricks:** (1) one global directional light + soft shadows + slight `Environment` tonemap (ACES/AgX) and matching `ssao` off; (2) force all imported materials to the same `roughness ≈ 0.8, metallic 0`; (3) a single post-process outline shader (godotshaders.com) hides source differences; (4) unify scale on import (`Scene > Root scale` in the `.import` or a parent Node3D); (5) recolour palettes: replace Kenney `colormap.png` / KayKit atlas colours to your game palette.
- **2D:** Kenney's 2D packs share line weight and palette across "Tiny", "Scribble", "Pixel" series — mix within a series only. Lucide/Tabler icons (2 px stroke, 24 px grid) match each other; game-icons are solid black glyphs — use one family for UI.

---

## 10. Importing glTF/GLB into Godot 4 from the command line — VERIFIED (docs + source) with caveats

- `godot --headless --path <project> --import` — "Starts the editor, waits for any resources to be imported, and then quits. Implies `--editor` and `--quit`" (VERIFIED docs). Needs the **editor** binary (not an export template). `--export-release/--export-debug/--export-pack` imply `--import` (VERIFIED docs) — the old bug where headless export skipped importing (issue #73782, 4.0-rc) was fixed in 4.0 (VERIFIED issue; fix version UNVERIFIED but the 4.7 docs say export implies import).
- **It does pick up new files**: the editor scans the filesystem on start, creates `<file>.import` next to each new asset and writes compiled data to `.godot/imported/`. Commit the `.import` files, git-ignore `.godot/`.
- **Gotchas (mix of VERIFIED docs and experience — UNVERIFIED where marked):**
  1. glTF with external textures: keep `textures/` and `.bin` at the relative paths the `.gltf` references (Poly Haven's `include` list). GLB embeds everything — prefer GLB for unattended pipelines.
  2. First headless import of a large asset drop can time out or exit before finishing on slow disks; running `--import` **twice** is a common CI idiom (UNVERIFIED but widely used). Check exit code and grep stderr for `ERROR`.
  3. Embedded textures from GLB become internal sub-resources; if you want editable textures set `import > Materials/Textures extract` in the `.import` (`materials/extract=true`, `materials/extract_path`) — property names UNVERIFIED for 4.7.
  4. Name suffixes work headless: `-col`, `-convcol`, `-colonly`, `-convcolonly` (collision), `-noimp` (skip), `-occ/-occonly`, `-navmesh`, `-loop` for animations (VERIFIED docs).
  5. glTF is the recommended format; FBX imports via built-in **ufbx** (no external FBX2glTF needed anymore) (VERIFIED docs). KayKit/Quaternius FBX therefore import, but glTF is safer.
  6. Godot does not import from `addons/` any differently — the KayKit `addons/<pack>` layout is only a convention.
  7. Textures inside a folder with a `.gdignore` file are skipped — useful to exclude `Previews/`, `Isometric/`, `Source/` folders from Kenney/Quaternius zips. Write an empty `.gdignore` there before importing.
  8. Changing `rendering/textures/vram_compression/import_etc2_astc` does **not** re-import already-imported textures; delete `.godot/imported/` and re-run `--import` (VERIFIED docs).
- Minimal Windows pipeline:
  ```powershell
  & "C:\godot\Godot_v4.7.2-stable_win64.exe" --headless --path . --import 2>&1 | Tee-Object import.log
  if (Select-String -Path import.log -Pattern "ERROR") { throw "import errors" }
  & "C:\godot\Godot_v4.7.2-stable_win64.exe" --headless --path . --export-debug "Android" build\game.apk
  ```
- three.js side: GLB loads directly with `GLTFLoader`; for Poly Haven glTF+textures keep the same relative layout; run `gltf-transform optimize in.glb out.glb --texture-compress webp` (npm `@gltf-transform/cli`, UNVERIFIED version) to shrink for PWA delivery.

---

## 11. Texture sizes & compression for Android (~1080×2340 phone)

**Engine facts (VERIFIED from Godot docs/source):**
- Compress modes: Lossless (default for 2D, recommended for pixel art), Lossy (WebP, large 2D), **VRAM Compressed** (default for 3D; "S3TC, BPTC or ETC2 depending on platform"; 4–6× less VRAM), VRAM Uncompressed, Basis Universal (small files, lower quality, slow import).
- "Detect 3D" auto-switches a texture to VRAM Compressed + mipmaps the first time it is used in 3D.
- **Compress > High Quality**: off (default) → S3TC desktop / **ETC2 mobile & web**; on → BPTC desktop / **ASTC 4×4 mobile** (only in Forward+ and **Mobile** renderers; Compatibility ignores it). ASTC/BPTC also allow compressed HDR.
- Project setting `rendering/textures/vram_compression/import_etc2_astc` (default **false**) must be **true** for Android — the Android exporter refuses with "ETC2/ASTC texture compression is required for Android export" otherwise (VERIFIED in `platform/android/export/export_plugin.cpp`). Turn `import_s3tc_bptc` off if you never ship desktop to halve import time/size (UNVERIFIED default behaviour; the importer "always imports the format the host platform needs" — VERIFIED note).
- Mipmaps add ~33 % memory; recommended in 3D, only if visibly needed in 2D (VERIFIED). `process/size_limit` clamps the longest edge on import — use it to keep source 4k art while shipping 1k (VERIFIED). Mobile GPUs usually cap at 4096² (VERIFIED docs note).

**Recommendations for a 1080×2340 phone (mine + one community guide, VERIFIED source for the numbers in quotes):**

| Asset | Size | Mode |
|---|---|---|
| Low-poly colormap atlases (Kenney/KayKit) | as shipped (often 64–1024 px); keep **Lossless**, mipmaps on, filter *Nearest* only if you want crisp swatches — the atlas is tiny so VRAM is irrelevant | Lossless |
| PBR sets (Poly Haven / ambientCG) | **1024²** for props, **2048²** max for hero/terrain ("1024×1024 maximum for props, 2048×2048 for hero" — slicker.me guide) | VRAM Compressed, High Quality ON (ASTC) in Mobile renderer; ETC2 if using Compatibility |
| Normal maps | same size as albedo or one step smaller; ETC2 uses RG (RGTC-like) automatically | VRAM Compressed |
| HDRI sky | 1k–2k `.hdr` | VRAM Compressed (ASTC HDR needs High Quality) or use `PanoramaSkyMaterial` with 1k |
| UI / sprites | native size at 2× (design at 1080 wide, export @2x for 1440 phones only if needed) | Lossless (or Lossy WebP for big backgrounds); no mipmaps unless scaled |
| Particles | Kenney 512² | Lossy or Lossless |
| Fonts | MSDF for scalable UI, or bitmap at 2× | n/a |

- Renderer: **Mobile** for 3D (tile-GPU tuned, supports High-Quality ASTC & glow); **Compatibility** for 2D/very simple 3D and widest device reach (no ASTC "High Quality"; ETC2 only). Never Forward+ on phones (VERIFIED guide).
- Budget: aim for < 300 MB total RAM on mid-range Android (guide); a 2048² RGBA ETC2/ASTC 4×4 texture with mipmaps ≈ 5.3 MB vs 21 MB uncompressed (from docs table scale; exact numbers UNVERIFIED).
- Render at 0.75–0.85 `scaling_3d_scale` with FSR/bilinear on 2340-tall phones; keep UI at native res (separate `SubViewport`) — standard practice, UNVERIFIED docs cite.
- `.import` template for a PBR albedo (property names from Godot 4 `.import` files — UNVERIFIED for 4.7 exact keys):
  ```
  [params]
  compress/mode=2            ; 2 = VRAM Compressed
  compress/high_quality=true ; ASTC on mobile
  compress/hdr_compression=1
  compress/normal_map=0      ; 1 = force normal-map (RGTC) for *_nor_gl
  mipmaps/generate=true
  process/size_limit=1024
  detect_3d/compress_to=1
  ```
  Set once via a Godot `EditorImportPlugin`/`EditorScript`, or generate the `.import` file next to each texture **before** running `--import` so headless import honours it.

---

## 12. Quick-reference: unattended fetch matrix

| Source | Curl-able? | Key | Licence | Verdict |
|---|---|---|---|---|
| Kenney (scrape) | Yes | – | CC0 | ★★★ |
| KayKit GitHub | Yes | – | CC0 | ★★★ |
| Poly Haven API | Yes | – (User-Agent) | CC0 | ★★★ |
| ambientCG API | Yes | – | CC0 | ★★★ |
| Poly Pizza API | Yes | free (credits) | per model | ★★ |
| OpenGameArt | Yes (HTML) | – | per item | ★★ |
| Quaternius | Google Drive via gdown | – | CC0 / QAL | ★★ (fragile) |
| itch.io free packs | Yes with itch API key | free | per pack | ★★ |
| Sketchfab | OAuth/token | account | per model | ★ |
| Mixamo | No | Adobe login | Mixamo EULA | ✗ (use Quaternius UAL2 / KayKit anims) |
| Sonniss GDC | Yes | – | royalty-free | ★★★ (huge) |
| Freesound | Yes (previews) | free key | per sound | ★★ |
| jsfxr (Node) | local | – | generated | ★★★ |
| Kenney audio | Yes | – | CC0 | ★★★ |
| Pixabay audio | No | – | Pixabay | ✗ |
| ZapSplat | No (forbidden) | account | credit req. | ✗ |
| BBC SFX | No | – | non-commercial | ✗ |
| Incompetech | Yes | – | CC-BY 4.0 | ★★ |
| Tallbeard loops | itch flow | free | CC0 | ★★★ (best music) |
| Google Fonts / Fontsource | Yes | – (or free key) | OFL | ★★★ |
| Lucide / Tabler / game-icons | Yes | – | ISC / MIT / CC-BY 3.0 | ★★★ |
| Godot addons via GitHub | Yes | – | MIT | ★★★ |
| Legacy Asset Library API | Yes | – | per asset | ★★ (read-only soon) |
| New Asset Store | No API | – | – | ✗ for scripts |

## 13. Attribution checklist for a shipped game
- CC0 (Kenney, KayKit, Poly Haven, ambientCG, Tallbeard, 3dtextures, Quaternius-CC0 packs): nothing required — a credits line is polite.
- QAL (new Quaternius): nothing required; don't redistribute raw files (e.g. don't commit them to a public repo).
- CC-BY: Kevin MacLeod (exact text in §6), game-icons.net (author + URL), Freesound CC-BY sounds (author + link), Sonniss (none), OFL fonts (ship the OFL.txt with the font), Lucide (ISC notice in credits), Tabler (MIT notice).
- Keep a `CREDITS.md` generated by your fetch script: record source URL, licence, and download date for every asset — Maaack's template has a credits screen that can render it.
