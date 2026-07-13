---
name: skill-forge
description: Turns a hard-won solution into a reusable skill so future sessions skip the trial-and-error. Use when the user says "make this a skill", "turn this into a skill", or "skill-forge this" — or, unprompted, when a problem in this session was solved only after several failed attempts AND the journal shows a similar problem was solved before. Drafts a SKILL.md and proposes where to save it; never writes without approval.
---

# Skill forge

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
An explicit request ("make this a skill", "turn this into a skill")
always fires — no further bar; the user's ask is its own justification.

Unprompted noticing requires BOTH of:
1. **Trial-and-error, in this session**: the problem was solved only
   after several genuinely failed attempts before the working fix. A
   long or multi-step task done right the first time does NOT qualify —
   there's no hard-won path worth preserving.
2. **Recurrence, in the journal**: a similar problem was solved before
   (the procedure's journal search finds it). A first occurrence,
   however hard-won, stays quiet — it takes a second one to confirm the
   pattern is real rather than a one-off.

Never interrupt mid-task: finish the current action first, then offer in
one line (e.g. "This took three tries and the journal shows we hit it
before — want me to draft a skill for it?"). One offer per solution; if
declined, don't re-offer the same skill.

## Procedure
Follow the "Skill forge" section of the assistant folder's CLAUDE.md —
it is the single source of truth for the recurrence check, drafting
format, and routing. In short: keyword-grep all of
`memory/journal/*/sessions/` and read only the matching entries (the one
sanctioned exception to the no-cross-folder-reads rule); check BOTH
skill homes for an existing skill to extend before creating anything
new; draft an agentskills.io-compatible SKILL.md whose body captures
what worked AND the failed approaches to avoid; route it domain vs
general (narrowest that fits); show the full text and destination and
write ONLY after an explicit yes; commit in the assistant folder; then
offer the activation symlink — a skill in its home folder is not live.

## Never
- Write any file without the user's explicit yes to both text and
  destination.
- Put secrets, credentials, or tokens into skill text.
- Propose a new skill when the solution belongs inside an existing
  skill's purpose — propose extending that one instead.
