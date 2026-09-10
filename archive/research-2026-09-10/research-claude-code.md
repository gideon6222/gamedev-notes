# Claude Code documentation research (September 2026)

Scope: redesigning a multi-repo shared knowledge base for several concurrent Claude Code sessions (Claude Desktop "Code" tab, Windows) working in `C:\dev\<game>` and sharing `C:\dev\gamedev-notes`.

**Important location note.** `https://docs.claude.com/en/docs/claude-code/*` now 302-redirects to `https://code.claude.com/docs/en/*`. All citations below are to `code.claude.com`. The docs describe Claude Code ~v2.1.26x.

Legend: **VERIFIED** = quoted from or directly stated on the cited page. **UNVERIFIED** = inference, third-party source, or not stated in the docs.

---

## 1. CLAUDE.md, imports, `.claude/rules/`, CLAUDE.local.md

Source: https://code.claude.com/docs/en/memory (and https://code.claude.com/docs/en/best-practices)

### Locations (VERIFIED)

| Scope | Location |
|---|---|
| Managed policy (Windows) | `C:\Program Files\ClaudeCode\CLAUDE.md` |
| User | `~/.claude/CLAUDE.md` — on Windows `~/.claude` means `%USERPROFILE%\.claude` (settings page) |
| Project | `./CLAUDE.md` or `./.claude/CLAUDE.md` |
| Local | `./CLAUDE.local.md` — "Personal project-specific preferences; add to `.gitignore`" |

"CLAUDE.md and CLAUDE.local.md files in the directory hierarchy above the working directory are loaded at launch. Files in subdirectories load on demand when Claude reads files in those directories."

Load order: root of filesystem down to cwd; within a directory `CLAUDE.local.md` is appended after `CLAUDE.md`. All files are concatenated, not overridden.

### `@path` import syntax (VERIFIED)

> "CLAUDE.md files can import additional files using `@path/to/import` syntax. Imported files are expanded and loaded into context at launch alongside the CLAUDE.md that references them.
> Both relative and absolute paths are allowed. Relative paths resolve relative to the file containing the import, not the working directory. Imported files can recursively import other files, with a maximum depth of four hops."

Doc example:
```text
See @README for project overview and @package.json for available npm commands for this project.

# Additional Instructions
- git workflow @docs/git-instructions.md
```
Home-directory import example: `- @~/.claude/my-project-instructions.md`

Import parsing skips code spans/fenced blocks: write `` `@README` `` in backticks to mention a path without importing it.

- **Max recursion depth: 4 hops** (VERIFIED).
- **Absolute Windows paths (`C:/dev/...`)**: the docs say "absolute paths are allowed" but give no drive-letter example. **UNVERIFIED** that `@C:/dev/gamedev-notes/x.md` works; `@~/...` is the documented cross-project form. Safer: `@~/.claude/...` or a relative path from `~/.claude/CLAUDE.md` (e.g. `@../../dev/gamedev-notes/index.md` resolves relative to the file containing the import).
- **External-import approval dialog** (VERIFIED): "An import in a project-level memory file is external when its path resolves outside your working directory ... The first time Claude Code encounters external imports in a project, it shows an approval dialog ... User-scope memory files, such as `~/.claude/CLAUDE.md` and `~/.claude/rules/`, are files you wrote yourself. Except in Cowork sessions on your desktop, Claude Code loads their imports without the dialog." Note the Cowork restriction: "In Cowork sessions on your desktop, Claude Code skips any import in a user-scope file that resolves to a path outside the session's working directory". (Cowork is the Desktop app's other mode; the Code tab reads the same files as the CLI per the desktop page — whether the Code tab counts as a "Cowork session" for this rule is **UNVERIFIED**; test with `/context`.)
- Imports don't save context: "Splitting into `@path` imports helps organization but doesn't reduce context, since imported files load at launch."
- Symlinked CLAUDE.md works but "On Windows, creating a symlink requires Administrator privileges or Developer Mode, so use the `@AGENTS.md` import instead."
- HTML comments `<!-- ... -->` are stripped before injection (free maintainer notes).

### Size guidance (VERIFIED)

- "**Size**: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence."
- "Claude Code loads a CLAUDE.md file of up to 4 MiB in full and skips a larger file. Shorter files produce better adherence."
- Best-practices: "Keep it concise. For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual instructions!"
- Include: "Bash commands Claude can't guess; Code style rules that differ from defaults; Testing instructions; Repository etiquette; Architectural decisions; Developer environment quirks; Common gotchas". Exclude: "Anything Claude can figure out by reading code; Detailed API documentation (link to docs instead); Information that changes frequently; Long explanations or tutorials; File-by-file descriptions".
- "If an entry is a multi-step procedure or only matters for one part of the codebase, move it to a skill or a path-scoped rule instead."
- `/doctor` proposes trims for a checked-in CLAUDE.md (v2.1.206+). `/context` shows what actually loaded under "Memory files".
- Project-root CLAUDE.md survives `/compact` (re-read from disk).

### `.claude/rules/` (VERIFIED — exists)

- Project: `.claude/rules/*.md`, discovered recursively. "Rules without `paths` frontmatter are loaded at launch with the same priority as `.claude/CLAUDE.md`."
- User-level: `~/.claude/rules/` — "apply to every project on your machine ... loaded before project rules".
- Path-scoped:
```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API Development Rules
...
```
"Path-scoped rules trigger when Claude reads files matching the pattern, not on every tool use." Brace expansion supported (`"src/**/*.{ts,tsx}"`).
- Symlinks supported: `ln -s ~/shared-claude-rules .claude/rules/shared` (Windows symlink caveat applies).
- `claudeMdExcludes` setting (glob on absolute paths) to skip files, any settings layer.
- `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config` loads `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`, `CLAUDE.local.md` from an added directory.

---

## 2. Skills (Agent Skills)

Source: https://code.claude.com/docs/en/skills

### Locations (VERIFIED)

| Location | Path |
|---|---|
| Enterprise | managed settings dir `.claude/skills/<name>/SKILL.md` (highest priority) |
| Personal | `~/.claude/skills/<name>/SKILL.md` |
| Project | `.claude/skills/<name>/SKILL.md` (also every parent dir up to repo root; nested subdir skills load lazily) |
| Plugin | `<plugin>/skills/<name>/SKILL.md`, invoked as `/plugin-name:skill-name` |
| `--add-dir` | `.claude/skills/` inside a `--add-dir` path, "Yes, with live reload" (permissions page) |
| claude.ai synced | `~/.claude/skills/synced/` (reserved name) |

Priority when names collide: managed > user > project (features-overview).

### Frontmatter fields (VERIFIED — all exist)

`name`, `description` (recommended; `description` + `when_to_use` truncated at 1,536 chars in listing; if omitted, first paragraph is used), `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation` (bool; hides description from Claude, only `/name` invokes), `user-invocable` (bool, default true; `false` hides from `/` menu — "Use for background knowledge not actionable as a command"), `allowed-tools` (pre-approves tools for the turn, e.g. `Bash(git add *) Bash(git commit *)`), `disallowed-tools`, `model`, `effort`, `context` (`fork` runs in an isolated subagent), `agent` (which subagent type with `context: fork`: `Explore`, `Plan`, `general-purpose`, or a custom `.claude/agents/` name), `background`, `paths` (glob list limiting automatic activation; "Manual invocation ignores this"), `shell` (`bash`|`powershell`), `hooks` (registered when the skill is invoked, rest of session; `once: true` supported), `metadata`, `license`, `compatibility`.

Only `name, description, license, compatibility, metadata, allowed-tools` are allowed when uploading to claude.ai / Skills API.

### Invocation (VERIFIED)

- `/skill-name [args]`; `$ARGUMENTS`, `$0`/`$1`/`$N`, `$ARGUMENTS[N]`, named `$issue` via `arguments:`.
- Automatic: Claude invokes when the prompt matches `description`/`when_to_use` or `paths` match, unless `disable-model-invocation: true`.
- Stacking up to 6 skills inline: `/skill1 /skill2 args` (v2.1.199+).
- Descriptions of model-invocable skills load every session (context cost); full body loads on use. Body persists across turns; auto-compaction re-attaches the last invocation (first 5,000 tokens each, 25,000 combined).
- "Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files."

### Supporting files / scripts (VERIFIED)

```
my-skill/
├── SKILL.md
├── reference.md      # lazy-loaded only when Claude reads it
└── scripts/helper.py
```
Reference with relative markdown links (`see [reference.md](reference.md)`) — "Supporting files not referenced: Don't consume context tokens."

Variables substituted in skill body and `allowed-tools`: `${CLAUDE_SKILL_DIR}` (dir containing SKILL.md), `${CLAUDE_PROJECT_DIR}` (v2.1.196+), `${CLAUDE_SESSION_ID}`, `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`.

Dynamic context injection runs shell before Claude sees the skill:
```markdown
Current status: !`git status --short`
```
Multi-line: a ```` ```! ```` fenced block. Non-zero exit aborts the skill (grep/diff/find exit 1 excepted). `shell: bash` requires Git Bash on Windows, else fails with "requires bash but Git Bash not found"; `shell: powershell` needs the PowerShell tool enabled. Commands run in the session cwd — use `${CLAUDE_SKILL_DIR}` / `${CLAUDE_PROJECT_DIR}` for stable paths. This is the documented way for a skill to pull live content from another repo (e.g. `!`cat "$HOME/../../dev/gamedev-notes/INDEX.md"`` or `!`git -C C:/dev/gamedev-notes pull -q && cat C:/dev/gamedev-notes/INDEX.md``) — the mechanism is VERIFIED; the specific Windows path form is UNVERIFIED.

### Symlinks / files outside the folder (VERIFIED)

"**Symlinks**: Skill folders can symlink to directories elsewhere. Claude Code reads `SKILL.md` from the target and loads once even with multiple pointers." So `~/.claude/skills/gamedev-notes -> C:\dev\gamedev-notes\skills\gamedev-notes` is supported (Windows: `mklink /D`, needs admin or Developer Mode). Skill bodies can reference any path with `@path` or `!` commands (features-overview: skills "Can include files: Yes, with `@path` imports"). The "cannot reference files outside its own directory" restriction applies to **plugins**, not standalone skills (plugins-reference).

Live reload: `~/.claude/skills/`, `.claude/skills/`, and `--add-dir` `.claude/skills/` are watched; SKILL.md edits apply mid-session. "If `.claude/skills/` didn't exist at session start, restart to enable watching."

### Plugin skill caching (VERIFIED — explains the user's lost edits)

plugins-reference: "For security and verification purposes, Claude Code copies *marketplace* plugins to the user's local **plugin cache** (`~/.claude/plugins/cache`) rather than using them in place ... each installed version is a separate directory in the cache, grouped by marketplace and plugin and named for the resolved version". Cache path: `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`. "`${CLAUDE_PLUGIN_ROOT}` changes when the plugin updates ... treat it as ephemeral and don't write state there." Persistent per-plugin data goes to `${CLAUDE_PLUGIN_DATA}` = `~/.claude/plugins/data/{id}/`. Marketplace auto-update "runs once per session". So editing the cached copy is overwritten on the next update/re-resolve. Fixes: edit the source repo and bump `version` (or rely on commit SHA), run `/plugin marketplace update` + `/reload-plugins`; or develop with `claude --plugin-dir <path>` (loaded in place, overrides same-named installed plugin); or use a **skills-directory plugin**: `claude plugin init my-tool` creates `~/.claude/skills/my-tool/.claude-plugin/plugin.json` and it "loads as `my-tool@skills-dir` with no marketplace or install step" — SKILL.md edits take effect immediately.

### Commands vs skills

See §6.

---

## 3. Subagents

Source: https://code.claude.com/docs/en/sub-agents

Locations (VERIFIED, priority order): managed > `--agents` JSON flag > `.claude/agents/` (project, scanned recursively, walked up from cwd) > `~/.claude/agents/` (user) > plugin `agents/`. Also loaded from `--add-dir` directories (no live reload).

Format (VERIFIED):
```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```
Only `name` and `description` required. Other fields: `tools` (allowlist; `Agent(worker, researcher)` restricts spawnable subagents), `disallowedTools`, `skills` (array of skill names; "Full skill content injected"), `model` (`sonnet|opus|haiku|fable|inherit` or full ID), `effort`, `maxTurns`, `permissionMode` (`default|acceptEdits|auto|dontAsk|bypassPermissions|plan`), `isolation: worktree`, `memory` (`user` → `~/.claude/agent-memory/<name>/`, `project` → `.claude/agent-memory/<name>/`, `local` → `.claude/agent-memory-local/<name>/`; first 200 lines/25 KB of its `MEMORY.md` are injected into the system prompt), `background`, `color`, `mcpServers` (inline or by name), `hooks`, `initialPrompt`, `experimental.cacheTtl`.

Telling a subagent to read specific files: there is no frontmatter field for it; put it in the body prompt ("Before starting, read `C:/dev/gamedev-notes/playtest-checklist.md` ...") and/or preload via `skills:`. The body is the system prompt; subagents get `Read` (and Read/Write/Edit are auto-enabled when `memory` is set). What loads at startup (VERIFIED): the agent's prompt, the delegation message, **the full CLAUDE.md hierarchy including `~/.claude/CLAUDE.md`, project rules, CLAUDE.local.md** (except built-in `Explore`/`Plan` which skip CLAUDE.md), git status, preloaded skills. The main conversation's auto memory is NOT loaded into subagents (except forks).

Invocation: natural language ("Use the playtester subagent to ..."), `@agent-playtester ...`, or `claude --agent playtester` / `"agent": "playtester"` in settings. `/agents` no longer opens a wizard (v2.1.198+): edit files directly. Validate with `claude plugin validate ~/.claude/agents`.

Example "playtester" (form VERIFIED, content mine):
```markdown
---
name: playtester
description: Plays a built phone game in a browser/emulator, records bugs and feel issues. Use after a build.
tools: Read, Grep, Glob, Bash, WebFetch
model: sonnet
memory: user
skills: [gamedev-playtest-checklist]
---
Before you start, read your MEMORY.md and C:/dev/gamedev-notes/playtesting/checklist.md ...
When done, append findings to C:/dev/gamedev-notes/playtests/<game>-<date>.md and save durable lessons to your memory.
```

---

## 4. Hooks

Sources: https://code.claude.com/docs/en/hooks (reference), https://code.claude.com/docs/en/hooks-guide

Config shape in any settings file (`~/.claude/settings.json`, `.claude/settings.json`, `.claude/settings.local.json`, managed, plugin `hooks/hooks.json`, skill/agent frontmatter) — VERIFIED:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_PROJECT_DIR}\"/.claude/hooks/x.sh", "timeout": 600 }
        ]
      }
    ]
  }
}
```
Handler types: `command`, `http`, `mcp_tool`, `prompt`, `agent`. Common fields: `if` (permission-rule syntax, tool events only), `timeout` (seconds; default 600, but 30 s for `UserPromptSubmit`/`Stop`, `PreModelSwitch`/`PostModelSwitch`), `statusMessage`, `once` (skill frontmatter only), `async`, `asyncRewake`, `shell`, `args`.

Events (VERIFIED, partial list): `SessionStart` (matchers `startup|resume|clear|compact|fork`), `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `Stop`, `SubagentStart`, `SubagentStop`, `PreCompact`, `PostCompact`, `Notification`, `SessionEnd`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `TaskCreated/Completed`, `Setup`, and more. Matcher: exact string, `A|B`, regex, `mcp__server__.*`; omit/`*` for all.

Stdout → context (VERIFIED): "For `UserPromptSubmit`, `UserPromptExpansion`, `SessionStart`, and `PostModelSwitch` hooks, Claude Code adds stdout it treats as plain text to Claude's context." JSON alternative: `{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"..."}}` (for `UserPromptSubmit`, `additionalContext` must be nested under `hookSpecificOutput`). Exit 2 = block (for `SessionStart` "exit 2 shows stderr to the user and execution continues" per hooks-guide; the summarised reference said "blocks" — treat as **UNVERIFIED**, don't rely on it). Doc example that injects context after compaction:
```json
{ "hooks": { "SessionStart": [ { "matcher": "compact", "hooks": [ { "type": "command",
  "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing. Current sprint: auth refactor.'" } ] } ] } }
```
"You can replace the `echo` with any command that produces dynamic output, like `git log --oneline -5`."

**Can a SessionStart hook `git pull` another repo and inject context?** Yes by construction: command hooks are arbitrary shell commands run "in the current directory with Claude Code's environment", with env vars `CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT`, `CLAUDE_PLUGIN_DATA`, `CLAUDE_EFFORT`, `CLAUDE_CODE_MESSAGING_SOCKET`, and stdin JSON (`session_id`, `cwd`, `hook_event_name`, `source`/`why`). The reference page contains **no statement** forbidding a hook from running git in a different repository (I checked explicitly). So `git -C C:/dev/gamedev-notes pull --ff-only -q && cat C:/dev/gamedev-notes/INDEX.md` in a `SessionStart` hook in `~/.claude/settings.json` is VERIFIED mechanism / UNVERIFIED specific command. Also `CLAUDE_ENV_FILE`: a SessionStart/CwdChanged hook can write `export VAR=...` lines to `"$CLAUDE_ENV_FILE"` and Claude Code sources it before each Bash command.

**Windows shell** (VERIFIED): "Shell form runs when `args` is absent. The `command` string is passed to a shell: `sh -c` on macOS and Linux, Git Bash on Windows, or PowerShell when Git Bash isn't installed. Set the `shell` field to choose explicitly." `"shell": "bash" | "powershell"`. Exec form (`"command": "powershell.exe", "args": ["-NoProfile","-ExecutionPolicy","Bypass","-File","${CLAUDE_PROJECT_DIR}/.claude/hooks/script.ps1"]`) spawns directly with no shell; `.cmd`/`.bat` shims need shell form or `node`. The Desktop Code tab requires Git for Windows, so Git Bash is present. Not cmd.exe (the only cmd.exe mention is for plugin marketplace `command` sources).

Hooks in `~/.claude/settings.json` apply to all projects; project hooks in `.claude/settings.json` wait for workspace trust. `/hooks` is read-only; `disableAllHooks: true` turns them off. Debug with `claude --debug` or `/debug`. Windows gotcha: a `~/.bashrc` that echoes will prepend text to hook stdout and break JSON output.

---

## 5. Auto memory

Source: https://code.claude.com/docs/en/memory#auto-memory (VERIFIED)

- On by default. Toggle in `/memory`, or `"autoMemoryEnabled": false` in settings, or env `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.
- Storage: `~/.claude/projects/<project>/memory/` with `MEMORY.md` (index, "one line per memory") plus topic files (`user_role.md`, `feedback_testing.md`, ...). `<project>` is derived from the git repo root so all worktrees/subdirs of one repo share it; e.g. `/home/user/.claude/projects/-home-user-work-my-repo` (claude-directory page: path with separators replaced by `-`). Windows form is UNVERIFIED but follows the same scheme.
- Loaded: "The first 200 lines of `MEMORY.md`, or the first 25KB, whichever comes first, are loaded at the start of every conversation." Topic files are read on demand. Claude Code warns/errors when the index exceeds the limit.
- Kinds of notes: `user`, `feedback`, `project`, `reference`. "Claude skips anything it can derive from the codebase ... It also skips anything your CLAUDE.md files already say."
- Relation to CLAUDE.md: complementary; both loaded every session. "Use CLAUDE.md files when you want to guide Claude's behavior. Auto memory lets Claude learn from your corrections without manual effort." "add this to CLAUDE.md" asks Claude to write CLAUDE.md instead.
- Machine-local, not shared across machines. Not loaded into subagents (except forks); subagents can have their own via `memory:`.
- **Relocation options relevant to a shared KB**: `"autoMemoryDirectory": "~/my-custom-memory-dir"` (absolute or `~/`; any settings scope) — and `CLAUDE_CODE_PROJECT_DIR_NAME` with `CLAUDE_CONFIG_DIR` (v2.1.234+) makes every repo launched with that config dir share one auto-memory directory. Pointing all game repos' auto memory at one directory inside `C:\dev\gamedev-notes` is possible but reintroduces the concurrent-write problem on `MEMORY.md` (UNVERIFIED: the docs say nothing about locking).

---

## 6. Custom slash commands vs skills

Source: https://code.claude.com/docs/en/slash-commands, skills page (VERIFIED)

> "**Custom commands have been merged into skills.** A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way. Your existing `.claude/commands/` files keep working."

Commands (`~/.claude/commands/`, `.claude/commands/`) still work, support the same frontmatter except `name` and `paths`, no supporting files, no subdirectory structure. Skills page heading literally: "Relationship to `.claude/commands/` (Deprecated)" and "Prefer skills for new work." The claude-directory page: "Commands and skills are now the same mechanism. For new workflows, use skills/ instead." So: not removed, but superseded — use `.claude/skills/<name>/SKILL.md`.

---

## 7. Permissions

Sources: https://code.claude.com/docs/en/permissions, https://code.claude.com/docs/en/permission-modes, https://code.claude.com/docs/en/settings (VERIFIED)

Rule syntax: `Tool` or `Tool(specifier)`. Bash rules match the whole command text with `*` wildcards; "`Bash(ls *)` matches `ls`"; "The `:*` suffix is an equivalent way to write a trailing wildcard, so `Bash(ls:*)` matches the same commands as `Bash(ls *)`" (the dialog writes the space form; `:*` only at the end). Compound commands: "a rule like `Bash(safe-cmd *)` won't give it permission to run the command `safe-cmd && other-cmd`... A rule must match each subcommand independently." Deny beats allow; ask beats allow. Built-in read-only commands (`ls`, `cat`, `git status`, `cd` within working dirs, ...) never prompt.

Doc example:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git commit *)"
    ],
    "deny": [
      "Bash(git push *)"
    ]
  }
}
```
For this user (form VERIFIED, list mine):
```json
{
  "permissions": {
    "allow": [
      "Bash(godot *)", "Bash(gh *)", "Bash(adb *)", "Bash(curl *)",
      "Bash(git *)", "Bash(npm *)", "Bash(npx *)",
      "Read(//c/dev/**)", "Edit(//c/dev/gamedev-notes/**)",
      "WebFetch(domain:docs.godotengine.org)"
    ],
    "additionalDirectories": ["C:/dev/gamedev-notes"]
  }
}
```
Windows path rules: "On Windows, paths are normalized to POSIX form before matching. `C:\Users\alice` becomes `/c/Users/alice`, so use `//c/**/.env`". `Write(...)`/`Glob(...)` path rules are ignored — use `Edit(...)`/`Read(...)`. `permissions.additionalDirectories` in settings grants file access only (no config loading); `--add-dir`/`/add-dir` additionally loads skills, commands, agents, `enabledPlugins`/`extraKnownMarketplaces`, and CLAUDE.md with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1`.

Where rules live: `~/.claude/settings.json` (user), `.claude/settings.json` (project, `allow` rules wait for workspace trust), `.claude/settings.local.json` ("Yes, and don't ask again" writes here; at repo root — "except ... on Windows", where it stays in the starting directory). Lists merge across scopes. Settings hot-reload.

Modes: `default` (alias `manual`), `acceptEdits`, `plan`, `auto` (classifier; built-in default on Pro/Max/Team), `dontAsk` (only pre-approved tools), `bypassPermissions`. `--permission-mode <mode>`; `--dangerously-skip-permissions` = `--permission-mode bypassPermissions`; `--allow-dangerously-skip-permissions` adds it to the Shift+Tab cycle. `"permissions": {"defaultMode": "..."}` — `auto` and `bypassPermissions` "don't take effect from project or local settings; set them in user or managed settings" (v2.1.257+). Deny rules apply in every mode; allow rules are irrelevant in bypass. Desktop app: mode picker per folder overrides `defaultMode`; Bypass needs a Settings toggle on Pro/Max. `disableBypassPermissionsMode: "disable"` (managed) removes it. Sandbox (`/sandbox`, `sandbox.enabled`) is macOS/Linux/WSL2 only.

---

## 8. Multi-session concurrency, worktrees, shared memory

Sources: https://code.claude.com/docs/en/worktrees, https://code.claude.com/docs/en/desktop, https://code.claude.com/docs/en/cross-session-messaging, best-practices (VERIFIED)

- `claude --worktree <name>` / `-w`: creates `.claude/worktrees/<name>/` at repo root on branch `worktree-<name>`; add `.claude/worktrees/` to `.gitignore`. `EnterWorktree`/`ExitWorktree` tools; `worktree.baseRef: "fresh"|"head"`; `.worktreeinclude` copies gitignored files. Hooks' `${CLAUDE_PROJECT_DIR}` stays at the main checkout; hook `cwd` follows the worktree.
- Desktop app: "For Git repositories, each session gets its own isolated copy of your project using Git worktrees ... Worktrees are stored in `<project-root>/.claude/worktrees/` by default. You can change this ... in Settings → Claude Code under 'Worktree location'." Ctrl+N for a new parallel session. Desktop reads the same `~/.claude/settings.json`, `~/.claude.json`, CLAUDE.md, hooks, skills as the CLI. Windows requires Git for Windows.
- What worktrees share: `.git`, project-scope plugins, saved permission approvals ("On Windows ... the rule stays with that worktree"), and auto memory (per repo).
- **Cross-session messaging** (v2.1.234+ on native Windows; named pipes): `ListAgents` + `SendMessage`; `/list-agents` (`/peers`); `@session-name` mention; `--name`/`/rename`. "Coordinate parallel worktrees: when sessions work the same repository in separate worktrees, Claude can tell the other sessions what landed." Messages are plain text; the receiver "never change[s] permission settings, CLAUDE.md, or other configuration because another session asked." Sessions in different directories on the same machine can reach each other (they register in shared files under the home dir). `crossSessionInbound: accept|hold|refuse`.
- Best practices: "Run multiple Claude sessions in parallel ... Worktrees ... Cross-session messaging ... Desktop app ... Agent view (`claude agents`) ... Agent teams (experimental)". Writer/Reviewer pattern.
- **Shared team memory**: the docs' answer is committed project files — `.claude/CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, and plugins/marketplaces for "A second repository needs the same setup". There is no documented multi-writer shared memory store; auto memory is explicitly "machine-local". Nothing in the docs addresses concurrent writes to the same markdown file by multiple sessions — the only concurrency primitives are git worktrees (file isolation) and messaging.

---

## 9. `gh` for repo creation, secrets, Pages

- Best-practices (VERIFIED): "If you use GitHub, install the `gh` CLI. Claude knows how to use it for creating issues, opening pull requests, and reading comments. Without `gh`, Claude can still use the GitHub API, but unauthenticated requests often hit rate limits." So yes, `gh` is the recommended path.
- `gh repo create` (https://cli.github.com/manual/gh_repo_create, VERIFIED flags): `gh repo create [<name>] [flags]` with `--public`, `--private`, `-s, --source <path>`, `--push`, `-r, --remote`, `-d, --description`. Manual example: `gh repo create my-project --private --source=. --remote=upstream`. So `gh repo create <name> --public --source=. --push` is valid (VERIFIED flags; the exact combination is the manual's documented pattern minus `--remote`).
- `gh secret set` (https://cli.github.com/manual/gh_secret_set, VERIFIED): `gh secret set MYSECRET < myfile.txt` is a documented example ("reads from standard input if not specified"); also `--body`, `-R owner/repo`, `-f .env`, `--env`, `--app actions|agents|codespaces|dependabot`.
- GitHub Pages REST (https://docs.github.com/en/rest/pages/pages, VERIFIED): `POST /repos/{owner}/{repo}/pages` with body `build_type` ("Possible values are `legacy` and `workflow`") and `source` object (`branch` required inside it, `path` `/` or `/docs`); `source` is not marked required at top level. Responses 201/409 (already exists)/422. Needs "Pages (write)" and "Administration (write)" or classic `repo` scope. `PUT /repos/{owner}/{repo}/pages` updates (`build_type`, `source`, `cname`, `https_enforced`). Therefore `gh api -X POST repos/{owner}/{repo}/pages -f build_type=workflow` is consistent with the schema — VERIFIED schema, UNVERIFIED that GitHub accepts it without `source` (docs don't say). A community thread (https://github.com/orgs/community/discussions/51268) reports `gh api -X PUT "/repos/$OWNER/$REPO/pages" -f build_type=workflow` working (UNVERIFIED, third-party). Practical recipe: try POST; on 409 fall back to PUT. Note `gh api` `{owner}`/`{repo}` placeholders auto-fill from the current repo.

---

## 10. Other features for "many sessions learning from each other"

- **Plugin marketplace on a local git repo** (https://code.claude.com/docs/en/plugin-marketplaces, VERIFIED): create `C:\dev\gamedev-notes\.claude-plugin\marketplace.json`:
```json
{
  "name": "gamedev",
  "owner": { "name": "Gideon" },
  "plugins": [
    { "name": "gamedev-kb", "source": "./plugins/gamedev-kb", "description": "Shared game-dev skills and agents" }
  ]
}
```
Add with `/plugin marketplace add ./path/to/repo` or `claude plugin marketplace add C:/dev/gamedev-notes`, or GitHub `owner/repo`; install `/plugin install gamedev-kb@gamedev`. Persist in `~/.claude/settings.json`:
```json
{ "extraKnownMarketplaces": { "gamedev": { "source": { "source": "github", "repo": "you/gamedev-notes" } } },
  "enabledPlugins": { "gamedev-kb@gamedev": true } }
```
Caveat: cached copy (see §2); git sources use commit SHA as version so each push yields a new version on the next marketplace refresh ("once per session"); `/reload-plugins` after update. Windows: link mode unsupported, command sources run via `cmd.exe`, `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` for HTTPS clones.
- **Skills-directory plugin** (`claude plugin init`) — simplest zero-cache route for personal use.
- **`--add-dir`** the notes repo: loads `.claude/skills` (live reload) and `.claude/agents` from it, and CLAUDE.md/rules with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1`. In Desktop, `/add-dir C:/dev/gamedev-notes` mid-session (flag not available in the GUI; UNVERIFIED whether Desktop honors env vars).
- **`claude mcp`** (https://code.claude.com/docs/en/mcp, VERIFIED): `claude mcp add --transport http <name> <url>`; stdio: `claude mcp add [--scope user|project|local] [-e KEY=val] <name> -- <command> [args]`; project `.mcp.json` `{"mcpServers": {...}}`; user scope in `~/.claude.json`; `claude mcp list|get|remove|add-json`. Tool search on by default so idle MCP tools are cheap. No Windows `cmd /c` note on the current page (UNVERIFIED whether `npx` needs a wrapper on Windows).
- **Godot MCP servers** (third-party, UNVERIFIED quality): `Coding-Solo/godot-mcp` (~5.6k stars; `claude mcp add godot -e GODOT_PATH=/path/to/godot -- npx @coding-solo/godot-mcp`; launches editor, runs project, captures debug output, scene/node ops); `mkdevkit/godot-mcp` (editor addon + node server over WebSocket, 173 tools, Godot 4.4+, `.mcp.json` with `node <path>/server/build/index.js`, `GODOT_MCP_PORT`); also `slangwald/godot-mcp` (Godot 4.6), `ee0pdt/Godot-MCP`, `PiMPStudios/Claude-GoDot-MCP`.
- **Subagent `memory:`** (project scope, committable) gives a playtester/asset-scout its own curated MEMORY.md that can live in the shared repo.
- **Hooks** `InstructionsLoaded` (log what loaded and why), `Stop` (e.g. append a session summary to the notes repo and push — deterministic), `UserPromptSubmit` (inject freshest index each prompt, 30 s timeout).
- **`/goal`, `/verify`, `/code-review`, `/batch`, `/doctor`, `/skill-doctor`** bundled skills; `/context` to audit what loaded; `/memory`.
- **Extension triggers table** (features-overview): "Claude gets a convention or command wrong twice → CLAUDE.md; You keep typing the same prompt → user-invocable skill; You paste the same playbook for the third time → skill; A side task floods your conversation → subagent; You want something to happen every time → hook; A second repository needs the same setup → plugin."

---

## Design implications (synthesis, not from docs)

1. Shrink `~/.claude/CLAUDE.md` to < 200 lines of always-true rules plus a one-line pointer to the notes repo; do not `@`-import 330 KB (imports load fully at launch).
2. Move the 330 KB into `C:\dev\gamedev-notes\.claude\skills\<topic>\SKILL.md` (+ lazy `reference.md` files); expose them via a symlinked `~/.claude/skills/<topic>` folder, `--add-dir`/`/add-dir`, or a skills-directory plugin. Only descriptions cost context per session.
3. A `SessionStart` (`startup|resume|clear`) hook in `~/.claude/settings.json` running `git -C C:/dev/gamedev-notes pull --ff-only -q` and `cat`-ing a small `INDEX.md` to stdout keeps every session current without CLAUDE.md growth.
4. For writes: one file per session/game/date (`notes/<game>/<yyyy-mm-dd>-<session>.md`) plus a `Stop` hook that commits+pushes with `--rebase` on conflict, instead of many sessions editing shared files; use cross-session messaging for real-time hand-offs.
5. Pre-allow `Bash(gh *)`, `Bash(godot *)`, `Bash(adb *)`, `Bash(curl *)`, `Bash(git *)` and `Edit(//c/dev/gamedev-notes/**)` in user settings; run Desktop sessions in Auto or Accept-edits mode.
