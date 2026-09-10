# A replaced repo keeps recruiting sessions until it says it is dead

**What happened.** Candle Gift was rewritten from the web build in
`Desktop\ClaudeCode\Captain_Run` into the Godot game in `C:\dev\candle-gift`. The new repo
recorded where it came from, in the first section of its `CLAUDE.md`. The old repo recorded
nothing. Its `CLAUDE.md` still opened with "Live: https://gideon6222.github.io/Captain_Run/",
still described itself in the present tense as the game, and still pointed at `SKILL.md`,
`PIPELINE.md` and `PLAYTESTS.md` in the shared notes, which had been archived the same day.
The workspace `CLAUDE.md` one level up still listed `Captain_Run` as where Candle Gift lives.
A session opened in that folder, asked for anything about the game, would have read three
files that all agreed with each other and all pointed at the dead build, and would have built
there. The rewrite direction only exists in the repo that was written last, which is the one
that does not need it.

**The rule.** When a game moves to a new repo, mark the old one dead in the same commit as
the first commit of the new one: a banner at the top of its `CLAUDE.md` and `README.md`
saying where the game went and that the repo is read only. The pointer has to be written
backwards, from the replacement to the thing replaced, because forwards is the direction
nobody is standing in. This is rule 12, "delete the stand-in in the same commit as the real
thing", applied to a whole repo rather than a file, and a retired repo is kept rather than
deleted, so the banner is what deletion would have been.

**A second thing worth keeping.** The stale pointers were to files in `gamedev-notes` that
`/digest` had moved into `archive/`. Reorganising the shared notes leaves every game repo
naming files that no longer exist. After a reorganisation, grep the game repos for the old
filenames.

**Where it belongs.** `CRAFT.md`, in whatever section covers repo hygiene and starting a
game over, or `INDEX.md` beside standing rule 12.
