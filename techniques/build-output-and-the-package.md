# Build output inside the project: the 1.42 GB APK, the 1.7 GB import cache, and the two guards

**Game:** Gravewell, Stillwater, and every game scaffolded from `godot-template` · **Status:** both guards now in the template; `new-game.ps1` refuses to scaffold without the marker · **Read when:** a game starts filming runs or writing any artefact into its own project directory; an APK or an import step that has quietly grown; setting up `exclude_filter`, `build/.gdignore` or `.gitignore` in a new repo

Godot walks the project directory. Not the tracked files, not the files git can see - the
directory. So the moment a tool writes output *into* the project, that output is a candidate for
the package and for the import cache, and `.gitignore` has no say in either. Two different guards
are needed because they fail at two different moments, and the guard that matters more is the one
that is easier to lose.

**Generalisable takeaways**

- **`.gitignore` says nothing about what ships.** The exporter and the importer both walk the
  directory; only `exclude_filter` and `.gdignore` speak to them.
- **A guard that lives INSIDE the thing being excluded is not a guard.** Every directory exclusion
  in every tool takes its exceptions with it. Recreate the exception after the copy and assert it.
- **A gate step that gets slower over a session is a symptom, not a slow machine.**

---

## The 1.42 GB APK

A sixty-second filmed run is **3,720 PNGs** in `build/`. The exporter walked the project
directory, packed every one of them, and Gravewell's next APK came out at **1.42 GB** (M) against
a 28 MB budget. The export succeeded and printed `DONE`. Nothing in the toolchain objected; only
the size guard noticed, which is the whole argument for **a size guard from the first commit**.

Two fixes, and both are needed because they fail differently:

| guard | protects | hit when |
|---|---|---|
| `exclude_filter="build/*, *.log, *.apk, *.aab, *.idsig"` in **every** preset | the package | on an export |
| `build/.gdignore` | the import cache | on every run of the gate |

The `.gitignore` has to let the marker survive, and the obvious form silently cannot:

```gitignore
build/*            # not build/ - see below
!build/.gdignore
```

`build/` ignores the **directory**, so git refuses to descend into it at all and the negation can
never match. `build/*` ignores the directory's contents, which leaves the negation reachable. The
broken pair (`build/`, then `!build/`, then `!build/.gdignore`) shipped in Stillwater and left 38
untracked `build/*.png` sitting where a `git add -A` would have staged them.

## Why no scaffolded game ever had the marker

`new-game.ps1` copied the template with `robocopy /E /XD ... build ...`. The one file in `build/`
that is not build output - `.gdignore` itself - went with the directory, so **no game ever
scaffolded from this template had the marker**, for the template's whole life. Nothing notices
until the first filmed run is followed by an export, which can be weeks.

The general shape is worth more than the instance: **a directory exclusion takes its exceptions
with it, in every tool** - robocopy, `.gitignore`, `exclude_filter`, rsync. So recreate the
exception after the copy and **assert it exists**, which is what `new-game.ps1` now refuses to
scaffold without. The same shape in `.gitignore` is the `build/*` form above.

## `.gdignore` is the load-bearing half, not `exclude_filter`

The filter protects the package and is hit on an export, which happens occasionally. The marker
protects the importer and is hit on **every run of the gate**.

Stillwater deletes its frames after each contact sheet, so it was immune to the first failure and
fully exposed to the second. Godot imports a frame **the moment it appears** and keeps its copy
forever, so deleting the source reclaims nothing: `.godot/imported/` held **1.7 GB across 2,646
entries** and the gate's import step had drifted from **5.8 s to 80 s** (M) while everyone
involved assumed the machine was busy.

Tidying an existing repo that has been through this needs `build/**/*.import` and the matching
`.godot/imported/` entries deleted by hand, once. The marker alone stops it recurring; it does not
reclaim what is already there.
