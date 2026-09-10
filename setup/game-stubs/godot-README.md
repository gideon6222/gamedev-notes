# {{NAME}}

{{DESCRIPTION}}

A phone game for Android built in Godot 4.7. Every push to `main` builds a signed APK and
attaches it to a GitHub Release; tap the latest release on the phone to install or update.
A `v*` tag builds the Play bundle.

```powershell
scripts\check.ps1                                   # tests, smoke, guards
& $env:GODOT --headless --path . --export-debug "Android" build/{{SLUG}}.apk
scripts\device.ps1 install                          # onto the phone over adb
```

Built with Claude Code from `C:\dev\godot-template`, on the process in
`C:\dev\gamedev-notes`. Assets are credited in `assets/CREDITS.md`.
