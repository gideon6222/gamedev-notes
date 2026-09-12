# A missing machine-level dependency fails once per test, and the instruction is buried in the first one

**Game:** coreward  **Date:** 2026-09-12  **Belongs in:** WEB.md / The stack

## What happened

`npm run check` on a machine that had never run Playwright: typecheck clean, 286
node tests passing, build fine, bundle within budget, then **39 failed e2e tests**,
every one of them the same line:

```
Executable doesn't exist at C:\Users\...\ms-playwright\chromium_headless_shell-1243\...
```

The instruction that fixes it (`npx playwright install`) is drawn inside a box in
the middle of failure number one, and is then repeated 38 more times. Reading the
tail of that output tells you 39 things are broken about the game. Nothing is: the
browser binaries are a machine-level download that `npm install` does not perform
and the repo does not carry, like Godot or the JDK on the native side.

The Godot repos have no equivalent because `check.ps1` resolves the Godot binary by
path and says so when it cannot find it. The web stack had no such preflight.

## The rule

A dependency that lives on the machine rather than in the repo gets a preflight that
fails ONCE, before the suite, naming the install command. `coreward/scripts/check-e2e-browser.mjs`
checks `chromium.executablePath()` exists and exits 1 with the one line to run;
`npm run e2e` is now `node scripts/check-e2e-browser.mjs && playwright test`.

More generally: when a missing prerequisite makes every case in a suite fail
identically, the suite is reporting the prerequisite N times and the game zero times.
Check the prerequisite first and fail once.

## Replaces or contradicts

Nothing. `WEB.md`'s stack table gained `npm run check` in the 2026-09-12 digest but
says nothing about the browsers being a separate, machine-level install. That is the
line to add.
