# personal-claude-assistant-template

**My Claude Assistant** gives Claude Code a memory. Normally every session
starts from zero — it doesn't remember who you are, how you work, or what
happened last time. Set this up once (it asks you a few questions about
yourself) and every future session, in any folder, boots already knowing
your standing context. It also learns: corrections become standing rules,
hard-won solutions become reusable skills, and a weekly tidy-up keeps
memory sharp instead of letting it silt up.

Nothing enters your memory without your explicit yes. Background work runs
freely but only ever produces drafts and offers — the moment something
would enter a memory file, it stops and asks. That's why you can let it run
unattended without fearing what it "learned" while you weren't looking.

Your whole memory is plain markdown in one folder — inspectable, editable,
versioned, portable — and `~/.claude/` holds only a pointer and symlinks.
This file is for you, the human. Everything else here is addressed to Claude.

## Install

The clone IS the install: this checkout becomes the live assistant, and git
versions your memory over time. Your copy will hold personal data, so it
must stay private.

- **Do NOT fork this repo on GitHub.** Forks of public repos are public and
  can never be made private — your interview answers and journal would end
  up on the open internet. Clone locally instead.
- **Optional but recommended — off-machine backup:** local commits don't
  survive a dead disk. Create your own empty PRIVATE repo and point your
  clone at it: `git remote set-url origin <your-private-repo-url>` —
  otherwise origin points at this template repo, which you can't push to.

1. Put this folder at whatever permanent path and name you want:

   ```
   git clone https://github.com/nimarsagi/Personal-Claude-Assistant-Template.git ~/<name-of-your-choosing>
   ```

2. Open a Claude Code session **inside that folder** and say **"Run
   INSTALL.md."** Claude shows you the exact pointer block it wants to add
   to `~/.claude/CLAUDE.md` and waits for your yes — that pointer is what
   loads the assistant in every future session.
3. Start your next session anywhere. Boot finds `SETUP.md` and runs the
   first-run interview, then SETUP.md deletes itself. One question in there
   is worth taking seriously: which of your preferences are absolute — the
   ones that shouldn't bend even when there's a good local reason to.

Order matters: INSTALL before SETUP. Until the pointer from step 2 exists,
boot treats any copy of this folder as a source checkout and refuses to run
setup or write memory.

## Optional installs

Say "install the hooks", or name one — the only step that edits
`~/.claude/settings.json`, behind the same backup-show-confirm gate as
step 2. **session-start** pushes your user model and memory straight into
every new session, so boot stops depending on Claude following the pointer,
which a task-heavy first message can outrace. **session-end** drafts every
session into your approval inbox when it ends and commits unsaved memory.
**standing-rules** restates the preferences you marked absolute, one
sentence, on every prompt — a rule stated once at the top of a session
quietly loses to a good reason forty turns later.

Three skills install the same way, one symlink each: **lesson-capture**
notices a correction that implies a standing rule, **skill-forge** offers to
package a solution you've now reached the hard way twice, and
**memory-gardener** adds the weekly tidy-up.

## Daily use

Each of these writes only on your explicit yes. **"log this session"**
appends outcomes, decisions and open loops to the journal, and **"where did
we leave off?"** reads them back. **"remember this"** captures a lesson and
proposes the narrowest home that fits — global memory, one domain's lessons
file, or that project's own CLAUDE.md. **"review proposals"** walks through
the auto-drafted entries waiting in your inbox — approve, edit, or reject
each. **"make this a skill"**
packages what was just done, dead ends included. **"park this for later"**
saves a non-urgent thing you noticed mid-task instead of derailing what
you're doing. **"consolidate memory"** is the weekly tidy-up: it proposes,
as per-file before/after diffs you approve one by one, which themes to
promote into standing memory, which stale rules to prune, which
near-duplicates to merge.

With lesson-capture installed Claude also tries to notice on its own, but
not reliably — for anything you want caught for sure, say "always...",
"never...", or "remember this".

## Layout

```
personal-claude-assistant-template/
├─ CLAUDE.md          boot protocol: the guard, the boot read, what to open when
├─ rules.md           the gates: where a lesson lands, how much journal to read
├─ USER.md            who you are — written by the interview, loaded every session
├─ SETUP.md           the first-run interview; deletes itself when done
├─ INSTALL.md         the only steps that write outside this folder
├─ ROADMAP.md         phase plan and build notes: why each odd detail is odd
├─ parked-for-later.md   deferred work spanning more than one domain
├─ reference/
│  └─ journaling.md      logging a session, reviewing proposals
├─ install/
│  ├─ hooks/             the three background helpers, each optional
│  ├─ general_skills/    lesson-capture, skill-forge, memory-gardener
│  └─ settings.template.json   the hook entries INSTALL.md merges into yours
└─ memory/
   ├─ MEMORY.md          curated global facts, loaded every session
   ├─ consolidation-log.md  one dated line per tidy-up; the weekly nudge reads it
   ├─ proposals/         approval inbox for auto-drafted journal entries
   └─ journal/<domain>/  sessions/ + lessons/ + skills/ + parked-for-later.md
```

Domain skills activate per project: symlink one from
`memory/journal/<domain>/skills/` into that project's `.claude/skills/` and
it loads only there; delete the symlink to turn it off. Still to come: a
scheduled consolidation that drafts its proposals in the background, like
session journaling already does.

## Uninstall

Delete the `<!-- my-claude-assistant:start/end -->` block from
`~/.claude/CLAUDE.md`, remove any hook entries from
`~/.claude/settings.json` and any skill symlinks in `~/.claude/skills/`
(if you installed those), then delete this folder. Backups of every control
file INSTALL.md ever touched live in `~/.claude/backup-<timestamp>/`.

MIT licensed.
