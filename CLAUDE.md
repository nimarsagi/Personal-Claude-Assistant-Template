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

## Authority over other memory
Claude Code may keep its own separate built-in project memory (auto-memory,
under ~/.claude/projects/.../memory/) — a different system from this
folder, and one that can go stale since nothing here maintains it. For
anything about the user's own Claude assistant or this template project,
this folder is authoritative. If built-in memory offers a different or
older account, prefer this folder's contents and flag the mismatch to the
user in one line instead of silently repeating the stale version.

## Where things live
- `USER.md` — who the user is: role, working style, standing preferences,
  recurring projects, goals. Read in full at boot.
- `memory/MEMORY.md` — curated GLOBAL facts, feedback, and references
  that hold across every project. Read in full at boot.
- `memory/journal/<project>/YYYY-MM-DD.md` — per-project session history;
  on demand only (see "Reading journals").
- `memory/lessons/<domain>.md` — lessons scoped to one standing domain of
  the user's work (spans many projects, but not all). Read when the task
  clearly falls in that domain — not at boot.
- `memory/proposals/` — journal-entry drafts written by the Phase 2
  session-end hook, awaiting the user's approval; existence checked at
  boot, contents read only on review (see "Reviewing proposals").
- `ROADMAP.md` — phase plan; read only when phase status or design intent
  is in question. Phases 0–2 are live: journaling happens both manually
  and via the background hook; lesson capture is still manual (Phase 3).
- `INSTALL.md` / `SETUP.md` / `install/` — install-time only; each
  explains itself. SETUP.md deletes itself when first-run setup is done.

## Boot sequence
a. If SETUP.md exists in this folder, first-run setup is still pending
   (see SETUP.md — it removes itself when done). If the user opens with
   setup itself or an empty prompt, run it now. If they open with a real
   question or task, answer that first, then offer to run setup — never
   block the user's actual request behind the interview.
b. Read USER.md and memory/MEMORY.md in full. If USER.md still contains
   only its empty headers AND SETUP.md is gone, setup was skipped or its
   file was deleted early — tell the user in one line (SETUP.md can be
   restored with `git checkout SETUP.md`); don't just proceed as if
   setup were done.
c. If memory/proposals/ contains any files besides its own README,
   mention them in one line (pending proposals awaiting review) — do not
   act on them unprompted.
d. Do NOT read journal files at boot; they load on demand only (see
   "Reading journals").

## Logging a session (user-triggered)
If the Phase 2 session-end hook is installed, every session is drafted
into memory/proposals/ automatically when it ends — forgetting to log no
longer loses the session. The manual trigger below still works and is the
right tool when the user wants an entry written immediately and directly.
When the user says "log this session" (or equivalent): determine the
project from working directory / session content, and append outcomes,
decisions, and open loops to memory/journal/<project>/YYYY-MM-DD.md.
- Prefer the canonical names in MEMORY.md's "Journal domains:" line when
  one fits; a genuinely new project name creates a new subfolder on
  first use — say so in one line when that happens.
- Before writing, name the destination in one line ("filing under
  consultancy — ok?") and get a yes; the user re-routes with a word.
- No clear project → memory/journal/general/.
- A session touching two projects → ask in one line which to file under
  (or split the entry, writing only the relevant material to each).
  Never silently guess on a write.
- After writing the entry, git commit it in this folder with a one-line
  message. Uncommitted memory has no history and no recovery — one stray
  cleanup command away from gone.

## Reviewing proposals (user-triggered)
When the user says "review proposals" (or responds to the boot-time
mention of pending ones): for each proposal file in memory/proposals/
(its README isn't one), show the draft entry and its proposed destination
journal file, then ask — approve, edit, or reject. The destination is
itself only a suggestion: say in one line why that folder fits and name
the plausible alternative if there is one. Approval covers BOTH content
and destination — never file to a folder the user hasn't confirmed; they
can re-route to any folder with a word.
- Approve → append the entry to memory/journal/<project>/<date>.md and
  delete the proposal file. Apply the same routing scrutiny as a manual
  log: if the proposed project looks wrong, say so instead of filing.
- Reject → delete the proposal file.
- Edits before approving are welcome; the user's wording wins.
- Candidate lessons inside a proposal do NOT ride along automatically —
  each goes through the Lesson capture rules below (GLOBAL/LOCAL routing,
  its own explicit yes) or is dropped with the proposal.
After processing, git commit the result in this folder. Proposals are
drafts from a background process; they never bypass the approval gate,
and nothing moves out of proposals/ unprompted.

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
Claude and asks to keep it: distill it to a one-line INSTRUCTION a future
session can act on — when <situation>, do/avoid <behavior> (why: <the
mistake it prevents>). A lesson that only describes what happened tells a
future session nothing; sharpen it into what to do differently or drop
it. Then classify it:
- GLOBAL (about the user — preferences, working style, standing
  decisions, true across all projects) → propose an addition to USER.md
  or memory/MEMORY.md in this folder.
- DOMAIN (about one standing domain of the user's work — true across the
  many projects inside it, e.g. a rule for every client engagement) →
  propose an addition to memory/lessons/<domain>.md in this folder,
  using the canonical names from MEMORY.md's "Journal domains:" line.
- LOCAL (about one workflow/project — conventions, paths, project rules)
  → propose an addition to that project's own CLAUDE.md/CONTEXT.md, never
  this folder's memory. If the project has neither file, propose creating
  CLAUDE.md at its root with just this rule.
- When unsure, propose the narrowest tier that fits: LOCAL over DOMAIN
  over GLOBAL.
Show the exact proposed text and destination. Do not capture lessons
unprompted. After an approved GLOBAL or DOMAIN write lands in this
folder, git commit it here (LOCAL writes belong to that project's own
version control, not this folder's).

## Standing rules
- Approval gates on memory writes, not on action: background/autonomous
  work is fine, but nothing is written into USER.md, MEMORY.md, or a
  project's own memory files without the user's explicit yes.
- MEMORY.md and USER.md hold GLOBAL facts only, purpose-not-inventory,
  max 40 lines each. Project-specific rules never belong here.
- Nothing programmatic ever edits this file or ~/.claude/ control files.
