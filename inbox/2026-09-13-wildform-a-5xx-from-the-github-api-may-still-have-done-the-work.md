# A 5xx from the GitHub API is about the response, not the action: check what it did before retrying

**Game:** wildform  **Date:** 2026-09-13  **Belongs in:** GODOT.md / CI

## What happened
Between 08:27 and 09:08 on 2026-09-13 GitHub's Releases API was failing, and three CI runs
across snowball and wildform went red. None of them was a code failure: the headless test job
passed in all three and the APK built, and only the final `Publish a release` step failed, with
`softprops/action-gh-release` getting **HTTP 500** three times and aborting. The failures were
not identical, which is what makes the shape worth writing down. wildform's build-35 was never
created at all, while build-36 got as far as **a draft release with the 35 MB APK already
attached** and then failed at `error finalizing release: HttpError`. So a red release step can
mean nothing was published, or that everything was uploaded and only the last flag was not set,
and the two look the same from the run's conclusion.

Then `gh run rerun <id> -R <repo> --failed` **itself** returned `HTTP 502: Server Error`. That
read as "the re-run did not start", and the obvious next move was to issue it again. It had in
fact started: snowball's `build-13` published four minutes later, from exactly that re-run. A
blind retry would have queued the same job twice and published two releases for one commit. The
API's rate limit was untouched at 5000/5000 throughout and githubstatus.com said "All Systems
Operational" the whole time, so neither of those is worth consulting for this.

## The rule
**When a `gh` command or a release step fails with a 5xx, look at the effect before doing
anything about the cause.** `gh run list` for a new run, `gh release list` and
`gh api repos/<owner>/<repo>/releases` for a release that may exist as a draft. A 500 or 502 is
the server failing to answer, not a promise that it did nothing, and the repair for "the release
did not publish" is often `--draft=false` on a release that is already there with its asset,
not another full build. Do not re-issue a write after a 5xx until a read says it did not happen.
Do not treat githubstatus.com as evidence either way: it said everything was operational through
all of this.

## Replaces or contradicts
`GODOT.md:389` (the `## CI` section) covers how to WATCH a run but says nothing about a run that
fails at the release step or an API call that errors:

> Poll with `gh run watch` or `gh run list --limit 3`, never a 15-second unauthenticated curl
> loop (it burns the API budget and prints nothing, which reads as "still running"). A check that
> cannot determine the answer must say so.

That last sentence is the same principle and this extends it to writes: a write whose response
was lost is a check that cannot determine the answer, so it must be answered by reading the
effect rather than by assuming either outcome. Add the rule to that section rather than
replacing anything.
