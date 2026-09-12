/* {{NAME}} - boot and frame loop.

   {{DESCRIPTION}}

   Scaffolded {{DATE}}. This is the stub; PLAN.md says what replaces it.

   Two things here are not placeholder and should survive the rewrite.

   THE LAST LINE OF THIS FILE IS requestAnimationFrame(frame). A module split once dropped
   exactly that line in the game this tooling came from: every golden test passed, the
   typecheck was clean, the build succeeded, and the game drew one frame and sat there. The
   e2e smoke test asserts the loop advances, and bundle-budget.json notices the game chunk
   shrinking when everything reachable only from the loop gets tree-shaken away.

   WINDOW.__GAME IS THE TICK SEAM. e2e and scripts/filmstrip.mjs drive game time through
   advance() instead of sleeping, so neither is measuring the machine. Never drive the game
   from a test by importing a module: under the dev server a dynamic import resolves to a
   different module instance than the one the loop is running. */

import { MAX_DELTA } from './sim/config';
import { advance, advanceSteps, newWorld, type World } from './sim/state';
import { makeView } from './view/scene';

const host = mustEl('game');
const ticksEl = mustEl('ticks');
const world: World = newWorld();
const view = makeView(host);

/* mustEl, not getElementById. A missing id is a wiring bug that should be one loud error in
   the overlay, not `null` quietly reaching the first property access ten frames later. */
function mustEl(id: string): HTMLElement {
  const el = document.getElementById(id);
  if (!el) throw new Error(`missing #${id} in index.html`);
  return el;
}

const stamp = mustEl('stamp');
stamp.textContent =
  (typeof __BUILD_SHA__ === 'string' ? __BUILD_SHA__ : 'dev') + ' ' +
  (typeof __BUILD_TIME__ === 'string' ? __BUILD_TIME__.slice(0, 16) : '');

window.addEventListener('resize', () => view.resize());

let last = performance.now();
let frames = 0;

function frame(now: number) {
  const dt = Math.min((now - last) / 1000, MAX_DELTA);
  last = now;
  advance(world, dt);
  view.render(world);
  frames++;
  ticksEl.textContent = String(world.ticks);
  requestAnimationFrame(frame);
}

mustEl('boot').classList.add('hidden');

/* The seam. Kept deliberately small: game state, a way to step game time, and a frame
   counter that only the real rAF loop moves. */
(window as unknown as { __game: unknown }).__game = {
  get world() { return world; },
  get frames() { return frames; },
  advance(seconds: number) { advanceSteps(world, seconds); view.render(world); },
  ready: true
};

requestAnimationFrame(frame);
