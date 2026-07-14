# Install — one-time, wires this folder into every Claude Code session

This step is separate from SETUP.md. SETUP.md personalizes USER.md and
memory/MEMORY.md and never touches anything outside this folder. INSTALL.md
is the only step that edits a file OUTSIDE this folder — the user's global
~/.claude/CLAUDE.md — so it carries its own, stricter safety gate.

## Why this file exists
Without this step, this folder loads only when a session happens to `cd`
into it — it is not ambient. The fix is a small pointer appended to the
user's ~/.claude/CLAUDE.md (loaded in every session, any folder) that tells
Claude to read this folder's CLAUDE.md at boot. That pointer edit is the
highest-blast-radius action this scaffold ever takes: ~/.claude/CLAUDE.md
is a load-bearing control file read at the start of EVERY session the user
runs, for every project, forever — not just this one. Treat it accordingly.

Run this once, when this folder is first placed at its permanent path —
any location, any name the user chose. Re-running is safe (see idempotency
check below); it does not delete itself, since re-runs may legitimately be
needed if the user ever moves or renames the folder.

## Steps — do not reorder, do not skip, do not batch without the approval gate

1. **Idempotency check first.** Read ~/.claude/CLAUDE.md. If a section
   delimited by `<!-- my-claude-assistant:start -->` / `:end` already
   exists, STOP and ask the user what they want (do not assume it's stale,
   do not overwrite it, do not append a second copy). This one check is
   what would have caught a duplicate install automatically.
2. **Backup before any edit — both files, unconditionally.** Copy the
   CURRENT on-disk content of BOTH ~/.claude/CLAUDE.md AND
   ~/.claude/settings.json into
   ~/.claude/backup-<YYYY-MM-DD-HHMM>/, even if settings.json is not
   being changed in this step. "I'm only editing one file" is not an
   exemption — back up both, every time this file runs. Use a
   date-plus-time timestamp, not just the date: a date-only folder name
   means a second run on the same day overwrites the first backup with
   whatever is on disk at that moment — which, if an edit already happened
   earlier that day, means the pristine "before" copy gets silently
   clobbered by an already-edited copy, destroying the one snapshot you'd
   want to revert to. A timestamped folder makes every run's backup
   immutable and independent of how many times this file has run before.
   If ~/.claude/CLAUDE.md does not exist yet, note that explicitly instead
   of skipping the backup step silently (absence is still a fact worth
   recording before you create the file).
3. **Show, don't just do.** Show the user the backup paths from step 2 and
   the EXACT text block you intend to append (see template below). Wait
   for an explicit yes. This is a hard approval gate — not a formality to
   narrate after the fact.
4. **Append-only, delimited, capped.** Append (never rewrite or reorder
   existing content) a single section, max 10 lines, delimited by HTML
   comments so it's unambiguous to find and to remove later. Fill in
   `<this folder's absolute path>` with where this folder actually sits
   on disk right now (e.g. the output of `pwd`) — never assume a default:

   ```
   <!-- my-claude-assistant:start -->
   ## My Claude Assistant
   Read <this folder's absolute path>/CLAUDE.md at the start of this
   session — it is the boot protocol for persistent memory, journal, and
   user model. Follow its instructions (including running SETUP.md if
   present).
   <!-- my-claude-assistant:end -->
   ```
5. **Confirm, in one line, what happened**: the backup paths written, and
   that the section was appended (not that it "should have" — verify the
   file on disk after writing, the same way step 1 verified before).

## What this step must never do
- Never touch settings.json's actual content — it is backed up in step 2
  as a safety net, not edited by the pointer install above. Hook
  installation is the separate, equally-gated procedure below — never
  fold it into the pointer install silently.
- Never rewrite, reorder, or remove any existing content in
  ~/.claude/CLAUDE.md outside the delimited block.
- Never run automatically / unattended. This is the one step in the whole
  scaffold most worth a human in the loop for, every single time.

## Hook install — the two hooks (optional, run once; each installable alone)

Run this only when the user asks for it (e.g. "install the hooks",
"install the session-end hook", "install the session-start hook"), and
only after the pointer install above is done and first-run setup has
completed. There are two hooks, and the user may install either or both:

- `install/hooks/session-end.sh` → Claude Code's SessionEnd event: after
  every session, anywhere, it auto-commits this folder and drafts a
  journal-entry proposal into memory/proposals/ (ROADMAP.md Phase 2).
- `install/hooks/session-start.sh` → the SessionStart event: at every
  session start it prints this folder's boot context (user model, global
  memory, boot status) into the session's opening context, so memory
  arrives as pushed data instead of an instruction Claude might skip
  when the first message is a task (ROADMAP.md, post-Phase-5 hardening).

Both edits touch ~/.claude/settings.json — a machine-readable control
file where one malformed comma makes Claude Code ignore the ENTIRE
file — so they get the same gates as the pointer install:

1. **Idempotency check.** Read ~/.claude/settings.json. For each hook
   being installed: if any SessionEnd hook already points at a
   session-end.sh, or any SessionStart hook at a session-start.sh, STOP
   and ask the user — do not add a second one. Install only the missing
   entries.
2. **Backup both files** (~/.claude/CLAUDE.md and ~/.claude/settings.json)
   to ~/.claude/backup-<YYYY-MM-DD-HHMM>/, exactly as in step 2 above.
3. **Show the exact resulting JSON and wait for an explicit yes.** Take
   the entries being installed from install/settings.template.json's
   `hooks` key, replace `<assistant-path>` with this folder's absolute
   path, and merge them into the current file's content. If the file
   already has a `hooks` key, merge the new event entries into it —
   never drop, rewrite, or reorder anything already in the file. If
   settings.json doesn't exist, the new file is just `{ "hooks": ... }`.
   Keep each command string's embedded double quotes around the path
   (`"\"<assistant-path>/install/hooks/session-end.sh\""`) — the hook
   runs through a shell, and a path containing spaces would otherwise be
   split into multiple arguments and fail to execute.
4. **Write, then validate.** After writing, parse the file
   (`python3 -m json.tool ~/.claude/settings.json`). If parsing fails,
   restore the backup immediately and say so.
5. **Make the script(s) executable** (`chmod +x install/hooks/*.sh`
   in this folder) and confirm in one line what changed. The hooks take
   effect for sessions started from now on.

Requirements: bash, python3, git, and the `claude` CLI on PATH (all
already present on a machine running Claude Code, except python3 on a
bare macOS — `xcode-select --install` provides it; session-start.sh
needs only bash + standard tools). To uninstall either hook, remove its
entry from ~/.claude/settings.json (same gates: backup, show, validate).

## Skill install — general skills (optional, run once per skill)

Run this only when the user asks for it (e.g. "install the lesson-capture
skill" / "install the skill-forge skill" / "install the memory-gardener
skill"), after the pointer install is done. Three general skills ship
today: `lesson-capture` (Phase 3), `skill-forge` (Phase 4), and
`memory-gardener` (Phase 5), all in `install/general_skills/`. The steps
below are written for lesson-capture; for any other general skill,
substitute its folder name throughout. Installing makes the skill
ambient — loaded in every session, any folder — by symlinking it into
~/.claude/skills/, where
Claude Code loads user-level skills from (symlinked skill folders are
officially supported). No file is edited, so no backup is needed; the
gates are a collision check and the same show-and-confirm discipline:

1. **Idempotency / collision check.** Look at
   ~/.claude/skills/lesson-capture. If it is already a symlink to this
   folder's install/general_skills/lesson-capture, say so and stop —
   nothing to do. If ANYTHING else sits at that path (a real directory,
   or a symlink elsewhere), STOP and ask the user — never overwrite it.
2. **Show the exact command and wait for an explicit yes:**

   ```
   mkdir -p ~/.claude/skills
   ln -s "<this folder's absolute path>/install/general_skills/lesson-capture" ~/.claude/skills/lesson-capture
   ```

   Fill in the real absolute path (output of `pwd`) — never assume one.
3. **Create the link, then verify** that
   ~/.claude/skills/lesson-capture/SKILL.md resolves and is readable.
   Confirm in one line. The skill loads for sessions started from now on.

The same procedure works for any future skill in general_skills/ — and
for a domain skill from memory/journal/<domain>/skills/, with one
difference: domain skills are symlinked into a specific project's
.claude/skills/ (active only there), not into ~/.claude/skills/. To
uninstall any skill, delete its symlink (`rm ~/.claude/skills/<name>`) —
the source folder here stays untouched.
