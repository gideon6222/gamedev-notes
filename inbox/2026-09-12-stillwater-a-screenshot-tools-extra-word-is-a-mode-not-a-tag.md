# In a screenshot or film tool with positional arguments, a new moment to photograph is a new MODE name, never an extra word after the mode - and when a shot comes back looking unchanged, compare its pixels to the previous file before reviewing it, because a run that died before the shutter leaves the old picture in place with no error.

**Game:** stillwater  **Date:** 2026-09-12  **Belongs in:** TESTING.md / filming / screenshot tooling section, and techniques/filming-a-run.md if it describes shot modes

## What happened
Stillwater's `scripts/shot.gd` takes positional user args: seconds, then a mode/state name, then (by an older convention) the HOUR, the WEATHER, a depth and a spot. Twice in one session a new moment to photograph was added as an extra word after the mode (`-- 1.3 cast throw` for the mid-throw, `-- 0.7 fight hot` for the rod over the danger line). Both times the extra word was silently taken as the hour: the first produced a HUD reading "day 1, throw, clear" (noticed by reading the caption in the screenshot), the second produced NO new screenshot at all - the run died before the shutter on an unknown hour with no message, and the file on disk was the previous shot, which was reviewed as if it were the new one until a pixel comparison showed the two images identical. The fix both times was to make the moment its own mode name (`throw`, `strain`) and, the second time, to write the argument layout as a warning at the top of the argument handling. The general fault: a tool whose positional arguments have meanings is a tool where an unrecognised extra word does not fail, it becomes data.

## The rule
In a screenshot or film tool with positional arguments, a new moment to photograph is a new MODE name, never an extra word after the mode. When a shot comes back looking unchanged, compare its pixels to the previous file before reviewing it, because a run that died before the shutter leaves the old picture in place with no error.

## Replaces or contradicts
nothing
