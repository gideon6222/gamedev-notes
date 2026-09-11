# A skinned mesh does not know how big it is, and four different ways of asking all lied

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `ASSETS.md` under importing models,
and `GODOT.md` under rendering traps.

## What happened

Four imported creature models had to be normalised to a size ladder - 0.95, 1.25, 1.55 and
1.95 units tall - so a stage-4 creature reads as bigger than a stage-1 one. Every automatic
approach printed exactly the right number and drew the wrong picture.

| what was asked | what came out |
|---|---|
| `mi.mesh.get_aabb().size.y * model.scale` | **100x too big.** The mesh sits under an Armature carrying the FBX's centimetre scale, so the mesh's own AABB is a hundredth of what draws. The first screenshot was a 95-unit dinosaur filling the sky. |
| the AABB transformed by the chain from mesh up to model | **40-49% of target**, differing per model. These models are Z-up, so the local Y extent is the model's DEPTH, not its height. |
| `VisualInstance3D.get_aabb()` (skinning-aware) | numbers exactly right, **picture completely unchanged** |
| a re-measure in `_ready`, in-tree, after a frame | numbers exactly right, picture unchanged |

The last two are the interesting ones. Both printed `drawn 0.95 / 1.25 / 1.55 / 1.95` - the
targets, to two decimals - while the render showed a stage-1 creature roughly **four times**
the size of the stage-4 one. Nothing about the pipeline was broken: the right model was
visible, the right scale was applied, and the measurement was self-consistent.

## The rule

**A probe that disagrees with a picture you are looking at is measuring the wrong quantity,
and the picture wins.** The studio already had that rule for camera framing; it is at least
as true for imported geometry.

For a SKINNED mesh, none of the bounds you can ask for describe what the renderer draws:
the resource's AABB is the bind pose, the visual AABB is recomputed from the skeleton and
still does not survive the importer's axis conversion, and both are read through a transform
chain carrying unit scales you did not author.

**So set the scale as a measured constant per model, in the content table, and check it by
looking.** It is one number per asset, it never lies, and it is exactly the kind of tuned
constant every other row of a content table already is.

Give the eye something to check AGAINST rather than "looks right": here it was the collision
width. A stage-4 creature is 1.80 units across against a 4.00 unit band, so it should cover a
little under half the road - and a body drawn wider than the box that gets hit is the usual
way a fair obstacle starts reading as an unfair one.

## Check the pack before you design around it

The same session fetched three Quaternius packs and measured every model for a Run cycle
before choosing:

- **farm animals**: 7 models, only 3 with a Run cycle, and those 3 share one height and one
  silhouette - no ladder in them at all
- **monsters**: 4 models, only 1 with a Run cycle
- **dinosaurs**: 6 models, **all** with a Run cycle, CC0 by its own `License.txt`, silhouettes
  that genuinely differ

A pack's name and its preview say nothing about which models are animated. Twenty lines of
script that instantiate each file and print its animation list and its height is the cheapest
possible way to find out, and it turned a plan built on "monsters" into a plan built on the
one pack that could carry it.

Delete the packs you did not choose in the same commit. Two of these were 11 MB of Blends,
OBJs and preview GIFs that no build would ever have used.

## Replaces or contradicts

Extends `ASSETS.md`'s existing note to "normalise import scale across every pack" - correct,
and it does not say that the scale cannot be computed. It cannot, for skinned meshes. The note
should say: measure it once, by eye, per model, and write it in the table.
