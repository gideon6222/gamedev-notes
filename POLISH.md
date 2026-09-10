# POLISH.md - what "complete" means on a phone, and the ship gate

A game is finished when every line below is true, not when the mechanic works. `/ship`
walks this list and refuses to ship on a no. Everything here is cheap compared to the
mechanic, and it is what separates "a prototype that runs" from a game he would choose over
the ones already on his phone. Edited only by `/digest`.

## The first sixty seconds

- [ ] The game is playable within ten seconds of tapping the icon. No menu to wade through.
      HOME is the level you are about to play with `advance` not being called.
- [ ] The first thirty seconds need zero reading. The first minute gives a win.
- [ ] Every state on screen names a visible action, and the next goal is visible.
- [ ] A new player can tell what to do, what hurts, and what is worth more, from the picture
      alone. Hazards in one colour family, the reward the brightest thing on screen.
- [ ] There is a reason to play again in five minutes: a thing you keep, a next unlock shown
      (exactly one teaser), a run that ended one decision short.

## Feel

- [ ] Every action fires visual, audio, camera and haptic feedback together. Hit-stop on the
      big ones (presentation only, never the sim clock).
- [ ] Movement has velocity and coasting; nothing snaps to a grid or stops dead. Smoothing
      is exponential and assigned, not added.
- [ ] Controls are thumb-sized, at the bottom, anchored to the real viewport, safe-area
      aware, and each control owns its input. The hit box is the drawing.
- [ ] Filmed run reviewed against the six questions in `TESTING.md` and the answers are in
      `NOTES.md`.
- [ ] The camera has been checked for handedness with the NDC test and re-shot after the
      last change to any length.

## Presentation

- [ ] A real light with falloff, a considered sky, and a normal map on the largest surface.
      "Cartoony" from him means under-lit and under-textured.
- [ ] Post-processing under the HUD: a vignette in three stops, mid-tone grain, blacks
      lifted toward the scene colour.
- [ ] A self-hosted font, two weights, used everywhere. No default Godot font on any screen.
- [ ] Every interactable has visible geometry. If the game names a thing, the thing exists.
- [ ] Ambient motion in the idle state (water, dust, a sway) so a still frame is not a
      screenshot.
- [ ] The shop or upgrade screen is a place with the real object in it, scrolls from a
      finger, and its primary button is pinned to the bottom.
- [ ] Every screen has been looked at once as a picture at the phone's aspect.

## Audio

- [ ] Sound for every action, with pitch jitter on repeats and a round-robin pool.
- [ ] Music with a written theme, a cadence and a pulse, crossfading on a gameplay quantity
      where the game has an arc. Ambience under it.
- [ ] Buses `Master / Music / SFX / UI`; music and SFX volume sliders in options that do what
      they say; a mute that persists. Nothing to switch that does not exist.
- [ ] Audio ducks and pauses on focus loss and resumes on return.

## Shell and system integration

- [ ] Main menu, options (audio, haptics, a graphics scale slider), pause, credits, and a
      confirmation before erasing progress. Maaack's Menus Template or the game's own shell
      built to the same standard.
- [ ] Version number, build stamp and patch notes reachable from the pause screen.
- [ ] Progress saved to `user://` on every meaningful change and on
      `NOTIFICATION_APPLICATION_PAUSED`. Settings in a separate `ConfigFile`. Erase progress
      sets a one-way latch so the unload save cannot write it back.
- [ ] The Android back button pauses in play, goes back in menus, and never quits without
      asking (`quit_on_go_back = false`, `NOTIFICATION_WM_GO_BACK_REQUEST` handled).
- [ ] Home then resume returns to a paused game, not a restarted one. Screen sleep is
      prevented during play (`keep_screen_on`).
- [ ] Orientation locked to portrait. Immersive mode on. Safe area applied.
- [ ] Haptics on hits and purchases, with `permissions/vibrate` set.
- [ ] Adaptive launcher icon (foreground, background, monochrome at 432 px), a splash that
      matches the game's palette, `splash_screen/disable_godot_boot_splash` on, a 512 px
      store icon exported. App name and package `com.gideon.<slug>` set.

## Performance and stability

- [ ] Steady frame rate with the screen full: `perf` percentiles recorded at the start and
      after ten minutes of play. No thermal climb into throttling in a normal session.
- [ ] No `ERROR:` lines in logcat across a full play session. No resources still in use at
      exit.
- [ ] Textures sized and compressed per `ASSETS.md`. APK inside its size budget.
- [ ] Launch, play through a level boundary, die, retry, buy, home, resume, back, quit: all
      exercised on the phone with `scripts/device.ps1` before shipping.

## Content

- [ ] Enough content that the next hour is not a repeat of the first: a ladder of levels,
      species, buildings or planets, each row reachable and proven by a design test.
- [ ] A meta-goal that does not decay (a collection, a logbook, a relic per planet).
- [ ] The second month's content is sketched in `PLAN.md` even if not built.

## Repo hygiene

- [ ] CI green. APK attached to the release. Changelog entry written in the player's words.
- [ ] `CLAUDE.md`, `NOTES.md` and `PLAN.md` current. Milestone list ticked.
- [ ] `assets/CREDITS.md` complete, and the credits screen renders it.
- [ ] Lessons filed to `inbox/`, his words filed to `playtests/<game>.md`.
- [ ] Screenshot at 460x996, the APK link, the changelog entry and the numbered answers to
      his last message, sent together.
