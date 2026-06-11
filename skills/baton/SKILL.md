---
name: baton
description: Save the distilled working state of a session to a .baton.md handoff file, or pick it up in a fresh session and resume work without re-asking. Use when the user says to save the state, hand off, or continue where the last session left off.
---

# Baton

Treat session handoff like a relay race: the current session writes one small,
dense file (the baton), the next session picks it up, verifies it, and keeps
running. The baton is distilled state, never a chat transcript.

There are two modes. Detect which one the user wants from intent:

- Save mode: "save the state", "write a handoff", "baton save", "we are
  stopping here", "make sure the next session can continue".
- Pickup mode: "continue where we left off", "pick up the baton", "baton
  pickup", "resume the last session's work".

If a `.baton.md` exists in the project root and the user opens a session with
a resume-like request, prefer pickup mode.

## Save mode

Write the file `.baton.md` into the project root. Overwrite any existing
`.baton.md` without asking, the baton always reflects the latest state.
Include the current date in the header.

Rules for the content:

- Distill, do not transcribe. No dialogue, no "first we tried X, then Y".
  Only what the next session needs to act.
- Every claim about state must carry a file path. "The parser is done" is
  useless, "parser implemented in `src/parse.ts`, tests in
  `tests/parse.test.ts`" is a baton.
- The next step is exactly one concrete action, not a list. If you write
  three next steps, you have written zero. Pick the one thing the next
  session should do first.
- Pitfalls capture the non-obvious knowledge that prevents breakage: fragile
  invariants, ordering constraints, things that look wrong but are right.
- Verification names the exact commands that prove the state is healthy,
  with their expected outcome.

### Template

```markdown
# Baton: <project or task name>
Date: <YYYY-MM-DD>

## Mission
Why this work exists, in 2-3 sentences. The goal, not the history.

## State
What is done and where it lives. Bullet points, each with file paths.
- Implemented X in `path/to/file`, covered by `path/to/test`
- Config for Y added in `path/to/config`
- Z is half-done: the function exists in `path/to/file` but is not wired up

## Next step
The single concrete action to take first. One sentence, imperative.
Example: Wire `parseInvoice()` into the upload handler in `src/routes/upload.ts`
and make the failing test in `tests/upload.test.ts` pass.

## Open decisions
Decisions deliberately not made yet, each with the current leaning.
- Retry strategy for failed uploads: leaning toward exponential backoff,
  not decided.

## Pitfalls
What the next session must know to avoid breaking things.
- `migrate.sh` must run before the test suite, tests assume schema v3.
- Do not rename `legacy_id`, an external consumer reads it by name.

## Verification
How to prove the described state actually works.
- `npm test` passes (2 tests intentionally skipped in `tests/email.test.ts`)
- `npm run build` completes without errors
- `curl localhost:3000/health` returns `{"status":"ok"}` after `npm start`
```

### Save procedure

1. Review what actually happened this session: files changed, tests written,
   decisions made. Check `git status` and the diff if available, do not rely
   on memory alone.
2. Fill every section of the template. If a section is genuinely empty,
   write "None" rather than deleting the section, the fixed structure is
   what makes pickup reliable.
3. Run the verification commands yourself before writing them down. Never
   hand the next session a verification step you have not seen pass, and if
   something fails, document the failure honestly in State.
4. Write `.baton.md` to the project root and confirm to the user with a
   one-line summary of the recorded next step.

## Pickup mode

The goal of pickup is to start working within minutes, without asking the
user questions the baton already answers.

### Pickup procedure

1. Read `.baton.md` from the project root. If it does not exist, say so and
   ask the user where the handoff state lives, this is the only case where
   pickup starts with a question.
2. Verify the baton against reality before trusting it:
   - Check that every file path mentioned in State actually exists.
   - Run the commands listed under Verification and compare against the
     expected outcomes.
   - Glance at `git log` / `git status` for changes made after the baton was
     written.
3. Report deviations briefly and factually:
   - "Baton says tests pass, but `npm test` now fails in `parse.test.ts`,
     likely due to a commit made after the baton (abc123). Fixing that first."
   - "Baton references `src/old/` which no longer exists, it was moved to
     `src/core/` after the save. Adjusting."
4. Then start working on the "Next step". Do not ask "should I continue with
   X?" when the baton already states X as the next step, that question is
   exactly what the baton exists to eliminate. Only stop to ask if
   verification reveals that the next step no longer makes sense.
5. Keep the Pitfalls section in mind for the entire session, it is the
   previous session's accumulated scar tissue.

### Example pickup opening

```
Picked up .baton.md (dated 2026-06-10).

Verification:
- All referenced paths exist.
- `npm test`: 14 passing, 2 skipped, matches the baton.
- `npm run build`: clean.
- One deviation: `src/routes/upload.ts` was modified after the baton
  (uncommitted changes), reviewing the diff before proceeding.

Starting on the next step: wiring parseInvoice() into the upload handler.
```

## Anti-patterns

- Writing a session diary. The baton is state, not story. If a paragraph
  starts with "First we discussed", delete it.
- Vague next steps like "continue with the API". The next step names a file
  and an action.
- Multiple competing next steps. One baton, one first move.
- Skipping verification on pickup and inheriting a broken state silently.
  Ten minutes of verification beats two hours of debugging someone else's
  stale assumptions.
- Keeping the baton out of date. An old baton is worse than none, it sends
  the next session confidently in the wrong direction. Overwrite on every
  save.
