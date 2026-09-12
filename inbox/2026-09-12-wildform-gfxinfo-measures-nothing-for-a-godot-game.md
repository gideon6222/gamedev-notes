# `dumpsys gfxinfo` measures nothing for a Godot game, and reports a confident zero rather than an error

**Game:** wildform  **Date:** 2026-09-12  **Belongs in:** `TESTING.md` under the phone run, and
`GODOT.md` under the Android toolchain.

## What happened

The first time a phone was actually plugged in for this game, `scripts\device.ps1 perf` - which
every game inherits from the template - was asked for frame-time percentiles. It reported:

```
Total frames rendered: 0
Janky frames: 0 (0.00%)
50th percentile: 4950ms   90th percentile: 4950ms   95th percentile: 4950ms
```

straight after a run that had just drawn **2,117 frames**. `4950ms` is gfxinfo's no-data
sentinel, and `Janky frames: 0` is what it says about a game it cannot see at all.

**`dumpsys gfxinfo` instruments HWUI - the Android View hierarchy.** A Godot game draws to its
own `SurfaceView`, so none of its frames pass through the thing being measured. Every
frame-time number this studio has ever printed for a Godot game came from this, and every one
of them meant nothing. Worse, the failure mode reads as a pass: zero janky frames out of zero
frames is the most reassuring possible output.

## The rule

**Measure a Godot game's frames with SurfaceFlinger, not gfxinfo.**

```
adb shell dumpsys SurfaceFlinger --timestats -disable -clear
adb shell dumpsys SurfaceFlinger --timestats -enable
# ... play ...
adb shell dumpsys SurfaceFlinger --timestats -dump
adb shell dumpsys SurfaceFlinger --timestats -disable
```

Find the block whose `layerName` contains the package. It gives `totalFrames`,
`droppedFrames`, `jankyFrames`, `averageFPS` and a **present-to-present histogram** - the gap
between one frame reaching the panel and the next, which is the number a player actually
feels. Percentiles come off the histogram cumulatively.

Wildform on a Galaxy S26 Ultra, measured this way: 2,117 frames, **2,115 in the 8 ms bucket and
2 in the 7 ms bucket, zero anywhere else**, 0 dropped, 0 janky, average 125 FPS on a 120 Hz
panel. Every percentile is 8 ms. That is a real measurement; the gfxinfo one was not.

**`dumpsys SurfaceFlinger --latency <layer>` is not the answer** - it returns only the refresh
period on current Android and no frame rows at all. It is superseded by `--timestats`.

And the layer name from `--list` arrives wrapped as `RequestedLayerState{<hex> <name>
parentId=...}`; the part to pass on is the middle.

## The other half: `-W` never reached adb either

`device.ps1 launch` ran `Adb shell am start -W -S -n $component` and had **never once worked**.
PowerShell binds parameters before handing anything to the native command, and an unquoted
`-W` prefix-matches the common parameters `-WarningAction` and `-WarningVariable`: the result
is an `AmbiguousParameter` error against the script itself. Quoting each flag (`'-W'`) makes it
a value. **Any adb flag beginning with w, v, d or c needs the same treatment** (Verbose, Debug,
Confirm), and a function taking `ValueFromRemainingArguments` does not protect you - the binder
still tries parameter matching first.

## Replaces or contradicts

`device.ps1` already carried a hedge - *"gfxinfo instruments HWUI; if the frame count is tiny,
read `Engine.get_frames_per_second()` from the game's own log instead"*. That was correct and
it prevented nothing, because the tool went on printing authoritative-looking percentiles
beside it and no game writes FPS to its log. A caution next to a wrong number is not a fix;
print the right number or print nothing.
