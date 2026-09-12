# inbox

Unfolded lessons. One file per lesson, named `YYYY-MM-DD-<game>-<slug>.md`, written by
`/record-lesson` the moment something is learned. Nothing in here is read by a build
session directly; `/digest` folds each file into `CRAFT.md`, `GODOT.md`, `TESTING.md`,
`ASSETS.md`, `POLISH.md`, `PLAYER.md` or `WEB.md`, or into a `techniques/` file, and then
deletes it. Unique filenames mean two sessions never conflict here.

A lesson file has four parts, and `/record-lesson` has the exact shape: what happened (one
paragraph), the rule (one sentence, the thing that would have saved time this morning),
`Belongs in` (a file and a section), and `Replaces or contradicts` (the existing line this
changes, quoted as it reads there, or "nothing"). The last two are not optional: they are
how `/digest` folds the lesson into the right place without leaving a rule and its
correction both standing.
