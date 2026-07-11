# My Claude Assistant

Give Claude Code a memory. Normally every session starts from zero — it
doesn't remember who you are, how you like to work, or what happened last
time. This template fixes that: set it up once (it asks you a few
questions about yourself), and every future session — in any project, any
folder — boots already knowing your standing context. Say "log this
session" to record what happened, and "where did we leave off?" to pick
the thread back up, even weeks later. It's all plain markdown files a
human can read, and Claude keeps them updated as you go.

This file is for you, the human. Everything else in here is addressed to
Claude. **Start here; the install order below is the only part that isn't
self-driving.**

## Install (once)

The clone IS the install: this checkout becomes the live assistant, and
git versions your memory over time. Your copy will hold personal data, so
it must stay private:

- **Do NOT fork this repo on GitHub.** Forks of public repos are public
  and can never be made private — your interview answers and journal
  would end up on the open internet. Clone locally instead (step 1); a
  local clone is private by nature.
- **Optional but recommended — off-machine backup:** local git commits
  don't survive a dead disk. Create your own empty PRIVATE repo and point
  your clone at it: `git remote set-url origin <your-private-repo-url>`.
  This also avoids confusing errors later — your clone's origin otherwise
  points at this template repo, which you can't push to.

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
