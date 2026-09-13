# GODOT.md - the native Android stack, its traps, and the toolchain

Current state, not history. Edited only by `/digest`. Read before writing any Godot code,
because most of this is not obvious from the source and every item cost time once.

## The stack

| Piece | Choice |
|---|---|
| Engine | **Godot 4.7.2 stable**, pinned exactly. CI uses `barichello/godot-ci:4.7.2` |
| Renderer | **Mobile** (Vulkan, Forward Mobile) with `fallback_to_opengl3` on. Never Forward+ on a phone |
| Language | **GDScript, statically typed** everywhere (`func f(x: int) -> float:`) |
| Structure | `src/sim/` pure simulation, `src/game/` the shell that draws it, `test/` harness, `scripts/` tools |
| Tests | `godot --headless --script res://test/run_tests.gd`, exits non-zero. GUT or gdUnit4 only when the hand harness starts growing mocks |
| Ship | CI builds a signed debug APK on every push to `main` and attaches it to a GitHub Release. A `v*` tag builds the Play AAB |
| Save | `user://` JSON through `FileAccess`. Settings in their own `ConfigFile` |
| Audio | Buses `Master / Music / SFX / UI` in `default_bus_layout.tres`. Files in `assets/audio/`, generated or fetched, never synthesised per frame in GDScript |

## Toolchain, and where it lives

Nothing is installed system-wide and nothing needed admin; everything is portable under
`C:\dev\toolchain\`.

| Piece | Version | Path |
|---|---|---|
| Godot | 4.7.2 stable | `%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe` (`$env:GODOT` in scripts) |
| JDK | Temurin 17.0.20.1 | `C:\dev\toolchain\jdk\jdk-17.0.20.1+1` |
| Android SDK | platform 36, build-tools 36.0.0, platform-tools 37.0.1 | `C:\dev\toolchain\android-sdk` (`adb` at `platform-tools\adb.exe`) |
| Debug keystore | alias `androiddebugkey`, pass `android` | `C:\dev\toolchain\debug.keystore` |
| Upload keystore | alias `upload` | `C:\dev\keys\upload.keystore`, password in `C:\dev\keys\UPLOAD-KEY-README.txt` |
| Export templates | 4.7.2.stable | `%APPDATA%\Godot\export_templates\4.7.2.stable` |
| ffmpeg, gh, scrcpy | via winget, user scope | on the **user** PATH; a session older than the install will not see it |

**Anything winget installed during a session is invisible to that session**: a process reads
PATH once, at startup, so `Get-Command` says "not installed" about a tool that is installed. Never
send the reader to `setup\install.ps1` for it - it is a whole-machine script that rewrites
`~/.claude` and is shared with other running sessions. Re-read the user PATH at the top of any
script that shells out, which fixes `gh`, `adb` and `ffmpeg` at once, then fall back to the winget
Packages glob (`...\WinGet\Packages\<Publisher>.<Id>_*\...`, how `GODOT` is resolved), and give
up with `winget install --id <id> --scope user`, never the installer:

```powershell
$u = [Environment]::GetEnvironmentVariable('PATH','User')
$miss = @($u -split ';' | Where-Object { $_ -and ($env:PATH -split ';') -notcontains $_ })
if ($miss.Count) { $env:PATH = ($miss -join ';') + ';' + $env:PATH }
```

**Seven PowerShell traps take a script out before it can report anything.** Mechanism, code and
measurements: `techniques/powershell-traps-in-the-scripts.md`. The rules:

- **`$ErrorActionPreference = 'Stop'` makes a native command's stderr terminate the script** before
  any `$LASTEXITCODE` check below it runs, so every `-AllowFail` flag downstream is decoration.
  Wrap any native call whose failure is expected in the `Native` helper.
- **Never compute a `param()` default from `$PSScriptRoot`**, which binds EMPTY while defaults are
  evaluated. `doctor.ps1` dying inside its own `param()` read as `framework FAIL exit 1` on every
  game with nothing wrong in any of them. Default to `''` and derive in the body: a param default
  that can throw takes the whole script with it, before its own logging exists.
- **Quote every adb flag beginning with w, v, d or c** (`'-W'`, `'-S'`) - a bare `-W`
  prefix-matches `-WarningAction`, and `device.ps1 launch` raised `AmbiguousParameter` against
  itself and had never once worked. `ValueFromRemainingArguments` does not protect you.
- **`*> $log` does not write what the program printed**: native stderr arrives as an `ErrorRecord`
  in UTF-16. Unwrap with `$_.Exception.Message`, never `ToString()`, which returns the bare type
  name `System.Management.Automation.RemoteException` for a BLANK line and turns every spacer in an
  error block into a class name (PS 7.4.6, M). `check.ps1` once reported `errors 0` for every Godot
  error in every game built from the template.
- **A cross-cutting check must not fail a gate for a condition the gated repo cannot fix**: scope
  it to the repo named in `-Repo`, or report a WARN. Wildform's gate went red over lessons a
  DIFFERENT game's session had filed in the wrong format. A gate step that fails prints the reason,
  not only the verdict.
- **Never name a wrapper after the command it wraps** (`RunGit`, not `Git`): PowerShell prefers a
  function over the same-named executable, so `& git` inside `function Git` calls itself - symptom
  is a stream of zeros, a two-minute hang, or a call-depth overflow, never a message naming the
  function. And a wrapper returns the exit code ALONE: a native command's stdout joins the
  function's own output, so `git status --porcelain` came back as an `Object[]` with the exit code
  appended, and `-ne 0` against that array is truthy - a clean call reported as a failure. Capture
  output, read `$LASTEXITCODE` on the very next line, print the captured lines yourself; never pipe
  to `Out-Host`, which deadlocks inside an `if`.
- **A guard that rejects a missing path must still permit a deletion**: `kb.ps1 commit`'s
  `Test-Path` check refused a file `git rm` had just removed, so the digest's own documented step 7
  (fold, delete and commit in one call) could never run as written. Check what git already knows
  is gone (`git diff --cached --diff-filter=D`, the index, HEAD) and reject only a path that is
  missing AND untracked.

**Every temporary file outside the repo goes in the session scratchpad**, whose path is unique per
session, never `/tmp` or any other fixed path. A gravewell loop backed each source file up to
`/tmp/s.keep` while a stillwater session picked the same obvious short name for the same obvious
reason; stillwater's `sim.gd` was restored over gravewell's, the suite simply stopped compiling,
and the cause was found by grepping the file for the other game's vocabulary (`HOLDING`,
`tension`). `git checkout --` recovered the committed part and the uncommitted milestone on top was
lost. Same family as the per-game port rule in `WEB.md`: **any agreed-looking short name outside
the repo is a collision waiting for the second session**, and it presents as one game's source
appearing inside another.

**Godot finds the SDK, the JDK and the debug keystore through editor settings, not
environment variables**: `%APPDATA%\Godot\editor_settings-4.7.tres`, keys under
`export/android/`. `ANDROID_HOME` alone does nothing and the error names "Editor Settings"
without saying which file. The **release** keystore is the opposite - it comes from
`GODOT_ANDROID_KEYSTORE_RELEASE_PATH / _USER / _PASSWORD` environment variables, and without
them the export fails with "Could not find release keystore", which reads like a missing file.

## Commands (every one exits non-zero on failure)

```powershell
$godot = $env:GODOT   # set by setup/install.ps1; falls back to the winget path above
& $godot --headless --path . --import                                  # after adding files
& $godot --headless --path . --script res://test/run_tests.gd          # pure tests, ~1 s
& $godot --headless --path . --script res://test/run_smoke.gd          # boots the real scene
& $godot --headless --path . --script res://test/run_probe.gd          # balance readings, never fails
& $godot --headless --path . --export-debug "Android" build/<slug>.apk
& $godot --headless --path . --script res://scripts/check_size.gd      # size guard - weighs the APK in build/, so export first
& $godot --path . --resolution 460x996 --script res://scripts/shot.gd -- 45 <state>   # screenshot at the PHONE's aspect
& $godot --path . --resolution 460x996 -- record=test/replays/<name>.json touch  # record a scenario
scripts\movie.ps1 -Replay test/replays/<name>.json -Seconds 20         # then film it to a contact sheet
scripts\movie.ps1 -Seconds 10 -Name idle                               # or film the attract state
scripts\device.ps1 install|launch|log|shot|record|perf                 # the phone over adb
scripts\check.ps1                                                       # everything above that can run on the desk, in the order that fails fastest
```

Redirect long runs to a file and read the FILE: a PowerShell pipeline that assigns to a
variable buffers the whole run, so a hung command shows nothing at all.

## Invariants every game keeps

- **`src/sim/` may not reference a Node, a Viewport, an input event or a real frame.** If it
  needs to know about the world it takes it as an argument. This is what made a genre change
  three times in a day cost nothing in tests.
- **Nothing that affects game state may use `randf()`.** Place-keyed decisions go through
  `SimUtil.hash2` seeded on (chunk, level); stream-like values through `SimRng`. A value that
  decides *when* something happens is simulation even if it looks like decoration.
- **The hash uses unsigned shifts on a masked 32-bit value.** A signed shift silently returns
  only `[0, 0.5)` and disabled three shipped mechanics for a game's whole life; `test_util.gd`
  asserts the range and the distribution.
- **Physics is for debris, which decides nothing.** Anything the game is scored on is
  arithmetic in `src/sim/`; a `RigidBody3D` on a joint puts the outcome inside the physics server
  and ends any chance of a golden. `techniques/wrecking-crew-pendulum.md`.
- **One writer per UI phase.** `_set_phase()` assigns AND recomputes every screen's visibility.
  Assigning the phase next to a `_show_screens()` call worked in four places out of five; the
  fifth left a screen drawn over the whole game.
- **Anything that restarts a level for a gameplay reason pushes the save back in afterwards**,
  or buying a boost wipes the player's money. `Sim.restart()` zeroes run state; progress lives
  in `save.gd`.
- **A finished level starts the next one and running out restarts.** `run_smoke.gd` drives
  THROUGH every terminal state: a suite that stops where the content stops cannot see past the
  end of the content.
- **Every interactable has visible mesh within arm's reach of its point.** Visible: a
  hidden mesh let a lamp that is off until bought stand in for one that is there.
- **A change to what a saved field CONTAINS is a version bump**, the same as adding or removing
  one. Gravewell moved `cores` from an `int` tally to an `Array[int]` of class ids and left
  `Save.VERSION` at 2: every test wrote a NEW-shaped save and read it back, so the suite was green,
  while a save already on a phone would have passed the version check, reached
  `d.get("cores", []) as Array` on an integer - `null` in Godot 4 - and iterated it. Pin it with a
  test that WRITES an old-shaped save at the old version and asserts it is refused. A
  `VERSION + 99` test cannot catch this: it proves an unknown future version is rejected, never
  that the current shape change was declared.
- **A golden over floats uses `TestHarness.FLOAT_EPS`.** `snappedf` does not round-trip
  through a source literal, and goldens are recorded on Windows and checked on Linux.

## Layout: the base resolution is a lie about height

**Nothing in the HUD is positioned against a literal screen size.**
`display/window/stretch/mode = canvas_items` with `aspect = expand` keeps the base width and
extends the height to the device, so a 1080x1920 project renders into roughly 1080x2340 on the
S26 Ultra and anything placed against the literal 1920 lands hundreds of pixels high - reported
as "the buttons are about half an inch too high".

- One `Control` with `PRESET_FULL_RECT` inside a `CanvasLayer`, everything anchored to it;
  `PRESET_CENTER_BOTTOM` plus a negative `offset_bottom` puts a thumb control a fixed distance
  from the real bottom edge at any aspect.
- Apply `DisplayServer.get_display_safe_area()` as margins on `_ready` and on `size_changed`,
  required once `screen/edge_to_edge` is on - but **guard it behind `OS.has_feature("mobile")`
  and make it exactly zero everywhere else**, **clamp the rect to the window before subtracting**
  so every inset is non-negative by construction, and convert through
  `DisplayServer.window_get_size()`, never `screen_get_size()`. Off a phone it returns the usable
  DESKTOP: Gravewell's d-pad moved 104 px up (M) and Wildform's inset became an outset of
  **-1460** (M) that pushed the evolution mechanic's pips off the viewport.
  `techniques/phone-layout-and-safe-area.md`.
- **Every interactive control handles its own input** through `_gui_input`, calls
  `accept_event()` and sets `mouse_filter = STOP`, so position and hit box are one object. A
  manual `_unhandled_input` hit test is a second source of truth for where a button is.
- **No headless test can catch a layout bug by reading live values**, and asserting the
  property rather than the position is necessary and NOT sufficient: headless uses the base size
  and reports a safe area of **zeros**, so Wildform's smoke test asserted exactly the right
  property and was true on every run for the whole time the window was broken. **Put the
  arithmetic in a pure static function and assert THAT, fed the awkward inputs.** Guard the
  arithmetic, not the reading. `techniques/phone-layout-and-safe-area.md`.
- **Off-tree, a Control's `get_global_rect()` reports offsets, not pixels, and a container's
  children have zero size** - anchored controls report raw, often negative, numbers measured from
  an unresolved parent. Nothing errors, so a pure-suite test must assert WHICH control was chosen
  (distance to each candidate's centre) rather than that a point lies inside its rect; leave
  "inside" to the smoke suite (which adds the scene to the root) or a film.

## Touch and scrolling

- **A `ScrollContainer` does not scroll from a finger.** Measured: wheel 50, pan gesture 400,
  `InputEventScreenDrag` **0**; `emulate_mouse_from_touch` does not help, a drag is not a wheel.
  Translate it by hand in `_gui_input` (`scroll.scroll_vertical -= int(event.relative.y);
  accept_event()`), and rows inside need `MOUSE_FILTER_IGNORE` or each row swallows the gesture.
- Prefer `InputEventScreenTouch` / `InputEventScreenDrag` with `index` for multi-touch.
  Leave `emulate_mouse_from_touch = true` so Controls work. For desk testing, set
  `Input.emulate_touch_from_mouse = true` at runtime from a `--touch` user arg.
- **A touch control's per-frame sync must send to the simulation only while the thumb is on it,
  and once more as it lifts.** A sync that also sends its resting value every frame (`want = 0`
  with no thumb down) silently overrides every OTHER driver of the sim sixty times a second: the
  scripted policies, the smoke harness's direct calls, and the filmed bot's policy seam, which then
  read as a broken loop rather than an overridden one. Gate the send on a thumb-down flag and one
  more send on release, never a per-frame default.
- `Input.vibrate_handheld(ms, amplitude)` needs `permissions/vibrate` in the export preset or it
  silently does nothing (ticks 10-30 ms, amplitude 0.3-0.6), and it has no amplitude stream, so a
  continuous effect is a short pulse re-issued at a period that shortens with the load, never a
  retrigger per event. Godot 4.7 has a built-in `VirtualJoystick` control (fixed, dynamic,
  following) - use it before writing another.

## Headless lifecycle, which is where the time goes

- **`_ready` does not run at `add_child()`** inside `SceneTree._initialize()`; it is deferred
  to the first processed frame. Symptom: hundreds of `Nonexistent function ... in base 'Nil'`
  and a run that never terminates. Guard with an idempotent `_ensure_booted()` called from
  `_ready` and from every harness entry point.
- **`is_inside_tree()` is FALSE for everything a `SceneTree` harness builds.** Measured one
  line after `root.add_child(m)` in `_initialize()`: the root window has not entered the tree
  yet and it is the tree entering that sets the flag, while `get_parent()` already returns
  `root`, so the node looks attached by every other test. The flag is honest and IS the right
  guard (`if is_inside_tree(): get_tree().paused = on`) - but **every path behind such a guard is
  a silent no-op for the whole `_initialize` stage of a suite**. So a smoke harness runs in **two
  stages**: what must work outside the tree in `_initialize()`, and everything guarded in
  `_process()` on frame one.
- **A Control's own `gui_input` handler is drivable headless; `accept_event()` is not.**
  `accept_event()` is wrapped in `if (is_inside_tree())` upstream (4.3 through master), so off
  the tree it is a silent no-op. That is a reason to call the handler the `gui_input` signal
  calls, not to stop short of it: `test_controls.gd` reaches a d-pad this way with no viewport.
  `_size_changed()` is NOT gated, so a Control whose two anchors on an axis are equal has a real
  `size` off the tree - assert that size first, because one reading zero takes a thumb resting
  dead center as a full push.
- **Guard on the node, never on what the call gives back.** One family, one cause - an API that
  needs the node in the tree, called from a harness where it is not. `Node3D.look_at` errors (use
  `Transform3D.looking_at`); `Camera3D.unproject_position` errors, returns a meaningless vector,
  and wants a live viewport headless does not have; `Control.is_visible_in_tree()` answers false
  for a control that is perfectly well built; `global_transform` returns IDENTITY silently; and
  `Node.get_tree()` pushes an engine ERROR **and then** returns null, so
  `var tree := get_tree(); if tree != null:` still fails the run - an `ERROR:` line is a test
  failure even when every assertion passes. In a harness use `transform`, keep the node a direct
  child of a root that never moves, and prefer arithmetic to a call: a camera cone rather than a
  projected point, a `visible` flag and a parent rather than a tree walk.
- **Tweeners added to a plain `Tween` run one after another, and a headless harness ticks no
  Tween at all**, so a `tween_property` inside a loop over a collection makes the animation's
  length a property of how much content the game HAS (Wildform's 0.56 s transform ran **8.96 s**,
  M). Tween ONE value and fan it out where the collection is already written per frame, and assert
  the MEASURED length with `Tween.custom_step(delta)`, never the constants - the obvious test
  (advance a second, assert the flash is down) passes on the bug.
  `techniques/wildform-evolution-transform.md`.
- **Control layout only resolves during a frame.** A harness that does everything in
  `_initialize()` finds every `Control` at zero size. Let three frames pass and assert the
  rects are non-zero before any click.
- **`Viewport.push_input(event)` does nothing for the GUI unless `in_local_coords = true`.**
  Measured on a bare `Button`: zero presses without it, one with. A click that hits nothing is
  not an error, so a UI test goes green having proved nothing.
- **A headless run allocates no MultiMesh buffer**, so `get_instance_transform` and
  `get_instance_color` read back as identity and white and prove nothing - measured against a real
  Vulkan run with the same seed and scene: every `origin.x` that was 26.08, -12.42, -33.04 and so
  on read back as exactly 0.00 headless. This is not merely weak, it is false: it fails on correct
  code, which is the worst kind of check because the first instinct is to "fix" the code.
  `visible_instance_count` is CPU-side and reliable, and is also the flush: forgetting it fails
  completely silently. A headless smoke test may assert HOW MANY instances are drawn, never WHERE
  - placement belongs in a pure test on the arithmetic that decides it, plus a screenshot for the
  picture (`TESTING.md`).
- **`MultiMesh.use_colors` must be set BEFORE `instance_count`** or every instance is
  silently untinted.
- **Start audio playback from `_ready`**, never `_enter_tree` or right after `add_child`,
  or every player logs "Playback can only happen when a node is inside the scene tree".
- **An engine `ERROR:` line is a test failure** even when every assertion passes; the runner
  fails on any of them. **Free the scene the smoke test built before quitting**, or the run ends
  with resources still in use.
- **A new `class_name` is invisible until re-import**, and the failure mode is a hang with
  no output. `--import` after adding one.
- **A parse error in a script the harness loads produces a run that never terminates**, not a
  failure: the scene's script fails to parse, `main.tscn` instantiates as a **bare `Node3D`**,
  the harness calls `freeze()` on it, that error is non-fatal, and every `advance until X` loop
  then drives a stub that can never reach X. Read the TOP of the log - when a run does not
  finish the first command is `head`, not a grep for `FAIL`, because this fault produces no
  `FAIL` at all. Tell a parse error from slow code by CPU share
  (`Get-Process Godot* | % { $_.CPU }` against elapsed): real work pins a core, and a ratio well
  under 100% means the file is broken, not slow.
- **Never let a `MeshInstance3D` hold the only reference to a material it was given.** Freeing
  such a node headless prints `Parameter "material" is null` at
  `material_get_instance_shader_parameters` once per node, which a Logger-based harness
  (`TESTING.md`) turns into a failure on every controls and bot-seam test. Keep duplicated or
  generated materials in a cache keyed by the source material's instance id, shared across
  instances, rather than one duplicate per node.
- **`JSON.stringify(data)` defaults to `full_precision = false`** and truncates a state float on
  the way to disk, so a round-trip save test can fail on a real precision loss (`1.371412` back
  as `1.37141`). Pass `full_precision = true` for any float that is state, and compare saved
  dictionaries by KEY, never as `str(dict)` (`sort_keys` changes order).
- **GDScript lambdas capture by VALUE.** A probe that writes its result into a captured local
  reports the initial value forever: Stillwater's loss-reason probe said no fish is ever lost
  anywhere in the game, which was a fact about the closure, and a model change was half built on
  top of it. Carry the result in a Dictionary or an Array, which are reference types.
- **Any `:=` on a Variant-returning expression fails the whole FILE, not the line** - a
  Dictionary read, an untyped Array element, or `Callable.call()`, which is the one a TEST file
  hits, because a local lambda is how a test avoids repeating itself. Annotate the local:
  `var pos: Vector3 = c.pos`, `var hit: int = fires.call(t)`. Grep
  `'var [a-z_]* := .*\(\.call(\|\["\)'` over `src/ test/`: the Dictionary-only version could not
  see `fires.call(threshold)`, which cost fifteen minutes on a three-second suite misdiagnosed as a
  quadratic hang, because the failure mode is the non-terminating run above.
- **Godot eats a leading `--` even after the `--` separator**, so a user flag is a bare word.

## Rendering traps

Thirteen measured traps, the arithmetic and the dead ends are in
`techniques/godot-rendering-traps.md`. The ones that have cost this studio the most time:

- **Four ways a quad "is not drawing" that are not the quad** - print its position in CAMERA
  space before touching the material.
- **When a value is computed correctly and displayed wrongly, RENDER THE VALUE.** Keep a
  `debug_term` uniform with one branch per term permanently; isolate a term by REPLACING it, not
  by reading it.
- **A shader that computes its own lighting must say so: `render_mode unshaded`**, and
  `rendering/textures/vram_compression/import_etc2_astc = true` is required for an Android export.
- **`DEPTH_TEXTURE` is corrupt on Forward Mobile with MSAA**, and `fog_sky_affect` defaults to
  1.0, so depth fog repaints the SKY. Godot blend shapes cannot morph one creature into another
  at all (`techniques/wildform-evolution-transform.md`).
- **A `SurfaceTool`/`ArrayMesh` mesh that draws nothing is a winding order before it is the
  material, the position or the fog** - `set_normal()` does not decide the front face, the vertex
  order does, and a correct normal is what makes the mistake invisible in code review. To tell
  "not drawn" from "drawn and faint" (fog can look identical to absent at range): paint the mesh a
  color that cannot occur in the scene (magenta, cyan) and scan a screenshot for that hue rather
  than staring at the frame. For a backdrop seen from one side only, `cull_mode =
  BaseMaterial3D.CULL_DISABLED` is the right answer, not a workaround - the overdraw is trivial
  and it removes a whole class of silent failure.
- **Walking a path once per follower is quadratic and reads as a hang**, not as slowness.
- **`Basis.scaled()` scales the WORLD axes**, WAVs import as QOA, and `TorusMesh` has no arc
  parameter.
- **Depth on a high-albedo surface under soft sky light reads through ambient occlusion and
  normals, not albedo**, and the vertex grid must be finer than the feature width.
  `techniques/godot-rendering-traps.md`.

## Export, signing and the two builds

| | `Android` preset | `Android Release` preset |
|---|---|---|
| Output | `.apk` | `.aab` (what Play accepts) |
| Build | prebuilt template, seconds, no Gradle | Gradle, minutes, ~300 MB on a cold run |
| Signed with | debug key | upload key from `C:\dev\keys` |
| Trigger | every push to `main` | a `v*` tag |

- **Anything a tool writes INTO the project directory is a candidate for the package and for
  the import cache, and `.gitignore` has no say in either.** Both guards, in every game:
  `exclude_filter="build/*, *.log, *.apk, *.aab, *.idsig"` in **every** preset, and
  `build/.gdignore`. The marker is the load-bearing half - the filter is hit on an export, the
  marker on every run of the gate. For it to survive git the ignore must be **`build/*`** then
  `!build/.gdignore`: `build/` ignores the DIRECTORY, git refuses to descend, and the negation
  can never match. **A directory exclusion takes its exceptions with it, in every tool**, so
  recreate the exception after any copy and assert it exists. Both failures were silent and both
  are measured in `techniques/build-output-and-the-package.md`. **This is the case for a size
  guard from the first commit.**
- **AAB export is only valid with `gradle_build/use_gradle_build = true`**, and Gradle is the
  only way to set `target_sdk` (Play requires 36 and it rises every year).
  **`--install-android-build-template` only works alongside an export command** - alone it opens
  the editor and never returns - and **`GRADLE_OPTS=-Dorg.gradle.daemon=false` for any release
  export**, or Godot writes a good bundle and waits forever on the daemon.
- **Verify the artifact, not the exit code.** The exporter has returned -1 with a valid bundle
  and 0 with nothing. Check the file exists, is plausible in size, and passes `jarsigner -verify`.
  Read the target SDK from `android/build/config.gradle`, not the bundle: an AAB manifest is
  protobuf and `aapt2` returns nothing, which passes.
- **Never invoke Godot through `Start-Process -ArgumentList`**: it drops the quotes and
  `Android Release` arrives as two arguments. `scripts/export_release.bat` exists for this.
- **`ANDROID_DEBUG_KEYSTORE_B64` must be a repository secret** or every CI build is signed with
  a throwaway key and Android refuses to update the installed app. `/game-scaffold` sets it with
  `gh secret set` at repo creation, with the upload key secrets.
- **Never import `config/quit_on_go_back=false` on its own.** The other half is
  `NOTIFICATION_WM_GO_BACK_REQUEST` in `_notification`, unwinding **one** layer per press in the
  order the game stacks its screens and quitting only when nothing is open. Godot's default
  throws the run away on a stray back press; the setting with no handler gives a dead system
  button, which is worse. Neither state shows in a headless suite: assert the unwinding, never
  the setting - a config line cannot fail. A game with no pause screen still handles back,
  because `NOTIFICATION_WM_CLOSE_REQUEST` does **not** arrive on an Android back-out, so that is
  where the save has to happen.
- `android/` is gitignored (the unpacked export template, not source). The Android launch
  component is `<unique_name>/com.godot.game.GodotAppLauncher` - `.GodotApp` itself is not
  exported - and Godot's logcat tag is `godot`.

## Measured on the phone

**Measure frames with SurfaceFlinger `--timestats`, never `dumpsys gfxinfo`.** gfxinfo
instruments HWUI, the Android View hierarchy, and a Godot game draws to its own `SurfaceView`, so
none of its frames pass through the thing being measured. Asked for percentiles straight after a
run that had drawn 2,117 frames it answered `Total frames rendered: 0`, `Janky frames: 0 (0.00%)`
and `4950ms` at every percentile - 4950 ms is its no-data sentinel, and zero janky out of zero
frames is the most reassuring output there is. **Every frame-time number this studio has printed
for a Godot game came from gfxinfo and meant nothing**, including the 5 ms p50/p90/p95 for this
phone that used to be quoted here. `device.ps1` carried a caution beside the number and the
caution prevented nothing: print the right number or print nothing.

Wildform on an S26 Ultra, measured the right way: 2,117 frames, 2,115 in the 8 ms bucket and 2 in
the 7 ms bucket and none anywhere else, 0 dropped, 0 janky, 125 FPS average on a 120 Hz panel, so
every percentile is 8 ms (M). Recipe, histogram arithmetic and the layer-name trap:
`techniques/measuring-frames-on-the-phone.md`. Thermal throttling after five to ten minutes of
sustained rendering is still the constraint that matters; fill rate feeds it, draw calls do not
(`WEB.md` has the measurement that put the "50 to 100 calls" folklore off by 30x).

## CI

`barichello/godot-ci:4.7.2` for both jobs. The image may not carry an Android SDK, so the
workflow looks for one, installs it if missing, and prints what it found; every path check fails
with the directory it wanted. Poll with `gh run watch` or `gh run list --limit 3`, never a
15-second unauthenticated curl loop (it burns the API budget and prints nothing, which reads as
"still running"). A check that cannot determine the answer must say so. Do not report a push as
done while the check is in flight.

**When a `gh` command or the release step fails with a 5xx, look at the effect before doing
anything about the cause** - a 500 or 502 is the server failing to answer, not a promise that it
did nothing. wildform's `Publish a release` step got HTTP 500 from `softprops/action-gh-release`
three times in one morning: build-35 was never created, build-36 got as far as a draft release
with its 35 MB APK attached and only the finalize step failed, and those two look identical from
the run's conclusion alone. Read with `gh run list` for a new run, `gh release list` and
`gh api repos/<owner>/<repo>/releases` for a draft that may already exist with its asset - the
repair is often `--draft=false` on what is already there, not another full build. Do not re-issue
a write after a 5xx until a read says it did not happen: `gh run rerun --failed` itself returned
HTTP 502 once, read as "did not start", and had in fact started - a blind second retry would have
queued the job twice and published two releases for one commit. Read the 500's response BODY, not
just its status, because the body names the endpoint (wildform's pointed at
`generate-release-notes`) - but do not let one line of payload become a story about your own repo's
data before checking: a same-minute POST-and-delete-draft probe against wildform, snowball and
stillwater found 0/6, 1/6 and 5/6 successes, so it was GitHub's release creation degraded across
the whole account, not any one repo's state. **A 5xx that hits one repo and not another is still
most likely the server**, and the only way to tell is to make the same call several times against
a repo that is working - that probe is cheap and safe (`draft=true`, then `DELETE`, invisible to
the public, no tag). Do not treat githubstatus.com as evidence either way; it read "All Systems
Operational" throughout.

## Tools that do not exist here, and what to use instead

- Windows has no ImageMagick; `convert` is a disk utility. Use `ffmpeg` for images, and Pillow
  rather than `sharp-cli` for conversions (`ASSETS.md` has the reason and the recipe).
- **Never rewrite a source file through PowerShell `Get-Content`/`Set-Content`**: 5.1 reads a
  BOM-less file as ANSI and corrupts every non-ASCII byte. Use the Edit/Write tools, or
  `[System.IO.File]::ReadAllText/WriteAllText` with `UTF8Encoding($false)`. `stamp.ps1`, which
  rewrites `src/build_stamp.gd` on every build, is the one script that has to get this right.
- **Write Windows paths with forward slashes whenever they cross the Bash tool**
  (`C:/dev/gamedev-notes/scripts/progress.ps1`) - PowerShell, Godot, node, python, adb and ffmpeg
  all accept them, so no case needs the backslash form. A backslash path silently loses its
  escapes crossing the tool: as an output directory with no error at all (a run-together
  capitalized name like `SERSGIDEOAPPDATAocaltemp` IS `C:\Users\gideo\AppData\Local\Temp` with
  `\U`, `\A`, `\L`, `\T` eaten - treat it as this bug and look for the files it swallowed rather
  than deleting it blind), or as an argument with a visible error (the `.ps1` suffix with every
  backslash before it eaten, so it reads as one run-together word with no directory in it). If a
  backslash path is unavoidable, single-quote it and check what arrived before doing anything with
  it. **When a topic file has to show a broken or mangled path as an example, break the file
  extension too** (a bare mangled word, or "the .ps1 suffix with every backslash eaten") so
  `scripts\doctor.ps1`'s cross-reference check, which reads every `name.ps1`/`.py`/`.gd` in prose
  as a claim that file exists, cannot mistake the illustration for a promise and fail the next run
  on a file that was never supposed to exist. **Never put backslash
  escapes in a Python heredoc through the Bash tool** for the same reason: write the script to a
  file and run it, with an `assert pattern in text` beside every replace.
- **Do not juggle source files through the shell for a two-line experiment**, and never
  `git checkout -- <file>` on a file with uncommitted edits. Commit before probing.
- **Normalize line endings on day one**: `* text=auto eol=lf` in `.gitattributes`, one pass
  converting the repo, before the first bulk edit. Mixed endings inside a file defeat every
  exact-match edit silently.
