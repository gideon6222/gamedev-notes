# three.js / WebGL / DOM traps from the web-stack games

**Game:** Coreward, Captain Run, Wick, Candle Gift (web / PWA builds) · **Status:** shipped; Coreward and Candle Gift are live on GitHub Pages · **Read when:** working on a three.js or browser build; porting a web-stack lesson to Godot and wondering whether it still applies; a draw-call budget, a rotation, a chase camera, browser scheduling or storage

The first four games were built on Vite, TypeScript and pinned three.js, installed as PWAs
from GitHub Pages. Most of the lessons in `CRAFT.md`'s "Graphics that carry on a phone" and
"Traps that have cost time more than once" sections are specific to that stack: three.js
defaults, WebGL's silent failures, and browser scheduling and storage. New games start on
Godot, where several of these traps do not exist and one of them (`Object3D.layers` and
lights) is exactly backwards. This is the reference list, kept so a web session does not
rediscover them and a Godot session does not import them by mistake. Each entry is the
original text followed by the one lesson that survives the API. This file is the entry point
and holds the draw-call arithmetic, rotation order, cameras and coordinates, and the browser
and DOM traps; the other two thirds were split out on 2026-09-12 when it went over the 30 KB
limit:

- **`three-js-renders-as-nothing.md`** - things that render as nothing: z-order occluders,
  `PlaneGeometry` facing, uniforms declared and never supplied, `onBeforeCompile` chaining and
  `Material.clone()`, an additive mesh inside an opaque one, and the HUD occlusion arithmetic.
- **`three-js-materials-and-lights.md`** - the surface half: the CSS sky against
  `EffectComposer`, `MeshStandardMaterial` and metals, PMREM environment maps and `colorSpace`,
  `MeshToonMaterial` and inverted-hull outlines, `FogExp2`, world-space normal maps and
  displacement, and `Object3D.layers` not filtering lights (backwards in Godot).

**Generalisable takeaways**

- **Enumerate the defaults you never set.** A missing uniform, a plane facing the wrong way, a
  texture read in the wrong colour space, a rotation composed in the wrong order - none of
  these errors; they render as nothing, as too bright, or as half a feature. The first two of
  those live in `three-js-renders-as-nothing.md` and the third in
  `three-js-materials-and-lights.md`; the rotation is here.
- **Assert against the frame and the compiled artefact, not the object you configured.** Drive
  real pointer events and check where the avatar is in normalised device coordinates; count what
  the renderer actually drew, with `renderer.info.autoReset` off if you render twice; read the
  shader back out of WebGL.
- **Budgets measured on one renderer are regression detectors, not hardware limits.** Draw
  calls were 5.0 us each on a desktop; fill rate and thermal throttling are what a phone
  charges for.

---

## Instancing and per-instance data

**Instancing is the whole game** — but not for the reason usually given. Coreward went from 207
draw calls to 35 by instancing terrain; Captain Run draws 26 vikings, 18 draugr, a boss, 420 loot
chunks and all scenery in 42–55 calls. What instancing actually buys is that **the draw count
stops being a function of how much content exists**, which is what keeps it from drifting as a
game grows.

**The "50 to 100 draw calls on mobile" rule of thumb is off by more than an order of magnitude,
and it is worth knowing that before designing around it.** Measured on Coreward: 5.0 microseconds
per call, linear from 79 to 2,519 calls, so about 3,200 calls to miss 60 fps on a desktop and the
high hundreds at worst on a phone. The game uses 60. A budget set at that guideline is a
regression detector wearing a hardware limit's clothes — useful, but do not let it talk you out of
a feature. **Fill rate is the real cost on a phone**, because that is what a heavier shader
charges and what feeds thermal throttling: Coreward's PBR terrain cost 0.098 ms/frame at an
unchanged draw count, which is more than a hundred extra draw calls would have.

*General lesson:* the draw count must not be a function of how much content exists. Godot's equivalent is `MultiMeshInstance3D`, and `visible_instance_count` is the number to assert a render path against. The 5.0 us/call figure was measured in WebGL on a desktop; the phone figure is inferred, and fill rate is the real mobile cost.

---

**Instance the body parts, not the character.** One `InstancedMesh` per part — leg, torso, arm,
head, helmet, weapon, shadow — with matrices recomputed each frame from a procedural animation
cycle. Crowd size then stops being a performance question at all, and a boss is the same rig at
3.3× with a different colour: a whole boss for zero extra draw calls.

**Instance the bolt-on hardware too, not just the crowd.** Coreward's upgrade parts started as
thirteen separate meshes and took the worst case from 55 draw calls to 67 against a budget of 70 —
three from failing CI, for what is four copies of two shapes. One `InstancedMesh` per KIND with
`count` as the lever is exactly the semantics an upgrade ladder wants (show the first n), and it
stops the draw count moving with how upgraded the player is, which is otherwise a budget that
fails only for veterans.

*General lesson:* one instanced mesh per KIND with `count` as the lever is the semantics an upgrade ladder or a crowd wants; a draw-call budget that only fails for veterans is not a budget.

---

**`setColorAt` is what makes one layer look like many objects.** Per-instance colour over a white
base material gives every unit its own cloak and shield, and drives a weapon's colour straight
from its tier — all from a single mesh.

**Per-instance data can never fade across a boundary.** Learned twice on Coreward: seams between
cells, then glow that stopped dead at a cell edge. If an effect has to be continuous across the
world, it belongs in a shader keyed on world position, not in instance data.

*General lesson:* per-instance data cannot fade across an instance boundary; anything continuous across the world belongs in a shader keyed on world position.

---

**A cell's id is cached the moment it is drawn, so state that changes an id has to force the
redraw itself.** Coreward's terrain is `InstancedMesh` pools keyed by block id - every cell of a
given type shares one draw call - which is correct for as long as a cell's id only changes when
the world is rebuilt. Then a monument was added that lights up when the player reaches it:

```ts
return { id: lit ? 'anchorlit' : 'anchor', ... };
```

Lighting it changed nothing on screen. The cell stayed in the `anchor` pool, because nothing in
the streaming system had any reason to think that cell had moved pools. It redrew several seconds
later, when the player crossed a row and the window rebuilt — so the one thing they were looking
at was the one thing that did not react, and then it changed for no visible reason.

The fix is a full rebuild of the window, not hand-moving one instance between pools:

```ts
dropBlock(key(x, d));   // pull the cell out of its old pool
resetBlockCache();
syncBlocks(true);       // rebuild the window
```

Moving one instance is three more places for the pools to disagree with the world, and this fires
nine times in a whole campaign. **The question to ask of every state change is: does this change
what `blockAt` would return for a cell that is already on screen?** If yes, and the change did not
go through a path that already rebuilds (digging, a collapse, a world change), it needs an
explicit redraw.

*General lesson:* any render cache keyed on a derived value — an instance pool, an atlas slot, a material bucket — is a second copy of that value, and the writer of the source has to invalidate it. The symptom is always the same and always looks like something else: *it works, but only after you move.*

---

## Rotation order

**Two rotations on one object compose in an order, and the default is rarely the one you
want.** Coreward's ship carried its facing on `rotation.z` and its bank on `rotation.y`. Under
three.js's default `XYZ` the facing composes first and the bank then turns the already-turned
ship about the **world** vertical - a roll about the drill when pointing down, which is right,
and a swing of the nose toward the camera when pointing sideways, which reads as the ship
flipping out of the screen plane. `rotation.order = 'ZYX'` composes the other way, so the bank
applies in the ship's own frame and the facing turns the result: a roll in every facing. One
line, and it is worth checking the moment a second rotation is added to anything.

**A bank must read off the lateral axis in the object's own frame.** The same bug had a second
half: it was driven by `vx` regardless of which way the ship pointed, so flying left or right
banked the ship for going *fast* rather than for going sideways. Whichever axis the object is
not pointing along is the one that means "drifting".

*General lesson:* two rotations compose in an order; check it the moment a second rotation is added to anything. Godot's `Node3D.rotation_order` defaults to YXZ, so the fix is different but the check is the same. And a bank must read off the lateral axis in the object's own frame.

---

## Cameras and coordinates

**A chase camera behind the player, looking along +z, mirrors the x axis - and it will invert
your controls.** Putting the camera at a *lower* z than everything it looks at is a 180-degree
rotation about Y, so world +x projects to screen LEFT. Measured in Wick: world +2 lands at NDC
-0.31. Mapping a rightward drag to increasing x - the obvious thing - therefore moves the
avatar the wrong way.

Captain Run shipped with this for its entire life and nobody noticed, which is the part worth
remembering: **every test drove the steering seam in world coordinates, which is exactly the
layer the bug lives under.** A test that says "steer(1.5) put x at 1.5" passes happily on
inverted controls. The only thing that catches it is driving real pointer events and then
asking where the avatar *is in the frame*, in normalised device coordinates. Every game with a
chase camera needs that one test.

Either move the player along -z so the camera keeps its default orientation, or flip the sign
where the drag meets the world and comment it loudly. Do not "fix" it later by flipping
something else as well.

**Take the first option.** Wrecking Crew draws the street along -Z while the simulation
counts distance upward, through one `wz()` helper called everywhere, so the camera is never
turned around and screen right IS world +X by construction - no sign flip anywhere near the
input. A flipped sign is a fact that has to stay true through every future change to the
camera; an axis convention is one that cannot come apart. Keep the NDC test either way, and
**verify it by turning the camera around and watching it fail** - it should name the
consequence ("a rightward drag will move the rig the wrong way"), not the geometry.

*General lesson:* every game with a chase camera needs one test that drives real pointer events and asserts where the avatar lands in normalised device coordinates. Prefer an axis convention (draw along -z) to a sign flip. Godot's camera looks along -z by default, so the trap is inverted there but the test is the same.

---

**A raycast reads world matrices, and those are only refreshed by a render.** Tap something in the
same tick a 3D screen opens — before it has ever been drawn — and every object is still at the
identity matrix, so the ray misses everything and the tap silently does nothing. It starts working
the instant one frame has gone by, which means it reproduces on a fast tap and nowhere else. Call
`updateMatrixWorld(true)` at the top of the pick.

*General lesson:* world matrices are only refreshed by a render; refresh before a pick. Godot's `global_transform` outside the tree returns identity rather than erroring, which is the same trap with a quieter symptom.

---

## Browser scheduling, storage and arithmetic

**Use `requestAnimationFrame` to draw, never to undo.** Anything that reverses itself on the next
frame sticks forever if the tab is hidden at that moment. An impact flash cleared from a rAF
callback stayed at 0.75 opacity over the whole UI — a "the CSS is wrong" symptom with a scheduling
cause. `setTimeout(..., 20)` instead.

*General lesson:* never schedule an undo on a frame callback; a hidden tab stops frames and the undo never comes.

---

**Ship a headless tick seam.** Split the loop into `frame(now)`, which computes dt and calls rAF,
and `tick(dt)`, which does everything else — then expose `tick` behind a `?debug` query param. A
whole run compresses into `advance(56)` plus a screenshot, deterministically and faster than real
time. It costs one `if`, and every balance number in Captain Run was set that way.

*General lesson:* split `frame(now)` from `tick(dt)` and expose the tick; this is the seam every balance number and every screenshot tool depends on, on both stacks.

---

**`localStorage.clear()` plus a reload does not clear anything** if the game saves on
`visibilitychange` — the outgoing page writes it straight back. Freeze `Storage.prototype.setItem`
first. Three sessions, three times.

*General lesson:* a game that saves on `visibilitychange` writes over any seed you plant; freeze `Storage.prototype.setItem` first.

---

Two follow-ons worth having in advance. **A 32-bit multiply needs `Math.imul`**: `x * 374761393`
is ~2^62, past what a double holds exactly, so the low bits a later xor-shift mixes down are
rounded away before use. And **balance tuned against a broken random source is tuned against a

*General lesson:* JavaScript numbers are doubles; a 32-bit hash multiply needs `Math.imul`. GDScript ints are 64-bit and do not have this problem. Test the random source itself.

---

- Chrome **refuses to create an `AudioContext` outside a user gesture**. Build the graph on
  first touch, and build it atomically — publish the whole graph or none of it, so one null
  check narrows everything.

*General lesson:* build the audio graph on the first gesture, atomically.

---

## DOM

**One scroll region per screen.** Giving an inner list its own `overflow-y` inside a flex column
quietly clips it at the fold — an entire category looked like it held one item, and another looked
like it did not exist.

*General lesson:* one scroll region per screen; Godot's `ScrollContainer` has its own failure (it does not scroll from a finger - see `GODOT.md`).

---

**For analog gauges in the DOM, use SVG and `pathLength="100"`.** It renormalises a path so its
length is exactly 100 regardless of the real geometry, so "show 62 per cent" is
`stroke-dasharray: 62 100` and nothing needs to know the radius. Needles are one transform
each. It stays crisp at any pixel density with no redraw, and the drawn fraction is directly
readable from a test - which is what lets an assertion follow a value from a bar to a dial
without becoming a lie.

*General lesson:* an analog gauge should expose its drawn fraction to a test; on Godot that is `_draw()` and a value on the node.

---

## The preview server serves the previous build

(From `archive/PIPELINE-2026-09-09.md`.)

- **`npm run preview` serves the service worker, so a driven browser can test the build BEFORE
  the one you just made.** The PWA registers its worker on the first visit and then answers
  navigations from cache, so a rebuild is one load behind - and unlike the phone, where this is
  expected and the build stamp is checked, nothing prompts you to doubt it locally. It cost an
  hour: a fix was verified as "still broken", diagnosed as a wrong diagnosis, and was actually
  correct all along. **Check the hashed filename, not the behaviour**, and clear it before
  trusting anything:
  ```js
  [...document.querySelectorAll('script[src]')].map(s => s.src.split('/').pop())
  // then, to start clean:
  for (const r of await navigator.serviceWorker.getRegistrations()) await r.unregister();
  for (const k of await caches.keys()) await caches.delete(k);
  ```
  A test suite is immune - Playwright gives each test a fresh context - which is exactly why the
  suite disagreed with the browser and the browser was wrong.

*General lesson:* check the hashed filename, not the behaviour, before trusting a locally served PWA build.

---
