---
name: memory-gardener
description: Consolidates accumulated journal history into curated memory and prunes what's stale. Use when the user says "consolidate memory", "run the gardener", "garden my memory", "weekly memory audit" — or asks to act on the boot-time mention that consolidation is overdue. Reads the journal, proposes per-file diffs to MEMORY.md / USER.md / domain lessons, and writes nothing without approval.
---

# Memory gardener

Domains: all — this skill applies to every kind of work, which is why it
lives in `install/general_skills/` and is linked user-wide, not in one
domain's `skills/` folder linked per project.

## Guard
Resolve the assistant folder: read `~/.claude/CLAUDE.md` and find the
path inside the `<!-- my-claude-assistant:start -->` ... `:end` block.
If the block is missing, say in one line that the assistant isn't
installed (point at its README.md) and stop. Never write into a copy of
the assistant folder that the pointer doesn't name — that's a source
checkout, and its own CLAUDE.md guard refuses memory writes there.

## When to fire (and when not to)
Explicit user request ONLY. Unlike lesson-capture and skill-forge, this
skill has no unprompted noticing: the boot protocol mentions when
consolidation is overdue, but even that is a mention, never a run —
gardening starts when the user asks for it. If the user responds to the
overdue mention ("go ahead", "run it"), that counts as asking.

## Procedure
Follow the "Consolidation" section of the assistant folder's CLAUDE.md —
it is the single source of truth. In short: if proposals are pending,
recommend "review proposals" first; read the curated files, every
domain's LESSONS.md, and journal sessions across all domains since the
last consolidation-log entry (this audit is the explicitly-requested
case where cross-folder journal reads are allowed); report themes to
promote (routed GLOBAL / DOMAIN / LOCAL), stale rules to prune,
duplicates to merge, misrouted content, and cap pressure (MEMORY.md and
USER.md must end at 40 lines or fewer); propose the result as per-file
before/after diffs; write each file ONLY on an explicit yes for that
file; commit, then append one dated line to memory/consolidation-log.md
and commit that too — even on a no-changes run, so the overdue nudge
resets.

## Never
- Edit journal sessions/ files or memory/proposals/ — the historical
  record and the review queue are read-only input here.
- Write any curated file without the user's explicit yes to that file's
  exact diff.
- Propose edits that leave MEMORY.md or USER.md over their 40-line cap.
- Delete or rewrite consolidation-log.md history — append only.
