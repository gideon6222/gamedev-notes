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

Nothing is installed system-wide and nothing needed admin. Everything portable under
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

**Anything winget installed during a session is invisible to that session.** winget writes
the user PATH in the registry and a process reads it once, at startup, so `Get-Command` says
"not installed" about a tool that is installed and signed in. Never send the reader to
`setup\install.ps1` for it - that is a whole-machine script that rewrites `~/.claude` and is
shared with other running sessions. Instead, re-read the user PATH at the top of any script
that shells out, which fixes `gh`, `adb` and `ffmpeg` at once:

```powershell
$userPath = [Environment]::GetEnvironmentVariable('PATH','User')
if ($userPath) {
  $have = $env:PATH -split ';'
  $missing = @($userPath -split ';' | Where-Object { $_ -and $have -notcontains $_ })
  if ($missing.Count) { $env:PATH = ($missing -join ';') + ';' + $env:PATH }
}
```

Then fall back to the winget Packages glob (`%LOCALAPPDATA%\Microsoft\WinGet\Packages\<Publisher>.<Id>_*\...`,
which is how `GODOT` is already resolved) before giving up, and give up with the one-line
`winget install --id <id> --scope user` rather than the installer.

**`$ErrorActionPreference = 'Stop'` makes a native command's stderr terminate the script
before any `$LASTEXITCODE` check below it runs.** Redirection does not save it - `*>` and
`2>$null` send the text somewhere and the ErrorRecord still throws - so every `-AllowFail`
flag, `-ErrorAction SilentlyContinue` and exit-code branch downstream is decoration. It cost
two sessions: `check.ps1` died at step one on one stderr line from an import warning it was
explicitly told to forgive, and `new-game.ps1` died on a `gh repo view` probe that is
*supposed* to fail on a new game. Wrap every native call whose failure is expected:

```powershell
function Native([scriptblock]$Block) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $Block } finally { $ErrorActionPreference = $prev }
}
```

**Godot finds the SDK, the JDK and the debug keystore through editor settings, not
environment variables**: `%APPDATA%\Godot\editor_settings-4.7.tres`, keys under
`export/android/`. Setting `ANDROID_HOME` alone does nothing and the error names "Editor
Settings" without saying which file. The **release** keystore is the opposite: it comes from
`GODOT_ANDROID_KEYSTORE_RELEASE_PATH / _USER / _PASSWORD` environment variables, and a
release export without them fails with "Could not find release keystore", which reads like a
missing file.

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
scripts\movie.ps1 -Replay test/replays/level1.json -Seconds 20        # filmed run to a contact sheet
scripts\device.ps1 install|launch|log|shot|record|perf                 # the phone over adb
scripts\check.ps1                                                       # everything above that can run on the desk, in the order that fails fastest
```

Redirect long runs to a file and read the FILE. A PowerShell pipeline that assigns to a
variable buffers the whole run, so a hung command shows nothing at all.

**But `*> $log` does not write what the program printed.** It sends a native command's stderr
through PowerShell's error channel, so every line arrives as an `ErrorRecord` rendered
`Godot...exe : SCRIPT ERROR: ...` plus a `+ CategoryInfo` block, in UTF-16. `check.ps1`
counted `'^(SCRIPT )?ERROR'` over that file and so reported **`errors 0` for every Godot error
in every step, in every game built from the template**. It surfaced only because a throw
inside a smoke check skipped every assertion after it while the gate printed `smoke ok`.
Unwrap the records and write UTF-8:

```powershell
& $godot @a 2>&1 |
  ForEach-Object { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.ToString() } else { $_ } } |
  Out-File -FilePath $log -Encoding utf8
```

Same family as the `$ErrorActionPreference = 'Stop'` trap below: PowerShell treats native
stderr as an object rather than as text. **A log written by a shell is not the program's
output until you have decoded the bytes and looked at one known-bad line.**

## Invariants every game keeps

- **`src/sim/` may not reference a Node, a Viewport, an input event or a real frame.** If
  something in there needs to know about the world, it takes it as an argument. This is the
  rule that made a genre change three times in a day cost nothing in tests.
- **Nothing that affects game state may use `randf()`.** Place-keyed decisions go through
  `SimUtil.hash2` seeded on (chunk, level); stream-like values through `SimRng`. A value that
  decides *when* something happens is simulation even if it looks like decoration.
- **The hash uses unsigned shifts on a masked 32-bit value.** A signed shift silently
  returns only `[0, 0.5)` and disabled three shipped mechanics for a game's whole life.
  `test_util.gd` asserts the range and the distribution.
- **Physics is for debris, which decides nothing.** A pendulum, a structure, anything the
  game is scored on is arithmetic in `src/sim/`. A `RigidBody3D` on a joint puts the outcome
  inside the physics server and ends any chance of a golden. `techniques/wrecking-crew-pendulum.md`.
- **One writer per UI phase.** `_set_phase()` assigns AND recomputes every screen's
  visibility. Assigning the phase next to a `_show_screens()` call worked in four places out
  of five; the fifth left a screen drawn over the whole game.
- **Anything that restarts a level for a gameplay reason pushes the save back in
  afterwards**, or buying a boost wipes the player's money. `Sim.restart()` zeroes run
  state; progress lives in `save.gd`.
- **A finished level starts the next one and running out restarts.** `run_smoke.gd` drives
  THROUGH every terminal state, because a suite that stops where the content stops cannot
  see past the end of the content.
- **Every row in a content table is reachable in play**, and `test_tuning.gd` proves it.
- **Every interactable has visible mesh within arm's reach of its point.** Visible: a
  hidden mesh let a lamp that is off until bought stand in for one that is there.
- **Nothing in the HUD is positioned against a literal screen size.** See layout below.
- **A golden over floats uses `TestHarness.FLOAT_EPS`.** `snappedf` does not round-trip
  through a source literal, and goldens are recorded on Windows and checked on Linux.
- **Freeze before advancing** in any harness, or results move with the speed of the machine.

## Layout: the base resolution is a lie about height

`display/window/stretch/mode = canvas_items` with `aspect = expand` keeps the base width and
extends the height to the device. A 1080x1920 project renders into roughly 1080x2340 on the
S26 Ultra, so anything placed against the literal 1920 lands hundreds of pixels high. The
player's report was "the buttons are about half an inch too high".

- One `Control` with `PRESET_FULL_RECT` inside a `CanvasLayer`; everything anchors to it.
  `PRESET_CENTER_BOTTOM` plus a negative `offset_bottom` puts a thumb control a fixed distance
  from the real bottom edge at any aspect.
- Apply `DisplayServer.get_display_safe_area()` as margins on `_ready` and on `size_changed`,
  required once `screen/edge_to_edge` is on - but **guard it behind `OS.has_feature("mobile")`
  and make it exactly zero everywhere else.** Off a phone it returns the usable DESKTOP (the
  monitor minus the taskbar), which has nothing to do with the game's window, and applying it
  displaced Gravewell's d-pad 104 px upward (M). Convert through
  `DisplayServer.window_get_size()`, never `screen_get_size()`: the safe area is measured in
  window pixels and the margins are viewport units, so mixing in the monitor makes the answer
  arbitrary. Assert the margins are zero off a phone - a structural claim is the only kind a
  headless run can make about layout, and this bug walked straight past the anchored-not-placed
  test. A drawn control moves with its own hit box, so a screenshot shows it in a sensible
  place; what found it was a filmed replay whose taps landed in empty space.
- **Every interactive control handles its own input** through `_gui_input` and calls
  `accept_event()`, with `mouse_filter = STOP`. Position and hit box are then one object. A
  manual `_unhandled_input` hit test is a second source of truth for where a button is.
- **No headless test can catch a layout bug**: headless runs use the base size, where wrong
  and right are identical. Screenshots go through `--resolution 460x996`, and CI asserts the
  *property* (the control resolves from the viewport edge), not the position.

## Touch and scrolling

- **A `ScrollContainer` does not scroll from a finger.** Measured: wheel 50, pan gesture 400,
  `InputEventScreenDrag` **0**, and `emulate_mouse_from_touch` does not help because a drag
  is not a wheel. Translate the drag by hand in `_gui_input`:
  `scroll.scroll_vertical -= int(event.relative.y); accept_event()`. Rows inside need
  `MOUSE_FILTER_IGNORE` or each row swallows the gesture.
- **Shrink the view on purpose to test a scrolling list.** Seven rows fit on a phone, so at
  real size the test passed having exercised nothing.
- Prefer `InputEventScreenTouch` / `InputEventScreenDrag` with `index` for multi-touch.
  Leave `emulate_mouse_from_touch = true` so Controls work. For desk testing, set
  `Input.emulate_touch_from_mouse = true` at runtime from a `--touch` user arg.
- `Input.vibrate_handheld(ms, amplitude)` needs `permissions/vibrate` in the export preset or
  it silently does nothing. Ticks: 10-30 ms, amplitude 0.3-0.6.
- Godot 4.7 has a built-in `VirtualJoystick` control (fixed, dynamic, following). Use it
  before writing another.

## Headless lifecycle, which is where the time goes

- **`_ready` does not run at `add_child()`** inside `SceneTree._initialize()`; it is deferred
  to the first processed frame. Symptom: hundreds of `Nonexistent function ... in base 'Nil'`
  and a run that never terminates. Guard with an idempotent `_ensure_booted()` called from
  `_ready` and from every harness entry point.
- **`Transform3D.looking_at`, never `Node3D.look_at`**: the node method errors outside the
  tree. **`global_transform` outside the tree returns IDENTITY** without erroring. In any
  harness use `transform` and keep the node a direct child of a root that never moves.
- **Control layout only resolves during a frame.** A harness that does everything in
  `_initialize()` finds every `Control` at zero size. Let three frames pass and assert the
  rects are non-zero before any click.
- **`Viewport.push_input(event)` does nothing for the GUI unless `in_local_coords = true`.**
  Measured on a bare `Button`: zero presses without it, one with. A click that hits nothing
  is not an error, so a UI test goes green having proved nothing.
- **A headless run allocates no MultiMesh buffer.** Instance colours read back black there
  and prove nothing. `visible_instance_count` is CPU-side and reliable; build smoke tests on
  it. **`visible_instance_count` is also the flush**: forgetting it fails completely silently.
- **`MultiMesh.use_colors` must be set BEFORE `instance_count`** or every instance is
  silently untinted.
- **Start audio playback from `_ready`**, never `_enter_tree` or right after `add_child`,
  or every player logs "Playback can only happen when a node is inside the scene tree".
- **An engine `ERROR:` line is a test failure** even when every assertion passes. The runner
  fails on any of them. **Free the scene the smoke test built before quitting**, or the run
  ends with resources still in use.
- **A test must not depend on what the case before it left on disk.** Reset the file AND
  the value the object loaded from it.
- **A new `class_name` is invisible until re-import**, and the failure mode is a hang with
  no output. `--import` after adding one.
- **A parse error in a script the harness loads produces a run that never terminates**, not
  a failure. Read the TOP of the log. Tell a parse error from slow code by CPU share:
  ```powershell
  $p = Get-Process -Name "Godot*" | Select-Object -First 1
  "CPU={0:N1}s elapsed={1:N1}min" -f $p.CPU, ((Get-Date) - $p.StartTime).TotalMinutes
  ```
  Real work pins a core. A ratio well under 100% means the file is broken, not slow.
- **A value read out of a Dictionary is a Variant and `:=` cannot infer from one.** Annotate
  the local: `var pos: Vector3 = c.pos`. `grep -rn 'var [a-z_]* := .*\["' src/ test/` finds
  every one in a second and the failure mode is a five-minute hang each.
- **Godot eats a leading `--` even after the `--` separator**, so a user flag is a bare word.

## Rendering traps

- `rendering/textures/vram_compression/import_etc2_astc = true` is **required** for an
  Android export. Changing it does not re-import existing textures: delete `.godot/imported`
  and `--import` again. `config/icon` is required or the export errors.
- **The `.hdr` import default is uncompressed** and six skies cost 14 MB of APK. Set
  `compress/mode=2` and `process/size_limit=512` in the `.import`; 2.1 MB becomes 175 KB and
  on a sky it is invisible. `ls -laS .godot/imported` after any import is the only place the
  real cost shows.
- **Inverted-hull outlines do not work on a `MultiMeshInstance3D`** (the hull draws over the
  object even six centimetres inside it). Use a fresnel rim in the material:
  `e = smoothstep(ink_width, ink_width * 0.35, abs(dot(NORMAL, VIEW)))`, written so that
  zero width means no line.
- **`DEPTH_TEXTURE` is corrupt on Forward Mobile with MSAA.** Do not turn MSAA off. When a
  shader wants to know something about the world, the simulation usually already owns it:
  upload the heightfield as a small texture and sample by world position. Exact, testable
  headlessly, and the picture cannot disagree with the rules.
- **`Basis.scaled()` scales the WORLD axes**, not the mesh's own. A cylinder rotated to lie
  along X is scaled `(length, radius, radius)`. Getting it backwards looks like a layout bug
  and is a transform one.
- **`TorusMesh` has no arc parameter.** A curved arm is a post and a leaning boom.
- **A procedural surface can be the expensive thing.** Thirteen octaves of noise over a
  third of the screen cost 1.60 ms a frame; two texture samples of a 36 KB texture cost
  0.82 ms, within noise of a flat material (M, vsync off). Measure with vsync off, and build
  the cheap case with the SAME uniforms.
- **Do not derive a normal from `dFdx`/`dFdy` on a surface seen at a grazing angle.** It is
  a speckle generator.
- **`Light3D.light_cull_mask` and `VisualInstance3D.layers` really do exclude a light from
  an object** in Godot. That is one flag, not a second pass. The opposite rule in
  `techniques/three-js-traps.md` is a three.js limitation.
- **Walking a path once per follower is quadratic and reads as a hang.** One backward walk
  emits every follower as it crosses each threshold.
- Anti-aliasing on a phone: MSAA 2x at most, or FXAA. Keep `scaling_3d/scale` around
  0.75-0.85 for a heavy scene while the UI stays crisp.
- **A shader that computes its own lighting must say so: `render_mode unshaded`.** `ALBEDO`
  in a lit `shader_type spatial` is not the colour that reaches the screen, it is the base
  colour that LIGHTS MULTIPLY - so a surface excluded from every light (via `light_cull_mask`)
  has nothing to multiply it by and renders black at every value of every constant. Either go
  `unshaded` and write the finished colour to `ALBEDO`, or write the computed light to
  `EMISSION`. Nothing warns. Gravewell lost two rounds to the falloff curve first, which is
  the tell: a complaint that survives a correct fix is about something else.
- **When a value is computed correctly and displayed wrongly, RENDER THE VALUE.** A shader has
  no `print`, so the screen is its only readout: `ALBEDO = vec3(f.g, f.r, 0.0); EMISSION =
  same;` and one screenshot ruled out the solver, the upload, the world-position mapping and
  the texture format together. Three plausible hypotheses had been reasoned about first (a
  half-texel UV offset, `source_color` sRGB-decoding a data texture, a wrong uniform) and all
  three were consistent with the symptom and none was true. This is `CRAFT.md`'s "attribute an
  artefact to a layer before touching the maths" one level down - which of my NUMBERS is
  wrong - and it should be the first move, not the fifth.

## Export, signing and the two builds

| | `Android` preset | `Android Release` preset |
|---|---|---|
| Output | `.apk` | `.aab` (what Play accepts) |
| Build | prebuilt template, seconds, no Gradle | Gradle, minutes, ~300 MB on a cold run |
| Signed with | debug key | upload key from `C:\dev\keys` |
| Trigger | every push to `main` | a `v*` tag |

- **Anything a tool writes INTO the project directory is a candidate for the package, and
  `.gitignore` has no say in it.** A sixty-second film is 3,720 PNGs in `build/`, the exporter
  walks the project directory, and Gravewell's next APK was **1.42 GB** (M) - a 4,933% growth
  that only the size guard noticed, because the export itself succeeded, printed `DONE`, and
  merely took ninety seconds instead of twelve. Two fixes, because they fail differently:
  `exclude_filter="build/*, *.log, *.apk, *.aab, *.idsig"` in **every** preset keeps it out of
  the package, and a `build/.gdignore` keeps it out of the import cache. The marker has to
  survive `.gitignore`, so that needs **`build/*`** then `!build/.gdignore`: `build/` ignores
  the DIRECTORY, git then refuses to descend into it, and the negation under it can never
  match - which is why it first got written as `!build/`, re-including every output file, so
  one `git add -A` staged 3,905 of them.
  **This is the case for a size guard from the first commit**: nothing else in the gate had an
  opinion, and the game inside the 1.42 GB APK worked perfectly.
- **`.gdignore` is the load-bearing half of that pair, not `exclude_filter`.** The filter
  protects the package, which is hit on an export; the marker protects the importer, which is
  hit on every run of the gate. Stillwater deletes its frames after each contact sheet, so it
  was fully immune to the first and fully exposed to the second: `.godot/imported/` held
  **1.7 GB** across 2,646 entries and the gate's import step had drifted 5.8 s -> 80 s (M).
  Godot imports a frame the moment it appears and keeps the copy forever; deleting the source
  reclaims nothing. **A gate step that gets slower over a session is a symptom, not a slow
  machine** - `check.ps1` prints each step's duration, which is the only reason it was
  recoverable. Tidying an existing repo needs `build/**/*.import` and the matching
  `.godot/imported/` entries deleted by hand once. And when two fixes address one fault,
  removing one and measuring proves nothing: the first "before" measurement here came out
  identical because the other fix was still in place.
- **AAB export is only valid with `gradle_build/use_gradle_build = true`**, and Gradle is
  the only way to set `target_sdk` (Play requires 36 and it rises every year).
- **`--install-android-build-template` only works alongside an export command.** Alone it
  opens the editor and never returns.
- **`GRADLE_OPTS=-Dorg.gradle.daemon=false` for any release export**, or Godot writes a good
  bundle and waits forever on the daemon.
- **Verify the artifact, not the exit code.** The exporter has returned -1 with a valid
  bundle and 0 with nothing. Check the file exists, is plausible in size, and passes
  `jarsigner -verify`. Verify the target SDK from `android/build/config.gradle`, not from the
  bundle (an AAB manifest is protobuf and `aapt2` returns nothing, which passes).
- **Never invoke Godot through `Start-Process -ArgumentList`**: it drops the quotes and
  `Android Release` arrives as two arguments. `scripts/export_release.bat` exists for this.
- **`ANDROID_DEBUG_KEYSTORE_B64` must be a repository secret** or every CI build is signed
  with a throwaway key and Android refuses to update the installed app. `/game-scaffold`
  sets it with `gh secret set` at repo creation, along with the upload key secrets.
- **Never import `config/quit_on_go_back=false` on its own.** It is half a mechanism: the
  other half is `NOTIFICATION_WM_GO_BACK_REQUEST` in `_notification`, unwinding **one** layer
  per press in the order the game stacks its screens, and quitting only when nothing is open.
  Godot's default throws the player's run away on a stray back press; the setting with no
  handler produces a dead system button, which is worse, because a player presses it again
  harder rather than concluding the game is fine. Neither state shows in a headless suite.
  Assert the unwinding, never the setting - a config line cannot fail. A game with no pause
  screen still handles back, because `NOTIFICATION_WM_CLOSE_REQUEST` does **not** arrive on an
  Android back-out, so that is where the save has to happen.
- `android/` is gitignored (it is the unpacked export template, not source).
- The Android launch component is `<unique_name>/com.godot.game.GodotAppLauncher`.
  `.GodotApp` itself is not exported. Godot's logcat tag is `godot`.

## Measured on the phone

S26 Ultra, 2026-09-08, placeholder scene: Vulkan 1.4.295, Forward Mobile, Adreno 840,
`dumpsys gfxinfo` over 44 frames gave 5 ms at the 50th, 90th and 95th percentiles, one janky
frame, 1 ms GPU at the median. That is the engine and the pipeline, not a game, and the
ceiling is nowhere near. Thermal throttling after five to ten minutes of sustained rendering
is the constraint that matters on a phone; fill rate feeds it, draw calls do not (see
`WEB.md` for the draw-call measurement that put the "50 to 100 calls" folklore off by 30x).

## CI

`barichello/godot-ci:4.7.2` for both jobs. The image may not carry an Android SDK, so the
workflow looks for one, installs it if missing, and prints what it found. Every path check
fails with the directory it wanted. Poll the run with
`gh run watch` or `gh run list --limit 3`, never with a 15-second unauthenticated curl loop
(it burns the API budget and then prints nothing, which reads as "still running"). A check
that cannot determine the answer must say so, never say nothing. Do not report a push as
done while the check is in flight.

## Tools that do not exist here, and what to use instead

- Windows has no ImageMagick; `convert` is a disk utility. Use `ffmpeg` for images and
  `npx sharp-cli` for resizing.
- **Never rewrite a source file through PowerShell `Get-Content`/`Set-Content`**: 5.1 reads
  a BOM-less file as ANSI and corrupts every non-ASCII byte. Use the Edit/Write tools, or
  `[System.IO.File]::ReadAllText/WriteAllText` with `UTF8Encoding($false)`.
- **Never put backslash escapes in a Python heredoc through the Bash tool.** Write the
  script to a file and run it, with an `assert pattern in text` beside every replace.
- **Do not juggle source files through the shell for a two-line experiment**, and never
  `git checkout -- <file>` on a file with uncommitted edits. Commit before probing.
- **Normalise line endings on day one**: `* text=auto eol=lf` in `.gitattributes`, one pass
  converting the repo, before the first bulk edit. Mixed endings inside a file defeat every
  exact-match edit silently.
