# Measuring frames on the phone: SurfaceFlinger, not gfxinfo

**Game:** wildform found it, every Godot game inherits it  **Status:** measured on an S26 Ultra
**Read when:** you are about to quote a frame time, a percentile or a janky-frame count for a Godot
game on a phone, or `device.ps1 perf` prints numbers that look too good.

`dumpsys gfxinfo` instruments **HWUI, the Android View hierarchy**. A Godot game draws to its own
`SurfaceView`, so none of its frames pass through the thing being measured. Asked for percentiles
straight after a run that had drawn 2,117 frames, gfxinfo answered:

```
Total frames rendered: 0
Janky frames: 0 (0.00%)
50th percentile: 4950ms   90th percentile: 4950ms   95th percentile: 4950ms
```

`4950ms` is gfxinfo's no-data sentinel and `Janky frames: 0` is what it says about a game it cannot
see at all. **Every frame-time number this studio had ever printed for a Godot game came from here,
and every one of them meant nothing.** The failure mode reads as a pass, which is what made it last:
zero janky frames out of zero frames is the most reassuring output available.

`device.ps1` already carried a hedge - "gfxinfo instruments HWUI; if the frame count is tiny, read
`Engine.get_frames_per_second()` from the game's own log instead" - and it prevented nothing,
because the tool went on printing authoritative-looking percentiles beside it and no game writes FPS
to its log.

## Two takeaways

- **A caution beside a wrong number is not a fix.** Print the right number or print nothing. A
  hedge in a doc cannot compete with a confident figure in the output.
- **A no-data sentinel that looks like data is the worst failure mode a tool can have**, because it
  passes every check written to catch an error. Ask any measuring tool what it prints when it has
  measured nothing, and make your own print that on the last line with a non-zero exit.

## The recipe

```
adb shell dumpsys SurfaceFlinger --timestats -disable -clear
adb shell dumpsys SurfaceFlinger --timestats -enable
# ... play ...
adb shell dumpsys SurfaceFlinger --timestats -dump
adb shell dumpsys SurfaceFlinger --timestats -disable
```

Find the block whose `layerName` contains the package. It gives `totalFrames`, `droppedFrames`,
`jankyFrames`, `averageFPS` and a **present-to-present histogram** - the gap between one frame
reaching the panel and the next, which is the number a player actually feels. Percentiles come off
the histogram cumulatively.

Two traps in getting there:

- **`dumpsys SurfaceFlinger --latency <layer>` is not the answer.** On current Android it returns
  only the refresh period and no frame rows at all. It is superseded by `--timestats`.
- The layer name from `--list` arrives wrapped as `RequestedLayerState{<hex> <name> parentId=...}`.
  The part to pass on is the middle.

## Measured, wildform on a Galaxy S26 Ultra

2,117 frames, **2,115 in the 8 ms bucket and 2 in the 7 ms bucket, zero anywhere else**, 0 dropped,
0 janky, average 125 FPS on a 120 Hz panel. Every percentile is 8 ms. That is a real measurement;
the gfxinfo one was not. `POLISH.md`'s performance gate now requires the numbers to come from here.

## And `-W` never reached adb either

Found in the same session, in the same script. `device.ps1 launch` ran
`Adb shell am start -W -S -n $component` and had **never once worked**: PowerShell binds parameters
before handing anything to the native command, and an unquoted `-W` prefix-matches the common
parameters `-WarningAction` and `-WarningVariable`, so the result is an `AmbiguousParameter` error
against the script itself. Quoting each flag (`'-W'`) makes it a value. **Any adb flag beginning
with w, v, d or c needs the same treatment** (Verbose, Debug, Confirm), and a function taking
`ValueFromRemainingArguments` does not protect you - the binder still tries parameter matching
first. More of the same family in `techniques/powershell-traps-in-the-scripts.md`.
