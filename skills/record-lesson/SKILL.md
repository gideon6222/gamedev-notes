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
2. Write `C:\dev\gamedev-notes\inbox\<YYYY-MM-DD>-<game>-<slug>.md` with the Write tool:

   ```markdown
   # <The rule, as one sentence>

   **Game:** <slug>  **Date:** <date>  **Belongs in:** <CRAFT|GODOT|TESTING|ASSETS|POLISH|PLAYER|WEB>.md / <section>, or techniques/<file>.md

   ## What happened
   One paragraph. What was tried, what the symptom was, what settled it. Numbers if measured.

   ## The rule
   One or two sentences a future session can act on without the story.

   ## Replaces or contradicts
   The existing line in the topic file this changes, quoted, or "nothing".
   ```

3. Commit it by name:
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
