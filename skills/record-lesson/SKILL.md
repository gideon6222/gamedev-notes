---
name: record-lesson
description: Record a lesson in the shared game-dev knowledge base the moment it is learned, without conflicting with other sessions. Use whenever something surprised you, cost time, contradicted a rule, measured a number, or when Gideon says "remember this" about game building. Also used to append his playtest words.
argument-hint: <game> <the lesson in one sentence> | playtest <game>
---

# Record a lesson

Other sessions are writing to `C:\dev\gamedev-notes` right now, so nothing here edits a
topic file. A lesson is one new file in `inbox/`; `/digest` folds it in later.

## A lesson

1. Ask: would this have saved time this morning? If not, it goes in the game's `NOTES.md`
   instead (game-specific decisions never come here).
2. Decide where it belongs, and check. Pick the topic file and section, then search that
   file for the rule itself, not for its title: the Grep tool on
   `C:\dev\gamedev-notes\GODOT.md` with a distinctive phrase from the rule, or
   `Select-String -Path C:\dev\gamedev-notes\GODOT.md -Pattern '<phrase>'`.
   What comes back is what goes in `Replaces or contradicts` - the line, quoted, as it
   actually reads. If nothing comes back, the field is `nothing`. Do not quote a line from
   memory: the audit found a lesson replacing a line that exists in no file.
3. Write `C:\dev\gamedev-notes\inbox\<YYYY-MM-DD>-<game>-<slug>.md` with the Write tool,
   **in exactly this shape**. All four headings, and both fields in the header line, every
   time:

   ```markdown
   # <The rule, as one sentence>

   **Game:** <slug>  **Date:** <YYYY-MM-DD>  **Belongs in:** <CRAFT|GODOT|TESTING|ASSETS|POLISH|PLAYER|WEB>.md / <section>, or techniques/<file>.md

   ## What happened
   One paragraph. What was tried, what the symptom was, what settled it. Numbers if measured.

   ## The rule
   One or two sentences a future session can act on without the story.

   ## Replaces or contradicts
   The existing line in the topic file this changes, quoted as it reads there, or "nothing".
   ```

   **`Belongs in:` and `Replaces or contradicts` are not optional.** `nothing` is a valid
   answer to the second; leaving the heading out is not. Those two fields are the whole
   interface to `/digest`: `Belongs in` puts the rule in the section a future session will
   actually open, and `Replaces or contradicts` is what makes the digest delete the old line
   instead of writing the correction beside it. A lesson missing either gets folded into the
   wrong file, or leaves a rule and its correction both standing. Both have happened: the
   2026-09-11 audit found 29 of 42 lessons with no `Replaces` field and two live
   contradictions in the base as the direct result. Do not invent a new header layout. A
   file that does not match this shape is one the digest has to guess at.
4. Commit it by name:
   `powershell C:\dev\gamedev-notes\scripts\kb.ps1 commit -Files inbox\<file> -Message "Lesson: <rule>"`

Prefer a measurement to a caution. If the lesson is "be careful with X", measure X and
write the number. If a lesson corrects a rule that is in context right now, act on the
corrected version for the rest of this session.

## His words (`playtest <game>`)

Append to `C:\dev\gamedev-notes\playtests\<game>.md` under `## <YYYY-MM-DD>`: his message
verbatim in a blockquote, then one line on what was done about each ask. Never paraphrase
the quote. Commit with `kb.ps1 commit -Files playtests\<game>.md -Message "Playtest <game> <date>"`.
If something in it generalises (a complaint that matches one in `PLAYER.md`, or a new
kind), also write an inbox lesson pointing at `PLAYER.md`.
