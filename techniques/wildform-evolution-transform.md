# Wildform's evolution transform: swapping one creature for another, and measuring the swap

**Game:** Wildform (Godot 4.7) · **Status:** shipped · **Read when:** a character has to visibly BECOME something else; reaching for blend shapes to morph between two authored models; any animation whose length is set by a loop over a collection

Wildform's whole mechanic is a creature that evolves through four stages, so the moment of change
is the moment the game is about. The obvious implementation does not exist in the engine, and the
implementation that replaced it shipped with its duration eight times longer than its constants
said, because nothing headless ticks a `Tween` and the obvious test passes on the bug.

**Generalisable takeaways**

- **Blend shapes interpolate WITHIN one mesh resource.** To change what a character IS, hide the
  swap instead of interpolating it.
- **An animation's length must not be a property of how much content the game has.** Tween ONE
  value and fan it out where the collection is already written per frame.
- **Assert the MEASURED length, not the constants.** `Tween.custom_step(delta)` drives a tween
  with no running `SceneTree`, so the real duration is a pure test.

---

## Godot blend shapes cannot morph one creature into a different creature

Not "badly", not "with artefacts" - at all. `set_blend_shape_value` interpolates **vertex deltas
within one mesh resource**, so a blend-shape target has to share vertex count and topology with
its base. Two separately authored glTF models never do, and there is no import setting, retopology
pass or runtime call that makes them.

The research is unanimous the other way too: the commercial games that do this convincingly do not
morph either. Pokemon's own evolution lines change silhouette drastically (Charmander to
Charizard), and what stays continuous is the palette and one signature feature, never the topology.
`ASSETS.md` records the same finding from the asset side - there is no free rigged growth line of
one creature identity anywhere, so a game that needs visible growth stages is committing to curate
a trio of separate models.

**So hide the swap instead of interpolating it.** The sequence that reads as a transformation:

| beat | what happens | length |
|---|---|---|
| dissolve out | noise-threshold dissolve on the old mesh | 0.3 s |
| flash | a white flash over the instant of the swap | the instant |
| reform | the same dissolve running backwards on the new mesh | 0.3 s |

Two details decide whether it reads:

- **Both forms are frozen at a matching rest pose**, or the creature pops under the flash: the old
  mesh is mid-run-cycle, the new one starts at frame zero, and the eye catches the jump even
  through a white frame.
- The flash is over **the instant**, not over the dissolve. A flash held across the whole
  transition is a white screen, and a white screen is not a transformation, it is a loading
  screen.

`GPUParticles3D` is the obvious way to garnish the moment and **draws nothing on the Compatibility
renderer** - it needs compute shaders and logs no error. Mobile, which is the default here, is fine.

---

## The tween whose length was a property of the content table

The transform was written as `tween_property` calls inside a loop over the creature's materials,
one call per material, so the old mesh's dissolve would drive every surface.

**Tweeners added to a plain `Tween` run one after another.** The loop therefore did not set up one
0.56 s animation on sixteen materials; it set up sixteen animations back to back. One shared
material had become sixteen duplicates on import, so Wildform's 0.56 s transform ran for
**8.96 s** (M) - **5.08 s of it the white flash held at peak** - three times in a 75 second run,
with every constant in the source unchanged and correct.

The shape of the bug is worth more than the instance: **a `tween_property` inside a loop over a
collection makes the animation's length a property of how much content the game has.** It is
invisible in review, it gets worse as the game grows, and the number in the source is right the
whole time. **Tween ONE value and fan it out** where the collection is already being written per
frame - the materials are updated every frame anyway, so one `t` drives all sixteen.

### Why the obvious test passes on the bug

The obvious test is: advance a second, assert the flash is down. It passes on the bug, because a
**headless harness ticks no `Tween` at all** - nothing raised the flash either, so "the flash is
down" is true for the wrong reason. That is the standard failure from `INDEX.md` rule 11: a check
that passes because nothing happened.

`Tween.custom_step(delta)` drives a tween with **no running `SceneTree`** and returns `false` when
it finishes, which turns the duration into a pure measurement:

```gdscript
var t := main.begin_transform()      # return the tween so this is possible
var elapsed := 0.0
while t.custom_step(1.0 / 60.0):
    elapsed += 1.0 / 60.0
assert(elapsed < 1.0)                # 8.97 on the bug, 0.56 after
```

Returning the tween from the method that starts it is the whole enabling change, and it costs one
line. **Assert the measured length, never the constants** - the constants were never wrong.
