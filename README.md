# My Claude Assistant

Give Claude Code a memory. Normally every session starts from zero — it
doesn't remember who you are, how you like to work, or what happened last
time. This template fixes that: set it up once (it asks you a few
questions about yourself), and every future session — in any project, any
folder — boots already knowing your standing context. Say "log this
session" to record what happened, and "where did we leave off?" to pick
the thread back up, even weeks later. It's all plain markdown files a
human can read, and Claude keeps them updated as you go.

It doesn't just remember — it learns. Corrections you make become
standing rules. Problems you solve the hard way become reusable skills.
And a weekly tidy-up keeps the memory sharp instead of letting it silt
up. Every one of those writes happens behind the same gate: nothing
enters your memory without your explicit yes.

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

5. Optional, any time later: three skills, each installed by asking and
   each just one symlink in `~/.claude/skills/` (see INSTALL.md):
   - **"install the lesson-capture skill"** — Claude notices when you
     correct it in a way that implies a standing rule ("always ask
     before deleting"), distills the correction into a lesson, and
     offers to save it.
   - **"install the skill-forge skill"** — when a problem gets solved
     only after several failed attempts, and your journal shows you've
     struggled through the same thing before, Claude offers to package
     the solution as a reusable skill — so the third time is one
     command.
   - **"install the memory-gardener skill"** — adds the "consolidate
     memory" command (see Daily use) and its weekly boot reminder.

Order matters: INSTALL before SETUP. Until the pointer from step 2
exists, the boot protocol treats any copy of this folder as a source
checkout and refuses to run setup or write memory (see the guard at the
top of `CLAUDE.md`).

## Daily use

- **"log this session"** — appends outcomes/decisions/open loops to
  `memory/journal/<project>/YYYY-MM-DD.md`.
- **"remember this"** — captures a lesson, proposes where it belongs
  (global memory, a domain lessons file, or that project's own
  CLAUDE.md), writes only on your explicit yes. If the lesson-capture
  skill (install step 5) is on, it also tries to notice on its own when
  a correction implies a standing rule — but that recognition isn't
  guaranteed for naturally-phrased corrections. For a recurring problem
  you want reliably caught, say it explicitly: "always...", "never...",
  or "remember this" — don't rely on it being inferred from ordinary
  wording.
- **"where did we leave off?"** — pulls recent journal entries for the
  current project.
- **"review proposals"** — walks through auto-drafted journal entries
  waiting in your approval inbox (only relevant once the session-end
  hook from install step 4 is on); approve, edit, or reject each.
- **"make this a skill"** — packages what was just done into a reusable
  skill draft, including the dead ends to avoid, and proposes where it
  belongs; written only on your yes.
- **"consolidate memory"** — the weekly tidy-up: reads what the journal
  has accumulated, then proposes — as per-file before/after diffs you
  approve one by one — which recurring themes to promote into standing
  memory, which stale rules to prune, which near-duplicates to merge.
  Do "review proposals" first if the inbox has items; unreviewed drafts
  aren't part of the record yet.

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
- **Notices corrections worth keeping** (once the skill from install
  step 5 is on) — when you correct Claude in a way that implies a
  standing rule, it offers to save the lesson, with a suggested home
  (global memory, a domain's lessons file, or that project's own
  CLAUDE.md). One-off fixes are left alone; nothing is saved without
  your yes.
- **Notices solutions worth keeping** (skill-forge, same install step) —
  when something got fixed only after several failed attempts AND the
  journal shows you've hit the same problem before, it offers to package
  the solution as a skill. A hard task done right first try, or a
  first-ever occurrence, stays quiet — the bar is a proven repeat.
- **Reminds you to tidy up** — if the last consolidation run is more
  than a week old, the next session mentions it in one line. Mentions
  only; the tidy-up itself never runs without you asking.

## The nuances — how it's designed

A few deliberate choices explain most of how this thing behaves:

**The learning loop.** Raw history flows upward through four stages,
each more distilled than the last: sessions get *journaled* (the raw
record), corrections get *distilled into lessons* (standing rules),
repeated hard-won solutions get *packaged as skills* (reusable
procedures), and the gardener periodically *consolidates* the
accumulation into curated memory. Each stage feeds the next; nothing
skips the approval gate on the way up.

**Approval gates memory, not action.** Background processes run freely —
the session-end hook journals on its own, skills notice things on their
own. But autonomous work only ever produces *drafts and offers*. The
moment something would enter a memory file, it stops and asks. That one
rule is why you can let it run unattended without fearing what it
"learned" while you weren't looking.

**Everything saved gets routed to the narrowest home that fits.** A fact
about you (goes in global memory, loads everywhere) is different from a
rule for one domain of your work (that domain's lessons file, loads when
working there) is different from a convention of one project (that
project's own CLAUDE.md — never this folder). When in doubt, narrower
wins: a misrouted global fact taxes every future session, a misrouted
local one costs almost nothing.

**Writes ask, reads guess.** Filing a journal entry under an ambiguous
project? It asks first — misfiled history is nearly invisible later.
Answering "where did we leave off?" from an ambiguous folder? It picks
the most recent journal and says which one it read — a wrong guess there
costs one answer, and disclosure lets you redirect it.

**Memory is curated, not accumulated.** The boot files have hard size
caps (about half a page each), so every session starts cheap. The
journal can grow; the stuff loaded every time cannot. The gardener
exists to enforce exactly this — promote what earned its place, prune
what went stale.

**Structure over instructions.** The project's recurring lesson: rules
that live only as written instructions eventually get skipped; rules
built into the machinery don't. So "commit after memory writes" became a
hook that commits automatically, and formatting rules that broke in
practice got replaced by checks that tolerate real-world writing. Where
you see an odd design detail, there's usually a story like that behind
it (ROADMAP.md's build notes record them).

**One folder, plain markdown, git underneath.** Your entire memory is
human-readable files in this one folder — inspectable, editable,
versioned, portable. `~/.claude/` holds only a pointer and symlinks.
Uninstalling is deleting a text block and some symlinks; nothing is
hidden anywhere else.

The one piece still to come: a scheduled version of consolidation that
drafts its proposals in the background (like session journaling already
does). Until then the gardener runs when you ask, and boot reminds you
weekly.

## What's in here

| Path | What it is |
|---|---|
| `CLAUDE.md` | Boot protocol Claude follows every session |
| `USER.md`, `memory/MEMORY.md` | Your user model and global memory (filled by setup) |
| `memory/journal/<domain>/` | Per-domain `sessions/` (dated logs) + `lessons/` (key rules) + `skills/` (that domain's own skills) |
| `memory/proposals/` | Approval inbox for auto-drafted journal entries |
| `memory/consolidation-log.md` | One dated entry per gardener run; boot checks it to remind you weekly |
| `INSTALL.md` | Pointer install + optional hook/skill installs — the only steps that edit outside this folder |
| `SETUP.md` | First-run interview; deletes itself when done |
| `ROADMAP.md` | Phase plan with build notes (all phases live; consolidation's scheduled mode still to come) |
| `install/` | The session-end hook script, settings template, and `general_skills/` (the three skills useful everywhere: lesson-capture, skill-forge, memory-gardener) |

Domain skills activate per project: symlink one from
`memory/journal/<domain>/skills/` into that project's `.claude/skills/`
and it loads only there; delete the symlink to turn it off. General
skills live in `install/general_skills/` and load everywhere once
installed (step 5).

## Uninstall

Delete the `<!-- my-claude-assistant:start/end -->` block from
`~/.claude/CLAUDE.md`, remove the SessionEnd entry from
`~/.claude/settings.json` and any skill symlinks in `~/.claude/skills/`
(if you installed those optional steps), then delete this folder.
Backups of every control file INSTALL.md ever touched live in
`~/.claude/backup-<timestamp>/`.
