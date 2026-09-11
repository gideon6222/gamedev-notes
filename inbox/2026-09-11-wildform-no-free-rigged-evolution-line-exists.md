# No free source ships an evolution line, and that decides a milestone rather than an import

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `ASSETS.md` under the misses /
"what does not exist free".

## What happened

Wildform's whole failure mechanic is that the creature visibly grows and shrinks through
evolution stages, so it needed **one creature identity at three or more growth stages on a
shared rig**. Searched, with the fixed kaykit endpoint and against working controls:

| Source | Result |
|---|---|
| KayKit | 10 repos, **zero creature or monster packs** (humans, skeletons, buildings, furniture) |
| Kenney | **no animal, creature or monster pack at all** across 16 3D packs; `cube-pets` is a static voxel prop |
| Quaternius | three rigged, animated packs with run cycles (`lowpoly-animated-monsters`, `lowpoly-animated-animals`, `animated-lowpoly-dinosaurs`) - each **a bag of unrelated creatures**, never a growth line |
| Poly Pizza | surfaces individual Quaternius models; **animation retention through their export is not guaranteed** and must be checked per model |

So: plenty of rigged creatures, no designed line. Nothing to fetch.

## The rule

**A game that needs visible growth stages of one identity is committing to curate or build
them, and that belongs in the milestone list before the plan is approved, not in the asset
hunt afterwards.** The workable free route is a curated trio of separate CC0 creatures
chosen by silhouette and unified by four things that are all cheap:

1. one palette per line,
2. one signature accessory carried across all stages,
3. **a normalised import scale across every pack**, so a size-based stage is a decision the
   game makes rather than an accident of which pack a mesh came from,
4. a dissolve transform hiding the swap (see the blend-shape lesson from the same day).

And the reason this is defensible rather than a compromise, worth writing down because it
will be questioned: **Pokemon's own lines change silhouette drastically** (Charmander to
Charizard, Magikarp to Gyarados). A changing body reads as correct for this genre. The thing
that must stay continuous is the palette and one signature feature, not the topology.

Also confirmed absent, against working controls (`forest`, `desert`, `beach` all returned
rich results in the same call shape): **no volcano or lava HDRI on Poly Haven, and no lava,
basalt or obsidian material on ambientCG.** A volcanic sky is a `ProceduralSkyMaterial` and
lava cracks are an emissive shader over a dark rock base. Both are code, not imports.

## Replaces or contradicts

Nothing. Adds to the existing `ASSETS.md` misses list (which already records that ambientCG
has no water, liquid or ripple material).
