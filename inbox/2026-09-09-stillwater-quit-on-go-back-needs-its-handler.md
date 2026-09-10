# `quit_on_go_back=false` and the `_notification` that handles GO_BACK ship in the same commit, or the back button is dead

**Game:** stillwater  **Date:** 2026-09-09  **Belongs in:** GODOT.md / Android and export, plus POLISH.md as a ship-gate line

## What happened

Framework v2's `project.godot` carries `config/quit_on_go_back=false` with the comment "the
Android back button is handled by the game (pause in play, back in menus), never a quit."
Copying that line into Stillwater would have been a one-line import - and Stillwater's
`main.gd` handled `NOTIFICATION_WM_CLOSE_REQUEST` and `NOTIFICATION_APPLICATION_PAUSED` but
not `NOTIFICATION_WM_GO_BACK_REQUEST`, so the setting on its own would have made the back
button do **nothing at all**.

Both states are shippable and neither shows in a headless suite. Godot's default quits the
app, which from inside an open logbook throws the player's morning away and reads as a crash.
The setting with no handler produces a dead system button, which reads as a hung app - the
worse of the two, because a player will press it again harder rather than conclude the game
is fine.

The handler that was actually needed is a single unwinding of the layers `_hud_is_down()`
already knows about: book, room, cinematic, title, and only then save and quit. Twelve smoke
assertions cover it, and all twelve were verified by putting `return false` at the top of
`_go_back()` and watching them fail.

## The rule

Never import `quit_on_go_back=false` on its own. It is half of a mechanism: the other half is
`NOTIFICATION_WM_GO_BACK_REQUEST` in `_notification`, unwinding **one** layer per press in the
same order the game stacks its screens, and quitting only when nothing is open. Assert the
unwinding rather than the setting - the setting is a config line that cannot fail, the
behaviour is what breaks. A game with no pause screen still handles back: it closes what is
open and saves on the way out, because `NOTIFICATION_WM_CLOSE_REQUEST` does **not** arrive on
an Android back-out.

## Replaces or contradicts

Nothing states this today. It sharpens the template's own comment on
`config/quit_on_go_back=false`, which describes the intent ("handled by the game") as though
the setting delivered it. The template ships that setting with a `main.gd` that does not
handle GO_BACK either, so every game scaffolded from it inherits a dead back button until
someone writes the handler - worth fixing in the template, or at minimum saying so in
`GODOT.md`.
