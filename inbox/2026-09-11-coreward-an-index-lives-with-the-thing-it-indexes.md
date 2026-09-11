# An index lives in the same module as the list it indexes

**Game:** Coreward (web, three.js) · **Date:** 2026-09-11 · **Topic:** engine traps, testing

A saved list grows to a couple of thousand entries and is asked "do you already
contain this" several times a second. `Array.includes` there is quadratic, so it
gets a `Set` mirror. Obvious enough.

The mistake was putting the `Set` in the module that ASKS the question (the
frame loop) rather than the module that OWNS the list (the save/state module).

`load()` does `g.seen = saved.slice()` - it replaces the list wholesale. An index
built in another module has no way to know that happened. It keeps answering
questions about the previous save, so after a reload every new entry looks like
one it already has and nothing is ever written again.

## The rule

**One writer per phase, one source of truth per fact** applies to derived
indexes too. Put the index beside the data, export a `mark()` that writes both
and a `reset()` that rebuilds, and call `reset()` from every path that replaces
the list wholesale - load, hard reset, new game.

```ts
let seenSet = new Set<string>();
export function resetSeen() { seenSet = new Set(g.seen); }
export function markSeen(keys: string[]) {
  for (const k of keys) if (!seenSet.has(k)) { seenSet.add(k); g.seen.push(k); }
}
```

Keeping it local also broke a dependency: the reset had to be callable from the
wipe path, and the wipe path importing the frame loop would have been a cycle.

## The test that holds it

Replace the list, rebuild, and assert a previously-unknown key is stored:

```js
g.seen = ['9,9'];
resetSeen();
markSeen(['1,1', '9,9']);
assert.deepEqual(g.seen.sort(), ['1,1', '9,9']);
```

Verified by making `resetSeen()` a no-op - it fails.

## Found alongside it

The same sweep found that the game's "wipe everything" button had never wiped
three discovery lists. It zeroed the upgrade tiers, so the found devices came
back at tier zero and stayed on the shop's shelf: a fresh save that had already
done the finding. **When adding a field to a save, grep the reset path, not just
the load path.** A `SaveState` interface will not tell you that one of them was
forgotten.
