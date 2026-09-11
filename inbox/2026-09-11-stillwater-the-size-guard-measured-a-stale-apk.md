# A size guard that measures whatever is in build/ passes on a stale build

**Stillwater, 2026-09-11.** Adding a whole new room - nine imported props and a plank
material - took the APK from 35.62 MB to **64.58 MB**, an 81% jump past a 10% tolerance.

The local `check.ps1` reported **`size ok`** the whole time. It runs the guard only `if
(Get-ChildItem build -Filter *.apk)`, and measures that file. Mine was from an earlier
session, before any of the new assets existed, so the guard was answering a question about a
build nobody had made that day. CI exports first and caught it immediately.

**Two things to fix in any repo with this shape:**

1. **Export before measuring, or do not measure.** A guard whose input is a build artifact
   has to own the build. Failing that, the runner must at least refuse a stale one - compare
   the APK's mtime against the newest source file and say "no APK newer than your changes"
   rather than printing OK.
2. **A green local check is not a green build.** This is the second time on this machine that
   a local pass and a CI fail disagreed because the local step silently measured the wrong
   thing.

**And the cost itself is worth knowing: VRAM-compressed textures are a fixed rate per pixel.**
How well the source JPEG packs is irrelevant - 39 new 1K maps are about 39 MB in the APK
whatever they weigh on disk. The lever is `process/size_limit` in the `.import`, which caps
the imported dimension:

- 512 across the room, 256 on the five props that are only ever background → **64.58 MB to
  43.71 MB**, and a screenshot from where the player stands is indistinguishable.

Downloaded assets also arrive with `mipmaps/generate=false` and `compress/mode=0`, which a
separate asset test caught on all 39. Patch the `.import` files and re-run `--import`; there
is no need to re-download.

Related: [[measure-do-not-guess]], [[a-construct-that-cannot-fail-is-untested]]
