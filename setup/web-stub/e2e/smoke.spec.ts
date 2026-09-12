import { expect, test } from '@playwright/test';

/* Smoke test against the PRODUCTION BUILD, served the way GitHub Pages will serve it.

   The golden tests in test/ cover the pure layer. They cannot catch a wiring bug: the one
   real bug the tooling this repo was scaffolded from ever shipped was a module split that
   dropped `requestAnimationFrame(frame)` from the entry point. Every pure function stayed
   correct, the typecheck was clean, the build succeeded, and the game was frozen. Only
   booting the built artifact catches that class, which is what this file is for.

   So the load-bearing assertion is "the frame loop advances". Keep it when you replace the
   stub, and add the scenarios this game is actually about underneath it. Wait on game
   STATE, never on the wall clock: the loop clamps its delta, so on a machine with no GPU
   the game advances in slow motion and any fixed sleep becomes a flake. */

/* Collected rather than thrown from the listener: a throw inside a page event handler
   surfaces as an unhandled rejection attributed to no test at all. */
let pageErrors: string[] = [];

test.beforeEach(async ({ page }) => {
  pageErrors = [];
  page.on('pageerror', (e) => pageErrors.push(e.message));
  await page.goto('/');
  await page.waitForFunction(() => (window as any).__game?.ready === true);
});

test.afterEach(() => {
  expect(pageErrors, 'the page threw during the test').toEqual([]);
});

test('boots without hitting the error overlay', async ({ page }) => {
  await expect(page.locator('#err')).toBeHidden();
  await expect(page.locator('#boot')).toBeHidden();
});

test('creates a WebGL context', async ({ page }) => {
  const ok = await page.evaluate(() => {
    const c = document.querySelector('#game canvas') as HTMLCanvasElement | null;
    return !!c && !!(c.getContext('webgl2') || c.getContext('webgl'));
  });
  expect(ok).toBe(true);
});

test('the frame loop advances', async ({ page }) => {
  const before = await page.evaluate(() => (window as any).__game.frames as number);
  /* Poll on the counter rather than sleeping a fixed time: on CI's software rasteriser a
     frame can take a hundred times longer than it does here. */
  await page.waitForFunction(
    (n) => ((window as any).__game.frames as number) > n + 5,
    before,
    { timeout: 15_000 }
  );
});

test('advance is deterministic and far faster than real time', async ({ page }) => {
  const [a, b] = await page.evaluate(() => {
    const g = (window as any).__game;
    const t0 = g.world.t;
    g.advance(10);
    const t1 = g.world.t;
    return [t0, t1];
  });
  /* Ten seconds of GAME time, in one call, costing no wall-clock seconds at all. */
  expect(b - a).toBeGreaterThan(9.5);
  expect(b - a).toBeLessThan(10.5);
});

test('the build stamp is populated', async ({ page }) => {
  const stamp = (await page.locator('#stamp').textContent()) ?? '';
  /* `unknown` is what vite.config.js writes when it cannot read a sha, and a stamp nobody
     can read is worse than no stamp: it makes an old build on the phone look current. */
  expect(stamp.trim()).not.toBe('');
  expect(stamp).not.toContain('unknown');
});
