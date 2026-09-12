/* Deletes caches left behind by a hand-written service worker.

   **This file is not optional, and a fresh game does not need what it does.**
   Those two facts are both true. `vite.config.js` names it in workbox's
   `importScripts`, and a service worker whose importScripts 404s fails to
   install - so deleting this file does not tidy the PWA, it turns it off. The
   scaffold checks it landed for that reason.

   What it does when there IS something to clean: Workbox's
   cleanupOutdatedCaches only removes precaches Workbox itself created
   (workbox-precache-v2-*). A cache that a hand-rolled worker named
   "{{SLUG}}-v5" is invisible to it and would sit on the device forever. On the
   game this tooling was first written for that measured 1.31 MB of orphaned
   data, including a CDN copy of three.js, on a real upgrade.

   A game scaffolded today has never shipped a hand-written worker, so the
   pattern matches nothing - which is the correct amount of work for it to do.
   Keep the pattern pointing at THIS game's name rather than deleting it: the
   cost is a regex nobody runs, and the day this repo ships its own worker the
   cleanup is already in place on every device.

   It runs on activate, not from the page. During an upgrade the old worker is
   still serving the old index.html, and deleting its cache from the page would
   send that load to the network, 404, and break the very load that is meant to
   hand over. By activate time the old worker is gone and nothing needs it.

   Matched by pattern rather than by name, so a device that skipped a few
   versions is cleaned up too. */

const LEGACY_CACHE = /^{{SLUG}}-v\d+$/;

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((names) =>
      Promise.all(
        names
          .filter((name) => LEGACY_CACHE.test(name))
          .map((name) => caches.delete(name))
      )
    )
  );
});
