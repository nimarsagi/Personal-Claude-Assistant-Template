# My Claude Assistant

A file-based persistent memory, journal, and user model for Claude Code.
Once installed, every Claude Code session — in any folder — boots with
your standing context and can log sessions and capture lessons on request.

This file is for you, the human. Everything else in here is addressed to
Claude. **Start here; the install order below is the only part that isn't
self-driving.**

## Install (once)

The clone IS the install: this checkout becomes the live assistant, and
git versions your memory over time. Keep the repo private — it will hold
personal data.

1. Put this folder at whatever permanent path and name you want — there's
   no required location:

   ```
   git clone https://github.com/nimarsagi/Personal-Claude-Assistant-Template.git ~/<name-of-your-choosing>
   ```

   INSTALL.md (next step) reads back the actual path you chose; it never
   assumes a fixed one.

2. Open a Claude Code session **inside that folder** and say:
   **"Run INSTALL.md."** Claude will show you the exact pointer block it
   wants to append to `~/.claude/CLAUDE.md` and wait for your yes. That
   pointer is what makes the assistant load in every future session.

3. Start your next session anywhere. The boot protocol finds `SETUP.md`
   and runs the first-run interview (role, preferences, projects, goals),
   then SETUP.md deletes itself. That's it.

Order matters: INSTALL before SETUP. Until the pointer from step 2
exists, the boot protocol treats any copy of this folder as a source
checkout and refuses to run setup or write memory (see the guard at the
top of `CLAUDE.md`).

## Daily use

- **"log this session"** — appends outcomes/decisions/open loops to
  `memory/journal/<project>/YYYY-MM-DD.md`.
- **"remember this"** — captures a lesson, proposes where it belongs
  (global memory vs. that project's own CLAUDE.md), writes only on your
  explicit yes.
- **"where did we leave off?"** — pulls recent journal entries for the
  current project.

## What's in here

| Path | What it is |
|---|---|
| `CLAUDE.md` | Boot protocol Claude follows every session |
| `USER.md`, `memory/MEMORY.md` | Your user model and global memory (filled by setup) |
| `memory/journal/` | Per-project session logs |
| `memory/proposals/` | Inbox for machine-proposed memories (Phase 2+) |
| `INSTALL.md` | One-time pointer install — the only step that edits outside this folder |
| `SETUP.md` | First-run interview; deletes itself when done |
| `ROADMAP.md` | Phase plan (only Phase 0–1 is live) |
| `install/` | Inert templates for future phases |

## Uninstall

Delete the `<!-- my-claude-assistant:start/end -->` block from
`~/.claude/CLAUDE.md`, then delete this folder. Backups of every control
file INSTALL.md ever touched live in `~/.claude/backup-<timestamp>/`.
