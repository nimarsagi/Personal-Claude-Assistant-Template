---
name: lesson-capture
description: Captures lessons from corrections so future sessions behave differently. Use when the user corrects your behavior or approach, says "remember this", "don't do that again", "always do X", "never do Y", "from now on", or corrects the same mistake a second time — distill the correction into a rule and propose where to save it. Also the handler for explicit requests to capture or save a lesson.
---

# Lesson capture

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
Offer to capture a lesson when a correction is GENERALIZABLE — it implies
a standing rule that should change behavior in future sessions, not just
in this task. Signals: "always...", "never...", "stop doing...", "from
now on...", a preference stated as policy, or the same mistake corrected
twice. When the user explicitly asks ("remember this"), always fire.

Stay quiet for one-off fixes: "no, I meant the other file", a typo fix, a
choice specific to the current task. When unsure whether it generalizes,
it probably doesn't — skip it, the user can always say "remember this".

Never interrupt mid-task: finish the current action first, then offer in
one line (e.g. "Want me to save that as a lesson? Draft: ..."). One offer
per correction; if declined, don't re-offer the same lesson.

## Procedure
Follow the "Lesson capture" section of the assistant folder's CLAUDE.md —
it is the single source of truth for format and routing. In short: distill
the correction into three plain-language lines (Rule / When / Why, each
understandable with no session context), classify it GLOBAL / DOMAIN /
LOCAL (narrowest tier that fits), check the destination file for an
existing equivalent rule first (propose sharpening that one instead of
duplicating), show the exact text and destination, and write ONLY after
an explicit yes. Commit GLOBAL/DOMAIN writes in the assistant folder.

## Never
- Write any file without the user's explicit yes to both text and
  destination.
- Put secrets, credentials, or tokens into lesson text.
- Capture a lesson about content the user merely mentioned — only about
  how the user wants the work done.
