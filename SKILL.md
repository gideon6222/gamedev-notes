# Phone Game Studio — the skill

**This is the canonical copy.** The installed skill is a short pointer at this file, because
the plugin cache it lives in is re-extracted per session and edits to it do not survive.
Change this file; never edit the cache and expect it to last.

---

Gideon builds games with Claude Code on his Windows PC and plays them on a Galaxy S26 Ultra -
now as **installed Android apps** built in Godot, and before that as PWAs on the home screen.
Claude has a shell, node, git, Godot, the Android toolchain, a browser it can drive, and CI.
Nothing here is limited by what Claude can run.

**The goal is not to satisfy one request. It is to make each game better than the last** —
and that only happens if the knowledge base is read at the start and written to *continuously*,
not at the end.

---

## Pick the stack FIRST, because it decides where you start

There are two, and they are both current:

| | **Native Android (Godot)** | **Web (PWA)** |
|---|---|---|
| Start from | **Copy `C:\dev\godot-template`** | Copy the last web game |
| Language | GDScript, statically typed | TypeScript + three.js |
| Ships as | A signed APK on a GitHub Release | GitHub Pages |
| Games | Wrecking Crew | Coreward, Candle Gift, Wick |

**Default to Godot for anything new.** It is where the work is going: a real Play listing is
possible, the GPU is the ceiling rather than a WebView, and - the one that keeps surprising -
**there is no download-size constraint**, so imported assets are finally worth having. The web
stack is not deprecated; it is just the right answer for fewer things now.

Take the web stack when the game genuinely wants to be a link: something to send someone, or
something that has to run without installing anything.

**The Godot path in one line:** copy `C:\dev\godot-template` (excluding `.git`, `.godot`,
`android` and `build`), `git init`, rename the project in `project.godot`,
`export_presets.cfg`, `README.md` and `CLAUDE.md`, reset `changelog.gd` to 0.1.0, ask Gideon
for an empty public repo, push. Its `CLAUDE.md` has the toolchain paths and the full invariant
list; **read that before writing any game code**, because most of it is not obvious from the
source.

## Before designing anything

Read, in this order:

1. **`PIPELINE.md`** — both stacks, how to ship, and the measured limits. This is where you
   find out what is actually constrained and what is not. The Godot section is at the end.
2. **`CRAFT.md`** — what makes a game good. Organised by topic, and **all of it applies to
   both stacks** — it is about games, not about a language.
3. **`ASSETS.md`** — before importing anything at all. Note that its central rule was
   rewritten once the native stack existed; read the exception at the top.
4. **`PLAYTESTS.md`** — for an existing game, what he has already said about it. Complaints
   first. Even for a NEW game it is worth ten minutes: the same five or six faults keep
   recurring across different games, and they are all listed there in his words.
5. **The game's own `CLAUDE.md` and `NOTES.md`**, which override anything general. The game
   knows more about itself than the shared notes do. For a new Godot game that means
   `godot-template/CLAUDE.md`.

If `gamedev-notes` is missing, say so plainly and ask him to create it. Do not skip it.
Without it nothing compounds.

---

## Research

Do not build from instinct alone. Run targeted searches for the specific thing this game
needs, and pick at least one technique per game that has not been used before. Good searches
are narrow: the genre's core loop and why it holds attention; a visual technique that would
lift *this* game; a mobile performance approach not yet tried.

Name the new technique in the design brief, and record what it taught in `CRAFT.md` when you
learn it — not afterwards.

---

## Design brief

Before writing code, a short brief in chat: the core loop in one sentence, what makes it fun,
what the first sixty seconds feel like, and the one new technique. A paragraph or two. He does
not need a document, he needs to know what he is getting.

---

## Build

**Set the game up to be continued, before writing any game logic.** Every game gets the full
stack — git, CI, the size guard, a golden test, `CLAUDE.md`, `NOTES.md`, a build stamp and a
changelog. There are no one-off games here, so there is no "start simple and migrate later":
that trade always loses, because the migration then has to happen around a game you are trying
not to break. On Godot that is a `cp -r` of the template; on web it is twenty minutes copied
from the last game.

**The one structural rule that carries both stacks: a pure simulation core with no renderer in
it.** Everything else follows from it — the whole-run golden, the headless tick seam, the
ability to rewrite the presentation without touching game logic. Wrecking Crew changed genre
three times in a day and the test suite came across every time; that is the entire return on
this rule, and it is worth more than any individual test.

And regardless of what the game is:

- **Touch controls sized for a thumb**, bottom of the screen, safe-area aware — and
  **anchored to the viewport, never placed at a literal coordinate.** See the layout rule in
  `PIPELINE.md`; getting this wrong is a shipped bug in two different games now.
- **Every interactive control handles its own input**, so its hit box and its drawing are the
  same object.
- **Progress saved** — `localStorage` on web, `user://` on Godot.
- **A build stamp, a version number and a changelog.** Add these on day one.
- **Playable within ten seconds of opening.** No menus to wade through.
- **A way OUT of every level.** Finishing one must start the next; running out must restart.
  This has shipped broken once and reads to the player as a crash.
- **Real 3D** unless the game genuinely reads better flat.

---

## Ship

Push straight to `main`; CI is the gate. **Confirm CI went green** - that is one call and is
not the same as polling the live site, which you should not do. On Godot the artifact is a
signed APK on a GitHub Release; hand him the download link. Details and the phone-update
behaviour are in `PIPELINE.md`.

**Send him a screenshot with it.** On Godot that is `scripts/shot.gd`, rendered at the phone's
own aspect ratio rather than the project's base one - the two differ, and things that are
wrong only show up at the real one.

---

## Record — continuously, not at the end

**This is the step that makes the next game better, and the one most likely to be skipped.**

Write the lesson **in the same commit as the change that taught it**. Not in a wrap-up. He
runs several games at once, so a lesson that lands after this game finishes is a lesson the
next game never got.

- **`CRAFT.md`** — anything that generalises. Find the topic section; add it there. Do not
  append a dated block.
- **`PIPELINE.md`** / **`ASSETS.md`** — rewrite in place when a fact changes. If you measure
  something, put the number in and delete the guess it replaces.
- **`PLAYTESTS.md`** — his words, dated, when he says them. Append only.
- **The game's `NOTES.md`** — decisions specific to this game, and what to do next in it.

The test for whether something belongs: *would this have saved time if I had known it this
morning?* If yes, write it now, even mid-build. A revised lesson is cheap; a missing one is
not.

**Prefer a measurement to a caution.** If a rule anywhere reads like a guess or a
precaution — "keep it small", "be careful with memory" — go and measure the real number,
write it down, and delete the caution.

---

## Quality bar

Check before calling anything finished:

- Can he tell what to do without being told?
- Does the first minute give him a win?
- Is there a reason to play again in five minutes?
- Does every action produce visible, audible and physical feedback?
- Does it hold a steady frame rate with the screen full?
- Would he choose this over the games already on his phone?

If any answer is no, fix it before shipping rather than after.
