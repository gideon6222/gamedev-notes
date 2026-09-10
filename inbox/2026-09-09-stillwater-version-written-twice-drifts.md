# `Changelog.VERSION` and `version/name` in every export preset are one fact in three places, so assert they agree

**Game:** stillwater  **Date:** 2026-09-09  **Belongs in:** TESTING.md / what every game asserts, and POLISH.md as a ship-gate line

## What happened

Bumping Stillwater to 0.5.2 meant editing `src/changelog.gd` and, separately, `version/name` in
`export_presets.cfg` - twice, because the debug APK preset and the Play AAB preset each carry
their own copy. Nothing derives one from the other: Godot will not read a constant out of a
script at export time. They were already at 0.5.1 against a changelog that had moved on.

The failure this produces is quiet and lands exactly where it hurts. The title screen says one
version, the phone's app info says another, and "did my build land" - the question the build
stamp and changelog exist to answer - gets two different answers depending on where you look.
The AAB copy is worse than the APK copy, because it is the one nobody sees until a store
upload.

A pure test now reads `export_presets.cfg`, pulls every `version/name`, and asserts each equals
`Changelog.VERSION`, plus that `RELEASES[0].version` is that same version - a bumped constant
with no entry under it is a build the player cannot read. Six assertions, no GPU. Verified by
reverting one of the two presets and watching it fail with both values named in the message.

## The rule

Any fact written in more than one file that no code derives gets a test on the agreement, not a
note asking people to remember. For version specifically, every game asserts:
`Changelog.VERSION` == `version/name` in **each** preset == `RELEASES[0].version`. Read the
file with `FileAccess.get_file_as_string("res://export_presets.cfg")` and parse the lines - it
is a pure test and belongs beside the other config assertions, not in the smoke suite.

## Replaces or contradicts

Nothing contradicted. It is the concrete instance of INDEX.md standing rule 10, "a constant
that must agree with another gets a test on the derived quantity" - which is stated as a
principle and had never been applied to the one constant every game has. Belongs in the
template so new games start with it.
