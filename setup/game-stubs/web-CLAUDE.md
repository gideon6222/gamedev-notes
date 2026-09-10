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
npm run typecheck ; npm test ; npm run build ; npm run e2e     # the CI gate, locally
npm run preview -- --port {{PREVIEWPORT}} --host 0.0.0.0        # on the phone over wifi
node scripts/filmstrip.mjs <scenario> [frames] [secondsPerFrame]
```

Read `C:\dev\gamedev-notes\WEB.md` before touching the build, the service worker or the tests.

## Files

| File | What it is |
|---|---|
| `src/sim/*.ts` | The whole game, with no renderer in it |
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

Tests {{TESTPORT}}, preview {{PREVIEWPORT}}. Never a Vite default; never another game's. Live at
https://gideon6222.github.io/{{SLUG}}/ once Pages is enabled (the scaffold does it).
