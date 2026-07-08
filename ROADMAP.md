# Roadmap

The full plan for My Claude Assistant, so each phase is designed with the
end-state in mind. Only Phase 0–1 is built/live today.

## Phase 0–1 (current)
Scaffold + boot protocol + first-run setup. Memory files load in every
session via the pointer in ~/.claude/CLAUDE.md. Journaling is
USER-TRIGGERED (the user says "log this session"); best-effort automatic
journaling does not exist until the Phase 2 hook. Lesson capture is
likewise USER-TRIGGERED ("remember this") until the Phase 3 skill.
Stop condition: a fresh session in an unrelated folder answers "where
did we leave off?"

## Phase 2 — background journaling
A SessionEnd hook fires a detached headless process that reads the
session transcript and writes journal entries + candidate lessons into
memory/proposals/ — never directly into MEMORY.md. This hook REPLACES
the manual "log this session" trigger from Phase 0–1. The boot protocol
already surfaces pending proposals at next session start for a quick
approve/reject. This is why proposals/ exists in the scaffold.

## Phase 3 — lesson-capture skill
Triggers when the user corrects Claude; distills the correction to a
one-line rule; proposes a diff AND a destination per the lesson-routing
principle below; applies only on approval. This skill REPLACES the
manual "remember this" trigger from Phase 0–1 (boot protocol step f)
with automatic noticing — the routing and approval rules stay identical.

## Phase 4 — skill-forge skill
After solving a novel multi-step problem, proposes a new SKILL.md
(agentskills.io-compatible). Bar: recurring problem + real
trial-and-error.

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
every session. LOCAL (about one workflow or project: its conventions,
paths, domain rules) routes to that project's own CLAUDE.md/CONTEXT.md
and never enters global memory. Every proposal states its classification
and destination; when unsure, propose LOCAL — global memory pollution
costs every future session, a local miss costs one.

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
