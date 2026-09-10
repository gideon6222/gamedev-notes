# Letting an AI coding agent test-play Godot 4.7 games (desktop + Android via adb)

Research date: 2026-09-10. Target: solo dev, Godot 4.7, Windows PC, Samsung S26 Ultra over USB/adb, Claude Code as the agent (can run shell commands and read image files, cannot watch a live window).

Legend: **VERIFIED** = read in official docs / engine source / the project's own README during this research. **UNVERIFIED** = from secondary sources, memory, or inferred; test before relying on it.

---

## 0. TL;DR - the practical loop that works for an agent

1. **Desktop, deterministic, image-based** (best signal per unit effort):
   `godot --path . --write-movie out/run.png --fixed-fps 60 --quit-after 600 --resolution 460x996 -- --replay=res://tests/replays/level1.json`
   -> 600 PNG frames at a fixed timestep; an autoload harness reads the `--replay=` user arg and feeds recorded/scripted `InputEventScreenTouch`/`Drag` via `get_viewport().push_input(ev, true)`; then `ffmpeg ... tile=6x5` makes contact sheets Claude can read. **VERIFIED** for every flag; harness pattern **VERIFIED** at API level (see section 2).
2. **Headless logic tests**: gdUnit4 v6.2.x or GUT 9.7.1 (both explicitly support 4.7) with real exit codes. **VERIFIED**.
3. **On device**: `adb install -r`, launch via the `GodotAppLauncher` alias, `adb logcat -s godot`, `adb exec-out screencap -p > shot.png`, `adb shell screenrecord --time-limit 30`, `adb shell dumpsys gfxinfo <pkg>` for frame-time percentiles, `adb shell dumpsys thermalservice` for throttling. **VERIFIED** except where marked.
4. **Emulator**: possible from cmdline-tools alone, but for Godot's Vulkan "mobile" renderer it is a poor proxy; a desktop run at phone aspect with `Input.emulate_touch_from_mouse = true` plus the real phone is the better pair. **Mostly VERIFIED**.

---

## 1. Godot Movie Maker mode (offline, deterministic frame capture)

### Flags (all VERIFIED from the command-line tutorial and `main/main.cpp`)

| Flag | Meaning (doc text) |
|---|---|
| `--write-movie <file>` | "Run the engine in a way that a movie is written (usually with .avi or .png extension)." Path is **relative to the project folder**, not cwd. |
| `--fixed-fps <fps>` | "Force a fixed number of frames per second. This setting disables real-time synchronization." |
| `--disable-vsync` | "Forces disabling of vertical synchronization, even if enabled in the project settings. Does not override driver-level V-Sync enforcement." |
| `--quit-after <int>` | "Quit after the given number of iterations. Set to 0 to disable." (the movie doc calls this "the number of frames to render before quitting") |
| `--resolution <W>x<H>` | "Request window resolution." Only affects output size in `disabled`/`canvas_items` stretch modes; window size is clamped to the display. |
| `--frame-delay <ms>` | "Simulate high CPU load (delay each frame by <ms> milliseconds). Do not use as a FPS limiter; use `--max-fps` instead." |
| `--time-scale <scale>` | "Force time scale (higher values are faster, 1.0 is normal speed)." |
| `--max-fps <fps>` | "Set a maximum number of frames per second rendered." |
| `--print-fps` | "Print the frames per second to the stdout." |
| `--`, `++` | "Separator for user-provided arguments. Following arguments are not used by the engine, but can be read from `OS.get_cmdline_user_args()`." |

Source-level facts (VERIFIED in `main/main.cpp`, master):
- `--write-movie` sets `fixed_fps = 60` if `--fixed-fps` was not given, sets `OS::_writing_movie = true`, and **forces the Dummy audio driver** (audio goes to the file, not the speakers).
- When `fixed_fps != -1` the main loop skips the frame-delay/sleep path, so the run goes as fast as the machine can render; simulation `delta` is constant. That is what makes a scripted input sequence reproducible.
- `--write-movie` and `--fixed-fps` are "both available in exported projects" (doc note), so an exported Windows build can also record.

### Output formats (VERIFIED, docs "Creating movies")
- **`.ogv`** (Theora/Vorbis) - recommended by docs; editor builds only.
- **`.avi`** (MJPEG + uncompressed audio) - 4 GB cap.
- **`.png` sequence + `.wav`** - **yes, PNG-sequence output is supported.** "If you specify an output path `folder/example.png`, Godot will write `folder/example00000000.png`, `folder/example00000001.png`, and so on... The audio will be saved at `folder/example.wav`." Always 8 zero-padded digits starting at 0. This is the ideal format for an agent that reads image files.
- Quit cleanly with `get_tree().quit()` or `--quit-after N`; Ctrl+C leaves the AVI/WAV without duration info (PNGs are unaffected).
- The `movie` feature tag (`OS.has_feature("movie")`) lets you override settings only when recording.
- Docs warning: Movie Maker is "not designed for capturing real-time footage during gameplay" - it is offline rendering. For an agent that is exactly what we want.
- **UNVERIFIED (inferred):** `--headless` uses the headless display driver, which does not render, so `--headless --write-movie` will not produce usable frames; run with a real window (it can be small/off-screen) on the Windows box.

### Example commands (VERIFIED flags)

```bat
:: 10 s at 60 fps, phone-portrait aspect, PNG sequence into <project>/out/
godot4 --path C:\proj --write-movie out/run.png --fixed-fps 60 --quit-after 600 --resolution 460x996 --disable-vsync -- --replay=res://tests/replays/level1.json

:: Same but one AVI for quick viewing
godot4 --path C:\proj --write-movie out/run.avi --fixed-fps 30 --quit-after 300

:: Stress-test how the game copes with a slow CPU (frame pacing / delta handling)
godot4 --path C:\proj --frame-delay 40 --print-fps --quit-after 600

:: Fast-forward a long sequence (tweens/timers scale too)
godot4 --path C:\proj --time-scale 4 --quit-after 1200
```

### Combining with a scripted input replay (deterministic)

Two ways to inject input, both VERIFIED at API level:

- `Input.parse_input_event(event)` - "Feeds an InputEvent to the game. Can be used to artificially trigger input events from code. Also generates `Node._input` calls." Goes through Input's normal pipeline (so it **is** affected by `emulate_touch_from_mouse` etc.); events are buffered and flushed at least once per frame (`Input.flush_buffered_events()` forces it).
- `Viewport.push_input(event, in_local_coords=false)` - "Triggers the given event in this Viewport... to locally apply inputs that were sent over the network or saved to a file." Order: `_input` -> `Control._gui_input` -> `_shortcut_input` -> `_unhandled_key_input` -> `_unhandled_input`, then physics picking. **It does not remap the event based on project settings like `emulate_touch_from_mouse`.** `in_local_coords=true` means "the event's position is in viewport coordinates" (what you want when you recorded positions in the game's own coordinate space); `false` treats it as embedder/window coordinates and converts.

Harness pattern (autoload `res://tests/replay_player.gd`; **pattern is UNVERIFIED as a whole but every API in it is VERIFIED**):

```gdscript
extends Node
# Reads --replay=<path> after "--". File: JSON array of {"f": frame, "t": "touch|drag", "i": index, "x":..,"y":.., "p": pressed}
var events := []
var idx := 0
func _ready():
    for a in OS.get_cmdline_user_args():
        if a.begins_with("--replay="):
            var f := FileAccess.open(a.trim_prefix("--replay="), FileAccess.READ)
            events = JSON.parse_string(f.get_as_text())
    set_physics_process(events.size() > 0)
func _physics_process(_d):
    var frame := Engine.get_physics_frames()
    while idx < events.size() and int(events[idx].f) <= frame:
        var e = events[idx]; idx += 1
        var ev: InputEvent
        if e.t == "touch":
            ev = InputEventScreenTouch.new(); ev.index = e.i; ev.position = Vector2(e.x, e.y); ev.pressed = e.p
        else:
            ev = InputEventScreenDrag.new(); ev.index = e.i; ev.position = Vector2(e.x, e.y)
        get_viewport().push_input(ev, true)   # in_local_coords = true: positions are in viewport space
```

Record the same file by logging `_input(event)` with `Engine.get_physics_frames()` (this is exactly how bitwes/GodotInputRecorder works; it records in `_input` and replays with `Input.parse_input_event` counted in `_physics_process` - VERIFIED from its README). Because `--fixed-fps` makes delta constant, frame indices are stable across runs (assuming the game itself is deterministic - no unseeded `randi()`, no wall-clock).

For **UI screens** (menus, buttons), `push_input` with an `InputEventMouseButton` at a button's global rect centre drives real `Control._gui_input`; you can also read `Control.get_global_rect()` from the harness to compute positions instead of hard-coding them. For anything action-based use `Input.action_press("jump")` (note: it "will not cause any `Node._input` calls" - only `is_action_pressed` style polling). VERIFIED.

### In-game screenshots without Movie Maker (VERIFIED API)
`await RenderingServer.frame_post_draw; get_viewport().get_texture().get_image().save_png("user://shot_%d.png" % n)` - the Viewport docs warn the texture "might be completely black or outdated if used too early... you can await `RenderingServer.frame_post_draw`".

### Contact sheets with ffmpeg (VERIFIED filter names; exact output UNTESTED here)

```bat
:: 30 frames -> one 6x5 sheet, sampling every 20th frame, each tile scaled to 230px wide
ffmpeg -framerate 60 -i out\run%08d.png -vf "select='not(mod(n\,20))',scale=230:-1,tile=6x5" -frames:v 1 -update 1 out\sheet.png

:: Several sheets (one per 30 sampled frames) for a long run
ffmpeg -framerate 60 -i out\run%08d.png -vf "select='not(mod(n\,10))',scale=230:-1,tile=6x5" out\sheet_%03d.png

:: PNG sequence -> mp4 for a human (docs' own command)
ffmpeg -r 60 -i out\run%08d.png -i out\run.wav -crf 15 out\run.mp4
```
`-vsync 0`/`-fps_mode passthrough` may be needed with `select` to avoid duplicated frames (UNVERIFIED detail). Burn frame numbers into the tiles with `drawtext=text='%{n}':x=5:y=5:fontcolor=white:box=1` before `tile` so Claude can cite a frame (UNVERIFIED on Windows builds without fontconfig - point `fontfile=` at a TTF if it errors).

### Installing ffmpeg without admin (VERIFIED)
- `winget install --id Gyan.FFmpeg` - the winget manifest (v9.0.1, 2026-08-12) is `InstallerType: zip / NestedInstallerType: portable` with command aliases `ffmpeg`, `ffplay`, `ffprobe`. Portable winget packages install to `%LOCALAPPDATA%\Microsoft\WinGet\Packages` in user scope (no elevation); add `--scope user` explicitly to be safe. `Gyan.FFmpeg.Essentials` is the smaller build.
- Portable zip: the same file winget uses - `https://github.com/GyanD/codexffmpeg/releases/download/9.0.1/ffmpeg-9.0.1-full_build.zip` - unzip anywhere, add `bin\` to PATH. No admin.
- `npm i ffmpeg-static` gives a static binary (v5.2.0 ships ffmpeg 6.0; Windows x64 supported) but it is a Node module returning a path, **not** a `npx ffmpeg-static` CLI (VERIFIED from the npm page). Use `node -e "console.log(require('ffmpeg-static'))"` to find it. Older than the Gyan build.

---

## 2. Headless testing: GUT, gdUnit4, `--script` harnesses, input driving, device replay

### GUT (VERIFIED from bitwes/Gut README + docs)
- Versions: **9.7.1 on the `godot_4_7` branch for Godot 4.7.x**; main/9.6.1 for 4.6.x; "GUT versions 9.x are for Godot 4.x".
- Install: download release zip -> `addons/gut` -> enable plugin. (Asset Library lists 9.6.1.)
- CLI: `godot -d -s --path "%CD%" addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gexit -gjunit_xml_file=res://reports/gut.xml`
  Options: `-gexit` (exit after tests), `-gexit_on_success`, `-gdir`, `-gtest`, `-ginclude_subdirs`, `-glog=0..3`, `-gjunit_xml_file`.
- Exit codes: "`0` will be returned if all tests pass and `1` will be returned if any fail (`pending` doesn't affect the return value)."
- Add `--headless` for no window (GUT docs' example does not include it; scene tests that need rendering should omit it). UNVERIFIED nuance.

### gdUnit4 (VERIFIED from godot-gdunit-labs/gdUnit4 README + CLI docs)
- Latest **v6.2.1**, compatibility table lists "v4.5 ... v4.7, v4.7.1".
- CLI: `godot --headless -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://test -c -rd res://reports` or the wrapper `addons\gdUnit4\runtest.cmd` (needs `GODOT_BIN` env var).
  Options: `-a/--add`, `-i/--ignore`, `-c/--continue` (no fail-fast), `-conf`, `-rd/--report-directory`, `-rc/--report-count`.
- Exit codes: **0 = pass, 100 = failures, 101 = warnings.** Reports: `index.htm` + JUnit `results.xml`.
- Has scene-runner APIs for simulating input in tests (`simulate_mouse_button_pressed`, `simulate_key_pressed`, `simulate_screen_touch_*`) - UNVERIFIED names this session; see docs.

### Bare `--script` harness (VERIFIED)
"The script must inherit from `SceneTree` or `MainLoop`." `godot -s res://tests/smoke.gd` (or `--script`; absolute path allowed). Combine with `--headless` for pure logic, `--check-only` to only parse. Example from docs:
```gdscript
extends SceneTree
func _init():
    print("Hello!")
    quit()
```
For scene-based smoke tests: `extends SceneTree`, in `_init()` `change_scene_to_file("res://main.tscn")`, then in `_process` advance N frames, push events with `root.push_input(ev, true)`, assert on nodes, `quit(exit_code)`. `--main-loop <ClassName>` runs a global-class MainLoop instead. All flags VERIFIED; the scene-test body is UNVERIFIED as written.

### Can `parse_input_event` / `push_input` drive the real UI? Yes (VERIFIED above)
- `push_input` reaches `Control._gui_input`, so real Buttons, Sliders, LineEdits react. Use `in_local_coords=true` when your positions are in the root viewport's coordinate space (they will be, if you take them from `Control.get_global_rect()` or from a `_input` recording made in the same stretch configuration). Note it "doesn't propagate input events to embedded Windows or SubViewports" for `push_unhandled_input`; for `push_input` push into the specific `SubViewport` if the UI lives there.
- `Viewport.push_text_input(text)` calls `set_text()` on the focused control - handy for LineEdit.
- `Input.parse_input_event` is simpler for actions/keys and honours `emulate_touch_from_mouse`; `Input.warp_mouse` only works on desktop.

### Recording real touch on the phone and replaying
- **Godot-side (works on device and desktop):** an autoload that logs `_input(event)` (`InputEventScreenTouch`/`Drag` with `index`, `position`, `pressed`, `Engine.get_physics_frames()`) to `user://replay.json`; pull with `adb pull /sdcard/Android/data/<pkg>/files/replay.json` (Godot's Android `user://` maps to the app's external files dir - **UNVERIFIED exact path; check with `adb shell run-as <pkg> ls` or `OS.get_user_data_dir()` printed to logcat**). Replay on desktop at the same base resolution/stretch settings. This is the same design as **bitwes/GodotInputRecorder** (records in `_input`, plays back with `Input.parse_input_event` in `_physics_process`, `.cfg` file; README warns playback depends on a consistent physics tick - VERIFIED) and **graydwarf/godot-ui-automation** (Godot 4.5+, MIT, F11 record / F10 screenshot checkpoints, baseline image compare with pixel tolerance; v1.0.0 Jan 2026 - VERIFIED from README). Neither was tested on 4.7 in this research.
- **Android-side:** `adb shell getevent -lt /dev/input/eventX` dumps raw touch events; replaying with `sendevent` is slow and device-specific (UNVERIFIED for S26 Ultra). Prefer `adb shell input tap/swipe` for scripted input and the Godot-side recorder for fidelity.

---

## 3. On-device testing over adb

### Godot 4 Android activity name (VERIFIED from engine source, 4.5 and master manifests)
The Android template's manifest declares:
- `<activity android:name=".GodotApp" ... android:exported="false">` and
- `<activity-alias android:name=".GodotAppLauncher" android:targetActivity=".GodotApp" android:exported="true">` with the MAIN/LAUNCHER intent filter.
- Gradle namespace is `com.godot.game`; `applicationId` is your export preset's `package/unique_name`.
So the fully-qualified class is `com.godot.game.GodotApp` regardless of your package name, and the exported entry point is the **alias**:

```bat
adb install -r -g build\game.apk
adb shell am start -W -S -n com.example.mygame/com.godot.game.GodotAppLauncher
```
`-S` force-stops first, `-W` waits for launch (VERIFIED adb docs). Starting `.GodotApp` directly from the shell may be refused with "Permission Denial ... not exported" because `exported="false"` (UNVERIFIED on this device; the alias avoids the question). Fallbacks that never need the class name: `adb shell monkey -p com.example.mygame -c android.intent.category.LAUNCHER 1` or `adb shell cmd package resolve-activity --brief com.example.mygame` to print the resolved component (UNVERIFIED wording, widely used).

### Reading `print()` from the phone (VERIFIED tag from `platform/android/os_android.cpp`)
Godot logs through `__android_log_vprint(..., "godot", ...)`, so:
```bat
adb logcat -c
adb logcat -s godot            :: only Godot stdout/stderr (print, push_error, GDScript errors)
adb logcat -s godot:* GodotEngine:* *:E   :: plus native errors (UNVERIFIED: Java-side tag names)
adb logcat -d -s godot > logcat.txt      :: dump and exit (for an agent)
```
The editor's "Deploy with Remote Debug" tunnels the debugger over `adb reverse`; there was a 4.2-era regression (#82764) where prints stopped reaching the Output panel - `adb logcat -s godot` is the robust path for an agent anyway.

### Screenshots / video (VERIFIED adb docs)
```bat
adb exec-out screencap -p > shot.png                          :: single command, lands on PC
adb shell screenrecord --time-limit 30 --size 720x1560 --bit-rate 8000000 /sdcard/run.mp4
adb pull /sdcard/run.mp4 .
ffmpeg -i run.mp4 -vf "fps=2,scale=230:-1,tile=6x5" sheet_%03d.png    :: contact sheets for Claude
```
`screenrecord`: max/default 180 s, **no audio**, rotation during recording unsupported.

### Scripted input (VERIFIED adb docs, syntax standard)
```bat
adb shell input tap 540 1800
adb shell input swipe 300 1500 800 1500 200      :: x1 y1 x2 y2 duration_ms
adb shell input keyevent KEYCODE_BACK             :: exercises NOTIFICATION_WM_GO_BACK_REQUEST
adb shell input keyevent KEYCODE_HOME             :: exercises APPLICATION_PAUSED / FOCUS_OUT
adb shell wm size                                  :: physical px size, to convert viewport coords
```

### Frame times (VERIFIED from Android "Testing display performance" doc; page now archived/mirrored)
```bat
adb shell dumpsys gfxinfo com.example.mygame reset
:: ...play 10 s...
adb shell dumpsys gfxinfo com.example.mygame            :: Total frames, Janky frames %, 50/90/95/99th percentile ms, Missed Vsync...
adb shell dumpsys gfxinfo com.example.mygame framestats :: CSV of the last 120 frames, nanosecond timestamps
```
Frame time = `FRAME_COMPLETED - INTENDED_VSYNC`. Columns: FLAGS, INTENDED_VSYNC, VSYNC, OLDEST_INPUT_EVENT, NEWEST_INPUT_EVENT, HANDLE_INPUT_START, ANIMATION_START, PERFORM_TRAVERSALS_START, DRAW_START, SYNC_QUEUED, SYNC_START, ISSUE_DRAW_COMMANDS_START, SWAP_BUFFERS, FRAME_COMPLETED. **Caveat (UNVERIFIED):** gfxinfo instruments HWUI; a Godot `SurfaceView`/Vulkan swapchain may report few or no frames. Cross-check with Godot's own numbers: print `Engine.get_frames_per_second()` / `Performance.get_monitor(Performance.TIME_PROCESS)` to logcat every second, or run `--print-fps` on desktop.

### Thermal / battery
- `adb shell dumpsys thermalservice` prints current thermal status and sensor temps (UNVERIFIED wording; widely used). Status levels from the Android Thermal API: NONE, LIGHT, MODERATE, SEVERE, CRITICAL, EMERGENCY, SHUTDOWN (VERIFIED).
- `adb shell cmd thermalservice override-status 0` / `cmd thermalservice reset` - used by Android's own CTS to pin the device to "no throttling" during tests (VERIFIED from the CTS commit). Try `override-status 3` (SEVERE) to see how the game behaves when throttled (UNVERIFIED that Samsung honours it).
- `adb shell dumpsys batterystats --reset` then `adb shell dumpsys batterystats com.example.mygame` after a session for per-app power/wakelock stats (UNVERIFIED formatting).
- `adb shell dumpsys SurfaceFlinger --latency` is an alternative frame-timing source for non-HWUI apps (UNVERIFIED for modern Samsung builds).

### scrcpy (VERIFIED from Genymobile/scrcpy docs/recording.md)
```bat
winget install Genymobile.scrcpy         :: UNVERIFIED package id; portable zip also available on GitHub releases
scrcpy --no-playback --no-window --record=run.mp4 --time-limit=30   :: headless recording, better quality than screenrecord, can include audio
scrcpy --record=run.mkv --no-audio
```
Container from extension (mp4/mkv/opus/flac/wav). Useful for the agent because it records without a window and can run longer than 180 s.

---

## 4. Android emulator vs desktop proxy

### Emulator from cmdline-tools only (VERIFIED commands from developer.android.com; note Google now marks sdkmanager/avdmanager/emulator flags as deprecated in favour of the new `android` CLI, but they still work)
```bat
set SDK=%LOCALAPPDATA%\Android\Sdk
%SDK%\cmdline-tools\latest\bin\sdkmanager --licenses
%SDK%\cmdline-tools\latest\bin\sdkmanager "platform-tools" "emulator" "platforms;android-35" "system-images;android-35;google_apis;x86_64"
%SDK%\cmdline-tools\latest\bin\avdmanager create avd -n phone35 -k "system-images;android-35;google_apis;x86_64" -d pixel_8
%SDK%\emulator\emulator -avd phone35 -gpu host -no-boot-anim -no-snapshot -no-audio
adb wait-for-device
```
Android Studio is **not** required. The new **Android CLI** (`android sdk install ...`, `android emulator create/start/list/stop`, `android run --apks=...`) is Google's 2026 replacement; the docs note "Downloading Android CLI from Windows PowerShell isn't currently supported" (VERIFIED).

### Vulkan on the emulator (VERIFIED from emulator release notes)
Vulkan 1.3 via gfxstream since API 34 images (emulator 33.1.23, Nov 2023); emulator 36.4.9 (Feb 2026) made **Lavapipe** the default *software* Vulkan renderer and fixed several Vulkan issues. With `-gpu host` and an x86_64 image on a decent NVIDIA/AMD desktop GPU it runs, but:
- Godot's `mobile` renderer (Vulkan) has a history of black 3D / missing features on emulated GPUs (issue #73384 class of bugs) and Godot's own device-support issue #111729 shows the mobile renderer reduces supported devices vs `gl_compatibility`. **UNVERIFIED for 4.7 + emulator 36.x specifically.**
- The emulator's x86_64 image also means your **arm64** export is not what runs (unless you export x86_64 too), and frame timings say nothing about the S26's Exynos/Snapdragon GPU or thermals.
Verdict: the emulator is useful only for "does it launch, is the safe area/back-button/pause flow right" without a phone plugged in. Since the S26 Ultra is on the desk, skip the emulator.

### Desktop proxy (VERIFIED settings/APIs)
- Run at phone aspect: `godot --path . --resolution 460x996 --windowed` (works in `canvas_items`/`disabled` stretch; with `viewport` stretch the base size wins).
- Touch emulation: project setting `input_devices/pointing/emulate_touch_from_mouse` ("sends touch input events when clicking or dragging the mouse") or at runtime `Input.emulate_touch_from_mouse = true` (exposed property, VERIFIED in `core/input/input.cpp`). Toggle it from an autoload when `"--touch" in OS.get_cmdline_user_args()`.
- Renderer parity: `--rendering-method mobile` (or `gl_compatibility`) and `--rendering-driver vulkan|opengl3` (VERIFIED flags) so desktop screenshots use the same shader path as the phone; `rendering/renderer/rendering_method.mobile` is the project-level override for phones.
- `--frame-delay 30` approximates a slow phone CPU; `--max-fps 30` approximates a 30 Hz cap. VERIFIED flags.

---

## 5. Godot 4 mobile "feels complete" checklist (settings + APIs, all VERIFIED from class/ProjectSettings docs unless marked)

**Display / layout**
- Stretch: `display/window/stretch/mode = canvas_items` ("the default for projects created starting in Godot 4.7"), `display/window/stretch/aspect = expand` - docs' mobile recipe: portrait base 720x1280 (or 1080x1920 + `gui/theme/default_theme_scale` 1.5-2.0), landscape 1280x720; use a 3:4 / 4:3 base to also fit tablets/foldables. Anchor Controls to corners.
- Orientation: `display/window/handheld/orientation` (`portrait`, `landscape`, `sensor`, `sensor_portrait`...) - "does not flip the project resolution's width and height automatically". Runtime: `DisplayServer.screen_set_orientation()` (Android/iOS).
- Safe area: `DisplayServer.get_display_safe_area()` ("Currently only implemented on Android, iOS, and macOS"; elsewhere falls back to `screen_get_usable_rect`) + `get_display_cutouts()`. Required if the export preset's `screen/edge_to_edge` is on (its doc says exactly that). `screen/immersive_mode` hides nav/status bars.
- Keep screen on: `display/window/energy_saving/keep_screen_on` (desktop + mobile) / `DisplayServer.screen_set_keep_on()`.
- Refresh rate: `DisplayServer.screen_get_refresh_rate()` (Android supported; returns -1 on failure - docs show the fallback-to-60 snippet). `Engine.max_fps` / `application/run/max_fps` to cap for battery; vsync takes precedence.
- `application/run/low_processor_mode` - keep **off** for games (docs).

**Input**
- Prefer `InputEventScreenTouch` / `InputEventScreenDrag` (multi-touch `index`), keep `input_devices/pointing/emulate_mouse_from_touch = true` (default) so Controls still work from touch; turn on `emulate_touch_from_mouse` for desktop testing.
- `Input.use_accumulated_input` (default **true**; disable for freehand drawing), `input_devices/buffering/agile_event_flushing` ("Currently implemented only on Android" - improves responsiveness when physics runs several ticks per frame).
- 4.7: built-in **`VirtualJoystick`** control node (Fixed/Dynamic/Following modes) - VERIFIED class exists in master docs.
- `input_devices/pointing/android/enable_long_press_as_right_click`; `InputEventScreenTouch.long_press`.
- Haptics: `Input.vibrate_handheld(duration_ms, amplitude=-1.0)` - Android/iOS/Web; **requires `permissions/vibrate` in the export preset** or it silently does nothing; device DND settings may block it.

**Lifecycle**
- Back button: handle `NOTIFICATION_WM_GO_BACK_REQUEST` in `_notification` ("Implemented only on Android"); `application/config/quit_on_go_back` decides whether the OS back quits the app.
- Pause/resume: `NOTIFICATION_APPLICATION_PAUSED` / `NOTIFICATION_APPLICATION_RESUMED` (Android/iOS; iOS gives ~5 s), `NOTIFICATION_APPLICATION_FOCUS_OUT/IN` (desktop + mobile). Pause the game, mute/duck audio, autosave on PAUSED.
- Memory: `NOTIFICATION_OS_MEMORY_WARNING` (iOS only).

**Export preset (Android) - VERIFIED property names**
- Icons: `launcher_icons/main_192x192` (falls back to `application/config/icon`), `launcher_icons/adaptive_foreground_432x432`, `adaptive_background_432x432`, `adaptive_monochrome_432x432`.
- Splash: `splash_screen/icon` (falls back to the adaptive foreground; may be an AnimatedVectorDrawable XML), `splash_screen/branding_image`, `splash_screen/background_color` (Gradle builds only), `splash_screen/disable_godot_boot_splash` (keeps the system splash until the main loop starts - cleanest look). Godot's own boot splash: `application/boot_splash/*` project settings.
- `package/unique_name` (reverse-DNS, lowercase), `version/code` (bump every store upload), `version/name`, `gradle_build/use_gradle_build`, `gradle_build/min_sdk`, `gradle_build/target_sdk`, `gradle_build/export_format` (apk/aab), `screen/background_color`, `package/retain_data_on_uninstall`, `permissions/vibrate`.

**Rendering**
- `rendering/renderer/rendering_method.mobile` = `mobile` (Vulkan, "newer or high-end" phones; the S26 Ultra qualifies) or `gl_compatibility` (widest support); Forward+ on mobile is "supported, but poorly optimized". Since 4.4 the RenderingDevice path falls back to Compatibility when Vulkan is unavailable; issue #111729 suggests keeping `rendering/rendering_device/fallback_to_opengl3` on and checking Play Console device counts.
- AA: docs say "When targeting low-end platforms such as mobile... FXAA is usually the only viable option. 2x MSAA may be usable in some circumstances, but higher MSAA levels are unlikely to run smoothly on mobile GPUs." MSAA/FXAA are not available in Compatibility (FXAA) / MSAA is; TAA is Forward+ only. Settings: `rendering/anti_aliasing/quality/msaa_3d`, `msaa_2d`, `screen_space_aa`.
- Textures: `rendering/textures/vram_compression/import_etc2_astc = true` for Android (ETC2 low-quality, ASTC 4x4 high-quality); it is an override - the importer always imports what the host needs; delete `.godot/imported/` to re-import. `rendering/textures/canvas_textures/default_texture_filter` (Nearest for pixel art + `rendering/2d/snap/*`), `gui/common/snap_controls_to_pixels`.
- `rendering/scaling_3d/scale` < 1.0 to undersample 3D on phones while UI stays crisp (docs recommend exposing it in options).
- Physics: `physics/common/physics_ticks_per_second` (60 default), keep `physics/common/physics_interpolation` in mind for smooth 120 Hz displays; `physics_jitter_fix` is auto-disabled when interpolation is on.

**Audio / saves / settings**
- Audio: put Music/SFX on separate buses in `default_bus_layout.tres` (`audio/buses/default_bus_layout`) so an options screen can set `AudioServer.set_bus_volume_db(idx, linear_to_db(v))`; `audio/driver/output_latency` (default 15 ms; web uses 50). UNVERIFIED best-practice, VERIFIED settings.
- Saves: `user://` is "created automatically and guaranteed to be writable to, even in an exported project"; use `FileAccess.open("user://save.json", FileAccess.WRITE)` (+ `store_string`/`store_var`), `ConfigFile` (`load`/`save`, `set_value("audio","music",0.8)`) for settings. Set `application/config/use_custom_user_dir` for a tidy desktop path (mobile unaffected).

**Misc polish**
- `Engine.time_scale` for hit-stop/slow-mo; `application/config/name` + localized `name_localized`; `application/config/icon`; `display/window/size/window_width_override` is ignored on Android.

---

## 6. Godot MCP servers usable from Claude Code (2026)

| Server | What it does | Install | 4.7 / Windows | Screenshots? | License |
|---|---|---|---|---|---|
| **Coding-Solo/godot-mcp** (npm `@coding-solo/godot-mcp`) - VERIFIED README | 13 tools: `launch_editor`, `run_project`, `get_debug_output`, `stop_project`, `get_godot_version`, `list_projects`, `get_project_info`, `create_scene`, `add_node`, `load_sprite`, `export_mesh_library`, `save_scene`, `update_project_uids` (4.4+). Pure CLI wrapper - no addon needed. | `claude mcp add godot -- npx @coding-solo/godot-mcp`; env `GODOT_PATH` to pin the binary, `DEBUG=true` | Node >= 18, Windows supported; no explicit 4.7 statement (it just shells out to `godot`) | **No** | MIT |
| **KeeVeeG/godot-mcp** (addon + `npx -y @keeveeg/godot-mcp`) - VERIFIED README | "300+ tools across 40+ modules": scene/node/script editing, runtime inspection, **input simulation & recording/replay**, "capture editor and game viewport screenshots for visual regression checks", multi-step test scenarios/assertions. | copy `addons/godot_mcp/`, enable plugin; MCP config `{"command":"npx","args":["-y","@keeveeg/godot-mcp"]}` | "4.x (tested with 4.7)"; Windows/Linux/macOS | **Yes** | MIT; v1.1.0 (Jul 2026) |
| **hybridindie/godot-mcp** (Python/uv + addon) - VERIFIED README | 175 tools: inspection, gated scene/script editing, runtime (headless run, editor play control, game inspection via `mcp_runtime_probe.gd` autoload), input simulation, profiling/breakpoints, export, **viewport screenshot capture "for vision-capable agents"**. | `uv sync`; copy `godot/addons/godot_mcp`; enable; configure Claude Code | Godot 4.4 min, "4.7 recommended"; Windows listed | **Yes** | MIT |
| **IvanMurzak/Godot-MCP** (Asset Library #5245) - VERIFIED listing | 42 tools incl. screenshots; requires the **.NET/mono** editor + .NET 8 SDK; cloud (ai-game.dev) or self-hosted server | Asset Library / GitHub | 4.3+ | Yes | Apache-2.0 |
| **youichi-uda/godot-mcp-pro** (Asset Library #4961) - VERIFIED listing | 163 tools, Node server over WebSocket; plugin is open, server is a **$15 itch.io purchase** | itch.io + addon | 4.4+ | UNVERIFIED | Proprietary |

Practical note: for the "test-play and judge" goal, an MCP server mostly saves you from writing the launch/log-capture glue; the deterministic Movie-Maker + replay pipeline in section 1 gives Claude far richer evidence (hundreds of frames) than a single editor-viewport screenshot. KeeVeeG's and hybridindie's servers are the ones worth trying first because they add screenshots + input simulation + runtime probes. None of them was exercised in this research (only READMEs read).

---

## 7. Free Godot 4 templates / addons that add polish out of the box

| Project | What you get | Licence | Godot | Install |
|---|---|---|---|---|
| **Maaack's Game Template** - github.com/Maaack/Godot-Game-Template (VERIFIED README) | main menu, options (audio/video/**input remapping**), pause menu, credits, scene loader/loading screen, example game, setup wizard; 640x360 to 4K | MIT | "For Godot 4.7 (4.4+ compatible)" | Asset Library "Maaack's Game Template"/"...Template - Plugin" (asset 2709, 1.5.2), "Maaack's Menus Template - Plugin" (2899), "Minimal Game Template - Plugin" (4658); or git |
| **Phantom Camera** - github.com/ramokz/phantom-camera (VERIFIED README) | Cinemachine-style Camera2D/3D: priority system, follow modes (glued/simple/group/path/framed dead-zones/third-person), zoom, look-at, tweened transitions | MIT | 4.4+ | Asset Library / git (`addons/phantom_camera`) |
| **Kenney Starter Kits** (VERIFIED READMEs): `KenneyNL/Starter-Kit-3D-Platformer`, `Starter-Kit-FPS`, `Starter-Kit-City-Builder` (+ Basic Scene) | complete small games: 3D platformer (double jump, coins, camera, gamepad), FPS (weapons, enemy AI), city builder (build/demolish, MeshLibrary, save/load) | **MIT** code, **CC0** assets | 4.6 (project files) - open in 4.7 and let it upgrade | git clone / Asset Library search "kenney" |
| **Beehave** - github.com/bitbrain/beehave (VERIFIED README) | behaviour-tree AI nodes in the scene tree, debugger | MIT | 4.x (`godot-4.x` branch, 2.x+) | release zip -> `addons/beehave`, enable, copy `script_templates` |
| **SmartShape2D** - github.com/SirRamEsq/SmartShape2D (VERIFIED README) | textured 2D terrain from point shapes | MIT | 4.x; v3.3.1 (Dec 2025) | `addons/` |
| **Dialogic 2** - github.com/dialogic-godot/dialogic (VERIFIED README) | dialogue/VN/RPG text system with editor, auto-updater | MIT (Roboto font Apache-2.0) | Dialogic 2 requires **4.5+** | `addons/dialogic`, enable |
| Tween/juice helpers | Godot 4 has built-in `Tween` (`create_tween().tween_property(...).set_trans(Tween.TRANS_BACK)`), `Engine.time_scale` hit-stop, `Camera2D/3D` offsets - no addon needed. Dedicated "juice" addons exist (e.g. search Asset Library for "shake", "juice") but none was verified here. | - | - | UNVERIFIED |

### Unattended download via the Asset Library API (VERIFIED from godot-asset-library/API.md and a live query)
- List: `GET https://godotengine.org/asset-library/api/asset?filter=<text>&godot_version=4.7&type=addon&sort=updated&max_results=10` -> JSON `{result:[{asset_id,title,version_string,godot_version,cost,...}],page,pages,total_items}`.
- Detail: `GET https://godotengine.org/asset-library/api/asset/<id>` -> includes **`download_url`** (usually a GitHub `archive/<sha>.zip`) and `browse_url`.
- Example script: `curl -s "https://godotengine.org/asset-library/api/asset/2709" | jq -r .download_url | xargs curl -L -o addon.zip` then unzip and copy `addons/*` into the project (addon zips are archived from the repo root; the folder inside is `<repo>-<sha>/addons/...`). UNVERIFIED unzip layout detail.
- **Important 2026 caveat (VERIFIED):** Godot announced the **Asset Store** (store.godotengine.org), "fully integrated in Godot 4.7"; the old Asset Library "will be set as a read-only repository in the near future" and is "considered deprecated" but still serves older versions. Many listings above show `godot_version: 4.3` metadata even though the repos support 4.7 - prefer the repo's own README/branch. The Asset Store's public API for unattended downloads was not documented in the announcement (UNVERIFIED) - pulling release zips straight from GitHub is the safest automation.

---

## 8. Game feel / juice / "finished mobile game" references

1. **Steve Swink, *Game Feel: A Game Designer's Guide to Virtual Sensation* (2008)** - defines feel as real-time control + simulated space + polish; the "six metrics" (input, response, context, polish, metaphor, rules). Takeaway: tune the *response curve* (acceleration, friction, coyote time, input buffering) before adding effects; measure input-to-visible latency. (VERIFIED existence; metric list from memory - UNVERIFIED wording.)
2. **"Juice It or Lose It" - Martin Jonasson & Petri Purho, GDC 2012** (gdcvault.com/play/1016487, YouTube Fy0aCDmgnxg) - a Breakout clone with tweens, particles, screen shake, sound layers, colour flashes added one at a time. Takeaway: every player action should produce *multiple* simultaneous feedback channels; each one is cheap. (VERIFIED links.)
3. **"The Art of Screenshake" - Jan Willem Nijman (Vlambeer), 2013** - 30 tricks (muzzle flash, recoil, hit-stop/sleep frames, camera kick, enemy knockback, permanence of debris). Takeaway: hit-stop of 2-4 frames and directional camera kick sell impact more than any particle. (Talk widely archived; link UNVERIFIED this session.)
4. **GMTK - "Why Does Celeste Feel So Good to Play?" and Maddy Thorson's public Celeste Player.cs** - coyote time, jump buffering, corner correction, variable jump height, wall-jump forgiveness. Takeaway: forgiveness windows of ~0.1 s are what make touch/mobile controls feel fair. (UNVERIFIED exact titles.)
5. **GMTK - "How Celeste Teaches You Its Mechanics" / "onboarding" design videos** - teach through safe practice rooms, escalate one variable at a time, never text-dump. Takeaway: a phone game's first 30 s should be playable with zero reading. (Link UNVERIFIED.)
6. **Nielsen Norman Group - 10 Usability Heuristics** (nngroup.com/articles/ten-usability-heuristics) applied to mobile: visibility of system status (loading, saving indicators), user control (pause/undo/back), error prevention, recognition over recall, touch targets ~44-48 dp. Takeaway: the OS back button, pause on focus loss, and a resume-where-I-left-off save are the three things mobile players notice most. (VERIFIED URL; mobile application is the author's synthesis.)
7. **Godot docs themselves** - "Multiple resolutions" mobile recipes, "Creating movies", "Input examples" touch tip - VERIFIED and quoted above.

---

## Sources (primary, read this session)
- godot-docs: `tutorials/animation/creating_movies.rst`, `tutorials/editor/command_line_tutorial.rst`, `tutorials/rendering/multiple_resolutions.rst`, `tutorials/rendering/renderers.rst`, `tutorials/3d/3d_antialiasing.rst`, `tutorials/inputs/input_examples.rst`, `tutorials/io/data_paths.rst`, `tutorials/export/exporting_for_android.rst` (master, Sept 2026)
- godot engine source (master): `doc/classes/{Viewport,Input,DisplayServer,MainLoop,Node,ProjectSettings,Engine,VirtualJoystick}.xml`, `platform/android/doc_classes/EditorExportPlatformAndroid.xml`, `platform/android/java/app/src/main/AndroidManifest.xml` (+ 4.5 branch), `platform/android/java/app/build.gradle` (4.5), `platform/android/os_android.cpp`, `core/input/input.cpp`, `main/main.cpp`
- GUT: https://github.com/bitwes/Gut, https://gut.readthedocs.io/en/latest/Command-Line.html
- gdUnit4: https://github.com/godot-gdunit-labs/gdUnit4, https://godot-gdunit-labs.github.io/gdUnit4/latest/advanced_testing/cmd/
- Input replay: https://github.com/bitwes/GodotInputRecorder, https://github.com/graydwarf/godot-ui-automation
- MCP: https://github.com/Coding-Solo/godot-mcp, https://github.com/KeeVeeG/godot-mcp, https://github.com/hybridindie/godot-mcp, https://godotengine.org/asset-library/asset/5245, https://godotengine.org/asset-library/asset/4961
- Android: https://developer.android.com/tools/adb, https://developer.android.com/studio/run/emulator-commandline, https://developer.android.com/tools/sdkmanager, https://developer.android.com/tools/avdmanager, https://developer.android.com/tools/agents/android-cli, https://developer.android.com/studio/releases/emulator, https://developer.android.com/games/optimize/adpf/thermal, archived "Testing display performance" (dumpsys gfxinfo) mirror, CTS commit using `cmd thermalservice override-status`
- scrcpy: https://github.com/Genymobile/scrcpy/blob/master/doc/recording.md
- ffmpeg: winget manifest `manifests/g/Gyan/FFmpeg/9.0.1/Gyan.FFmpeg.installer.yaml` (microsoft/winget-pkgs), https://www.npmjs.com/package/ffmpeg-static
- Godot issues: #111729 (mobile renderer device support), #82764 (Android print regression)
- Templates: Maaack/Godot-Game-Template, ramokz/phantom-camera, KenneyNL/Starter-Kit-{3D-Platformer,FPS,City-Builder}, bitbrain/beehave, SirRamEsq/SmartShape2D, dialogic-godot/dialogic; Asset Library API.md; https://godotengine.org/article/introducing-the-godot-asset-store/; https://godotengine.org/releases/4.7/
- Game feel: GDC Vault "Juice It or Lose It" (1016487), nngroup.com ten-usability-heuristics
