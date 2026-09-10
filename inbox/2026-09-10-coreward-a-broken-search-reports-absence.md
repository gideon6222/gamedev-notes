# A broken search reports absence, and absence is the answer we act on

**What happened.** An asset hunt for Coreward reported that Kenney had nothing suitable in
several categories. The asset scout was honest and thorough, and it also noticed why: the
`search_kenney` function in `scripts/assets.py` matched `href="https://kenney.nl/assets/..."`
with double quotes, and Kenney's listing pages emit single quotes. Measured on
`category:3D`: **55 single-quoted asset links against 6 double-quoted ones.** The function saw
about a tenth of the library, found no rows, and broke out of its paging loop, so every query
returned an empty table.

An empty table from a search tool does not read as "the tool is broken". It reads as "this
does not exist", which is exactly the shape of finding the plan then records as a miss. The
first re-run after a one-line fix surfaced `modular-cave-kit`, which is the single most
relevant pack in Kenney's library to a game made of caves, and which the original hunt had
concluded was not there.

**The rule.** A search that returns nothing must prove it ran. Before writing "no CC0 asset
exists for X" into a plan, run one query whose answer you already know and check it comes
back non-empty. Scrapers rot silently: markup changes, quoting changes, a class name changes,
and the failure mode is always a confident empty result rather than an error. The same test
applies to any tool whose output is used as evidence of absence.

**Also worth keeping.** The subagent found the bug, described it precisely, and correctly did
not fix it or edit the shared notes itself. That is the right division. The main session
verified the claim with its own measurement before changing anything, which took one command,
and only then made the one-line change.

**Where it belongs.** `ASSETS.md`, in the section on the fetch scripts, as a standing check
before recording a miss. The general form belongs in `TESTING.md` beside the rule about
constructs that cannot fail: a tool that cannot report failure will report absence instead.
