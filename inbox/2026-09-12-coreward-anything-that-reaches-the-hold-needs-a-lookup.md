# Any id that can reach the inventory must survive the inventory's lookup

**Game:** Coreward (web, three.js) · **Date:** 2026-09-12 · **Topic:** engine traps, testing

A new block type was added - cut stone, the wall of a hand-authored room. It
was given a token weight and value, the way plain rock has:

```ts
return { id: 'worked', name: 'Worked Stone', hard: ..., wt: 0.4, value: 1 };
```

Breaking a block with weight puts it in the hold. The manifest screen sorts the
hold:

```ts
Object.keys(g.cargo).sort((a, b) => g.cargo[b] * DEF[b].value - ...)
```

`DEF['worked']` does not exist. **The game ran, the manifest opened, and then
it did not - depending on whether the player had cut through a wall since the
last time they looked.**

No test had it, and the reason is worth writing down: **every fixture that cut
stone never opened the manifest, and every fixture that opened the manifest
never cut stone.** Both halves were covered and the join was not. It was found
by screenshotting every screen in the game, which is the only pass that visits
states in the order a player does.

## The fix, and the rule under it

A `spoil` flag on the three cut-stone blocks, checked in the dig handler above
the branch that fills the hold - so breaking a wall puts nothing in it. Which
is also the right game rule: you are getting THROUGH a wall, not mining it.

**The invariant to state out loud in the repo's own notes:** anything that can
reach the inventory must have an entry in the table the inventory looks things
up in. Not "should" - the screen crashes.

## The test that holds it is wider than the bug

Not "worked stone is flagged spoil" - that is the fix restated. Sweep the
world, and for every block that could be broken into the hold, assert the
lookup exists:

```js
for (each sampled cell) {
  const b = blockAt(x, d);
  if (!b || b.spoil || b.hazard || b.cache || b.find || b.relic) continue;
  if (!Number.isFinite(b.hard)) continue;        // unbreakable
  if (!DEF[b.id]) bad.add(b.id);
}
assert.deepEqual([...bad], []);
```

That one passes for the next block type somebody adds, or fails on it. The
narrow version would have passed for both.
