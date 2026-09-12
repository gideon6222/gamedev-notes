/* Test-only entry point. Re-exports the pure modules so the harness can bundle exactly one
   thing and get everything the golden tests need.

   None of these touch the DOM, three.js or an audio context, which is why they can run under
   node at all. Keep it that way: if importing this ever starts pulling in a renderer, the
   pure/view split has leaked and `npm test` has quietly become a browser test. */

export * from '../src/sim/config';
export * from '../src/sim/state';
