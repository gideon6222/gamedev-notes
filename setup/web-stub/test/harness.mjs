/* Golden-test harness.

   The tests are .mjs so node's test runner can run them with no build step, and the game is
   .ts, so something has to bridge the two. This bundles test/pure-entry.ts with esbuild and
   imports the result, which means the tests run against the REAL shipping modules through
   the real import graph - not against a copy, and not against a hand-maintained JS mirror
   that drifts. */

import { build } from 'esbuild';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { dirname, join } from 'node:path';
import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';

const HERE = dirname(fileURLToPath(import.meta.url));
export const REPO = join(HERE, '..');

let cached = null;

/* Async because bundling is. Test files use top-level await, which node's ESM test runner
   supports. */
export async function loadPure() {
  if (cached) return cached;
  const outfile = join(mkdtempSync(join(tmpdir(), 'pure-')), 'pure.mjs');
  await build({
    entryPoints: [join(HERE, 'pure-entry.ts')],
    bundle: true,
    format: 'esm',
    platform: 'neutral',
    outfile,
    logLevel: 'silent'
  });
  cached = await import(pathToFileURL(outfile).href);
  /* A bundle that imported cleanly but exported nothing would make every assertion below
     vacuously true, which is the failure mode this whole repo is most afraid of. */
  if (typeof cached.advance !== 'function') throw new Error('harness: advance missing from the bundle');
  if (typeof cached.newWorld !== 'function') throw new Error('harness: newWorld missing from the bundle');
  return cached;
}
