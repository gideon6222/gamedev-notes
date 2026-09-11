# When a 3D object "isn't rendering", check the HUD before the shader

**Game:** Coreward (web, three.js) · **Date:** 2026-09-11 · **Topic:** engine traps, testing

A new building was placed beside the player's landing pad and did not appear.
Twenty minutes went into shader theories - was the custom light injection
returning zero above ground, had `onBeforeCompile` failed silently, was the
material black against a black sky - before the arithmetic got done.

The object was rendering perfectly. It was behind four opaque HUD buttons.

## The arithmetic, which takes thirty seconds

```
halfHeight = distance * tan(fov / 2)
halfWidth  = halfHeight * aspect
screenFrac = 0.5 + (objectX - cameraX) / (2 * halfWidth)
```

Camera 17.7 units back, 52 degree vertical fov, 0.46 aspect (portrait phone):
the visible world is about eight units across. The object at x = -2.2 sat at 24%
across, and the action-button column occupies 16-32% of a portrait screen.

## The diagnostic order that would have been faster

1. **Is it in the scene, visible, and in the frustum?** Walk `scene.children`,
   print positions and `visible`, project the object's `Box3` centre with
   `.project(camera)` and check `z < 1`. Two minutes, and it told me the object
   was fine.
2. **Does the console have a shader error?** It did not - so the material
   compiled, and every theory about the shader was already dead.
3. **Then it is occlusion**, and on a phone the occluder is usually the HUD.

Step 1 said "in frame at screen (287, 366)" and I still went looking at
shaders, because "I cannot see it" felt like a rendering problem. It was a
LAYOUT problem, and the HUD is not in the 3D scene so nothing in the 3D
debugging toolkit can see it.

## The design lesson underneath

On a portrait phone the left column is usually action buttons and the bottom is
usually a d-pad and gauges. **The largest clear area is upper-right.** Anything
that has to be looked at while docked or standing still belongs there, and
"where the last thing stood" is not a reason - the last thing may have been
just as hidden and nobody noticed because it carried no information.

## And a cheaper way to have caught it

The screenshot that "proved" it was missing had the camera somewhere else
entirely - the fixture had flown the ship across the world and never brought it
back. **A look-pass fixture that positions the camera by playing the game can
fail to position the camera.** Assert the thing you are photographing is in
frame before you judge the photograph.
