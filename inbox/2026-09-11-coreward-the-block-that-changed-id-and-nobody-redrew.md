# When state changes a block's ID, something has to tell the renderer

**Game:** Coreward (web, three.js) · **Date:** 2026-09-11 · **Topic:** engine traps

Terrain drawn as `InstancedMesh` pools keyed by block id - every cell of a
given type shares one draw call. Fast, and correct as long as a cell's id only
changes when the world is rebuilt.

Then a monument was added that lights up when the player reaches it:

```ts
return { id: lit ? 'anchorlit' : 'anchor', ... };
```

Lighting it changed nothing on screen. The cell stayed in the `anchor` pool,
because nothing in the streaming system had any reason to think that cell had
moved pools. It redrew several seconds later, when the player crossed a row and
the window rebuilt - so the one thing they were looking at was the one thing
that did not react, and then it changed for no visible reason.

## The rule

**A cell's id is cached the moment it is drawn.** Anything that changes an id
from game state - lit/unlit, opened/sealed, charged/spent - has to force the
redraw itself:

```ts
dropBlock(key(x, d));   // pull the cell out of its old pool
resetBlockCache();
syncBlocks(true);       // rebuild the window
```

A full rebuild rather than hand-moving one instance between pools. Moving one
instance is three more places for the pools to disagree with the world, and
this fires nine times in a whole campaign.

## How to spot the class

Ask of every state change: **does this change what `blockAt` would return for a
cell that is already on screen?** If yes, and the change did not go through the
path that already rebuilds (digging, a collapse, a world change), it needs an
explicit redraw. The symptom is always the same and always looks like something
else: *it works, but only after you move.*
