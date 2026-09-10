# Kenney has no `UI` category, so a quarter of every default asset search returned nothing and read as "Kenney has no interface assets"

**Game:** found during the candle-gift digest, applies to every asset hunt  **Date:** 2026-09-10
**Belongs in:** `ASSETS.md`, beside the Kenney entry (already folded in), and `TESTING.md` as
the general shape.

## What happened

The 2026-09-10 digest folded in two separate lessons - one from gravewell, one from coreward -
both saying `assets.py search kenney` returned zero rows for every query because the slug
regex expected double-quoted `href` and Kenney emits single quotes. That fix had already been
made by another session.

So the new rule was applied to itself: run a positive control before trusting the search.
`python scripts/assets.py search kenney UI` returned **zero rows**, on the fixed code.

The regex was fine. `UI` is not a Kenney category. `kenney.nl/assets/category:UI` is a real
page that returns HTTP 200 and lists no packs at all. Measured, packs found per category page:

| selector | packs |
|---|---|
| `category:3D` | 32 |
| `category:2D` | 32 |
| `category:Audio` | 20 |
| `category:Textures` | 18 |
| `category:UI` | **0** |

The script's default list was `["3D", "2D", "Audio", "UI"]`. So one quarter of every
unfiltered search had always come back empty, silently, and the interface packs - `ui-pack`,
`ui-pack-sci-fi`, `ui-pack-adventure`, `input-prompts`, `mobile-controls`, `crosshair-pack` -
were unreachable through the tool. They are a TAG, not a category: `tag:interface`.

Two bugs of the same shape stacked on top of each other, and fixing the first one made the
second invisible, because the search now demonstrably worked for three of its four queries.

## The rule

**A positive control has to be a query whose answer you have actually checked, not one that
sounds right.** "Search for UI, obviously Kenney has UI assets" is a plausible control and it
was testing a URL that does not exist. Pick the control by looking at the source once.

**Better than remembering to run a control: make the tool tell the two apart itself.** Zero
rows because a filter matched nothing is a real answer; zero rows because the scraper saw no
items at all is a broken tool, and from outside they are the same empty table. `search_kenney`
now counts the items it sees BEFORE filtering and exits non-zero naming the selector when that
count is zero, so the absence answer can no longer be produced silently. Verified by
falsification: `search kenney category:UI` exits 1 with the message, the default search lists
packs and exits 0.

Any scraper, filter or allow-list whose empty result would be believed deserves the same
split. It is the fetcher-side form of "a construct that cannot fail is untested, not safe".

## Replaces or contradicts

Corrects the line the same digest had just written into `ASSETS.md` - which named
`search kenney ui` as the positive control - and both are now fixed in place. It does not
contradict the two folded lessons; it is the bug that was hiding behind the one they found.
