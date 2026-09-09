# PIPELINE.md

How a game gets built, shipped and played. **Current state, not history** — rewrite this
file in place when something changes. The dated record lives in git.

Read this before starting or resuming any game.

---

## How we actually work

Gideon runs **Claude Code on his Windows PC**, in a real terminal, against real git
repositories. Claude has a shell, node, npm, a browser it can drive, and the ability to run
builds and tests. Games are played on a **Samsung S26 Ultra**, in Chrome, installed to the
home screen as a PWA.

That combination is what makes everything below possible. The old rules — "five files, no
build step", "relative paths only, no tooling" — were written when Claude could only push
files through the GitHub connector and could not run anything. **They were precautions, not
design choices, and they are no longer binding.**

If a rule anywhere else reads like a precaution against not being able to run something, it
is from that era. Delete it.

### Several games run at once, and this repo is shared between them

**Never `git add -A` in `gamedev-notes`.** Two sessions were writing to it on 2026-09-09 —
Coreward's lighting work and Stillwater's first playable build — and a blanket add in one of
them swept up the other's half-finished edits and committed them under an unrelated message.
Nothing was lost that time, but the lesson generalises badly: a shared repo with two writers
means `-A` commits somebody else's work-in-progress, possibly mid-sentence, and the commit
message then describes the wrong change.

Stage the files you actually edited, by name. And when a commit here comes back "nothing to
commit, working tree clean" on changes you know you just made, look at the log before
re-doing them — they are probably already in, inside someone else's commit.

## Every game is built to be continued

**There are no one-off games.** Gideon does not make them, and nothing here should offer the
option. A game that starts without the build, the tests and the size guard is a game whose
second session begins with a migration — and that migration is strictly more work than
setting it up on day one, because by then there is a game to avoid breaking while you do it.

So: **the full stack below, from the first commit, for everything.** Even a prototype. Even
something that looks like an afternoon.

Concretely, before any game logic is written:

- `git init`, a GitHub remote, and a first commit
- Vite + TypeScript + the pinned three.js
- `CLAUDE.md`, so the next session and every other chat picks up this repo
- `NOTES.md`, so decisions have somewhere to go
- The CI workflow, the size guard, and a golden test that asserts *something*
- A build stamp, a version number and a changelog

That list is about twenty minutes copied from the previous game. The cost of skipping it is
paid later, with interest, by whoever comes back to the game — which is always going to be
someone.

---

## Two stacks now

**Web (PWA)** — Vite, TypeScript, three.js, GitHub Pages. Coreward and Candle Gift ship on
it. Instant to iterate, zero cost, no store.

**Native Android (Godot)** — for anything that wants a Play listing, Play Games Services,
in-app purchases, real asset sizes or a performance ceiling that is the GPU rather than a
WebView. Proven 2026-09-08 in `C:\dev\godot-template`.

**The method is the same in both and is the thing that actually carries over**: a pure
simulation core with no renderer in it, seeded determinism, a headless tick seam, a
whole-run golden test, a size guard that fails in both directions, a build stamp, a
changelog, and CI as the gate. Everything in `CRAFT.md` applies to both — it is about
games, not about a language.

Everything below in this section is the **web** stack. The Godot stack is at the end of
this file.

## The stack (web)

Verified working on Coreward. **This is the stack for every web game**, from the first
commit — see the section above for why there is no lighter option.

| Piece | Choice | Why |
|---|---|---|
| Build | **Vite** | Dev server, hashed output, `base: './'` for Pages subpaths |
| Language | **TypeScript, strict** | `verbatimModuleSyntax` on; `import type` is load-bearing |
| 3D | **three.js, pinned exactly** | Not a caret range. Lighting values are calibrated per version |
| PWA | **vite-plugin-pwa**, `generateSW` | Workbox builds the precache from real output. Never hand-write a service worker |
| Tests | **`node --test`** + esbuild bundling of a pure entry point | Golden tests over pure functions |
| Smoke | **Playwright** against the production build | The only thing that catches wiring bugs |
| Deploy | **GitHub Actions → GitHub Pages** | Gated: typecheck → golden → build → smoke → deploy |
| Audio | **Synthesised at runtime, Web Audio** | No files, no loading, no licensing |

### Non-obvious things that cost time to rediscover

- **`base: './'`** because Pages serves from `/reponame/`, not the domain root.
- **Split the vendor chunk.** `manualChunks(id) { if (id.includes('node_modules/three')) return 'three'; }`
  Two reasons: a gameplay tweak then invalidates ~28 KB instead of ~500 KB on mobile data,
  and the size guard becomes able to see a regression. In one combined chunk, the frame loop
  going missing measured as a 1.57% drop — inside any sane tolerance.
- **Put the error overlay handler in `<head>`**, before the module script. Vite hoists the
  entry above anything later in `<body>`, so a handler further down never sees a boot error.
  Verify it by deliberately breaking an import once.
- **`.gitattributes` with `* text=auto eol=lf`**, or CRLF rewrites golden baselines on
  checkout and every test fails on a fresh clone and in CI.
- **A build stamp** (`__BUILD_SHA__` / `__BUILD_TIME__` via Vite `define`) shown in a menu.
  An installed PWA can be one load behind and the game is meant to look identical between
  builds, so this is the only way to confirm on-device that an update landed.
- **A version number and a changelog** in the same menu. The stamp answers "did it land";
  it cannot answer "what changed". Add this from day one — on Coreward it arrived far too
  late to be as useful as it should have been.

---

## Starting a new game

```bash
mkdir <name> && cd <name> && git init && npm init -y
npm i three@<exact>
npm i -D vite typescript @types/three@<same-exact> vite-plugin-pwa @playwright/test esbuild @types/node
```

Then copy from the most recent game rather than writing fresh — the parts worth taking
verbatim are `vite.config.js`, `.github/workflows/deploy.yml`, `test/harness.mjs`,
`scripts/check-bundle-size.mjs`, `.gitattributes`, and the `<head>` of `index.html`.

Gideon creates the empty public repo; Claude pushes into it. Enable Pages → "GitHub Actions"
in the repo settings once.

**Write `CLAUDE.md` before writing the game.** It is the file that makes the next session
cheap: stack, deploy, the file map, and the invariants that are not obvious from the code.

---

## Shipping

**Enabling Pages is a one-time manual step, and a workflow cannot do it.** Settings → Pages
→ Source = "GitHub Actions". `actions/configure-pages` with `enablement: true` is refused
with `Resource not accessible by integration` on the create-a-pages-site endpoint, whatever
the workflow's `permissions:` block says. Captain Run sat with `has_pages: false` and a live
URL in three different files that had never served anything.

**Push straight to `main`.** CI is the gate. A build that fails any step cannot deploy, so
the previous version stays up.

Then check it on the phone. Expect the first open to show the old build; close it fully and
reopen. The stamp in the menu is the source of truth.

**Do not poll the live site to confirm a deploy — but DO confirm CI went green.** These are
not the same thing, and conflating them cost a whole session: a smoke test failed, the deploy
job was skipped, the live site stayed on the previous version, and Gideon spent his evening
restarting a phone app that had nothing new to fetch. "Push and move on" means not
re-verifying an artifact CI already tested; it never meant not looking at whether the gate
passed. One call, no auth needed on a public repo:

```bash
curl -s "https://api.github.com/repos/<owner>/<repo>/actions/runs?per_page=3"   | python -c "import json,sys; [print(r['head_sha'][:7], r['status'], r['conclusion']) for r in json.load(sys.stdin)['workflow_runs']]"
```

**When it does fail, the logs need auth but the annotations do not.** `Sign in to view logs`
on the web UI is a dead end; this returns the actual assertion text, and it is public:

```bash
curl -s "https://api.github.com/repos/<owner>/<repo>/check-runs/<job_id>/annotations"
```

Get `<job_id>` from `.../actions/runs/<run_id>/jobs`, which is also public.

If something plays badly: `git revert <sha>` and push. Two minutes to the previous state.

To preview a branch on the phone before pushing — useful for something purely visual —
`npm run preview -- --host 0.0.0.0` and open the PC's LAN address. No service worker over
plain http, so it will not test offline behaviour. Requires the same wifi.

---

## Limits: measured, not guessed

Everything here was measured on the real game. **Where a number is not listed, there is no
limit worth thinking about.**

| Thing | Measured | Actual ceiling | Verdict |
|---|---|---|---|
| JS heap in play | **22 MB** | 4096 MB | Not a constraint. Not close to one |
| Save file, typical | **339 bytes** | ~5 MB `localStorage` | 0.007% of quota |
| Save file, worst case | **12.5 KB** | ~5 MB | Every cell of a full planet dug |
| Download, gzip | **147 KB** | — | 119 KB of that is three.js, cached across updates |
| Draw calls, worst case | **60** | **~3,200** before missing 60 fps (measured) | 2% of the real ceiling |
| Cost of one draw call | **5.0 us** | — | Linear from 79 to 2,519 calls |
| Build | **4.1 s** | — | |
| Golden tests | **1.2 s** for 116 | — | Run them constantly |

### What that means

**Memory is not a constraint on this hardware and should not be treated as one.** Earlier
notes were cautious about it on no evidence. Delete that caution wherever it appears. If a
game ever does get near a limit, measure it and record the number here.

**The real constraints are these three, in order:**

1. **Thermal throttling.** A phone throttles GPU and CPU after five to ten minutes of
   sustained rendering. This matters far more than any static budget, because it is the one
   that degrades a session *while it is being played*. Nothing in the current games has hit
   it; if a game ever feels like it slows down after a while, this is why.
2. **Update size on mobile data**, which is why three.js is split into its own chunk.
3. **Draw calls** — and this one turned out to be much less of a constraint than the rule of
   thumb says. Instancing solves it almost entirely regardless: Coreward went 207 → 35 by
   instancing terrain, and sits at 60 with far more content.

### Budgets that exist, and what they are for

Both are **drift detectors, not ceilings**. Their value is failing when something changes
unexpectedly, not in the specific number.

- **`bundle-budget.json`** — per-chunk size with tolerances, checked in CI, and it fails in
  *both* directions. A shrink means code went missing. Re-record deliberately
  (`npm run size:update`) as part of any commit that adds a system.
- **A draw-call budget** in the smoke test. Seed it to the game's genuine worst case, not to
  whatever a short scripted run reaches — measuring the easy case is how a budget quietly
  stops being one.

  **Set it to catch instancing breaking, not to approximate a hardware ceiling.** The
  "roughly 50 to 100 draw calls on mobile" figure that every guide repeats is off by more
  than an order of magnitude for a game like this. Measured on Coreward by adding sub-pixel
  meshes to the real worst-case scene and timing whole frames through the tick seam, so it
  isolates call overhead from fill rate:

  | calls | ms/frame | | calls | ms/frame |
  |---|---|---|---|---|
  | 79 | 0.64 | | 819 | 3.66 |
  | 219 | 1.19 | | 1,519 | 7.27 |
  | 419 | 1.88 | | 2,519 | 12.88 |

  Linear at **5.0 us per call**. The game's 60 calls are 0.64 ms — under 4% of a 60 fps
  frame — and it would take about **3,200** to miss 60 fps on a desktop. Phone driver
  overhead is worse by some multiple, which still leaves the real ceiling in the high
  hundreds at minimum. So budget for the REGRESSION (Coreward's 150 against a worst case of
  60, where instancing breaking would put it in the hundreds), and stop treating a couple of
  hundred draw calls as a problem worth designing around.

  **Fill rate is the thing to watch on a phone instead**, because that is what a heavier
  shader costs and what feeds thermal throttling. Coreward's move to PBR terrain cost
  0.098 ms/frame at the same draw count — measurable, where a hundred extra draw calls would
  not have been.

---

## A test script that lists files by hand will silently stop running them

Candle Gift's `npm test` named its six unit-test files one by one. A seventh file was added,
`npm test` reported **65 passing**, and nine new tests had simply never run - no error, no
skip, nothing to notice unless you happen to know what the total should be. Point the runner
at a pattern (`node --test test/*.test.mjs`) so adding a file is enough.

The general shape: **any list of things to run that is maintained by hand fails silently in
the safe-looking direction.** It never breaks the build, it just quietly covers less. Worth
checking anywhere a config enumerates files - test globs, workbox precache patterns, the
entry points a bundler is told about.

## Testing, and what each layer is for

Three layers, each catching something the others cannot:

**Golden tests** (`node --test`, pure functions only). World generation, costs, derived
stats, pathfinding, curves. They run in a second and they catch balance and content changes.
They **cannot** catch a wiring bug: a module split once dropped
`requestAnimationFrame(frame)` and every golden test passed.

**The headless tick seam is what makes the deep game testable at all, and it is worth
retrofitting.** Coreward went three sessions with its deep content untested for one reason:
reaching 85 m meant holding a d-pad in a real browser for as long as it would actually take
to fly there, and a test that costs a minute of wall clock never gets written. Splitting
`frame(now)` (asks the time, calls rAF) from `tick(dt, draw)` (does the work) and exposing
the second behind `?debug` measured **51x real time** - twenty simulated seconds in 396 ms -
and made the first end-to-end proof that tremors fire take 2.6 seconds. Measured per tick on
a real GPU: **0.239 ms simulating, 0.534 ms drawing**, so the "only draw the last step" rule
is a 69% saving before you even reach a software rasteriser. Expose the state objects too:
a test that reads the HUD asserts on a rounded string, and `DEPTH 0 m` is true at both 0.0
and 0.49.

**Smoke tests** (Playwright, against the production build). The load-bearing assertion is
"the frame loop advances". Then: a WebGL context exists, digging and selling work, every
panel opens, the audio graph builds on a real gesture, draw calls are in budget, the stamp
is populated.

**Design tests.** The most valuable and least obvious layer: assertions about *intent*
rather than values. "A hazard breaks faster than the rock around it." "A deeper ore is
rarer than the one above it." "The Cooling Rig's mineral lives below the heat line." These
catch design mistakes before a human sees them, and several have.

**A golden over floats needs a tolerance, and `snappedf` does not give you one.** Snapping a
double to 0.001 and pasting it into the source as a literal does not round-trip: the bits the
literal parses to are not the bits the snap produced, so the recorded golden can never match
the run it was recorded from. The failure prints as `expected -0.825, got -0.825`, which is
the least informative message a test can produce and reads as a broken harness. Compare floats
in the golden comparator with an epsilon a thousand times finer than the snap - a behaviour
change would have to be smaller than a micron to hide in it.

It pays for itself a second time in CI. **Goldens are recorded on one machine and checked on
another**, here Windows against a Linux runner, and bit-identical IEEE arithmetic across two
toolchains is something people assume rather than something that is promised. Without the
tolerance the suite eventually becomes a platform detector.

### The two ways a phone game silently loses scrolling

Both of these were shipped in Candle Gift and neither is visible on a desktop, in a test that
does not use touch, or in a screenshot. They cost the player the whole game: the shop would
not scroll, and the button that starts a level sits at the bottom of the shop.

**`touch-action: none` belongs on the play area, never on `html`/`body`.** A browser decides
what a touch may do by intersecting `touch-action` up the *entire ancestor chain*, so setting
it on body disables panning inside every scroller underneath it - a menu, a shop, a changelog.
Put it on the canvas container and the HUD instead:

```css
html, body { overscroll-behavior: none; }   /* no rubber-banding */
#game, #hud, #pops { touch-action: none; }  /* no gestures over the game */
.sheet { touch-action: pan-y; overscroll-behavior: contain; }
```

**A window-level drag handler will eat gestures meant for the UI.** These games listen for
`touchmove` on `window` with `{passive:false}` and call `preventDefault()` so a steering drag
does not scroll the page - which is right over the game and wrong over a menu. Bail out when
the event started on UI:

```js
const onUI = (e) => !!(e.target?.closest?.('.modal'));
function ptDown(e) { sfx.init(); if (onUI(e)) { dragId = null; return; } ... }
function ptMove(e) { if (dragId === null || onUI(e)) return; ... }
```

`sfx.init()` still has to run on the gesture even when it was on a menu, because Chrome will
not build an AudioContext outside one.

**And do not let a control that leaves a screen depend on reaching the end of that screen.**
The START button was the last element after eight upgrades, a changelog and a build stamp, so
the scrolling bug was the difference between "awkward" and "the game cannot be continued".
Pin it: `position: sticky; bottom: 0` inside the scroller. Cheap insurance against every
future scrolling bug, not just this one.

### Two settings that have to be right per game, not copied

**Give every game its own fixed preview port.** Every game copies its stack from the last, so
every game inherited `vite preview` on 4173. Two suites running at once on this machine then
fight over one port - and the failures do not look like a port conflict. Wick's suite produced
a run of `ERR_CONNECTION_REFUSED` mid-suite when Coreward's server went away, which reads
exactly like boot bugs, and briefly - with `reuseExistingServer: true` - *ran Wick's tests
against Coreward* and reported that its debug seam did not exist. Coreward 4173, Wick 4179;
pick a new number for the next one. It costs one line.

Related: **`reuseExistingServer` should stay `false` everywhere.** It looks like a convenience
for local iteration and it is really "attach to whatever answers on this port, and skip the
build". A suite whose whole purpose is to test *this* artifact must never be allowed to test
another one.

**Put the test viewport AFTER the device spread.** `use: { ...devices['Desktop Chrome'] }`
carries its own 1280x720 viewport, and a project's `use` overrides the top-level one - so a
portrait size set at the top is silently discarded and every smoke test runs landscape on a
desktop-shaped window. These are portrait-only phone games whose cameras solve field of view
from the aspect ratio, so that is not cosmetic: the tests frame a picture the phone never
renders. It went unnoticed in two games. Write it as:

```js
projects: [{ name: 'chromium',
  use: { ...devices['Desktop Chrome'], viewport: { width: 390, height: 844 } } }],
```

### Rules that were learned the hard way

- **`npm run preview` serves the service worker, so a driven browser can test the build BEFORE
  the one you just made.** The PWA registers its worker on the first visit and then answers
  navigations from cache, so a rebuild is one load behind - and unlike the phone, where this is
  expected and the build stamp is checked, nothing prompts you to doubt it locally. It cost an
  hour: a fix was verified as "still broken", diagnosed as a wrong diagnosis, and was actually
  correct all along. **Check the hashed filename, not the behaviour**, and clear it before
  trusting anything:
  ```js
  [...document.querySelectorAll('script[src]')].map(s => s.src.split('/').pop())
  // then, to start clean:
  for (const r of await navigator.serviceWorker.getRegistrations()) await r.unregister();
  for (const k of await caches.keys()) await caches.delete(k);
  ```
  A test suite is immune - Playwright gives each test a fresh context - which is exactly why the
  suite disagreed with the browser and the browser was wrong.
- **`git checkout -- <file>` reverts the WHOLE file, not the experiment you just made in it.**
  Backing out a one-line "does the test still catch this" probe threw away every uncommitted
  change in that file: a fix, seven telemetry hooks and a rewritten block. Committing before
  probing is the cheap answer; failing that, patch the line back rather than reaching for the
  file. Nothing warns, and the typecheck stayed green because what was lost was only additive.
- **Give every game its own preview port, and never a Vite default.** Coreward and Captain
  Run both used 4173. With Playwright's `reuseExistingServer` on locally, a Coreward suite
  running while the sibling game's suite was running **adopted Captain Run's server** and
  tested a different game's build - then failed halfway through with
  `ERR_CONNECTION_REFUSED` when that run finished and tore the server down. It presents
  exactly like flake: single tests pass, the full suite fails, and a different set fails each
  time. Several games are built on this machine at once, sometimes literally at the same
  moment, so this is a standing hazard rather than a one-off. Pick a number no default will
  land on (Coreward: 4319 for tests, 4318 for the interactive preview, deliberately
  different so opening the game to look at it cannot disturb a run). Diagnose it with
  `Get-CimInstance Win32_Process -Filter "Name='node.exe'" | Select ProcessId, CommandLine` -
  the command line names the repo, which is what makes the collision obvious in seconds
  rather than after an hour of blaming your own change.
- **"Wait on game state" is not enough on its own if the state is measured in GAME time.**
  Coreward's heat test polled for a soak gauge to fill and passed everywhere except CI, where
  a GPU-less runner falls back to a software rasteriser and the game crawls: thirty seconds of
  wall clock bought 24.46% of the 25% the assertion wanted. Polling correctly on the right
  quantity does not help when the quantity accrues in a clock you are not driving. **Anything
  that accumulates over game time belongs on the headless tick seam**, where `advance(60)`
  is sixty game-seconds on every machine. Rewriting that one test took it from 13.6 s and
  machine-dependent to 2.8 s and deterministic.
- **A poll timeout must be shorter than the test timeout, or it can never report.** Both were
  30 s, so the test died before the poll could finish and the failure read "test timeout
  exceeded" instead of naming the value it was waiting on. Set the suite timeout comfortably
  above the longest poll.
- **A stale `dist/` is a lying test, and it lies in the direction of "your fix did not work".**
  Playwright runs the BUILT game. Fix a bug in `src/`, re-run one test, and it fails exactly as
  before - so the natural next move is to doubt the fix and go looking for a second cause. The
  same edit against the dev server was already correct. Rebuild before every e2e run that follows
  a source change, and when a test disagrees with what the dev server plainly shows, check the
  build before you check the code.
- **Never start the smoke tests while a build is in flight.** A backgrounded `npm run build` was
  still writing `dist/` when Playwright started, and nine tests failed against a half-written
  bundle. It looks exactly like a real regression - a scatter of unrelated failures that all pass
  in isolation - and it is worth recognising in one glance rather than bisecting.
- **Assert on the reading, not on how the view currently draws it.** A UI restyle in Coreward
  broke three e2e assertions at once, and all three had the same shape: they read a bar's
  `style.width` or the label's `innerText`. None of them was wrong about the game - they were
  wrong about the DOM. Read the number the player can see (the printed percentage, the drawn
  fraction of an arc) and the assertion survives the redesign. Bonus trap: `innerText` throws
  "Node is not an HTMLElement" on an SVG `<text>`, which reads like a broken selector rather
  than a changed element type - `textContent` works on both.
- **Wait on game state, never on wall-clock time - and that includes how long you HOLD an
  input.** The obvious version of this rule is about polling. The version that actually cost a
  deploy is about driving: a test that holds a d-pad for 600 ms delivers an unknown amount of
  GAME time, because the loop clamps its delta, and how much depends on how heavy a frame
  currently is. Coreward had one counting drill bursts; it passed for months and went red on a
  commit that only touched lighting, because the extra per-frame cost under SwiftShader meant
  thirty bursts no longer added up to 2.5 seconds of drilling. It failed claiming the drill was
  throwing away progress, which was not true and pointed at code that was fine. Drive input
  through the headless seam in fixed steps; hold a real control only in the tests whose subject
  IS the wiring.
- **Wait on game state, never on wall-clock time.** The frame loop clamps its delta, so on
  a machine without a GPU the game advances in slow motion and any fixed sleep becomes a
  flake. Poll for the state you asserted to be *rendered*, not just set.
- **Anything a test installs on the page must go in after the last reload**, or through
  `addInitScript`. A counter set before a reload is wiped, and incrementing `undefined`
  gives `NaN` — a failure that reads like a claim about the game.
- **Seeding a save through `localStorage` and reloading does not work** if the game saves on
  `visibilitychange`: the unload writes live state back over the seed. Freeze
  `Storage.prototype.setItem` for that key on the outgoing page first. This has cost time
  three times.
- **A safety test aimed at a case that cannot trigger is worse than no test**, because it
  reads as covered. Fixtures should assert their own preconditions, and a guarantee test
  should count the events it is making a guarantee about.
- **Verify a regression test by reintroducing the bug** and watching it fail. It is the only
  way to know it regresses anything.
- **Never re-record a golden baseline without reading the diff.** The whole value is in the
  reading.
- **Hand the harness the clock before the first `advance()`.** Real rAF frames run between
  page load and the moment a test takes over, and how many depends on how fast the machine
  boots the bundle — so every recorded number quietly becomes a function of the test
  runner's speed. Captain Run's golden "broke" when the build got *faster*. The seam is
  `freeze()`: stop the rAF tick and restart the run, so `advance(n)` is exactly n seconds
  from a clean start on any machine.
- **`advance()` must not render every tick.** Measured on Captain Run: 0.28 ms per tick with
  a real GPU, ~17 ms on the software rasteriser a headless browser falls back to. Forty
  simulated seconds is 2,500 ticks — 0.7 s against 42 s, and the first version of that suite
  took 3.3 minutes and timed out five of eight tests. Take a `draw` flag through `tick` and
  render only the last frame of a run; nothing in `renderer.render()` feeds back into game
  state, and drawing the last one keeps the draw-call count and every instance count honest.
- **A test helper that reads the wrong property returns zero and passes vacuously.** A
  Captain Run check summed `layer.count` on a *dict* of layers — `undefined` — so it would
  have reported zero for a healthy game and zero for a broken one. Anything a test reads out
  of the game should fail loudly when it is absent.
- **Drive real input for anything about direction.** A seam that takes world coordinates -
  `steer(1.5)` - cannot see inverted controls, because the inversion happens between the world
  and the screen. Captain Run's steering was inverted for the whole life of the game with a
  passing test suite. Dispatch real pointer events and assert where the avatar lands in
  normalised device coordinates. See CRAFT.md for why a chase camera causes it.
- **Measure the spread before setting the thresholds, not after.** Star ratings and grades
  are cut against a par, and the *gaps* between them have to match the real distance between
  bad and good play. Candle Gift's first thresholds were bunched inside a 1.5x band while the
  measured spread across four scripted play styles was 1.3x, so every one of them scored full
  marks - including the run that never touched the screen. Script the extremes first, read
  the ratio, then place the thresholds inside it.
- **When every play style scores the same, fix the game, not the thresholds.** That flat
  spread was the real finding: it meant the systems were applying themselves. Re-tuning par
  would have hidden it.
- **Set balance constants from a measurement through the debug seam, not from a guess.** Wick's
  grade thresholds were first set by eye, and a run that never touched the screen graded FINE
  while every competent run hit the ceiling. Three scripted runs - do nothing, dodge, dodge and
  collect - took ten minutes to write and gave three real numbers to cut the grades against.
  Keep the script long enough to use it again; delete it once the number is recorded, and put
  the measurement in the comment beside the constant.
- **Assert the state that distinguishes outcomes, not the panel that shows both.** The
  full-ascent test checked that the camp screen opened and matched `/CAMP/`, which is true
  of both `MOUNTAIN CAMP` (won) and `CARRIED HOME` (died). It passed for the whole of a
  balance cliff where the run died every time.

---

## Inverted-hull outlines do not work on a Godot MultiMesh. Use a fresnel rim.

The standard toon outline - the same mesh grown along its normals, drawn front-face-culled,
so only the sliver outside the silhouette survives - works on a `MeshInstance3D` and does not
work on a `MultiMeshInstance3D` in Godot 4.7. The hull draws OVER the object, so every
instanced thing in the game comes out as a solid black silhouette.

It was tried as a `next_pass`, as a second `MultiMeshInstance3D` sharing the same MultiMesh
resource, with `CULL_FRONT`, with `CULL_DISABLED`, with depth writing off, at both render
priorities, and **with the hull shrunk six centimetres INSIDE the object**. That last one is
the measurement that settles it: geometry entirely inside a solid object still drew over it,
so this is not a grow-direction problem or a draw-order problem, and no amount of tuning the
hull will fix it.

**A fresnel rim in the material does the same job for one dot product**, works on a MultiMesh,
and needs no second buffer to keep in step:

```glsl
float face = abs(dot(normalize(NORMAL), normalize(VIEW)));
float e = smoothstep(ink_width, ink_width * 0.35, face);
ALBEDO = mix(base, ink, e);
```

It is not identical - it cannot hold an even line width, and it darkens a flat face seen
edge-on, so anything thin and grazing (road stripes, decals) wants `ink_width = 0`. Write the
threshold so that **zero means no line**: expressed the other way round, as a smoothstep whose
two edges meet at zero width, it returns 1 everywhere and ink the entire surface.

Why it matters at all: a pale object on a pale ground has no edge without one. A cream candle
lying on a white runway rendered as a faint grey smear indistinguishable from a shadow, and
the batch - the thing the whole game is about - was the least legible object on screen.

## Test the PICTURE with pixels, test the PLACEMENT with the model

Both kinds of check are worth having and they are not interchangeable. Getting this backwards
cost three discarded metrics on one afternoon.

A wax pool rendering striped, and a station sign hung at the camera's eye height, were both
attacked first as frame statistics. Measured on a good build against a deliberately broken one:

| Metric | Good | Broken | Verdict |
|---|---|---|---|
| colour changes across a row | 45 | 49 | useless |
| saturated runs across five rows | 7 | 8 | useless |
| fraction of the upper frame still sky | 0.869 | 0.826 | too weak to threshold |
| **fraction of the lower frame near-black** | **0.028** | **0.196** | **kept** |

Both of the stubborn ones are GEOMETRY, and geometry is a number in the model: the pool's y
against the tops of the lane-stripe boxes, the distance from the lens to the nearest visible
gantry. In the model they are exact, they need no GPU, and the failure message names the number
and the object. In pixels they are a shade that also depends on marbling, on the time of the
frame, and on what happened to be on the ground where the band was sampled.

**What frame statistics are for is the whole picture going wrong at once** - everything one
colour, everything black, nothing drawn - which the model cannot see at all. That is a real
category: a build where every instanced object rendered as a solid black silhouette passed
every model assertion it had.

### Two rules for a pixel check that is worth running

**Measure first, then set the threshold, then break the build on purpose and watch it fail.**
A guard that does not move when the bug is present is worse than no guard - it is a green light
nobody has any reason to doubt. Give the runner a `--report` mode that prints the metrics and
asserts nothing, so the numbers can be re-derived rather than guessed at.

**Sample densely and judge the worst frame; a handful of chosen moments is not a sweep.** The
first version of this check sampled five seconds of a level and missed the exact bug it had
been written for, because a sign only fills the frame for about a second after you pass under
it. A frame costs milliseconds. Sample every second or two across the whole level. Transient is
precisely what a chosen-moment check cannot see, and in a runner transient is most of what is
wrong.

### State a guard in terms of what it is really about

The gantry check was first written as "no gantry is drawn behind the player", and it failed on
a deliberate one-metre grace that stops the gantry popping out as you cross it. That gantry is
still eleven metres from the camera and completely harmless. The rule is about distance from
the LENS, and once written that way it passes on every correct build and fails on the bug.

A guard phrased as the nearest convenient proxy will fail on correct changes, and a guard that
fails on correct changes gets deleted.

### Keep the pixel check local when CI has no GPU

Thresholds derived on one renderer do not transfer to another, and maintaining two sets of
numbers for one check is how a check stops meaning anything. Put it in a `check.sh` alongside
the headless suites and run that before committing, rather than pretending CI covers it.

## Screenshot a whole level as a contact sheet, not a second at a time

A single screenshot answers "does this moment look right" and costs an entire engine start, so
judging a level through one means guessing in advance which second to look at. Most of what is
wrong with a runner is only visible as a SEQUENCE: a prop that pops in, a sign that sweeps
through the middle of the frame, a pool that ends before the batch is out of it. None of that
can be seen in a frame chosen before you knew what was wrong.

One script that freezes, advances in fixed steps, and captures twelve frames across a level -
stitched into a grid - found four separate bugs in its first run that three individually
chosen screenshots had missed. Same seam as the tests (freeze, then advance), so cell *n* is
the same moment every time and two sheets a week apart are comparable.

## Testing a Godot UI from a headless harness: three things that fail silently

Driving real controls from a test is worth the trouble - it is the difference between asserting
a button WORKS and asserting a button EXISTS - but three separate things stop it working and
none of them reports an error.

**`Viewport.push_input(event)` does nothing for the GUI unless you pass `in_local_coords = true`.**
Without it the position is transformed by the viewport's canvas transform and the click lands
nowhere. Measured on a bare `Button` under the root: zero presses without the flag, one with.
This is the dangerous one, because **a click that hits nothing is not an error** - the test goes
green having proved nothing, and it looks like a passing UI test forever.

**Control layout is only resolved during a frame.** A `SceneTree` harness that does all its work
in `_initialize()` never runs one, so every `Control` keeps a zero-size rect at the origin and
every click misses. Let three frames pass first, and **assert the rects are non-zero before
anything that depends on them** - that assertion is what tells you which of these two problems
you have.

**A new `class_name` is invisible until the project is re-imported**, and the failure mode is a
*hang with no output* rather than a parse error you can read. `godot --headless --import` after
adding one; CI usually does it already as its first step, so this only bites on the desk.

### One writer for a UI phase

A phase enum with `_show_screens()` called next to each assignment worked in four places out of
five. The fifth was the test seam - it set the phase directly and left the previous screen drawn
over the entire game. Make a `_set_phase()` that assigns AND recomputes every screen's
visibility from the phase, and make it the only writer. Then a screen cannot be left up by a
transition nobody thought about, and the recompute-from-state shape means adding a screen does
not mean auditing every existing transition.

### Restarting a level owes it the save

Sim-level `restart()` naturally zeroes per-run state - cash, position, the batch. Progress lives
somewhere else. Anything that restarts a level for a gameplay reason (buying a pre-run boost, a
retry button) has to push the save back in afterwards, or it silently deletes progress as a side
effect of something that looks unrelated. The bug reads as "the shop does not work".

## Four Godot traps that fail silently, and one that reads as a hang

All five cost time on the first game written straight into the template rather than grown
from it. None of them fails the build.

**`MultiMesh.use_colors` must be set BEFORE `instance_count`.** Godot refuses to toggle it
once the buffer exists - "Instance count must be 0 to toggle whether colors are used" - and
the result is a runtime error that leaves every instance untinted while the game runs on. Set
it in the helper that builds the MultiMesh, before anything else touches it.

**`Basis.scaled()` scales the WORLD axes, not the mesh's own.** A cylinder rotated ninety
degrees about Z has its axis along world X, so it must be scaled `(length, radius, radius)` -
writing `(radius, length, radius)` because that is how the mesh was authored draws a heap of
overlapping boxes. **It looks like a layout bug and it is a transform one**, which is what
makes it expensive: the search starts in the wrong file.

**`TorusMesh` has no arc parameter.** There is no way to make a quarter-circle from one, so a
"curved lamp-post arm" built out of it is a complete ring lying flat across the track. Build a
curve from a post and a leaning boom, or from three boxes.

**Cull scenery against the CAMERA, not the player.** A chase camera sits ten to fifteen metres
behind, so anything culled at the player's own position is still several metres in FRONT of
the lens - and a signpost a metre from the camera fills the bottom of the screen. Keep the
camera's z in a field and cull against that.

**Walking a path once per follower is quadratic, and it reads as a hang.** A trailing formation
where each member samples back along a recorded path costs (members x samples) a frame: thirty
followers walking ninety samples is 2,700 steps, invisible in a game playing one level and
ruinous in a suite playing twenty. A pure test suite went from about two seconds to over five
minutes, which looks like an infinite loop rather than like slow code. The distances are
monotonic, so **one backward walk can emit every follower as it crosses each threshold.**

## Normalise line endings on day one, and commit a `.gitattributes`

A file with CRLF in some blocks and LF in others defeats every exact-match edit, and the
failure is silent in the worst way: the search string is visibly identical to the file when
printed, so the natural conclusion is that the anchor text is wrong and the next twenty minutes
go into rewriting a correct anchor. `cat -A` shows `$` for both, and only `repr()` of the raw
bytes shows `
`.

It happens without anyone choosing it: editors, tooling and generated files disagree, so a file
ends up mixed within itself. Run one pass over the repo converting to LF and commit
`* text=auto eol=lf` **before** the first session that does bulk edits, not after the third one
that loses time to it.

## Driving the browser

Claude can drive a browser to check things visually. Two traps:

- **The preview pane stops `requestAnimationFrame` entirely when it is hidden**, so the game
  clock nearly stops and a timed mechanic cannot be observed. Screenshots force a paint, so
  a burst of them will advance frames — but for anything on a timer, extract the clock into
  a pure reducer and test it in milliseconds instead.
- **Playwright composites properly.** When something needs real frames, that is the tool.

### A null A/B is worthless until you have proved the screen can change

Toggling one uniform, screenshotting twice and getting two identical images feels like a
result. It is not one — not until a **positive control** has shown that the path from the
change to the pixels actually works. Set something to a value that cannot possibly look the
same (a global gain to 0.02, so the frame goes near black), screenshot, and confirm it
changed. Only then does "no difference" mean "this is not the cause".

Cost of skipping it: two rounds of chasing a rendering artefact were spent on A/Bs that came
back identical, which was read as "not the cause" for one of them and as "the render is not
reaching the screen" for the other. Both readings were guesses. The control took one call and
settled it — the path was fine, so the null results were real, which immediately ruled out a
whole family of hypotheses instead of leaving them open.

The same rule covers the manual-render trap underneath it: if the page's own `rAF` is
stopped, whatever you call yourself is the frame; if it is running, it will overwrite you on
the next tick and your change may never be visible. The control tells you which world you are
in without having to reason about it.

### Attribute a rendering artefact to a LAYER before trying to fix it

Five playtest rounds went into "there is a circle of light around the ship", and four
different causes were found and correctly fixed before the fifth one was the real one. Every
one of those rounds started by reasoning about which term in the shader could produce the
shape, and every one of them cost an afternoon.

The move that actually settled it took one call: hide the additive fog quad and re-render.
The artefact vanished and the terrain kept its lighting, which said the fault was in the air
volume and not in the shadows, the flood, the filtering or the terrain shader — ruling out
four modules at once. Only then was it worth asking which term.

So: when something looks wrong on screen, the first question is **which draw call is putting
those pixels there**, not which line of maths is wrong. Toggle `.visible` on each candidate
layer in turn. It is one call per layer and it partitions the search space; reasoning about
the shader does not partition anything.

---

## A CI check that cannot tell you the answer must say so, not say nothing

"Push, say it is pushed, move on" only works if something actually confirms the run went
green. A background poll loop did the confirming here, and it failed in the worst possible
way: it burned the unauthenticated GitHub API's 60 requests an hour with a 15-second poll,
started getting rate-limit JSON instead of run status, and its final report printed **nothing
at all** and exited zero. Silence read as "still running", so a red build sat undeployed until
the user asked why his phone had not updated.

Three rules out of it:

- **Poll a remote API at 30 seconds or slower**, and remember that a loop left running from an
  earlier task is still spending the same budget. Sixty an hour is four polls a minute for one
  minute.
- **A verification step that cannot determine the answer must fail loudly.** `curl | python
  2>/dev/null` returning an empty string is indistinguishable from "not finished" and from
  "finished, green". Print the conclusion or print why you could not get it; never nothing.
- **`gh` is not installed on this PC.** A poll loop built on it never errors — the shell
  reports "command not found" on stderr, the loop swallows it, and every iteration looks like
  "not finished yet". Use `curl -s
  https://api.github.com/repos/<owner>/<repo>/actions/runs?per_page=3` and read
  `workflow_runs[].head_sha / status / conclusion`; unauthenticated is fine for a public repo.
  This is the rule above biting a second time, in a form that looks nothing like the first.
- **Do not report a push as done while the check is still in flight** unless the message says
  plainly that it is, and then actually come back to it. The user should never be the one who
  notices.

## Do not juggle source files through the shell for a two-line experiment

Swapping one line to check whether a test discriminates cost a whole source file: a `cp` from a
backup path that did not exist truncated it to zero bytes, and the change in it had not been
committed. The same session had already lost work to `git checkout -- <file>` on a file with
uncommitted edits.

Both were the same instinct - reach for the shell to make a quick reversible change - and
neither was reversible. **Use the editing tools for source.** If an experiment genuinely needs a
line swapped and swapped back, swap it with an edit, run, and swap it back with another edit:
those are checked, they report what they changed, and they cannot empty a file. Commit before
any experiment that touches a file you would mind losing.

## Never rewrite a source file through PowerShell

`Get-Content -Raw` + `Set-Content -Encoding utf8` looks like a round trip and is not.
PowerShell 5.1 reads a file with **no BOM as ANSI**, so every non-ASCII byte is
reinterpreted, then written back as UTF-8. A middle dot becomes `Â·`.

This bit twice in one day, in two repos, and both times it looked correct in the diff:
once turning `/\s+·/` into a regex that could never match, once corrupting a build stamp.
Neither produced an error — the test just failed on a string that also looked right.

- Use the **Edit/Write tools**, which understand encodings, for anything textual.
- If a script genuinely must rewrite a file, read and write through
  `[System.IO.File]::ReadAllText/WriteAllText` with an explicit
  `New-Object System.Text.UTF8Encoding($false)`.
- Better still, **keep files that a script rewrites ASCII-only**, so a re-encoding has
  nothing to damage.

---

## The Godot stack (native Android)

**This is where new games start.** Proven end to end on 2026-09-08, and a first real game -
Wrecking Crew - has been through it since. `C:\dev\godot-template` is the copy-from repo;
its `CLAUDE.md` has the toolchain paths, the copy-and-rename steps and the full invariant
list, and **it should be read before writing any game code**.

Starting a new one, in full:

```powershell
Copy-Item -Recurse C:\dev\godot-template C:\dev\<game>
Remove-Item -Recurse -Force C:\dev\<game>\.git, C:\dev\<game>\.godot, `
    C:\dev\<game>ndroid, C:\dev\<game>uild
```

Then `git init`; rename in `project.godot`, `export_presets.cfg` (unique name, package name
and BOTH export paths), `README.md`, `CLAUDE.md` and `scripts/check_size.gd`; reset
`changelog.gd` to 0.1.0; ask Gideon for an empty public repo and push. **Set
`ANDROID_DEBUG_KEYSTORE_B64` as a repository secret** from `C:\dev	oolchain\debug.keystore`
straight away, or every CI build is signed by a different throwaway key and Android refuses to
update the installed app.

What the template already carries, so it does not have to be rebuilt: a pure simulation core,
a hand-written test harness with a float tolerance, scripted policies and a balance probe, a
whole-run golden, a smoke test that boots the real scene, a deterministic screenshot tool, an
APK size guard that fails in both directions, CI, a build stamp and a changelog. A fresh copy
passes its own gate before a line of game code is written - check that first, because a
failing copy means something in the template drifted.

| Piece | Choice |
|---|---|
| Engine | **Godot 4.7.2**, pinned exactly — CI uses `barichello/godot-ci:4.7.2` |
| Language | **GDScript, statically typed** (`func f(x: int) -> float:`) |
| Tests | `godot --headless --script res://test/run_tests.gd`, exits non-zero |
| Smoke | a second SceneTree script that instantiates the real scene and plays it |
| Size guard | GDScript, checks the APK against a recorded budget, both directions |
| Deploy | CI → a signed APK attached to a GitHub Release |

**Everything is portable and nothing needed admin.** The JDK install via `winget` hangs
forever on a UAC prompt that cannot be shown; the Temurin **zip** from the Adoptium API
unpacks to a user directory and works immediately. Same for the Android command-line
tools and platform-tools.

### Things the exporter will not tell you clearly

- **Godot finds the SDK, JDK and keystore through editor settings, not environment
  variables.** `%APPDATA%\Godot\editor_settings-4.7.tres`, keys under `export/android/`.
  Setting `ANDROID_HOME` alone does nothing, and the error message talks about Editor
  Settings without saying which file.
- **`rendering/textures/vram_compression/import_etc2_astc=true` is required** for an
  Android export, and **a `config/icon` is required** — both fail the export.
- **`gradle_build/use_gradle_build=false`** uses the prebuilt template and needs no Gradle
  at all. Turn it on only when a plugin or a custom target SDK demands it.
- `sdkmanager` is deprecated in favour of an `android` CLI, and the old
  `platforms;android-36` syntax fails through `sdkmanager.bat` (the batch file splits on
  the semicolon) while working fine through `android.exe`.

### Headless lifecycle, which is where the time actually goes

- **`root.add_child(node)` inside `SceneTree._initialize()` does not run `_ready`** and
  does not put the node in the tree until the first processed frame. The symptom is
  hundreds of identical `Nonexistent function ... in base 'Nil'` errors and a run that
  never terminates. Guard it with an idempotent `_ensure_booted()` called from `_ready`
  *and* from every harness entry point — not with a rule about call order, which is
  something every future test has to remember.
- **`Node3D.look_at` errors when the node is not inside the tree**, which is that same
  case. `Transform3D.looking_at` is pure maths and works anywhere. Prefer it always.
- **`MultiMesh.visible_instance_count` is the flush** and is the number to assert a render
  path against, exactly as `mesh.count` is in three.js.

### Godot facts that cost time on the first real game

- **A headless run allocates no MultiMesh buffer at all.** `use_colors` reads back `true`,
  `set_instance_color` raises no error, and `get_instance_color` returns black - because
  `multimesh.buffer` is empty under the dummy rendering server. So instance colour cannot
  be checked headlessly, and a headless probe of it is worse than none: it reports a
  confident wrong answer. `visible_instance_count` is a CPU-side property and *is* reliable
  headlessly, which is why the smoke test is built on that and not on colour. Check colour
  in a real renderer or not at all.
- **`Node3D.global_transform` outside the tree does not error - it returns IDENTITY.**
  `look_at` at least refuses; this hands back a plausible wrong answer, so a camera assertion
  fails for a reason that has nothing to do with what it tests. In any harness, use
  `transform` and keep the node a direct child of a root that never moves.
- **A value read out of a Dictionary is a Variant, and `:=` cannot infer from one.**
  `var b := Basis.from_euler(c.ang)` is a parse error, and the message names the variable
  rather than the dictionary lookup that caused it. Annotate the local explicitly:
  `var ang: Vector3 = c.ang`. Entities held as dictionaries - which is what keeps the scene
  tree out of the test runner - make this common. **Grep for it rather than waiting to hit
  it**, because the failure mode is a hang rather than an error: `grep -rn 'var [a-z_]* :=
  .*\["' src/ test/` finds every one in a second, and on Stillwater it found all three
  after they had already cost a five-minute timeout each.
- **A parse error in a script the harness loads produces a run that never terminates**, not
  a failure: `_initialize` aborts before it reaches `quit()`. The symptom is a hung command,
  and the cause is several screens up the output. Read the top of the log, not the end.
  **Two practical consequences for how to run it at all.** Redirect to a file with `*>` and
  read the file - a PowerShell pipeline that assigns to a variable buffers the whole run, so
  a hung command shows you nothing at all rather than showing you the parse error at the top.
  And when a command does hang, the first move is to check the log's first twenty lines, not
  to raise the timeout.
- **Tell a parse error from slow code by CPU share, before theorising about cost.** The trap
  is that a parse error in a big file does not fail fast - Stillwater's test suite went from
  one second to sixteen minutes because a golden-recording splice left a stray `]` at the end
  of a 190-line data const, and the process sat there *running*. It looks exactly like a test
  that got expensive, which is the wrong thing to go and fix: two rounds of "which test did I
  make slow?" cost twenty-five minutes, and the answer was that no test was slow at all.

  One command separates them:

  ```powershell
  $p = Get-Process -Name "Godot*" | Select-Object -First 1
  "CPU={0:N1}s elapsed={1:N1}min" -f $p.CPU, ((Get-Date) - $p.StartTime).TotalMinutes
  ```

  **Real work pins one core - CPU seconds track elapsed seconds. A parse that has gone
  quadratic does not: 147 CPU-seconds against 16 elapsed minutes is about 15%, and that ratio
  is the tell.** Anything well under 100% means the file is broken, not the code slow.
- **NEVER put backslash escapes in a Python heredoc through the Bash tool.** `
` and `	`
  arrive collapsed, so a generated GDScript string literal becomes a real newline and the
  file is silently mangled - and a `replace()` without an `assert` next to it fails quietly
  and looks like it worked. This has now cost time three times. Write the script to a file
  with the Write tool and run it; put an `assert pattern in text` beside every replace.
- **A hand-edit that has broken twice is a tool that has not been written yet.** The golden
  re-record was a manual copy-paste and it left a stray `]` on two separate occasions. The
  recorder now rewrites the file itself and refuses to save one whose top-level bracket
  count is wrong. Two other things surfaced while writing it, both general: Godot eats a
  leading `--` even after the `--` separator, so a user flag has to be a bare word; and
  search a source file LINE BASED, not for `"
]
"`, or the first Windows tool to touch it
  breaks the match and the error message sends you looking at brackets instead of newlines.
- **Splice a re-recorded golden by finding the const's real end, not by appending a bracket.**
  The stray `]` above came from replacing `s[a:b]` with a block that had its own `]` added
  back on. After any script rewrites a source file, `grep -n '^\]' file.gd` costs nothing and
  catches exactly this - and the count of top-level closers should be one per const.
- **Start audio playback from `_ready`, never `_enter_tree` or straight after `add_child`.**
  A node added during `SceneTree._initialize` reports `is_inside_tree()` as true immediately,
  so guarding on that flag looks correct and still produces one "Playback can only happen
  when a node is inside the scene tree" error per player per run. The flag is set before the
  tree is actually running; `_ready` is deferred to the first PROCESSED frame, which is what
  playback really requires. It also hands the headless tests what they want for free - they
  process no frames, so nothing plays, while the mixer is still fully built and its levels
  still assertable.
- **Free the scene the smoke test built, before quitting.** Otherwise the run ends with
  "N resources still in use at exit" - anything a node still caches. Harmless in itself and
  worth removing anyway: a gate that always prints an error is a gate whose errors nobody
  reads.
- **Drive the picture with a screenshot script, which is the Godot equivalent of driving a
  browser.** A `SceneTree` script that instantiates the real scene, calls `freeze()`, advances
  through the same seam the tests use, waits about five frames and saves
  `root.get_texture().get_image()`. It must NOT be headless - that is the whole point - and
  waiting the frames matters, since capturing on frame one gives a grey rectangle. Because it
  goes through `freeze` and `advance`, the same second of the same street is captured every
  time, which makes two screenshots taken a week apart genuinely comparable.
- **Give that script a STATE to advance until, not just a number of seconds.** A capture at
  "24.5 seconds" is a capture of whatever happened to be true then, and the moments worth
  looking at are the short ones - a hook window, an impact, a transition. Stillwater shipped a
  build in which neither HUD gauge was ever visible, and the single screenshot taken of them
  looked right because it froze mid-fight, the one state in which that particular bug cannot
  appear. `-- 90 hooking` advances until the state matches and complains if it never does.
- **A screenshot proves a state, never the absence of a bug in the states it did not reach.**
  Three HUD faults shipped together behind one good-looking picture.

### `stretch/aspect = "expand"` means the base resolution is a LIE about height

Godot's `canvas_items` stretch with `aspect = "expand"` keeps the base **width** and extends
the **height** to the device's aspect. A project based on 1080x1920 renders into roughly
1080x2340 on a 19.5:9 phone. So **any HUD element positioned against the literal number 1920
lands hundreds of pixels above where it belongs**, and the player's report is "the buttons are
about half an inch too high".

It shipped with a second bug of identical origin: a hand-rolled hit test that scaled touches
into a 1080x1920 space of its own, so the drawn control and the region that responded were in
two different coordinate systems and disagreed with each other as well as with the screen.

The fix is structural, not arithmetic:

- One `Control` with `PRESET_FULL_RECT` inside the `CanvasLayer`, and **everything anchors to
  that**. `PRESET_CENTER_BOTTOM` plus a negative `offset_bottom` puts a thumb control a fixed
  distance from the real bottom edge at any aspect.
- **Every interactive control handles its own input** via `_gui_input` and calls
  `accept_event()`. Position and hit box are then the same object and cannot drift apart.
  A manual `_unhandled_input` hit test is a second source of truth for where a button is.

**No headless test can catch this**, which is the part worth remembering: a headless run uses
the base viewport size, where the wrong layout and the right one are identical. Screenshots
have to be taken at the PHONE's aspect (`--resolution 460x996` for this one, not 540x960), and
the thing CI can assert is the *property* rather than the position - that the control resolves
from the viewport edge, and that `mouse_filter` is `STOP` so a drag on it is not also a swipe
somewhere else.

### Do not build a gameplay pendulum out of the physics server

The obvious way to hang a wrecking ball in Godot is a `RigidBody3D` on a `PinJoint3D`. That
puts the outcome of every run inside the physics server, at the mercy of its tick rate and
its solver, and ends any possibility of a whole-run golden. Thirty lines of arithmetic -
`L*theta'' = -g*sin(theta) - a_pivot*cos(theta) - c*L*theta'` - is deterministic, runs
headlessly, and is testable at 120 fps against 60. **Physics is for debris, which decides
nothing.** The same reasoning applies to any engine feature that would own a number the game
is scored on.

### `DEPTH_TEXTURE` is corrupt on Forward Mobile with MSAA, and the fix is better than the bug

Found while designing the water for a fishing game, before writing any of it. **Sampling the
depth texture on Forward Mobile with MSAA enabled returns corrupted data** — the MSAA resolve
is missing before the texture is bound. That matters because the standard recipe for water,
shore foam, soft particles and any depth-based fade is exactly this sample, and it is what
every tutorial reaches for.

The workaround is to turn MSAA off. **Do not take it.** The better answer is to notice that in
these games the renderer is being asked a question the simulation already knows the answer to:
the lake bed is a heightfield the sim authors and owns, because it decides where the fish are
and whether you snag. Upload that same field as a small texture, sample it in the shader by
**world position**, and the depth is exact, cheap, and *identical to the number the rules use*.

Three things fall out, and they are the reason this is a rule and not a workaround:

- **The picture cannot disagree with the game.** Foam is drawn where the sim says the bed is.
  Same guarantee as showing the real ship in the shop instead of a copy of it.
- **It is testable headlessly.** A depth-buffer read is invisible to a headless run; a
  heightfield lookup is arithmetic and goes straight into the golden.
- **MSAA stays on**, so thin geometry — line, reeds, rigging — stops shimmering.

Generalised: **when a shader wants to know something about the world, check whether the
simulation already owns it before asking the renderer.** Sampling the frame buffer to recover
a fact the game computed three milliseconds earlier is a second source of truth, and it is the
one that breaks on a specific renderer with no error message.

### Measured on the phone

First native build on the S26 Ultra, 2026-09-08: **Vulkan 1.4.295, Forward Mobile, Adreno
840**. `adb shell dumpsys gfxinfo <pkg>` over the first 44 frames gave **5 ms at the 50th,
90th and 95th percentiles**, one janky frame, 1 ms GPU at the median. That is a placeholder
scene, so it measures the engine and the pipeline rather than a game — but it is the
baseline every later number gets compared against, and it says the ceiling is nowhere near.

`adb shell dumpsys gfxinfo <package>` is the measurement. `adb shell screencap -p /sdcard/x.png`
then `adb pull` is how to see what is actually on screen; piping `exec-out screencap` through
PowerShell corrupts the bytes.

### CI, and one rule about it

`barichello/godot-ci:<version>` works for both the test job and the export job. Two things
were needed beyond the obvious:

- **The image may not have an Android SDK.** Have the workflow *look* for one, install it
  if missing, and print what it found. Hard-coding `/usr/lib/android-sdk` and reaching for
  `python3` (which is not in the image) produced `Process completed with exit code 127` and
  nothing else — the least informative failure available.
- **A CI step that can fail should say what it was looking for when it did.** Every path
  check in that job now fails with the directory it wanted. That turned the second attempt
  into a single fix rather than a guessing loop.

**A throwaway debug key per CI run means every build is signed differently**, and Android
refuses to update an installed app whose signature changed. Put the keystore in a base64
repository secret once the APK stops being a one-off proof.
