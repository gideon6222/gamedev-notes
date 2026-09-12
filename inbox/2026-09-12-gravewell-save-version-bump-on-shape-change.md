# Bump the save VERSION when a field changes SHAPE, not only when a field is added, and pin the bump with a test that writes an old-shaped save

**Game:** gravewell  **Date:** 2026-09-12  **Belongs in:** GODOT.md / Invariants every game keeps

## What happened
`cores` went from a tally (`int`) to the drive (`Array[int]` of class ids) and
`Save.VERSION` stayed at 2. Nothing failed: every test wrote a new-shaped save and read it
back, so the suite was green at 195 tests. An existing save on a phone would have passed
the version check, reached `d.get("cores", []) as Array` on an integer, which yields
`null` in Godot 4, and then iterated it. The comment written in the same commit claimed
"the version bump means such a save is not read at all" while the bump had not happened,
so the code was documented as doing something it did not do. The existing version test
used `VERSION + 99`, which cannot catch this: it proves an unknown future version is
rejected, never that the CURRENT shape change was declared.

## The rule
Any change to what a saved field CONTAINS is a version bump, the same as adding or
removing one. Pin it with a test that writes a save carrying the old shape at the old
version number and asserts it is refused, not with a test that uses `VERSION + n`, which
passes whatever the constant says.

## Replaces or contradicts
nothing
