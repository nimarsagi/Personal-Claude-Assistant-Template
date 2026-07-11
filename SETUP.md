# First-run setup — deletes itself when done

This file personalizes USER.md and memory/MEMORY.md for whoever installs
this scaffold. It runs once, on the first boot where CLAUDE.md finds it
present, then deletes itself (only itself — never edit CLAUDE.md).

## Steps
1. Look for an existing memory/context file: check ~/.claude/CLAUDE.md and
   anything it points to. If nothing turns up at the default path, ask in
   one line: "Do you have an existing memory/context file you'd like me
   to read? (path, or 'no')". If none exists, skip silently — that's the
   normal case, not a failure.
2. Surface what you already know about this person conversationally, from
   in-session knowledge — there's no API to read stored memory, so just
   draw on what you know from the conversation so far and ask if it's
   worth keeping. On a fresh session there is usually nothing yet: say so
   in one line and move on — never guess or invent impressions to fill
   this step.
3. Interview to filter — MANDATORY, no exception. Ask what matters for
   this workflow to remember as a baseline (role, standing preferences /
   hard guardrails, recurring projects, working style, communication
   defaults, goals). Run this step even if steps 1–2 found nothing — the
   interview alone is a sufficient floor.
   ANTI-PATTERN — do not do this: the user hands over rich material (a
   pasted profile, an imported memory file, a detailed description) and
   you skip the interview because "it already answers everything." It
   never does. Material is INPUT to the interview, not a replacement for
   it: the interview is where the user actively filters what becomes
   baseline memory. With rich material the interview changes shape, not
   existence — confirm what the material claims, and ask about whatever
   it left uncovered (typically hard don'ts, communication defaults,
   and what to call the user). "Skip" from the user on any question is
   a valid answer; skipping the questions yourself is not.
4. Show the confirmed entries for USER.md and memory/MEMORY.md and get an
   explicit yes before writing. Keep each file to max 40 lines,
   purpose-not-inventory — facts and conventions, not example content.
5. Delete this file (SETUP.md) — the whole file, nothing else. Deleting
   it asserts that ALL steps above ran, including the step-3 interview;
   if the interview did not happen, setup is not done and this file must
   stay. Before deleting, verify each step in one line to the user
   (1: import checked, 2: known context surfaced, 3: interview held,
   4: entries approved and written).
6. Git commit the result in this folder — the populated USER.md and
   memory/MEMORY.md plus this file's deletion, one commit. That commit is
   the baseline snapshot of the user's memory; without it the personalized
   files sit uncommitted, with no history and no recovery. If git refuses
   because no identity is configured (fresh machine: user.name/user.email
   unset), set one for this repo first — `git config user.name "<name>"`
   and `git config user.email "<email>"` (values from the user; repo-local
   is fine) — then commit. Don't skip the commit over this.

If setup is interrupted before step 5, this file still exists and will
correctly re-run at the next session boot.
