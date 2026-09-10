# The process opens filenames, so a plan called something else does not exist

**What happened.** Coreward had three rounds of planning in a 29 KB file, complete with a
status list, an order of work and his asks quoted verbatim. It was called `DESIGN.md`.
`INDEX.md` tells a resuming session to read `CLAUDE.md`, `NOTES.md`, `PLAN.md` and the
playtest file, and `gamedev-notes` never mentions `DESIGN.md` anywhere. Neither did
Coreward's own `CLAUDE.md` or `README.md`: a grep for the name across the whole repo returned
nothing, so the file was reachable only by listing the directory and guessing.

Stillwater has the same file under the same name. Candle Gift has `PLAN.md`. Nobody chose
this, it is just what each session happened to type on the day the game was planned.

**The rule.** The process is a list of filenames, so the filename is the interface. A plan
goes in `PLAN.md`, his words go in `playtests/<slug>.md`, decisions and measurements go in
`NOTES.md`, and a document that earns a different name has to be linked from `CLAUDE.md` or
it is invisible. When renaming, `git mv` and grep for the old name in the same commit.

**A second thing.** `PLAN.md` is most useful when the first unticked box is the answer to
"what now". Coreward's rounds were all shipped and the file said so in prose across three
sections, which still leaves the resuming session reading 29 KB to find out. A checklist at
the top, ticked to the current version, answers it in one screen.

**Where it belongs.** `INDEX.md`, beside the resume instructions, or `CRAFT.md` under how the
repo files are meant to be used. Worth a one-line audit in `/digest`: any game repo whose
plan is not called `PLAN.md`.
