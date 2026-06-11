---
name: elephant
description: Maintain persistent project memory as plain markdown files (one file per fact plus a one-line-per-entry index) readable by humans and agents alike, for remembering decisions, preferences, constraints, references, and lessons across sessions.
---

# Elephant

Give a project a memory that survives the session. No database, no embeddings, no special tooling: a `memory/` folder with one markdown file per fact and one index file. Humans can read and edit it, agents can grep it, git can diff it.

The design goal is cheap reads. The index is small enough to load at every session start; individual entries are opened only when their one-line hook matches the task at hand.

## Layout

```
project/
└── memory/
    ├── MEMORY.md                      index, read at session start
    ├── decision-db-sqlite.md
    ├── constraint-api-rate-limit.md
    ├── preference-commit-style.md
    ├── reference-payment-docs.md
    └── lesson-staging-db-shared.md
```

File naming: `<type>-<kebab-case-topic>.md`. The name doubles as the entry's identity for linking.

## Entry Format

One file per fact. Keep the body under one screen; if it grows past that, it is probably two facts.

```markdown
---
name: decision-db-sqlite
description: One sentence that lets a reader decide whether to open this file.
type: decision
created: 2026-06-11
updated: 2026-06-11
---

# SQLite over Postgres for this project

Context: single-user desktop tool, no concurrent writers, deployment must be
a single binary.

Decision: use SQLite via the standard driver. Revisit only if multi-user
sync becomes a requirement.

Related: [[constraint-offline-first]]
```

The `type` field uses a fixed vocabulary. Do not invent new types; if nothing fits, the fact probably should not be stored.

| Type | Meaning | Example |
|---|---|---|
| decision | A choice was made, with the reasoning | "Cursor pagination over offset, because of shifting result sets" |
| preference | How the user wants things done | "Commit messages in English, imperative, no scopes" |
| constraint | A hard limit imposed from outside | "Partner API allows 100 requests per minute, hard cap" |
| reference | An external resource that took effort to find | "The only accurate webhook docs are at <URL>, the main docs are stale" |
| lesson | A pitfall that was hit once and must not be hit again | "Staging DB is shared; never truncate tables there" |

## Index Format

`MEMORY.md` holds one line per entry: a link plus a hook. The hook answers "when should I open this?" in a few words. No prose, no sections per entry.

```markdown
# Project Memory

One line per entry. Open an entry only when its hook matches the current task.

- [decision-db-sqlite](decision-db-sqlite.md) - SQLite chosen over Postgres; read before touching persistence
- [constraint-api-rate-limit](constraint-api-rate-limit.md) - partner API caps at 100 req/min; read before adding API calls
- [preference-commit-style](preference-commit-style.md) - commit message rules; read before committing
- [lesson-staging-db-shared](lesson-staging-db-shared.md) - staging DB is shared; read before running anything destructive
```

Update the index in the same step as creating, changing, or deleting an entry. An index that lies is worse than no index.

## When to Save

Write a memory entry when one of these triggers fires:

- A decision was made after real discussion or comparison of options
- The user corrects you ("no, we always deploy from tags", "stop using that library")
- A pitfall cost noticeable time and would cost it again without a note
- An external reference was hard to find and will be needed again
- A stable preference shows up repeatedly in the user's feedback

When a trigger fires, save immediately, not at the end of the session. Sessions end unexpectedly.

## When NOT to Save

- Anything derivable from the code or git history: file locations, function signatures, who changed what. The repo already remembers this better than you can.
- One-off task details that will be irrelevant next week
- Speculation, plans not yet decided, or open questions (track those in an issue or todo, not in memory)
- Secrets, credentials, tokens: never, under any circumstances
- A near-duplicate of an existing entry (update the existing one instead)

## Hygiene Rules

- Update over duplicate. Before writing, scan MEMORY.md for an entry on the same topic. If one exists, update it and bump `updated`, do not create a sibling.
- Absolute dates only. Rewrite "since last sprint" or "next month" as concrete dates ("since 2026-05-25") at write time. Relative dates rot.
- Delete wrong entries. When a fact turns out to be false or obsolete, delete the file and its index line. Do not keep a corrected entry next to a wrong one.
- Link related entries with `[[name]]` so readers can follow the trail, for example `[[constraint-api-rate-limit]]` inside a decision about caching.
- Keep hooks honest. The index hook must say when to open the entry, not summarize its whole content.

## Loading the Index at Session Start

The memory only works if it is actually read. Two generic options, pick what the environment supports:

1. Project instructions file. Add a short standing instruction to whatever file your agent reads automatically at startup in this project:

```markdown
## Memory
Read memory/MEMORY.md at the start of every session. Open individual
entries only when their hook matches the current task. Follow the
elephant skill's rules when adding or updating entries.
```

2. Session-start hook. If the agent runner supports startup hooks, register one that prints the index into the context, for example a command equivalent to `cat memory/MEMORY.md`. Keep the hook reading only the index, not all entries; the point of the hook line is cheap context.

For human teammates, mention the `memory/` folder in the project README so they know it exists and may edit it.

## Worked Example

The user says during a session: "We tried caching the partner API responses last month and got burned, the data changes without notice. Don't cache it."

That is a lesson trigger. Create `memory/lesson-partner-api-no-cache.md`:

```markdown
---
name: lesson-partner-api-no-cache
description: Partner API responses must not be cached; payloads change without versioning or notice.
type: lesson
created: 2026-06-11
updated: 2026-06-11
---

# Do not cache partner API responses

Tried in 2026-05: cached responses for 15 minutes, served stale prices for
hours because the API mutates data without version bumps or cache headers.

Rule: always fetch live. If latency becomes a problem, solve it on our side
with request coalescing, not response caching.

Related: [[constraint-api-rate-limit]]
```

And add the index line:

```markdown
- [lesson-partner-api-no-cache](lesson-partner-api-no-cache.md) - never cache partner API responses; read before adding any caching layer
```

Next session, the index line alone is enough to prevent the same mistake, and the full file carries the reasoning for anyone who asks why.
