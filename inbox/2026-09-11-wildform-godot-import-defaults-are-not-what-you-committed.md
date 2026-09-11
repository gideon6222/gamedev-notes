# The file Godot loads is not the file you committed, and both defaults cost real money

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `GODOT.md` under rendering and
export, and `ASSETS.md` under import settings.

## Two measurements, one lesson

### 1. WAVs import as QOA, so reading `AudioStreamWAV.data` as PCM is nonsense

A generator wrote nineteen 16-bit mono WAVs. A test loaded each one as an `AudioStreamWAV`
and measured peak amplitude and duration off `w.data`, read as signed 16-bit frames.

Every duration came back at **about a fifth of the truth** - a 1.30 s fanfare measured
0.26 s - and the amplitudes were meaningless. Godot 4 imports WAVs with `compress/mode=2`,
which is **QOA**, so `data` holds compressed bytes. The "not silent" assertions had been
passing on compressed noise.

**The rule: measure the generator's artefact where the generator put it.** Read the file on
disk with `FileAccess`, parse the RIFF chunks, and measure the PCM. Then assert SEPARATELY
that the imported resource still matches - `AudioStreamWAV.get_length()` against the disk
duration, and `mix_rate` against the header - which is what catches a compression change, a
forced mono, a trim or a resample. Lengths, not samples, because the samples are compressed.

### 2. 1K textures import LOSSLESS with no mipmaps, at 1.33 MB each per format

Four biomes of ambientCG ground (Color, NormalGL, Roughness at 1K JPG) plus three Poly Haven
HDRIs took the APK from 28.9 MB to **42.4 MB, +57%**, and the size guard refused the build.

The source JPGs are about 1 MB each and look harmless. The IMPORTED textures are what ship,
and Godot's default for a plain texture is `compress/mode=0` - lossless - with
`mipmaps/generate=false`. Each 1024x1024 landed at **1.33 MB, and Godot generates both an
`astc` and a `bptc` variant**, so the imported folder was 34 MB for twelve textures.

What fixed it, in order of how much each was worth:

| change | effect |
|---|---|
| `compress/mode=2` (VRAM) + `mipmaps/generate=true` | the format a phone GPU actually samples |
| `process/size_limit=512` on ground textures | a quarter of the pixels, invisible at a grazing angle from 9 m |
| **deleting the roughness maps entirely** | one stylised roughness value; 1.33 MB per biome for a variation nothing reads |
| `process/size_limit=512` on HDRIs | plenty for a panorama behind a runner |

Imported set: 34 MB to **7.2 MB**. Final APK 30.8 MB, and the growth that remained was real
content, so the budget was re-recorded rather than the content trimmed.

Mipmaps are not optional on ground seen at a grazing angle from a chase camera - without them
it shimmers at distance, which reads as a rendering fault rather than as a setting.

## The rule

**An import setting is a file nobody reads, and its default is tuned for a desktop editor
rather than for your game.** After fetching any asset, set the import options explicitly and
in bulk, then re-import and MEASURE `.godot/imported`. The source file's size tells you
nothing about what ships.

And more generally: **verify the artefact the engine loads, not the artefact you wrote.**
Both of these bugs are the same shape - a file was fine, a default transformed it, and
everything downstream was measuring the transformation while believing it was measuring the
file.

## Replaces or contradicts

Extends `ASSETS.md`'s existing note that HDRIs want `compress/mode=2` and
`process/size_limit=512`. That note was right and was not enough: the same discipline is
needed for every texture, and the roughness map is usually the first thing that should go.
