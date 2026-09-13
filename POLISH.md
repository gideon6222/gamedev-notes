# POLISH.md - what "complete" means on a phone, and the ship gate

A game is finished when every line below is true, not when the mechanic works. `/ship` walks this
list and refuses to ship on a no. Everything here is cheap compared to the mechanic, and it is
what separates "a prototype that runs" from a game he would choose over the ones already on his
phone. Edited only by `/digest`.

**What may be deferred, and what may not.** A line is a yes, a no fixed now, or "not in this
phase" - and the last is only available under **Content**, for **Shell and system integration**
items that `PLAN.md` explicitly assigned to a later phase, with that phase named in the answer,
and for the one device carve-out named under **Performance and stability**. Nothing else under The
first sixty seconds, Feel, Presentation, Audio, Performance and stability or Repo hygiene may be
deferred. Read the same way at plan time: phase one owes every line that is not deferrable here.

## The first sixty seconds

- [ ] The game is playable within ten seconds of tapping the icon. No menu to wade through.
- [ ] The first thirty seconds need zero reading. The first minute gives a win.
- [ ] Every state on screen names a visible action, and the next goal is visible.
- [ ] Hazards are all in one colour family, no hazard shares a silhouette with a reward, and the
      reward is the brightest thing on screen.
- [ ] There is a reason to play again in five minutes: a thing you keep, a next unlock shown
      (exactly one teaser), a run that ended one decision short.

## Feel

- [ ] Every action fires visual, audio, camera and haptic feedback together. Hit-stop on the
      big ones (presentation only, never the sim clock).
- [ ] Movement has velocity and coasting; nothing snaps to a grid or stops dead. Smoothing
      is exponential and assigned, not added.
- [ ] Controls are thumb-sized, at the bottom, anchored to the real viewport, safe-area
      aware, and each control owns its input. The hit box is the drawing.
- [ ] Filmed run reviewed against the six questions (`TESTING.md`, spelled out in
      `techniques/filming-a-run.md`) and the answers are in `NOTES.md`.
- [ ] `test_controls.gd` passes: a real drag event through the real input handler moves the
      avatar the right way ON SCREEN, and the camera's own right vector satisfies
      `basis.x.x > 0.5`. Contact sheet re-shot after the last change to any length. Five games
      have shipped inverted with the rule written down; this line is the only thing that has
      ever caught it.

## Presentation

- [ ] Not "cartoony", which from him means under-lit and under-textured rather than a model
      style (`CRAFT.md` has the design reading, `PLAYER.md` his words): a real light with falloff,
      a normal map on the largest surface, and a sky that is not the
      Godot default: a Poly Haven HDRI or a `ProceduralSkyMaterial` with its colours set, named
      in `NOTES.md`.
- [ ] Post-processing under the HUD: a vignette in three stops, mid-tone grain, blacks
      lifted toward the scene colour.
- [ ] A self-hosted display family AND a self-hosted text family, two weights each, used
      everywhere. No default Godot font on any screen.
- [ ] Every interactable has visible geometry. If the game names a thing, the thing exists.
- [ ] Ambient motion in the idle state (water, dust, a sway) so a still frame is not a
      screenshot.
- [ ] The shop or upgrade screen is a place with the real object in it, scrolls from a
      finger, and its primary button is pinned to the bottom.
- [ ] Every menu and every room is drivable with on-screen up/down/left/right and a confirm as
      well as by touch: the selection is highlighted and shows its description, and left/right
      swaps a variant. Asked three times in two days (`PLAYER.md`).
- [ ] Every menu closes with an explicit X or back control. Tapping outside is never the only way
      out, and reaching the end of the content (the last page) does not close it by itself.
- [ ] A control that cannot do anything is visibly grey and one that can is not - the arrows, the
      select button, the primary button. No pips or arrows implying options that do not exist.
- [ ] Every screen has been looked at once as a picture at the phone's aspect.
- [ ] A phase check partitions over whatever the UI root actually holds, so a control added to one
      phase and forgotten in the other fails the moment it is added rather than drawing over the
      game for a release (`TESTING.md` has the shape, and `is_visible_in_tree()` is the test). Every
      node has a `name`. Nothing is drawn in both phases that is not on the written allow-list, and
      nothing is drawn in neither.

## Audio

- [ ] Sound for every action, with pitch jitter on repeats and a round-robin pool.
- [ ] Music with a written theme, a cadence and a pulse, crossfading on a gameplay quantity
      where the game has an arc. Ambience under it.
- [ ] Buses `Master / Music / SFX / UI`; music and SFX volume sliders in options that do what
      they say; a mute that persists. Nothing to switch that does not exist.
- [ ] Audio ducks and pauses on focus loss and resumes on return.

## Shell and system integration

- [ ] Main menu, options (audio, haptics, a graphics scale slider), pause, credits, and a
      confirmation before erasing progress. Maaack's **Godot Game Template**
      (`Maaack/Godot-Game-Template`, the one `/game-scaffold` installs) or the game's own shell
      built to the same standard.
- [ ] Version number, build stamp and patch notes reachable from the pause screen.
- [ ] A hand-rolled crash reporter prints the **stack**, not just the message. A message names
      what broke; a stack names what called it, and he has no console on the phone. Three hours
      went into placing a message that one frame would have named. On a phone it must also
      offer a way to clear the save, since a save that crashes the boot is otherwise
      unrecoverable without going into system settings.
- [ ] Progress saved to `user://` on every meaningful change and on
      `NOTIFICATION_APPLICATION_PAUSED`. Settings in a separate `ConfigFile`. Erase progress
      sets a one-way latch so the unload save cannot write it back.
- [ ] A test asserts the back button unwinds one layer per press and never quits with a screen
      open, and that the save fires on the last press. Assert the unwinding, never the setting -
      a config line cannot fail. Mechanism and both required halves: `GODOT.md`.
- [ ] Home then resume returns to a paused game, not a restarted one. Screen sleep is
      prevented during play (`keep_screen_on`).
- [ ] Orientation locked to portrait. Immersive mode on. Safe area applied.
- [ ] Haptics on hits and purchases, with `permissions/vibrate` set, and haptics used as a
      READOUT wherever a gauge is watched under pressure: a small pulse for the event, a heavier
      sustained one as the thing nears breaking. A continuous effort is one modulated loop, never
      a pulse per hit.
- [ ] Adaptive launcher icon (foreground, background, monochrome at 432 px) AND the boot splash
      set separately - they are two different engine-default faces. Set
      `application/boot_splash/image` and `bg_color` to the game's own and assert both with a
      test that reads `ProjectSettings`; expect Android's own system splash (a Gradle theme
      colour, not a project setting) to stay dark until a Gradle build overrides it.
      `splash_screen/disable_godot_boot_splash` does not exist in the Godot 4.7 Android export
      preset. A 512 px store icon exported. App name and package `com.gideon.<slug>` set.

## Performance and stability

- [ ] `scripts\device.ps1 perf` with the screen full, at the start of a session and again after
      ten minutes of play, both recorded in `NOTES.md`: **95th-percentile present-to-present frame
      time under 16.7 ms** (60 fps) in both, the ten-minute p95 **no more than 20% above** the
      opening one, and `dumpsys thermalservice` no worse than `THROTTLING_LIGHT` at the ten-minute
      mark. **The numbers must come from SurfaceFlinger `--timestats`, never `gfxinfo`**, which
      instruments HWUI and reports a confident `0 frames, 0 janky, 4950ms` for a Godot game - a
      gfxinfo reading is not a measurement and does not satisfy this line (`GODOT.md`,
      `techniques/measuring-frames-on-the-phone.md`). Wildform measured properly: every percentile
      8 ms over 2,117 frames, 0 dropped, 0 janky (M).
- [ ] No `ERROR:` lines in logcat across a full play session. No resources still in use at
      exit.
- [ ] Textures sized and compressed per `ASSETS.md`. APK inside its size budget, **weighed after an
      export in this commit**: the guard reads whatever APK is in `build/`, so run the check with
      `-Export` in any commit that adds, removes or reimports an asset and treat a green size step
      over a stale APK as no measurement at all. A shed of props went 35.6 to 64.58 MB, 81% past
      budget, green locally and red in CI a minute later (M).
- [ ] Launch, play through a level boundary, die, retry, buy, home, resume, back, quit: all
      exercised on the phone with `scripts/device.ps1` before shipping.
- [ ] **The one carve-out, worded the same way in `skills/ship/SKILL.md` so the two cannot
      drift:** the two Performance and stability lines that need the device - the `perf`
      percentiles at the start and after ten minutes, and the full launch-to-quit pass on the
      phone - may be deferred only when `adb devices` is empty. Record them in `NOTES.md` as "not
      run, no device", name the desk evidence that stood in, and run them on the next ship with
      the phone attached. Nothing else under Performance and stability may be deferred.

## Content

- [ ] The content ladder still has unreached rows after an hour: the progression probe reports
      the row reached at 60 minutes and the table's row count, and the first is lower than the
      second. Every row reachable and proven by a design test.
- [ ] A meta-goal that does not decay (a collection, a logbook, a relic per planet).
- [ ] The second month's content is sketched in `PLAN.md` even if not built.

## Repo hygiene

- [ ] CI green. APK attached to the release. Changelog entry written in the player's words.
- [ ] `CLAUDE.md`, `NOTES.md` and `PLAN.md` current. Milestone list ticked. The plan is
      called `PLAN.md` and its first unticked box is the answer to "what now".
- [ ] Version agrees everywhere, asserted by `test_version.gd`: `Changelog.VERSION`,
      `version/name` in **each** export preset, `RELEASES[0].version`, and `version/code` higher
      than the last release's (Play refuses an upload that does not raise it).
- [ ] `assets/CREDITS.md` complete, and the credits screen renders it.
- [ ] Lessons filed to `inbox/`, his words filed to `playtests/<game>.md`.
- [ ] Screenshot at 460x996, the APK link, the changelog entry and the numbered answers to
      his last message, sent together.
