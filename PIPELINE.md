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

They are still a legitimate *option*, and that distinction matters: Captain Run was built in
one session on the plain static stack and it was the right call for a game of that size.
Pick by the game, not by a limitation:

- **Plain static, no build** — one-session games, a single mechanic, no tests worth writing.
  Fastest path from idea to phone.
- **The full stack below** — anything that will be returned to. The moment a game has a
  second session, the golden tests and the size guard start paying for themselves.

If a rule anywhere else reads like a precaution against not being able to run something, it
is from that era. Delete it.

---

## The stack

Verified working on Coreward, and the default for a new game unless there is a reason:

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

**Push straight to `main`.** CI is the gate. A build that fails any step cannot deploy, so
the previous version stays up.

Then check it on the phone. Expect the first open to show the old build; close it fully and
reopen. The stamp in the menu is the source of truth.

**Do not poll the live site to confirm a deploy.** CI already smoke-tested that exact
artifact. Polling re-verifies what is verified and is the most expensive part of the cycle.
Push, say it is pushed, move on.

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
| Draw calls, worst case | **50** | ~100 is the 2026 mobile guideline | Comfortable |
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
3. **Draw calls**, which instancing solves almost entirely. Coreward went 207 → 35 by
   instancing terrain, and sits at 50 with far more content.

### Budgets that exist, and what they are for

Both are **drift detectors, not ceilings**. Their value is failing when something changes
unexpectedly, not in the specific number.

- **`bundle-budget.json`** — per-chunk size with tolerances, checked in CI, and it fails in
  *both* directions. A shrink means code went missing. Re-record deliberately
  (`npm run size:update`) as part of any commit that adds a system.
- **A draw-call budget** in the smoke test. Seed it to the game's genuine worst case, not to
  whatever a short scripted run reaches — measuring the easy case is how a budget quietly
  stops being one.

---

## Testing, and what each layer is for

Three layers, each catching something the others cannot:

**Golden tests** (`node --test`, pure functions only). World generation, costs, derived
stats, pathfinding, curves. They run in a second and they catch balance and content changes.
They **cannot** catch a wiring bug: a module split once dropped
`requestAnimationFrame(frame)` and every golden test passed.

**Smoke tests** (Playwright, against the production build). The load-bearing assertion is
"the frame loop advances". Then: a WebGL context exists, digging and selling work, every
panel opens, the audio graph builds on a real gesture, draw calls are in budget, the stamp
is populated.

**Design tests.** The most valuable and least obvious layer: assertions about *intent*
rather than values. "A hazard breaks faster than the rock around it." "A deeper ore is
rarer than the one above it." "The Cooling Rig's mineral lives below the heat line." These
catch design mistakes before a human sees them, and several have.

### Rules that were learned the hard way

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

---

## Driving the browser

Claude can drive a browser to check things visually. Two traps:

- **The preview pane stops `requestAnimationFrame` entirely when it is hidden**, so the game
  clock nearly stops and a timed mechanic cannot be observed. Screenshots force a paint, so
  a burst of them will advance frames — but for anything on a timer, extract the clock into
  a pure reducer and test it in milliseconds instead.
- **Playwright composites properly.** When something needs real frames, that is the tool.
