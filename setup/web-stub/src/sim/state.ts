/* The whole game, for now: something that turns.

   This is the stub {{SLUG}} was scaffolded with on {{DATE}}. Replace it with the systems in
   PLAN.md. What is worth keeping is the shape: a plain state object, and one `advance`
   that is a pure function of (state, dt). Everything the smoke test, the golden tests and
   scripts/filmstrip.mjs do goes through that seam, which is why a slow CI machine cannot
   make any of them flaky. */

import { MAX_DELTA, SPIN_PER_SECOND, TICK } from './config';

export interface World {
  /* Seconds of GAME time elapsed. Never wall-clock time. */
  t: number;
  /* Radians. */
  spin: number;
  /* How many times advance() has been called, so "the loop is running" is observable. */
  ticks: number;
}

export function newWorld(): World {
  return { t: 0, spin: 0, ticks: 0 };
}

export function advance(w: World, dt: number): World {
  const d = Math.min(Math.max(dt, 0), MAX_DELTA);
  w.t += d;
  w.spin = (w.spin + SPIN_PER_SECOND * d) % (Math.PI * 2);
  w.ticks += 1;
  return w;
}

/* Advance by a whole number of fixed steps. The filmstrip and the deterministic e2e
   assertions use this: the same call produces the same world on any machine. */
export function advanceSteps(w: World, seconds: number): World {
  const steps = Math.round(seconds / TICK);
  for (let i = 0; i < steps; i++) advance(w, TICK);
  return w;
}
