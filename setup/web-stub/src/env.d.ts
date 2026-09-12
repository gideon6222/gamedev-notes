/* Ambient declarations. No imports or exports in this file, so everything here is global. */

/* Replaced by Vite's `define` at build time; see buildSha() in vite.config.js. Read through
   a typeof guard so the game is still harmless when it runs unbuilt. */
declare const __BUILD_SHA__: string;
declare const __BUILD_TIME__: string;

interface Window {
  /* Safari's prefixed constructor, for when this game grows an audio graph. */
  webkitAudioContext?: typeof AudioContext;
}

/* Vite rewrites an asset import to the hashed, base-relative URL of the emitted file. */
declare module '*.webp' {
  const src: string;
  export default src;
}
