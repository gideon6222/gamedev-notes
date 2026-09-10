# Filming a run leaves thousands of PNGs inside the project, and the exporter packs every one: a 1.42 GB APK

**Game:** gravewell **Date:** 2026-09-10
**Belongs in:** `GODOT.md` under export, and `TESTING.md` beside `movie.ps1`.

## What happened

`scripts/movie.ps1` writes one PNG per frame into `build/movie/<name>/`. A sixty
second film at 60 fps is **3,720 files**, and `build/` is inside the project
directory. Godot's exporter walks the project directory.

The next `check.ps1 -Export` produced an APK of **1,423,818,175 bytes**. The
size guard caught it and reported it as a 4,933% growth, which is the only
reason it was noticed at all: the export itself succeeded, printed `DONE`, and
took ninety seconds instead of twelve, which reads as a slow machine.

`build/` is in `.gitignore`, so nothing about the repo looked wrong. Git is not
what decides what goes in an APK.

## The fix, in two places, because they fail differently

**`exclude_filter` in every export preset**, which is what keeps it out of the
package:

```
exclude_filter="build/*, *.log, *.apk, *.aab, *.idsig"
```

**A `.gdignore` in `build/`**, which is what keeps it out of the import cache.
Without it the editor imports 3,720 PNGs the first time it opens, which is its
own slow disaster and fills `.godot/imported` with things nothing uses.

And `build/.gdignore` has to survive `.gitignore`, so the ignore needs an
exception for it or the marker is missing on every fresh clone:

```
build/
!build/
!build/.gdignore
```

## The rule

**Anything a tool writes INTO the project directory is a candidate for the
package, and `.gitignore` has no say in it.** Films, screenshots, logs, probe
dumps, replay recordings and exported artefacts all land in `build/` by
convention here, and the convention is only safe if the export preset excludes
it and a `.gdignore` sits in it.

The wider version: **a size guard is the only check that can see this class of
mistake, and it is worth having from the first commit for exactly that reason.**
Nothing else in the gate had an opinion. The tests passed, the smoke passed, the
export exited zero and verified the APK, and the game inside it worked perfectly.
