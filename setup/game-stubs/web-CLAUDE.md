# {{NAME}}

A web phone game (Vite, TypeScript, three.js, GitHub Pages) scaffolded from the newest web
game on {{DATE}}. Repo `github.com/gideon6222/{{SLUG}}`.

@../gamedev-notes/INDEX.md

The shared rules and the process are in
`C:\dev\gamedev-notes` (loaded above). This file carries only what is specific to this
game. **Read `PLAN.md` for what to build and `NOTES.md` for what was decided and measured.**

## This game

{{DESCRIPTION}}

The design in the order it has to be understood: (fill from PLAN.md at scaffold time)

1.
2.
3.

## Commands

```powershell
npm run check                                                   # the CI gate, locally
npm run typecheck ; npm test ; npm run build ; npm run size ; npm run e2e   # or step by step
npm run size:update                                             # re-record the budget ON PURPOSE, then commit it
npm run preview -- --port {{PREVIEWPORT}} --host 0.0.0.0        # on the phone over wifi
node scripts/filmstrip.mjs <scenario> [frames] [secondsPerFrame]   # films on port {{FILMPORT}}
```

Read `C:\dev\gamedev-notes\WEB.md` before touching the build, the service worker or the tests.

## Files

| File | What it is |
|---|---|
| `src/sim/*.ts` | The whole game, with no renderer in it. Only `import type` from three |
| `src/main.ts`, `src/view/*` | The shell: reads the sim, draws it with three.js, feeds it input |
| `test/*.test.mjs`, `test/harness.mjs` | Golden tests over pure functions |
| `e2e/*.spec.ts` | Playwright smoke against the production build |
| `scripts/check-bundle-size.mjs`, `bundle-budget.json` | Size guard, both directions |
| `scripts/filmstrip.mjs` | Filmed runs on the tick seam |
| `PLAN.md`, `NOTES.md` | The plan and milestones; decisions and measurements |

## Invariants specific to this game

(Add one line per rule the plan established. Shared invariants live in GODOT.md; do not
copy them here.)

-

## Ports and identifiers

Tests {{TESTPORT}}, preview {{PREVIEWPORT}}, film {{FILMPORT}}. Never a Vite default; never another game's.
They live in `playwright.config.ts`, `.claude/launch.json` and `scripts/filmstrip.mjs`
respectively; `new-game.ps1` set all three by role. Live at
https://gideon6222.github.io/{{SLUG}}/ once Pages is enabled (the scaffold does it).

## The scaffold left a stub, not a game

`src/`, `e2e/`, `test/` and `public/` came from `gamedev-notes/setup/web-stub`, not from the
game this repo's tooling was copied from. `bundle-budget.json` was measured from this repo's
own first build. **`public/icon.svg` is a placeholder icon and `public/manifest.webmanifest`
names this game**; the icon is what a player taps before they have played anything, so replace
it early. `public/sw-legacy-cleanup.js` is named by workbox's `importScripts` in
`vite.config.js` and a worker whose importScripts 404s does not install - do not delete it.

Replace the stub as soon as PLAN.md says what to build, and keep three seams: `src/sim` stays
pure, `window.__game.advance(dt)` stays the way tests and films move game
time, and the ids `e2e/smoke.spec.ts` reads keep existing. Re-record the budget with
`npm run size:update` on the first commit that is a real game; the stub's index chunk is
about 2 KB and a 12% tolerance on that is a few hundred bytes.
