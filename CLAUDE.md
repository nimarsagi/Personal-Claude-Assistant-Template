# My Claude Assistant — Boot Protocol

This folder is the source of truth for persistent memory, journal, and
user-model context. Once installed, read this file at the start of every
Claude Code session, in any project.

## Guard — check before anything else
This protocol is LIVE only if this folder is the exact path named in the
`<!-- my-claude-assistant:start -->` pointer block of ~/.claude/CLAUDE.md.
If that block is missing or names a different path, this is a source/dev
checkout, not the live assistant: do NOT run SETUP.md, do NOT write to
memory/ or journal files here, do NOT delete anything. Say so in one line
and point the user at README.md.

## Where things live
- `USER.md` — who the user is: role, working style, standing preferences,
  recurring projects, goals. Read in full at boot.
- `memory/MEMORY.md` — curated GLOBAL facts, feedback, and references
  that hold across every project. Read in full at boot.
- `memory/journal/<project>/YYYY-MM-DD.md` — per-project session history;
  on demand only (see "Reading journals").
- `memory/proposals/` — machine-proposed entries awaiting approval
  (Phase 2+); existence checked at boot, contents read only on review.
- `ROADMAP.md` — phase plan; read only when phase status or design intent
  is in question. This is Phase 0–1: manual logging and lesson capture.
- `INSTALL.md` / `SETUP.md` / `install/` — install-time only; each
  explains itself. SETUP.md deletes itself when first-run setup is done.

## Boot sequence
a. If SETUP.md exists in this folder, first-run setup is still pending
   (see SETUP.md — it removes itself when done). If the user opens with
   setup itself or an empty prompt, run it now. If they open with a real
   question or task, answer that first, then offer to run setup — never
   block the user's actual request behind the interview.
b. Read USER.md and memory/MEMORY.md in full.
c. If memory/proposals/ contains any files, mention them in one line
   (pending proposals awaiting review) — do not act on them unprompted.
d. Do NOT read journal files at boot; they load on demand only (see
   "Reading journals").

## Logging a session (user-triggered)
When the user says "log this session" (or equivalent): determine the
project from working directory / session content, and append outcomes,
decisions, and open loops to memory/journal/<project>/YYYY-MM-DD.md.
- A new project name creates a new subfolder on first use.
- No clear project → memory/journal/general/.
- A session touching two projects → ask in one line which to file under
  (or split the entry, writing only the relevant material to each).
  Never silently guess on a write.
- After writing the entry, git commit it in this folder with a one-line
  message. Uncommitted memory has no history and no recovery — one stray
  cleanup command away from gone.

## Reading journals (on demand)
Pull journal history when the user asks a continuity question ("where did
we leave off", "what did we decide about X", "catch me up on <project>")
or when the task clearly depends on prior decisions in a known project.
- Determine the project the same way as at write time.
- Read only that project's folder, most recent entries first: at most
  the 5 newest entries, and none older than 14 days — both caps apply —
  unless asked for more.
- No clear project (e.g. an unrelated folder): find the journal folder
  with the most recently modified entry (general/ counts like any other —
  recency beats folder-guessing), answer from it, and name which folder
  you read in one line. Do not block on a clarifying question.
- Never read across all project folders unless explicitly asked.
- If an entry seems to belong to a different project than the folder it
  sits in, flag it to the user in one line instead of using it silently —
  misfiled history is invisible unless a reader says something.

## Lesson capture (user-triggered)
When the user says "remember this" / "capture that lesson", or corrects
Claude and asks to keep it: distill it to a one-line rule, classify it:
- GLOBAL (about the user — preferences, working style, standing
  decisions, true across all projects) → propose an addition to USER.md
  or memory/MEMORY.md in this folder.
- LOCAL (about one workflow/project — conventions, paths, domain rules)
  → propose an addition to that project's own CLAUDE.md/CONTEXT.md, never
  this folder's memory. If the project has neither file, propose creating
  CLAUDE.md at its root with just this rule.
- When unsure, propose LOCAL.
Show the exact proposed text and destination. Do not capture lessons
unprompted. After an approved GLOBAL write lands in this folder, git
commit it here (LOCAL writes belong to that project's own version
control, not this folder's).

## Standing rules
- Approval gates on memory writes, not on action: background/autonomous
  work is fine, but nothing is written into USER.md, MEMORY.md, or a
  project's own memory files without the user's explicit yes.
- MEMORY.md and USER.md hold GLOBAL facts only, purpose-not-inventory,
  max 25 lines each. Project-specific rules never belong here.
- Nothing programmatic ever edits this file or ~/.claude/ control files.
