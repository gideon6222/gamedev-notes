# Diagnosis and rework: what to do when a fix does not take

**Cross-game.** These were `CRAFT.md`'s "Process lessons that have each been paid for more than
once". The 2026-09-11 audit found the section duplicated INDEX rules 8 and 12, contradicted
rule 8 outright ("two fixes" against "a correct fix"), and was not design content read at plan
or polish time. It was corrected and moved here on 2026-09-12; `CRAFT.md` keeps the headlines.

**Read when:** a complaint survives a fix; a symptom that reads as tuning; a report whose
mechanism half you were about to skip; renaming or moving anything in a game repo.

---

## Diagnosis and rework

- A complaint that survives a **correct fix** is about something else. Stop fixing and measure:
  hide a layer, read a pixel, print the buffer. (Standing rule 8. One fix, not two.)
- **When the fix for one complaint reliably causes another, stop tuning the number and look for
  the missing degree of freedom.** Two things that must differ are driven by one value: the
  complaint survived a fix that was correct given a structure that was wrong.
- **Put a rule where the file system can see it, write the test that reads it, then break the
  code five times to prove the test is awake.** A boundary in a comment is a request: moving
  Coreward's thirteen pure modules into `src/sim/` cost 77 import lines and turned the rule into
  a location.
- Half a feature working is the worst symptom, because it reads as tuning. If adjusting the
  obvious parameter changes nothing, a constant term is drowning it.
- Two bugs can hide each other. When a fix makes a different test fail, suspect a mask.
- A rewrite beats revision when the fault is an inheritance (shape) rather than a decision.
  Keep research in `REFERENCE.md` so a rewrite is cheap.
- Separate means separate, not delete. The answer to a gauge in the wrong place is to move it.
- Before changing a constant, grep every formula it appears in. Test the derived quantity the
  player feels.
- Set up the test scene where the bug CAN appear. Four rounds were spent with the ship at the one
  junction where the artefact could not show.
- **When a verb changes which states the player spends time in, or which callers a path has, grep
  every system whose rules assumed the old distribution.** A plow that leaves the hull inside rock
  broke the light solver two files away; a burn that does not retarget turned a payout branch into
  an income.
- The filename is the interface: plan in `PLAN.md`, his words in `playtests/<slug>.md`,
  decisions and measurements in `NOTES.md`. A document with any other name is linked from
  `CLAUDE.md` or it does not exist, and a rename is a `git mv` plus a grep in one commit. When a
  game moves repo, mark the old one dead in the same commit as the new one's first: the pointer
  is written backwards, because forwards is the direction nobody is standing in.
