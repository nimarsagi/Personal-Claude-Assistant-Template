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
  as a safety net, not edited. Hook installation is a future phase.
- Never rewrite, reorder, or remove any existing content in
  ~/.claude/CLAUDE.md outside the delimited block.
- Never run automatically / unattended. This is the one step in the whole
  scaffold most worth a human in the loop for, every single time.
