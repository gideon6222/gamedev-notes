# A fetched texture lands with DEFAULT import settings, so every assets.py get must be followed by fixing the .import

**Game:** wildform  **Date:** 2026-09-13  **Belongs in:** ASSETS.md / fetch-recipe

## What happened
wildform swapped three biome ground textures and one sky HDRI - Lava001, Ground097, Gravel022 from ambientCG and quarry_cloudy from Poly Haven, fetched with scripts/assets.py. They REPLACED four assets of the same kind, which were deleted in the same commit, so the asset count did not change at all. The next export was 39.94 MB against a 33.66 MB budget, +18.63%, and scripts/check.ps1's size guard refused it. The cause was not the textures being bigger. Godot writes an `.import` file per asset the first time it sees one, with DEFAULTS: `compress/mode=0` (lossless, not VRAM), `compress/high_quality=false`, `mipmaps/generate=false`, `process/size_limit=0` (no cap). The settings this studio actually needs are per-file and were hand-set on the ORIGINAL textures months ago, so they did not carry across to the replacements: `compress/mode=2`, `compress/high_quality=true`, `mipmaps/generate=true`, `process/size_limit=512`, plus `compress/normal_map=1` on any normal map. An HDRI wants the same but with `compress/high_quality=false` and `process/size_limit=512` (Godot's own detect pass had left it at 1024). With those five lines patched into each new `.import` and a re-run of `godot --headless --path . --import`, the same four assets exported at 33.77 MB - exactly what the build was before the swap. The imported cache is 19 MB for the whole project at those settings.

## The rule
`assets.py get` fetches the file, it does not configure the import, and Godot's defaults are wrong for a phone game by roughly a factor of six on textures. After every texture or HDRI fetch, set `compress/mode=2`, `compress/high_quality=true` (false for an HDRI), `mipmaps/generate=true`, `process/size_limit=512` and `compress/normal_map=1` on normals, then re-import, and only then measure.

## Replaces or contradicts
nothing
