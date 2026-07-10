# My Claude Assistant — Boot Protocol

This folder is the source of truth for persistent memory, journal, and
user-model context. Once installed (default path: ~/my-claude-assistant/),
read this file at the start of every Claude Code session, in any project.

## Guard — check before anything else
This protocol is LIVE only if this folder is the exact path named in the
`<!-- my-claude-assistant:start -->` pointer block of ~/.claude/CLAUDE.md.
If that block is missing or names a different path, this is a source/dev
checkout, not the live assistant: do NOT run SETUP.md, do NOT write to
memory/ or journal files here, do NOT delete anything. Say so in one line
and point the user at README.md for install instructions.

## Where things live
- `USER.md` — who the user is: role, working style, standing
  preferences, recurring projects, goals. Read in full at boot.
- `memory/MEMORY.md` — curated GLOBAL facts, feedback, and references
  that hold across every project. Read in full at boot.
- `memory/journal/<project>/YYYY-MM-DD.md` — per-project session
  history. NOT read at boot; pulled on demand (see "Reading journals").
- `memory/proposals/` — machine-proposed journal entries/lessons
  awaiting approval (Phase 2+). Existence checked at boot; contents
  read only when the user reviews them.
- `ROADMAP.md` — the full phase plan; read only when phase status or
  design intent is in question.
- `INSTALL.md` — one-time step that wires this folder into
  ~/.claude/CLAUDE.md so it loads in every session, any folder. Separate
  from SETUP.md and gated more strictly: it is the only step that edits
  a file outside this folder. Run once when the folder is first placed
  at its permanent path; does not delete itself.
- `SETUP.md` — first-run personalization; present only until it
  completes and deletes itself.
- `install/` — inert templates (hook config, skill sources); not
  live until a future install step wires them into ~/.claude/.

## Boot sequence
a. If SETUP.md exists in this folder, first-run setup is still pending
   (see SETUP.md — it removes itself when done). If the user opens with
   setup itself or an empty prompt, run it now. If they open with a real
   question or task, answer that first, then offer to run setup — never
   block the user's actual request behind the interview.
b. Read USER.md and memory/MEMORY.md in full.
c. If memory/proposals/ contains any files, mention them in one line
   (pending proposals awaiting review) — do not act on them unprompted.
d. Do NOT read journal files at boot. Journal history loads on demand only
   (see "Reading journals" below).

## Logging a session (user-triggered)
When the user says "log this session" (or equivalent): determine the
project from working directory / session content, and append outcomes,
decisions, and open loops to memory/journal/<project>/YYYY-MM-DD.md.
- A new project name creates a new subfolder on first use.
- No clear project → memory/journal/general/.
- A session touching two projects → ask in one line which to file under
  (or split the entry, writing only the relevant material to each).
  Never silently guess on a write.

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
Show the exact proposed text and destination; write only on explicit
approval. Do not capture lessons unprompted.

## Standing rules
- Approval gates on memory writes, not on action: background/autonomous
  work is fine, but nothing is written into USER.md, MEMORY.md, or a
  project's own memory files without the user's explicit yes.
- MEMORY.md and USER.md hold GLOBAL facts only, purpose-not-inventory,
  max 25 lines each. Project-specific rules never belong here.
- Nothing programmatic ever edits this file or ~/.claude/ control files.

See ROADMAP.md for the full phase plan (this is Phase 0–1: manual
logging and lesson capture; no hooks or skills installed yet).
