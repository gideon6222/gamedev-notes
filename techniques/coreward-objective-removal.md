# Removing a stand-in objective: what a real ending costs to install

**Game:** Coreward · **Status:** shipped · **Read when:** a new objective replaces a placeholder
or an earlier one; two endings exist in the same build and neither has been deleted; a derived
stat or a frozen golden survives a feature it was computed for.

**Read this before budgeting the work as small.** Coreward's replacement of a placeholder
objective with the real one cost 1,300 lines and ninety call sites across nineteen files, about
two hours of that with the typechecker doing the finding.

**Generalisable takeaways**

- **When a new objective ships, the old one is a stand-in, and the round is not done until it is
  deleted.** Two objectives in one game is worse than either alone: the player collects components
  that now do nothing, and the next session cannot tell which ending is real.
- Expect three specific things, not just "some cleanup": a derived stat quietly changes, a file
  turns out to be two features under one name, and a frozen golden keeps the dead ids forever.

---

## A derived stat quietly changes

A drill formula lost its shards term when the shard economy was removed. The re-recorded golden
matching the old `shards == 0` row exactly is what makes the removal safe rather than a silent
rebalance - the number has to be checked against what it used to be, not just re-recorded and
trusted.

## A file turns out to be two features under one name

Deleting `transit.ts` took the title screen with it. Nothing named the file as carrying two
responsibilities until the second one vanished; grep every caller of a file before deleting it for
one reason, not just the callers that prompted the deletion.

## A frozen golden keeps the dead ids in its allow-list forever

An overwriter leaving a cell behind is as legal, to a golden diff, as one arriving - so a dead
objective's ids stay in the allow-list indefinitely unless someone removes them by hand. Read the
diff for what LEFT, not only what changed, and delete the dead ids in the same commit as the
feature that made them dead.
