# Every headless harness and every screenshot tool that boots the real shell points the save AND the settings at their own paths before booting, and erases them after; a save written by a bot into the player's file is a corrupted save the player will find later. Make the path a static the wrapper reads, not a constant.

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** TESTING.md / Rules for the suites

## What happened

Snowball's smoke test drives the real scene through a shatter and a finish and a village purchase, and the shell saves `Progress` on every one of those, to `user://progress.json` - the same file the game on the desk reads. The screenshot script then booted the game and photographed an almanac full of the smoke test's bot runs ("Stick x69, at 8.1 m") and a village with rows already built, and the desk copy of the game had the bots' progress the next time it opened. The pure save pair (`SimSave.to_dict` / `apply`) was tested with no file, as the rule says; it was the WRAPPER's default path that leaked. Fix: the file wrapper reads its path from a static `SimSave.path` (default the real one), the smoke test sets `SimSave.path = "user://smoke-progress.json"` and erases it at the start and the end, the screenshot script does the same with `user://shot-progress.json`, and the settings file got the same treatment (`Settings.path`). The smoke still asserts that a purchase writes a file - to the test's path.

## The rule

Every headless harness and every screenshot tool that boots the real shell points the save AND the settings at their own paths before booting, and erases them after. A save written by a bot into the player's file is a corrupted save the player will find later. Make the path a static the wrapper reads, not a constant.

## Replaces or contradicts

nothing
