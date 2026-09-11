# A test that re-derives the rule it is testing passes with the rule deleted

**Game:** Coreward (web, three.js) · **Date:** 2026-09-11 · **Topic:** testing

Placing hand-authored rooms into a generated world. The placer drops any room
that would overlap one already placed:

```ts
if (out.some((t) => Math.abs(t.x - s.x) < ROOM_W && Math.abs(t.d - s.d) < ROOM_H)) continue;
```

The test I wrote for it:

```js
// walk the same slots, apply the same drop rule, then assert nothing overlaps
const boxes = [...anchors];
for (const s of slots) {
  if (boxes.some(sameRuleAsAbove)) continue;   // <-- the bug
  boxes.push(s);
}
for (each pair) assert(noOverlap);
```

Deleting the drop rule from the source left this green. Of course it did: the
test builds its own list using the same filter and then checks the filter
worked. It never looks at the world.

## The fix: make the decision reportable, then check the OUTPUT

Split the placement from the stamping, and export the placement:

```ts
export function roomPlan(): Placed[]   // what is actually in the world
export function roomCells(): Map<...>  // built from roomPlan()
```

Now two assertions that cannot be satisfied by the code merely being
self-consistent:

1. **every room on the plan is stamped cell-for-cell as its template says** - a
   room that was overwritten loses cells and fails
2. **no two rooms on the plan overlap** - with the drop removed, the plan
   itself contains the overlap

Both read output. Both went red on the mutation.

## And the rewrite had its own bug, which is the point

The first version of (1) identified "was this room placed" by whether the
room's centre cell was stamped. That is ALSO true of a room that was dropped -
because the room it collided with covers that cell. It reported a room that
does not exist as having lost its walls.

**A derived predicate is the same trap one level down.** The only reliable
answer to "what did the code decide" is to have the code say so.

## The smell to look for

If a test contains a copy of a condition from the source, it is probably
testing that the copy matches, not that the behaviour is right. Ask: *could
this test be satisfied by the feature being absent, as long as both sides agree
it is absent?*
