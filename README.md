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

4. Optional, any time later: say **"install the session-end hook"** to
   turn on automatic background journaling — every session gets drafted
   into your approval inbox when it ends, so forgetting to say "log this
   session" no longer loses it. This is the only step that edits
   `~/.claude/settings.json`, and it runs behind the same
   backup-show-confirm gate as step 2 (see INSTALL.md).

Order matters: INSTALL before SETUP. Until the pointer from step 2
exists, the boot protocol treats any copy of this folder as a source
checkout and refuses to run setup or write memory (see the guard at the
top of `CLAUDE.md`).

## Daily use

- **"log this session"** — appends outcomes/decisions/open loops to
  `memory/journal/<project>/YYYY-MM-DD.md`.
- **"remember this"** — captures a lesson, proposes where it belongs
  (global memory, a domain lessons file, or that project's own
  CLAUDE.md), writes only on your explicit yes.
- **"where did we leave off?"** — pulls recent journal entries for the
  current project.
- **"review proposals"** — walks through auto-drafted journal entries
  waiting in your approval inbox (only relevant once the session-end
  hook from install step 4 is on); approve, edit, or reject each.

## What it does on its own

Beyond those commands, every session quietly does a few things without
being asked:

- **Loads who you are at boot** — your user model and global memory are
  read at the start of every session, so you never have to re-introduce
  yourself or restate standing preferences.
- **Notices when something's off** — if setup never actually finished, or
  a journal entry looks like it was filed under the wrong project, it says
  so in one line instead of silently working from bad state.
- **Backs memory up as it goes** — every memory write is followed by a
  git commit, so your history is versioned and one accidental deletion
  can't erase it.
- **Defends its own boundaries** — a copy of this folder that isn't the
  installed one refuses to run setup or write memory; stale notes from
  Claude's other, built-in memory don't override what's recorded here;
  and nothing is ever written into your memory files without your
  explicit yes.
- **Journals your sessions in the background** (once the hook from
  install step 4 is on) — when any session ends, a detached helper reads
  the transcript, drafts a journal entry, and drops it into a proposals
  inbox announced at your next session start. Drafts only: nothing enters
  real memory until you approve it. The same helper commits any
  unsaved memory changes, so the "backs memory up" promise above stops
  depending on anyone remembering.

What it deliberately does NOT do on its own (yet): capture lessons
unprompted — that stays user-triggered until Phase 3 in ROADMAP.md.

## Where it's headed

The later phases (see ROADMAP.md) make the assistant progressively more
self-driving, always behind the same approval gate:

- **Automatic lesson capture** — when you correct Claude, it notices,
  distills the correction into a rule, and proposes where to file it.
- **Skill proposals** — after you solve a hard multi-step problem, it
  searches the journal for whether you've struggled through the same
  thing before. Solved it twice, with real trial-and-error both times?
  It proposes packaging the solution as a reusable skill, so the third
  time is one command.

You don't have to wait for those phases to get a taste of the last one:
the journal is plain markdown, so you can always ask "search my journal —
which processes have I repeated?" and get the same analysis on demand.
The limit is coverage: the journal only knows what got logged.

## What's in here

| Path | What it is |
|---|---|
| `CLAUDE.md` | Boot protocol Claude follows every session |
| `USER.md`, `memory/MEMORY.md` | Your user model and global memory (filled by setup) |
| `memory/journal/<domain>/` | Per-domain `sessions/` (dated logs) + `lessons/` (key rules for that area) |
| `memory/proposals/` | Approval inbox for auto-drafted journal entries |
| `INSTALL.md` | Pointer install + optional hook install — the only steps that edit outside this folder |
| `SETUP.md` | First-run interview; deletes itself when done |
| `ROADMAP.md` | Phase plan (Phases 0–2 are live) |
| `install/` | The session-end hook script + settings template |

## Uninstall

Delete the `<!-- my-claude-assistant:start/end -->` block from
`~/.claude/CLAUDE.md`, then delete this folder. Backups of every control
file INSTALL.md ever touched live in `~/.claude/backup-<timestamp>/`.
