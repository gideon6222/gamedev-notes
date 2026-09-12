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

**Anything winget installed during a session is invisible to that session.** A process reads
PATH once, at startup, so `Get-Command` says "not installed" about a tool that is installed.
Never send the reader to `setup\install.ps1` for it - that is a whole-machine script that
rewrites `~/.claude` and is shared with other running sessions. Re-read the user PATH at the top
of any script that shells out, which fixes `gh`, `adb` and `ffmpeg` at once; then fall back to
the winget Packages glob (`...\WinGet\Packages\<Publisher>.<Id>_*\...`, how `GODOT` is already
resolved), and give up with `winget install --id <id> --scope user`, never the installer:

```powershell
$u = [Environment]::GetEnvironmentVariable('PATH','User')
$miss = @($u -split ';' | Where-Object { $_ -and ($env:PATH -split ';') -notcontains $_ })
if ($miss.Count) { $env:PATH = ($miss -join ';') + ';' + $env:PATH }
```

**`$ErrorActionPreference = 'Stop'` makes a native command's stderr terminate the script
before any `$LASTEXITCODE` check below it runs.** Redirection does not save it - `*>` and
`2>$null` move the text and the ErrorRecord still throws - so every `-AllowFail` flag and
exit-code branch downstream is decoration. `check.ps1` died at step one on an import warning it
was told to forgive; `new-game.ps1` died on a `gh repo view` probe that is *supposed* to fail on
a new game; `movie.ps1` died on Godot's normal shutdown warning **after** writing all 3,840
frames and before tiling one. Wrap every native call whose failure is expected:

```powershell
function Native([scriptblock]$Block) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $Block } finally { $ErrorActionPreference = $prev }
}
```

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
& $godot --headless --path . --script res://scripts/check_size.gd      # size guard, both directions
& $godot --path . --resolution 460x996 --script res://scripts/shot.gd -- 45 <state>   # screenshot at the PHONE's aspect
& $godot --path . --resolution 460x996 -- record=test/replays/<name>.json touch  # record a scenario
scripts\movie.ps1 -Replay test/replays/<name>.json -Seconds 20         # then film it to a contact sheet
scripts\movie.ps1 -Seconds 10 -Name idle                               # or film the attract state
scripts\device.ps1 install|launch|log|shot|record|perf                 # the phone over adb
scripts\check.ps1                                                       # everything above that can run on the desk, in the order that fails fastest
```

Redirect long runs to a file and read the FILE: a PowerShell pipeline that assigns to a
variable buffers the whole run, so a hung command shows nothing at all.

**But `*> $log` does not write what the program printed.** It sends native stderr through
PowerShell's error channel, so every line arrives as an `ErrorRecord` rendered
`Godot...exe : SCRIPT ERROR: ...` plus a `+ CategoryInfo` block, in UTF-16. `check.ps1` counted
`'^(SCRIPT )?ERROR'` over it and reported **`errors 0` for every Godot error in every step, in
every game built from the template**. Unwrap the records and write UTF-8:

```powershell
& $godot @a 2>&1 |
  ForEach-Object { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.ToString() } else { $_ } } |
  Out-File -FilePath $log -Encoding utf8
```

Same family as the `$ErrorActionPreference = 'Stop'` trap: PowerShell treats native stderr as
an object, not text. **A log written by a shell is not the program's output until you have
decoded the bytes and looked at one known-bad line.** `check.ps1`, `movie.ps1` and `device.ps1`
all carry the unwrap.

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

## Touch and scrolling

- **A `ScrollContainer` does not scroll from a finger.** Measured: wheel 50, pan gesture 400,
  `InputEventScreenDrag` **0**; `emulate_mouse_from_touch` does not help, a drag is not a wheel.
  Translate it by hand in `_gui_input` (`scroll.scroll_vertical -= int(event.relative.y);
  accept_event()`), and rows inside need `MOUSE_FILTER_IGNORE` or each row swallows the gesture.
- Prefer `InputEventScreenTouch` / `InputEventScreenDrag` with `index` for multi-touch.
  Leave `emulate_mouse_from_touch = true` so Controls work. For desk testing, set
  `Input.emulate_touch_from_mouse = true` at runtime from a `--touch` user arg.
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
  dead centre as a full push.
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
- **A headless run allocates no MultiMesh buffer**, so instance colours read back black and
  prove nothing. `visible_instance_count` is CPU-side and reliable, and is also the flush:
  forgetting it fails completely silently.
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
- **GDScript lambdas capture by VALUE.** A probe that writes its result into a captured local
  reports the initial value forever: Stillwater's loss-reason probe said no fish is ever lost
  anywhere in the game, which was a fact about the closure, and a model change was half built on
  top of it. Carry the result in a Dictionary or an Array, which are reference types.
- **A value read out of a Dictionary is a Variant and `:=` cannot infer from one.** Annotate
  the local: `var pos: Vector3 = c.pos`. `grep -rn 'var [a-z_]* := .*\["' src/ test/` finds
  every one in a second and the failure mode is a five-minute hang each.
- **Godot eats a leading `--` even after the `--` separator**, so a user flag is a bare word.

## Rendering traps

- `rendering/textures/vram_compression/import_etc2_astc = true` is **required** for an Android
  export, and changing it does not re-import existing textures - delete `.godot/imported` and
  `--import` again. `config/icon` is required or the export errors.
- **The file Godot loads is not the file you committed: verify the artefact the engine
  produced, never the one you wrote.** A plain texture imports `compress/mode=0` (lossless) with
  no mipmaps, and Godot writes BOTH an `astc` and a `bptc` variant, so what ships has no
  relationship to what the source weighs and `ls -laS .godot/imported` is the only place the cost
  shows. Mipmaps are not optional on ground at a grazing angle. The measured costs and the bulk
  `.import` recipe are in `ASSETS.md`, which owns them.
- **WAVs import as QOA**, so `AudioStreamWAV.data` is compressed bytes: read as PCM, a 1.30 s
  generated fanfare measured 0.26 s and every "not silent" assertion had been passing on
  compressed noise. Measure the PCM off the file with `FileAccess` and the RIFF chunks, then
  assert SEPARATELY that `get_length()` and `mix_rate` match the header. Lengths, never samples.
- **Inverted-hull outlines do not work on a `MultiMeshInstance3D`** (the hull draws over the
  object even six centimetres inside it). Use a fresnel rim in the material, written so that zero
  width means no line, and **on flat-shaded low poly take the power to 4.5 or steeper** - every
  facet has one normal, so a soft falloff paints panels rather than a rim.
  `techniques/wildform-creature-shader.md`.
- **`DEPTH_TEXTURE` is corrupt on Forward Mobile with MSAA**, and turning MSAA off is not the
  answer. When a shader wants to know something about the world the simulation usually already
  owns it: upload the heightfield as a small texture and sample by world position - exact,
  testable headlessly, and the picture cannot disagree with the rules.
- **The mesh AABB is useless for draw size on a skinned mesh and is the correct and only
  source for model-space extent.** For draw size nothing you can ask describes what is drawn, so
  set it as a measured constant per model in the content table and check it by eye against
  something - `ASSETS.md` has the four ways of asking and what each one returned. But a uniform
  CONSUMED in model space is tuned against `mesh.get_aabb()`, never world scale, because `VERTEX`
  is in exactly that space and an imported model relates the two by a different unknown factor
  each. **Assert the feature count, `uniform * extent`, not the frequency.**
  `techniques/wildform-creature-shader.md`.
- **Godot blend shapes cannot morph one creature into a different creature**, at all:
  `set_blend_shape_value` interpolates vertex deltas WITHIN one mesh resource, so the target must
  share vertex count and topology, which two authored glTF models never do. To change what a
  character IS, **hide the swap instead of interpolating it** - dissolve out, flash over the
  instant, reform, 0.3 s each way, both forms frozen at a matching rest pose.
  `techniques/wildform-evolution-transform.md`. **`GPUParticles3D` draws nothing on the
  Compatibility renderer** - it needs compute shaders and logs no error; Mobile, the default, is
  fine.
- **Four ways a quad "is not drawing" that are not the quad**; print its position in CAMERA
  space first. Writing `Node3D.rotation.y` rebuilds the WHOLE basis from `(0, y, 0)`, discarding
  the transform that laid it flat - keep a rest transform and compose. **`render_priority` only
  orders TRANSPARENT materials**, so two opaque quads with `no_depth_test` draw in undefined
  order; `transparency = TRANSPARENCY_ALPHA` (alpha still 1) makes it apply. A **`QuadMesh` faces
  its own +Z**, so a basis reused from a flat surface puts a wall board face-up at the ceiling, a
  one-pixel strip edge-on; a vertical surface wants `Basis(Vector3.UP, PI)`. And
  **`SubViewport.get_texture().get_image()` returns black** from a script. An untextured
  `QuadMesh` particle is a hard SQUARE - a `GradientTexture2D`, `FILL_RADIAL`, alpha to zero,
  costs no file and no APK bytes.
- **`Basis.scaled()` scales the WORLD axes**, not the mesh's own. A cylinder rotated to lie
  along X is scaled `(length, radius, radius)`. Getting it backwards looks like a layout bug
  and is a transform one.
- **`TorusMesh` has no arc parameter**; a curved arm is a post and a leaning boom.
- **A procedural surface can be the expensive thing.** Thirteen octaves of noise over a third
  of the screen cost 1.60 ms a frame; two samples of a 36 KB texture cost 0.82 ms, within noise
  of a flat material (M, vsync off). Build the cheap case with the SAME uniforms.
- **Do not derive a normal from `dFdx`/`dFdy` on a surface seen at a grazing angle**: it is a
  speckle generator.
- **`fog_sky_affect` defaults to 1.0, so depth fog repaints the SKY.** The sky is at infinity, so
  a fog tuned on the water covers the whole sky in the fog colour, and a flat cream wall where a
  dawn gradient should be reads as a *missing skybox* - which sends you into the sky material
  hunting a fault that is not there. Drop it to about **0.2 (T)**. General form: any effect
  applied by distance hits the background hardest, so check the sky FIRST when tuning fog.
  `techniques/stillwater-fishing-fight.md`.
- **Data textures (normal, roughness, AO, masks) must NOT be sRGB-decoded; colour textures must
  be.** A data map decoded as colour comes back with its dark end lifted, and the surface reads as
  washed out or flat rather than as a broken import. `compress/normal_map=1` is the Godot half of
  it; the rest of the `.import` recipe is in `ASSETS.md`.
- **`Light3D.light_cull_mask` and `VisualInstance3D.layers` really do exclude a light from an
  object** in Godot - one flag, not a second pass. The opposite rule in
  `techniques/three-js-materials-and-lights.md` is a three.js limitation.
- **Walking a path once per follower is quadratic and reads as a hang**; one backward walk
  emits every follower as it crosses each threshold.
- Anti-aliasing on a phone: MSAA 2x at most, or FXAA. Keep `scaling_3d/scale` around
  0.75-0.85 for a heavy scene while the UI stays crisp.
- **A shader that computes its own lighting must say so: `render_mode unshaded`.** `ALBEDO` in
  a lit `shader_type spatial` is not the colour that reaches the screen, it is the base colour
  that LIGHTS MULTIPLY - so a surface excluded from every light (`light_cull_mask`) has nothing
  to multiply it by and renders black at every value of every constant. Go `unshaded` and write
  the finished colour to `ALBEDO`, or write the computed light to `EMISSION`. Nothing warns.
- **When a value is computed correctly and displayed wrongly, RENDER THE VALUE.** A shader has
  no `print`, so the screen is its only readout: `ALBEDO = vec3(f.g, f.r, 0.0); EMISSION = same;`
  ruled out the solver, the upload, the mapping and the texture format in one screenshot, after
  three plausible hypotheses had each fitted the symptom. Keep the `flat` and `pattern` debug
  render modes permanently in the one-object screenshot script
  (`techniques/wildform-creature-shader.md`). It is the first move, not the fifth.

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

S26 Ultra, 2026-09-08, placeholder scene: Vulkan 1.4.295, Forward Mobile, Adreno 840,
`dumpsys gfxinfo` over 44 frames gave 5 ms at the 50th, 90th and 95th percentiles, one janky
frame, 1 ms GPU at the median. That is the engine and the pipeline, not a game, and the ceiling
is nowhere near. Thermal throttling after five to ten minutes of sustained rendering is the
constraint that matters; fill rate feeds it, draw calls do not (`WEB.md` has the measurement
that put the "50 to 100 calls" folklore off by 30x).

## CI

`barichello/godot-ci:4.7.2` for both jobs. The image may not carry an Android SDK, so the
workflow looks for one, installs it if missing, and prints what it found; every path check fails
with the directory it wanted. Poll with `gh run watch` or `gh run list --limit 3`, never a
15-second unauthenticated curl loop (it burns the API budget and prints nothing, which reads as
"still running"). A check that cannot determine the answer must say so. Do not report a push as
done while the check is in flight.

## Tools that do not exist here, and what to use instead

- Windows has no ImageMagick; `convert` is a disk utility. Use `ffmpeg` for images, and Pillow
  rather than `sharp-cli` for conversions (`ASSETS.md` has the reason and the recipe).
- **Never rewrite a source file through PowerShell `Get-Content`/`Set-Content`**: 5.1 reads a
  BOM-less file as ANSI and corrupts every non-ASCII byte. Use the Edit/Write tools, or
  `[System.IO.File]::ReadAllText/WriteAllText` with `UTF8Encoding($false)`. `stamp.ps1`, which
  rewrites `src/build_stamp.gd` on every build, is the one script that has to get this right.
- **Never put backslash escapes in a Python heredoc through the Bash tool.** Write the script to
  a file and run it, with an `assert pattern in text` beside every replace.
- **Do not juggle source files through the shell for a two-line experiment**, and never
  `git checkout -- <file>` on a file with uncommitted edits. Commit before probing.
- **Normalise line endings on day one**: `* text=auto eol=lf` in `.gitattributes`, one pass
  converting the repo, before the first bulk edit. Mixed endings inside a file defeat every
  exact-match edit silently.
