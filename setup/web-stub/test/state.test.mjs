/* The stub's golden test.

   One real assertion, not a placeholder, because `npm test` reporting green having run
   nothing is the exact fault this framework keeps writing lessons about. Delete this file
   when src/sim is the real game - and replace it, do not just remove it. */

import { strict as assert } from 'node:assert';
import { test } from 'node:test';
import { loadPure } from './harness.mjs';

const { TICK, MAX_DELTA, SPIN_PER_SECOND, newWorld, advance, advanceSteps } = await loadPure();

test('a fresh world starts at zero', () => {
  const w = newWorld();
  assert.equal(w.t, 0);
  assert.equal(w.spin, 0);
  assert.equal(w.ticks, 0);
});

test('one second of game time is one second however it is cut up', () => {
  const a = advanceSteps(newWorld(), 1);
  const b = advance(newWorld(), 1 / 60);
  assert.ok(Math.abs(a.t - 1) < 1e-9, `a whole second of steps came to ${a.t}`);
  assert.equal(a.ticks, Math.round(1 / TICK));
  assert.ok(a.spin > b.spin);
});

test('a backgrounded tab does not teleport the world', () => {
  /* The delta clamp. Without it, coming back to the tab after a minute advances a minute of
     game state in a single frame, and everything that moves has moved through walls. */
  const w = advance(newWorld(), 60);
  assert.equal(w.t, MAX_DELTA);
  assert.ok(w.spin <= SPIN_PER_SECOND * MAX_DELTA + 1e-9);
});

test('advance is deterministic', () => {
  const a = advanceSteps(newWorld(), 5);
  const b = advanceSteps(newWorld(), 5);
  assert.deepEqual(a, b);
});
