# Roadmap

The full plan for My Claude Assistant, so each phase is designed with the
end-state in mind. Phases 0–2 are built/live today.

## Phase 0–1 (built)
Scaffold + boot protocol + first-run setup. Memory files load in every
session via the pointer in ~/.claude/CLAUDE.md. Journaling was
USER-TRIGGERED only ("log this session") until Phase 2. Lesson capture is
likewise USER-TRIGGERED ("remember this") until the Phase 3 skill.
Stop condition (met 2026-07-12): a fresh session in an unrelated folder
answers "where did we leave off?"

## Phase 2 — background journaling (built 2026-07-12)
A SessionEnd hook (`install/hooks/session-end.sh`, wired into
~/.claude/settings.json by INSTALL.md's hook-install section) fires a
detached worker at every session end that reads the session transcript
and, via a cheap headless Claude run, writes a journal-entry draft plus
candidate lessons into memory/proposals/ — never directly into MEMORY.md.
The boot protocol surfaces pending proposals at next session start; the
"Reviewing proposals" section of CLAUDE.md handles approve/edit/reject.
This is why proposals/ exists in the scaffold. The same hook also commits
any uncommitted changes in this folder at session end — turning
Phase 0–1's instruction-based "commit after memory writes" into a
harness-enforced guarantee.
Build notes, where reality amended the original sketch:
- The manual "log this session" trigger was KEPT, not replaced — it's
  still the way to get an entry written immediately and directly; the
  hook is the safety net for sessions nobody logged. The summarizer is
  told to write nothing when a session already logged itself.
- Only interactive sessions are journaled: headless (`claude -p`) runs
  end with reason=prompt_input_exit and are skipped — which is also one
  of three loop guards keeping the hook's own summarizer session (and
  any scripted helper runs) from journaling themselves. The other two:
  the summarizer runs with all hooks disabled (`--settings
  '{"disableAllHooks": true}'` — verified; `--bare` also skips OAuth
  login, so it can't be used), and under a marker env var the script
  checks.
- The headless run gets NO tools: it only returns text, and the shell
  script does every file write and commit itself.

## Phase 3 — lesson-capture skill
Triggers when the user corrects Claude; distills the correction to a
one-line rule; proposes a diff AND a destination per the lesson-routing
principle below; applies only on approval. This skill REPLACES the
manual "remember this" trigger from Phase 0–1 (the "Lesson capture"
section of CLAUDE.md) with automatic noticing — the routing and approval
rules stay identical.

## Phase 4 — skill-forge skill
After solving a novel multi-step problem, proposes a new SKILL.md
(agentskills.io-compatible). Bar: recurring problem + real
trial-and-error. Detection leans on Phase 2's journal, so this phase
can't come before it: trial-and-error is visible within the current
session (several failed attempts before a working fix); recurring is
checked by searching the journal for a similar problem solved before. A
first occurrence, however hard-won, doesn't trigger a proposal — it takes
a second one to confirm the pattern is real rather than a one-off.

## Phase 5 — consolidation
Periodic gardener-style audit merges journal themes into MEMORY.md,
prunes stale rules, enforces page limits. Manual weekly at first; later
a scheduled headless run.

## Skills architecture (applies to Phase 3–4)
Skills follow the same source-vs-install split as memory. The source of
truth for every skill lives in install/skills/ inside this folder
(git-tracked, inert). To be ambient — loaded in every session, any
folder — a skill must be symlinked into the user-level ~/.claude/skills/
by the install step. Skills are NOT loaded directly from this project
folder; a skill that only exists in install/skills/ is not yet live.
skill-forge (Phase 4) writes new skills into install/skills/ and the
install step links them into ~/.claude/skills/.

## Standing principles across all phases

**Approval gates on memory, not on action.** Autonomous execution is
fine; approval is required specifically before writing into memory
(consolidating into MEMORY.md / USER.md, approving proposals).
Background processes write proposals, never final memory.

**Lesson routing** — every captured lesson is classified before filing:
GLOBAL (about the user: preferences, working style, standing decisions)
routes to this folder's MEMORY.md or USER.md and follows the user into
every session. DOMAIN (true across the many projects inside one standing
domain of the user's work, e.g. every client engagement) routes to this
folder's memory/journal/<domain>/lessons/LESSONS.md, read when working
in that domain.
LOCAL (about one workflow or project: its conventions, paths, project
rules) routes to that project's own CLAUDE.md/CONTEXT.md and never
enters this folder's memory. Every proposal states its classification
and destination; when unsure, propose the narrowest tier that fits —
global memory pollution costs every future session, a narrower miss
costs little.

**Journal routing is route-at-write-time**, per project (see this
folder's CLAUDE.md). There is NO retroactive splitter command. If a
supervised one-off reorganization is ever needed, it runs as a proposal
the user approves — never as an autonomous bulk edit of the historical
record.

**Journal folders are orthogonal to GLOBAL/LOCAL routing.** Per-project
journal folders organize the raw record. Lessons still route by the
GLOBAL/LOCAL principle when consolidated: user-level facts → MEMORY.md,
project rules → that project's own CLAUDE.md. "It's in the consultancy
journal folder" is never a substitute for proper lesson routing.

**All memory is human-readable markdown**; purpose-not-inventory; hard
size limits; the folder is the single source of truth, ~/.claude/ holds
only pointers.

**No automated process ever edits load-bearing control files**
(CLAUDE.md, ~/.claude/ config). Setup deletes its own file; hooks write
to proposals/; consolidation proposes diffs for approval.
