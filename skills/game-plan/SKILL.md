---
name: game-plan
description: Research a game idea and write the full PLAN.md that connects loop, feel, first minute, content, systems, assets, tests, polish and milestones. Use after an idea has been expanded (from /new-game) or when Gideon asks for a design document, a plan, or "research how other games do X".
argument-hint: <slug> and the expanded idea
---

# Game plan: research, then a plan that a build session can follow without asking

Output: `C:\dev\plans\<slug>\PLAN.md`, plus `REFERENCE.md` when there is a reference game.
`/game-scaffold` copies both into the new repo. For an existing game, edit the repo's
`PLAN.md` in place instead.

## 1. Research (parallel, with the subagents)

Launch these together and wait for all of them:

- **`game-researcher`** subagent, three separate briefs:
  1. The genre's core loop and why it holds attention: the three best-regarded games in
     it, what each does in the first minute, what they gate, what their meta-goal is.
  2. **One new technique** for this game that no past game here used (check
     `techniques/README.md`): a rendering, animation, procedural or feel technique that
     would lift THIS game, with a source that explains how. Name it in the plan.
  3. If he named a reference game: its strategy guide (for the verbs), the longest
     playthrough video, store screenshots, the upgrade list and prices. Write
     `REFERENCE.md` from it: what the game actually does, observed, with timestamps. Five
     rebuilds of one game went wrong by inferring instead of looking.
- **`asset-scout`** subagent: given the fantasy, the art direction and the list of things
  on screen at full size, return a shortlist per need (characters, props, environment,
  textures, sky, UI kit, icons, font, SFX packs, music) with source, id, licence and a
  fetch command from `ASSETS.md`. It also reports the misses, which shape the plan: if
  nothing has fish, fish are modelled.
- **Yourself**: read `C:\dev\gamedev-notes\CRAFT.md` sections the idea touches, and
  `POLISH.md` so the plan budgets for it.

Search narrowly. "Fishing game reel tension mechanic design" beats "fishing game".

## 2. Decide

For each of his suggestions and each of your additions: in or out of phase one, and why.
For each system: what it reads, what it writes, which test proves it. The plan connects
everything: an upgrade names the resource it costs and the place that resource is found;
a hazard names the tell, the window and the counter; a screen names the state that shows it
and the action that leaves it.

## 3. Write PLAN.md in this shape

```markdown
# <Name> - plan

## Summary (shown to Gideon at the gate)
**Fantasy:** one sentence. **Loop:** verb, resource, decision, consequence.
**Engine:** Godot (why) | web (why). **Reference:** <game> (REFERENCE.md) | none.
**The first minute:** what happens, second by second, and the first win.
**What you keep:** the collection / ladder / record.
**New technique:** <name>, from <source>.
**His asks, expanded:** numbered, one line each, with what each grew into.
**My additions:** three, marked as mine.
**Assets:** table of need, source, id, licence.
**Phases:** 1 first playable (n milestones), 2 content and meta, 3 polish and store.

## Player and controls
Portrait, one thumb. Each verb, its gesture, its lag constant, what it looks like.

## Systems
One subsection per system: state it owns, rules, numbers with the reason for each number,
the design test that proves it, how it is shown.

## Content ladder
The table of levels / species / buildings / planets, monotonic, each row's unlock and reward.

## Presentation
Camera (angle, FOV arithmetic for portrait), light, sky, palette, materials, post, HUD
placement (what is by the thumb, what is opposite it), the shop as a place, the shell
(Maaack's Menus Template or custom), fonts, audio plan (sampled versus generated).

## Assets
Per need: source, id, licence, fetch command, target folder, import settings.

## Tests and tools
Golden policies (which ones, what each fails at), design tests (one line each),
smoke path (the level boundary, the terminal states, the buttons), replay scenarios to
film (named), what the phone run checks.

## Polish budget
The POLISH.md lines this game must satisfy and which milestone pays for each.

## Milestones
### Phase 1: first playable
- [ ] M1 ... (each: what exists after, the test that proves it, the film scenario if visual)
### Phase 2: content and meta
- [ ] ...
### Phase 3: polish and store
- [ ] ...

## Second month
What the game becomes when it is working.

## Open decisions I made for him
Reversible choices, one line each, with the alternative. NOTES.md carries them after scaffold.
```

Keep it concrete: numbers, names, file paths. A plan a build session has to reinterpret is
not finished. Cut anything that is a restatement of `CRAFT.md`; reference the rule instead.

## 4. Hand back

Return to `/new-game` for the gate, or for an existing game commit the plan and start the
milestone loop.
