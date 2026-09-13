# Which model does which job

Fable and Opus are for judgement. Sonnet is for editorial and research work with a clear
brief. Haiku is for running an instrument and reporting what it said. Routing the cheap work
down is where most of the token cost in this studio goes away, because the cheap work is
also the frequent work.

| Work | Who runs it | Model | Why |
|---|---|---|---|
| Building a game (design, code, debugging feel) | the main Claude Code session | Opus (or Sonnet for a small, well-specified change) | judgement about a whole game |
| `/digest` folding lessons into the topic files | the main session, in `gamedev-notes`, or the Courier unattended when the inbox passes ten | Sonnet | editorial merge with a written procedure and a written format |
| `/framework-check` judgement on doctor output | the main session | Opus | deciding which failures are the check's fault |
| Running `doctor.ps1`, reading `reports\LATEST.txt` | `doctor-runner` agent | Haiku | runs a script, returns lines verbatim |
| Filing a lesson in `inbox/` | `lesson-filer` agent | Haiku | fixed format, one grep, one commit |
| Genre and reference research | `game-researcher` agent | Sonnet | reading and summarizing |
| Asset search | `asset-scout` agent | Sonnet | querying sources, listing licenses |
| Filmed-run and phone playtest judgement | `playtester` agent | inherits the session model | judging feel |
| The routine weekly check | Windows Task Scheduler running `scripts\weekly-check.ps1` | none | it is PowerShell |
| Big-picture review of the whole studio, a few times a month at most | a Cowork chat in the "Game Dev Management" project | Fable or Opus | the only job that wants the widest view; see the project's rules for what it may touch |

## How to set and verify the model

The agent model is the `model:` line in each `agents\*.md` frontmatter (`haiku`, `sonnet`,
`opus`, `inherit`). `setup\install.ps1` copies agents into `~/.claude/agents`, so re-run it
after changing one. The main session model is whatever Claude Code was started with, or
`/model` mid-session. `claude --model sonnet` starts a Sonnet session for a digest.

Verify, do not assume. `/agents` in Claude Code lists every agent with its model. `/cost`
shows the session spend. When an agent's report arrives it names the model that produced it
in the transcript header; if the `doctor-runner` result says anything other than Haiku,
`~/.claude/agents\doctor-runner.md` is stale and install.ps1 needs to run again.

The rule for adding an agent: if the job is "run X and tell me what it said" or "write Y in
this exact shape", it is Haiku. If the job is "read these and decide", it is Sonnet or up.
