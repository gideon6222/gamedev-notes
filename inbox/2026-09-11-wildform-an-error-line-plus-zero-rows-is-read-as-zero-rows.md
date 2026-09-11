# An error line above zero rows is read as zero rows, and gets written down as "nothing exists"

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `TESTING.md` beside "a tool that
cannot report failure reports absence instead", and `ASSETS.md` under the source list.

## What happened

`assets.py search kaykit <anything>` called `https://api.github.com/orgs/KayKit-Game-Assets/repos`.
**KayKit-Game-Assets is a GitHub USER, not an org**, so that endpoint 404s for every query,
and has since the source was added. Measured just now:

```
orgs:404
users:200   -> 10 repos
```

The asset scout hit this while looking for creature models and reported "KayKit has zero
creature/monster repos", which is **true**, but it reached a true conclusion through a broken
tool and described the tool as "silently returning nothing".

**It is not silent.** The script prints the failure and exits:

```
searching kaykit for: creature
HTTP 404 for https://api.github.com/orgs/KayKit-Game-Assets/repos?per_page=100
{"message":"Not Found",...}
```

That is the part worth keeping. The existing rule in `TESTING.md` covers a tool that
*cannot* report failure. This tool reported failure perfectly well, at the top of three
lines of output, and the consumer still recorded a miss - because what a reader of a search
looks for is **rows**, and an error line and an empty result both present as no rows. Loud
failure is not sufficient when the thing being scanned for is absence.

The fix in the script is one word (`/orgs/` to `/users/`). The fix in how we read tools is
the lesson.

## The rule

**When a search comes back empty, check the exit status before writing down a miss** - and
when the answer "nothing exists" is going into a plan, re-run the query yourself rather than
inheriting the conclusion. A 404 and a genuine zero look identical to anyone scanning for
rows, however loudly the 404 was printed.

The corollary for any tool whose empty result will be believed: **make the failure the last
line, not the first**, and exit non-zero. The reader sees the end of the output.

## Replaces or contradicts

Extends `TESTING.md`: *"A tool that cannot report failure reports absence instead, and
absence is the answer we act on."* It is not only tools that *cannot* report failure. A tool
that does report it, above an empty table, produces the same wrong answer downstream.

Also extends the positive-control rule: the control here would have been running one kaykit
query with a known-non-empty answer, which is exactly what re-running it after the fix did
(ten repos, none of them creatures - the conclusion survived, the reasoning did not).

## Fixed in the same commit

`scripts/assets.py` `search_kaykit` now calls `/users/`, with a comment naming the failure
mode so nobody "tidies" it back.
