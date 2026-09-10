# When a tool hits a crash in the game, fix the game

**What happened.** Writing an economy probe for Coreward, it crashed on
`Cannot read properties of undefined (reading 'value')` the moment the simulated player dug
into a planet core. The cause was `haulValue()`, which reads `DEF[id].value` for everything in
the hold, and `DEF` does not carry the core, the bedrock, a relic or a drive component -
those four are built inline in `blockAt()`.

I fixed it in the probe: made the probe skip cells `DEF` does not know. Wrote a comment
explaining why. Moved on.

**Hours later Gideon's phone showed the same message on a black screen**, and it took a long
time to place because it arrived from the shipped game rather than from the tool. `haulValue()`
is called by `updateHUD()`, which runs every frame - so one unsellable id reaching the hold is
not a bad sale, it is a save that cannot be loaded, on a device with no console.

**The rule.** A tool that drives the real code is a fuzzer whether or not you meant it to be.
When one throws, the first question is "can the game reach this state" and not "how do I get
my tool past it". If the answer is yes or maybe, the fix belongs in the game and the tool's
version is at best a second copy of it.

The tell is specific and easy to spot in hindsight: **the fix in the probe was a guard, not a
correction.** A guard says "this input is possible and I am handling it", which is a statement
about the code under test, not about the tool.

**A second lesson from the same crash.** The game's error overlay exists to make a phone crash
readable and it printed `e.message` and `e.filename` and threw away `e.error.stack`. A message
names what broke; a stack names what called it. Three hours of reasoning could not place a
message that one stack frame would have. Any hand-rolled crash reporter must print the stack,
and on a phone it should also offer a way to clear the save, because a save that crashes the
boot is otherwise unrecoverable without going into browser settings.

**Where it belongs.** `TESTING.md`, under what a probe or harness is for. The crash-reporter
half belongs in `POLISH.md` beside the build-stamp line, since both exist for the same reason:
he has no console on the phone.
