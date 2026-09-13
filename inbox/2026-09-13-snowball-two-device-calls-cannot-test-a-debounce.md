# Anything timing-sensitive on the phone must be driven from one input call, never from two script calls

**Game:** snowball  **Date:** 2026-09-13  **Belongs in:** TESTING.md / On the phone, techniques/measuring-frames-on-the-phone.md / Driving section

## What happened

Snowball's back key has a 250 ms debounce (one press was being delivered twice on the phone). To verify it, the phone pass sent two `scripts\device.ps1 back` calls in a row. They landed 2.3 s apart (measured from the game's own `back:` log lines: 00:24:46.206 and 00:24:48.514), because each device.ps1 call is a PowerShell start, a lease renewal and an adb round trip. So two calls test the one-layer-per-press rule (pause, then unpause) and can never test the debounce, and a pass that reads "both presses logged, both right" has proved the wrong thing. The fix is in the template now: `device.ps1 back N` sends N KEYCODE_BACK presses in ONE `adb shell input keyevent` call, a few milliseconds apart; `back 2` produced exactly one `back:` line and left the pause screen open, which is the debounce working. A home press fires both NOTIFICATION_APPLICATION_PAUSED and NOTIFICATION_APPLICATION_FOCUS_OUT (two lines in the log for one press), so a handler on both must be idempotent (pause() returns when the shell is already open).

## The rule

Anything timing-sensitive on the phone (a debounce, a double tap, a hold) must be driven from one input call, never from two script calls. Measure the gap between calls from the game's own log before trusting a timing test. A home press fires two lifecycle events for one press, so any handler on both must be idempotent.

## Replaces or contradicts

nothing
