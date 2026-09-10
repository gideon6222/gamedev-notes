# WEB.md - the web (PWA) stack, for the games that want to be a link

Read only when a game is built for the web. Coreward ships on this stack and is still
maintained; nothing here is deprecated, it is just the right answer for fewer things now.
The full web-era notes are in `archive/PIPELINE-2026-09-09.md`, and every three.js and DOM
trap is in `techniques/three-js-traps.md`. Edited only by `/digest`.

## When to choose it

Something to send someone, something that must run without installing anything, or a
game that is genuinely 2D and light. Everything else is Godot.

## The stack (verified on Coreward)

| Piece | Choice | Why |
|---|---|---|
| Build | **Vite**, `base: './'` | Pages serves from `/reponame/` |
| Language | **TypeScript, strict**, `verbatimModuleSyntax` | `import type` is load-bearing |
| 3D | **three.js pinned exactly** | Lighting values are calibrated per version |
| PWA | **vite-plugin-pwa** `generateSW` | Never hand-write a service worker |
| Tests | `node --test test/*.test.mjs` over pure functions, esbuild-bundled | A hand-listed test file set silently stops running new files |
| Smoke | **Playwright** against the production build, portrait viewport **after** the device spread | The only thing that catches wiring bugs |
| Deploy | GitHub Actions to GitHub Pages: typecheck, golden, build, smoke, deploy | CI is the gate |
| Audio | Synthesised at runtime with Web Audio, built on the first gesture | No files, responds to state |
| Fonts | Self-hosted woff2 from Google Fonts, `woff2` in the Workbox glob | An external stylesheet fails offline |

Start from the most recent web game, not from scratch: `vite.config.js`,
`.github/workflows/deploy.yml`, `test/harness.mjs`, `scripts/check-bundle-size.mjs`,
`.gitattributes` and the `<head>` of `index.html` are taken verbatim. `/game-scaffold web`
does this and creates the repo, then enables Pages with
`gh api -X POST repos/{owner}/{repo}/pages -f build_type=workflow` (fall back to `PUT` on a
409). A workflow cannot enable Pages itself; the `gh` call with the user's token can.

## Rules that were paid for

- **Split the vendor chunk** (`manualChunks` for `node_modules/three`) so a gameplay tweak
  invalidates 28 KB instead of 500 KB on mobile data and the size guard can see a
  regression. Bundle budget fails in both directions.
- **Error overlay handler in `<head>` before the module script.** Vite hoists the entry.
  He has no console on the phone.
- **Build stamp via Vite `define`, a version and a changelog** in the menu. An installed PWA
  is one load behind and the stamp is the only way to know an update landed.
- **`touch-action: none` on the play area and HUD, never on `html`/`body`**, or every
  scroller underneath stops panning. A window-level drag handler must bail when the event
  started on UI. Pin START with `position: sticky; bottom: 0`.
- **Every game gets its own preview and test ports, never a Vite default**, and
  `reuseExistingServer` stays `false`. Two suites on this machine once tested each other's
  builds. Coreward: 4319 tests, 4318 preview.
- **`npm run preview` serves the service worker**, so a driven browser can test the build
  before the one you just made. Check the hashed script filename, and unregister workers and
  clear caches before trusting anything.
- **Rebuild before every e2e run that follows a source change**, and never start the smoke
  tests while a build is in flight. A stale `dist/` lies in the direction of "your fix did
  not work".
- **The pure layer is a DIRECTORY, `src/sim/`, not a paragraph asking people to be careful.**
  Coreward kept thirteen pure modules beside the renderer modules with the rule written in a
  comment; an `import * as THREE` in one of them would have shipped and first shown up as an
  esbuild error in the golden harness days later, in a file nobody had touched. Moving them
  cost 77 import lines. Then a test reads the directory and fails on an import of three.js, on
  any non-`import type` crossing out of it, on a renderer or input global, and on an unseeded
  roll - and each of those five clauses gets falsified separately.
- **The headless tick seam** (`freeze()`, `advance(dt, draw)` behind `?debug`) is what makes
  the deep game testable: 51x real time, draw only the last frame. Anything that accrues in
  game time belongs on it, never on wall-clock polling.
- **Seeding a save through `localStorage` and reloading does not work** if the game saves on
  `visibilitychange`. Freeze `Storage.prototype.setItem` for that key first.
- **Drive real pointer events for anything about direction** and assert in NDC.
- **Filmstrip**: `node scripts/filmstrip.mjs <scenario> [frames] [secondsPerFrame]` composites
  in the browser on the tick seam. Same rules as `movie.ps1` on Godot.

## Measured limits (Coreward, S26 Ultra)

JS heap in play 22 MB against 4 GB. Save file 339 bytes typical, 12.5 KB worst. Download
147 KB gzip, 119 KB of it three.js cached across updates. Draw calls cost 5.0 us each on a
desktop, linear to 2,500; the game's 60 are under 4% of a frame. The real constraints, in
order: thermal throttling, update size on mobile data, then fill rate. Memory is not a
constraint and should not be treated as one. Draw calls are a regression detector, not a
ceiling: budget for instancing breaking, not for a hardware limit.

## Assets on the web

Every kilobyte is mobile data here, so the old caution applies on this stack: take the
normal map and leave the colour map, size textures from physical pixels (384 px WebP was
native for a Coreward cell), a font subset is 20 KB and the best import there is, and a
`.glb` costs `GLTFLoader` plus a precache entry, so it is for a hero asset, not scenery.
`npx @gltf-transform/cli optimize in.glb out.glb --compress draco --texture-compress webp`.
