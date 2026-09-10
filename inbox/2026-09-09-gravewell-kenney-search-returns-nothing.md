# `assets.py search kenney` silently returns zero results for every query, because the site changed to single-quoted hrefs

**Game:** gravewell (found during the `/game-plan` asset scout)  **Date:** 2026-09-09
**Belongs in:** `ASSETS.md`, in the "How each source is reached" list beside the Kenney entry,
and as a fix to `scripts/assets.py`.

## What happened

The asset scout for a new game ran `python scripts/assets.py search kenney <query>` for every
category it needed and got **zero results every time**. Not an error, not a warning, not a
non-zero exit. An empty list, which reads exactly like "Kenney has nothing for this".

Kenney has plenty for this. Every pack the scout eventually used (`ui-pack`,
`input-prompts`, `particle-pack`, `smoke-particles`, `interface-sounds`, `impact-sounds`,
`sci-fi-sounds`, `digital-audio`) exists and returns HTTP 200 on its own page. The scout only
found them by fetching category pages directly and reading the markup.

**The cause.** `kenney.nl` now emits single-quoted attributes, `href='...'`, and the slug
regex inside `search_kenney` still expects `href="https://kenney\.nl/assets/([a-z0-9-]+)"`.
Nothing matches, so the list is empty. `get kenney <slug>` is unaffected because it uses a
different regex for the zip link, which is why the packs were still fetchable once their
slugs were known by other means.

**The fix.** Accept either quote character in that regex. One character class.

## The rule

**A scraper that returns an empty list on a markup change is indistinguishable from a source
that has nothing, and the empty answer is the one that gets believed.** ASSETS.md already says
"search before deciding a subject is unservable" and "record the misses", and both of those
instructions are actively harmful when the search is broken: a miss gets written down as a
property of the library when it is a property of the regex.

So any scraper over a page we do not control needs a **positive control**: one query whose
answer is known to be non-empty, asserted on every run, failing loudly when it returns
nothing. `assets.py search kenney ui` should never legitimately return zero rows. Same shape
as `TESTING.md`'s existing rule that a construct which cannot fail is untested rather than
safe, applied to a fetcher rather than to a test.

This is the second time the same shape has cost time here: the Coreward `sim`-boundary guard
was green and inert because its allow-list clause permitted the exact thing it existed to
catch. **An empty or passing result from something that scrapes, filters or allow-lists is
worth one falsification before it is believed.**

## Where it belongs

`ASSETS.md`, beside the Kenney line in "How each source is reached", with the positive-control
rule stated once for every scraped source rather than only for Kenney. The regex fix belongs
in `scripts/assets.py` itself and was deliberately not made from the planning session, because
several sessions run against that file at once.
