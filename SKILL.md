# Phone Game Studio — the skill

**This is the canonical copy.** The installed skill is a short pointer at this file, because
the plugin cache it lives in is re-extracted per session and edits to it do not survive.
Change this file; never edit the cache and expect it to last.

---

Gideon builds games with Claude Code on his Windows PC and plays them on a Galaxy S26 Ultra,
installed to the home screen as PWAs. Claude has a shell, node, git, a browser it can drive,
and CI. Nothing here is limited by what Claude can run.

**The goal is not to satisfy one request. It is to make each game better than the last** —
and that only happens if the knowledge base is read at the start and written to *continuously*,
not at the end.

---

## Before designing anything

Read, in this order:

1. **`PIPELINE.md`** — the stack, how to ship, and the measured limits. This is where you find
   out what is actually constrained and what is not.
2. **`CRAFT.md`** — what makes a game good. Organised by topic; read the sections relevant to
   what you are building.
3. **`ASSETS.md`** — before importing anything at all.
4. **`PLAYTESTS.md`** — for an existing game, what he has already said about it. Complaints
   first.
5. **The game's own `CLAUDE.md` and `NOTES.md`**, which override anything general. The game
   knows more about itself than the shared notes do.

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

Pick the stack by the game, not by a limitation — see `PIPELINE.md`. A one-session game can be
plain static files; anything that will be returned to should have the build, the tests and the
size guard from the start.

Non-negotiables regardless of stack:

- **Touch controls sized for a thumb**, bottom of the screen, safe-area aware.
- **An on-screen error overlay**, registered in `<head>`. He has no console.
- **Progress saved to `localStorage`.**
- **A build stamp, a version number and a changelog**, in a menu. Add these on day one.
- **Playable within ten seconds of opening.** No menus to wade through.
- **Real 3D** unless the game genuinely reads better flat.

---

## Ship

Push straight to `main`; CI is the gate. Say it is pushed and stop — do not poll the live site,
and do not gate on a preview. Details and the phone-update behaviour are in `PIPELINE.md`.

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
