# web-stub

The game that a freshly scaffolded web repo starts with: a three.js scene, a frame loop, a
tick seam and one golden test. `scripts/new-game.ps1 -Stack web` copies the tooling from the
newest web game, DELETES that game's `src/`, `e2e/` and `test/`, and copies this over the
hole.

It exists because the scaffold used to say "keep the tooling, replace src with a stub the
smoke test can boot" in a comment and then not do it, so every new web game was committed
with the source game's entire codebase, its frozen golden baselines and its bundle budget.

What is in here is the smallest thing that satisfies the gate the tooling enforces:

| File | Why it has to exist |
|---|---|
| `index.html` | The error overlay must be the first script in the document; `#err`, `#boot` and `#game` are what the smoke test looks at |
| `src/sim/config.ts`, `src/sim/state.ts` | The pure layer. No DOM, no three.js, so node can run golden tests over it |
| `src/view/scene.ts` | The only file allowed to import three.js |
| `src/main.ts` | Boot, the frame loop, and the `window.__game` seam the smoke test and filmstrip drive |
| `src/env.d.ts` | `__BUILD_SHA__` / `__BUILD_TIME__`, which `vite.config.js` defines |
| `test/harness.mjs`, `test/pure-entry.ts` | Bundles the pure layer with esbuild so `.test.mjs` can import it |
| `test/state.test.mjs` | One golden test, so `npm test` is not green because it ran nothing |
| `e2e/smoke.spec.ts` | Boots the PRODUCTION build and proves the frame loop advances |

`{{NAME}}`, `{{SLUG}}`, `{{DATE}}`, `{{DESCRIPTION}}`, `{{TESTPORT}}`, `{{PREVIEWPORT}}` and
`{{FILMPORT}}` are substituted at scaffold time, and the scaffold then fails if any `{{...}}`
survived.

There is deliberately no `bundle-budget.json` here. A budget is a measurement, and one
copied from another game or guessed by hand is a guard that passes because the numbers were
invented. The scaffold builds this stub and runs `npm run size:update` to record the real
figures.

Replace all of it as soon as `PLAN.md` says what the game is. Keep the seams: the pure/view
split, `window.__game.advance(dt)`, and the ids the smoke test reads.
