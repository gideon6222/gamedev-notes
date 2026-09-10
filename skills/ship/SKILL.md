---
name: ship
description: Ship a build of a game. Walks the POLISH.md checklist and refuses on a no, confirms CI green, gets the APK onto a GitHub Release (or the web build onto Pages), writes the changelog, and sends Gideon the link, a screenshot and numbered answers. Use at the end of a phase, when he asks for a build, or with "store" to prepare the Play listing.
argument-hint: [store]
---

# Ship

## 1. The gate: POLISH.md

Read `C:\dev\gamedev-notes\POLISH.md` and go through it line by line against THIS build.
Every line is a yes, a no, or "not in this phase" with the phase named in `PLAN.md`. A no
is fixed now, not reported. The only lines that may be deferred are under Content and
Shell items the plan explicitly assigned to a later phase.

Write the result in `NOTES.md` under `## Ship <date>`: the lines that were no and what
fixed them, and the deferred lines with their phase.

## 2. Version and changelog

- Bump `VERSION` in `src/changelog.gd` and `version/name` in `export_presets.cfg`, and
  `version/code` by one. A Play upload needs a higher code every time.
- Add the changelog entry in the player's words: what he can now do or see, newest first,
  one line each. No refactors.
- `scripts\check.ps1 -Export`, then `scripts\device.ps1 install` if the phone is there.

## 3. Push and confirm

- Commit and `git push origin main`. Then `gh run watch` (or `gh run list --limit 1`) until
  the run is green. **Confirm the gate passed; do not poll the live artifact.** Never say
  "pushed" while the run is in flight without saying so and coming back to it.
- The APK is on the release CI creates (`gh release list --limit 1` gives the tag;
  `gh release view <tag> --json assets` gives the download URL). For a web game, the Pages
  URL from `gh api repos/{owner}/{repo}/pages --jq .html_url`.
- Screenshot at the phone's aspect: `godot --path . --resolution 460x996 --script res://scripts/shot.gd -- 30 <state>`
  and the `first-minute` contact sheet if it changed.
- File lessons (`/record-lesson`) and his words (`playtests/<slug>.md`) if any are pending.

## 4. Report to him

One message: the APK link (tap on the phone, install over the old one, the stamp in the
pause menu should read the new sha), the screenshot, the changelog entry, what to try first,
the numbered answers to his last message, the decisions made for him (from `NOTES.md`), and
what phase comes next. Then continue into the next phase unless he said stop.

## `store` mode: the Play listing

Read `C:\dev\gamedev-notes\PLAY.md`. Produce, into `store/`:

- `icon-512.png` (32-bit PNG with alpha, no rounded corners) and the adaptive icon layers
  in `export_presets.cfg`.
- `feature-1024x500.png` (no transparency) rendered from the game with the wordmark.
- At least four phone screenshots at 1080x2340 from `shot.gd` at the states that sell the
  game (the first minute, the shop, a big moment, the collection).
- `listing.md`: title, 80-character short description, 4000-character full description in
  his voice, content rating answers, the data safety answers (nothing collected), the
  privacy policy text for `PRIVACY.md` hosted on the repo's Pages.
- The release AAB: `git tag v<version> && git push origin v<version>`, watch the `play`
  job, and give him the AAB link. He uploads it; that step is his.
