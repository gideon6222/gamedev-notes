# The launcher icon and the boot splash are two separate engine-default faces, so fixing the icon ticks nothing about the splash—set application/boot_splash/image and bg_color to the game's own and assert both with a test that reads ProjectSettings, and expect Android's own system splash to stay dark until a gradle build overrides it.

**Game:** stillwater  **Date:** 2026-09-12  **Belongs in:** POLISH.md / launcher icon / splash checklist

## What happened

Stillwater's T4 polish milestone replaced the Godot logo in the launcher icon slots and was ticked. A phone playtest over adb the next day relaunched the app after a back-out and the screenshot 0.6 s after launch showed "GODOT Game engine" on a dark grey plate: the boot splash (`application/boot_splash/image` and `bg_color` in project.godot) was still at its engine default, and nothing had looked at it because the launcher icon was the face everyone checked. Fixed by setting `boot_splash/image` to the 512 px launcher icon PNG (whose own transparent ground is the same tint), `boot_splash/bg_color` to the dawn sky sampled off a phone screenshot (200,195,191), `fullsize=false`, and a pure test in test_assets.gd that reads the two settings through ProjectSettings and asserts the image path is set AND the file exists AND the plate's luminance is above 0.3 (Godot's default is 0.14 grey)—verified failing by setting the defaults back in memory in a probe. Two further facts: (1) POLISH.md names `splash_screen/disable_godot_boot_splash`, which does not exist in the Godot 4.7 Android export preset—the boot splash is the `application/boot_splash/*` project settings; (2) on Android 12+ there is a SECOND splash before Godot's, the OS SplashScreen, which shows the launcher icon on a plate whose colour comes from the export template's theme (dark by default) and is not a project setting—changing it needs a gradle build with a theme override, so the launch is dark plate then game plate until that is done.

## The rule

The launcher icon and the boot splash are two separate engine-default faces, so fixing the icon ticks nothing about the splash. Set `application/boot_splash/image` and `bg_color` to the game's own and assert both with a test that reads ProjectSettings. Expect Android's own system splash (a theme colour, not a project setting) to stay dark until a gradle build overrides it.

## Replaces or contradicts

a splash that matches the game's palette, `splash_screen/disable_godot_boot_splash` on, a 512 px
