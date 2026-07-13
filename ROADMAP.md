# Roadmap

The full plan for My Claude Assistant, so each phase is designed with the
end-state in mind. Phases 0–5 are built/live today (Phase 5 in its
manual mode; its scheduled headless run is still deferred).

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

## Phase 3 — lesson-capture skill (built 2026-07-12)
Triggers when the user corrects Claude; distills the correction to a
Rule/When/Why lesson; proposes the text AND a destination per the
lesson-routing principle below; applies only on approval. The manual
"remember this" trigger was KEPT (like Phase 2 kept manual logging) —
the skill adds automatic noticing on top; routing and approval rules
are identical for both.
Build notes, where reality amended the original sketch:
- Thin skill, single source of truth: SKILL.md
  (install/general_skills/lesson-capture/) owns only the NOTICING —
  when to fire, when to stay quiet — and defers the whole procedure to
  CLAUDE.md's "Lesson capture" section, so the rules can't drift apart.
- Sensitivity (user-chosen): fire on GENERALIZABLE corrections — ones
  implying a standing rule ("always/never...", same mistake twice) —
  not on one-off fixes. Explicit "remember this" always fires.
- Installed by symlinking into ~/.claude/skills/ (documented, supported
  by Claude Code) via INSTALL.md's skill-install section — the source
  stays git-tracked here.
- Two skill homes with activation to match — see the skills
  architecture below (this build renamed install/skills/ to
  install/general_skills/ and added memory/journal/<domain>/skills/).

## Phase 4 — skill-forge skill (built 2026-07-13)
After solving a novel multi-step problem, proposes a new SKILL.md
(agentskills.io-compatible). Bar: recurring problem + real
trial-and-error. Detection leans on Phase 2's journal, so this phase
can't come before it: trial-and-error is visible within the current
session (several failed attempts before a working fix); recurring is
checked by searching the journal for a similar problem solved before. A
first occurrence, however hard-won, doesn't trigger a proposal — it takes
a second one to confirm the pattern is real rather than a one-off.
Build notes, where reality amended the original sketch:
- Same thin-skill structure as Phase 3: SKILL.md
  (install/general_skills/skill-forge/) owns only the NOTICING; the
  whole procedure lives in CLAUDE.md's "Skill forge" section, so the
  rules can't drift apart.
- An EXPLICIT request ("make this a skill") bypasses the bar entirely —
  the same precedent as lesson-capture's "remember this" always firing.
  The recurrence + trial-and-error bar gates unprompted noticing only.
- The recurrence check needed an exception to the boot protocol's
  "never read across all project folders": it keyword-greps ALL of
  memory/journal/*/sessions/ but reads only the matching entries.
  Documented in CLAUDE.md as the one sanctioned, scoped exception —
  the grep is cheap and blind; full reads stay narrow.
- Drafted skills must include the FAILED approaches as explicit don'ts,
  not just the working procedure — preserving the dead ends is the
  value the trial-and-error paid for.
- Like every phase: unprompted noticing can't be verified on demand
  (same situation as the lesson-capture skill) — it waits for a real
  session that re-solves a journaled problem the hard way.

## Phase 5 — consolidation (built 2026-07-13 — manual mode)
Periodic gardener-style audit merges journal themes into MEMORY.md,
prunes stale rules, enforces page limits. Manual weekly at first; later
a scheduled headless run.
Build notes, where reality amended the original sketch:
- Same thin-skill structure as Phases 3–4: SKILL.md
  (install/general_skills/memory-gardener/) owns only the trigger; the
  whole procedure lives in CLAUDE.md's "Consolidation" section.
- Explicit trigger ONLY — no unprompted noticing at all. "Weekly" is
  made real by a boot nudge instead: the gardener appends one dated
  line to memory/consolidation-log.md after every run (even no-change
  runs), and boot step (e) mentions — never runs — consolidation when
  that log's last line is older than 7 days or missing.
- Prune scope is curated files only: MEMORY.md, USER.md, and domain
  LESSONS.md files. Journal sessions and proposals are read-only input,
  per the standing principle against autonomous edits of the historical
  record. Everything is proposed as per-file before/after diffs,
  approved per file.
- The gardener's read is the sanctioned cross-folder case: an
  explicitly requested audit reads sessions across ALL domains since
  the last log entry (fallback: 30 days).
- The scheduled headless run remains DEFERRED. Design note for when
  it's built: follow the Phase 2 hook pattern — a scheduled run drafts
  a consolidation PROPOSAL into memory/proposals/ for review at next
  boot; it never writes final memory, keeping the approval gate intact.

## Skills architecture (applies to Phase 3–4)
Skills follow the same source-vs-install split as memory, with TWO
git-tracked homes in this folder — and activation matches the home:
- install/general_skills/<name>/ — skills useful in every kind of work
  (lesson-capture lives here). Made live by a symlink in the user-level
  ~/.claude/skills/ (INSTALL.md's skill-install section) → loaded in
  every session, any folder.
- memory/journal/<domain>/skills/<name>/ — skills specific to one domain
  of the user's work, beside that domain's sessions/ and lessons/
  (private, like the rest of the journal — these never enter the public
  template). Made live PER PROJECT: symlinked into a project's own
  .claude/skills/ → loaded only there. Opt-in by construction; turning
  one off is deleting the symlink. No settings-based disable mechanism
  is built or documented — a general skill someone keeps wanting to
  disable isn't general, and should be demoted to a domain skill.
A skill that only exists in its home folder is not yet live anywhere.
skill-forge (Phase 4) routes its output like lessons: domain-specific →
that domain's skills/, genuinely general → install/general_skills/.
**Extend-before-create:** before proposing any new skill, skill-forge
must check BOTH homes for an existing skill the solution belongs in and
prefer proposing an amendment to it; a new skill requires a problem that
fits no existing skill's purpose. This keeps the library a handful of
substantial skills instead of a sprawl of near-duplicate small ones.

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
