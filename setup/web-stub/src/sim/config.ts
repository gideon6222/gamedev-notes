/* Numbers, in one place, with no behaviour in them.

   The pure layer of {{NAME}}: nothing in src/sim touches the DOM, three.js or an audio
   context, which is the whole reason node can run golden tests over it without a browser.
   Keep it that way - the moment a renderer import reaches in here, `npm test` needs a
   browser and the size guard starts watching three.js leak into the game chunk. */

/* The simulation's fixed step. advance() is called with real deltas but everything that
   accumulates does so per second, so a slow machine costs accuracy and never determinism. */
export const TICK = 1 / 60;

/* A frame delta larger than this is a tab that was backgrounded, not time the player
   experienced. Clamp it or the first frame back teleports everything. */
export const MAX_DELTA = 0.05;

export const SPIN_PER_SECOND = 0.6;
