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
   worth keeping.
3. Interview to filter: ask what matters for this workflow to remember as
   a baseline (role, standing preferences, recurring projects, working
   style). Run this step even if steps 1–2 found nothing — the interview
   alone is a sufficient floor.
4. Show the confirmed entries for USER.md and memory/MEMORY.md and get an
   explicit yes before writing. Keep each file under half a page,
   purpose-not-inventory — facts and conventions, not example content.
5. Delete this file (SETUP.md) — the whole file, nothing else.

If setup is interrupted before step 5, this file still exists and will
correctly re-run at the next session boot.
