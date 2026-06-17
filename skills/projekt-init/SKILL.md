---
name: projekt-init
description: Scaffold a clean, conventional project skeleton — vision, brief, agent instructions, and a file-based _memory/ folder — before any code is written. Use when starting a new project or repository and you want a structure that both humans and agents can navigate from day one.
---

# Projekt Init

Start every project on the same skeleton so an agent never has to guess where
things live. No database, no tooling: a handful of Markdown files plus a
`_memory/` folder that holds everything an agent should know about the project.

The skeleton separates three concerns that usually get muddled in a fresh repo:
- **why** the project exists (`VISION.md`)
- **what** it is and where it stands right now (`PROJECT_BRIEF.md`)
- **how** an agent should operate inside it (`CLAUDE.md` + `_memory/`)

This is the setup step, not the build step. It writes structure and placeholders,
never feature code.

## When to Use

- the user starts a new project, app, or repository
- an existing folder has no consistent agent-readable structure
- you want vision / brief / agent-instructions split into stable files
- you want persistent, file-based project memory from the first commit

## When NOT to Use

| Instead of projekt-init | Use |
| --- | --- |
| Turning an idea into a build plan | `blueprint` |
| Pressure-testing the plan first | `plan-interview` |
| Adding memory to a project that already has structure | `elephant` |
| Writing actual feature code | just build it |

## What it creates

```
<project>/
  VISION.md            why it exists, success criteria, non-goals, stakeholders
  PROJECT_BRIEF.md     what/how + current status, quick-facts, conventions
  CLAUDE.md            agent operating instructions; @-pulls _memory into context
  .gitignore           sensible defaults (secrets, deps, caches, raw inputs)
  _input/              raw briefing material — gitignored, never the source of truth
  _output/             generated artifacts (decks, docs, mockups)
  _memory/
    DOMAIN.md          pointer file → domain-model.md
    HOWTO.md           operational knowledge: workarounds, setup notes, lessons
    domain-model.md    entities, relations, constraints, invariants
    open-threads.md    current open questions / work in progress
    memory/
      MEMORY.md        index for project-specific memories (one file per fact)
```

`_memory/` is the project's brain. It is plain Markdown so humans can read and
edit it, agents can grep it, and git can diff it. `CLAUDE.md` pulls
`domain-model.md` and `open-threads.md` into context automatically via
`@`-pointers, so an agent always loads the structural facts and the live
threads without being told to.

## Workflow

### 1. Pick a name

Use `kebab-case-lowercase`, starting with a letter (`sales-analyse`, `my-app` —
not `MyApp`, `my_app`, or `1app`). This becomes the folder name and, if you
publish, the repo name.

### 2. Copy the template

Copy `template/` from this skill into a new folder named after the project.
Then replace the two placeholder tokens in every file:

- `{{PROJECT}}` → the project name
- `{{DATE}}` → today's date (`YYYY-MM-DD`)

Keep the `_memory/` files even though they are mostly empty. Empty-but-present
beats missing: the agent learns the shape of the project's memory before there
is anything to remember.

### 3. First commit

```bash
cd <project>
git init -b main
git add .
git commit -m "init: <project> project skeleton"
```

Optionally create a remote and push (`gh repo create <project> --source=. --push`,
or your platform's equivalent). This is optional — the skeleton is useful with
or without a remote.

### 4. Hand off to the human

The skeleton ships full of `_TBD_` placeholders on purpose. Do **not** invent
content. Point the user at the next steps:

1. Drop briefing material into `_input/` (transcripts, PDFs, requirement docs).
2. Fill `VISION.md` and `PROJECT_BRIEF.md` with real content.
3. Capture structural knowledge in `_memory/domain-model.md`.

## Conventions baked in

- **`_input/` is never the source of truth.** It is raw, gitignored material.
  The distilled Markdown files are what the project actually relies on.
- **`_output/` is for generated artifacts**, kept separate from source.
- **One AGENTS.md, one CLAUDE.md.** If you run more than one agent harness,
  symlink `AGENTS.md → CLAUDE.md` so every tool reads the same instructions:
  `ln -s CLAUDE.md AGENTS.md`.
- **Don't commit secrets or raw inputs.** The shipped `.gitignore` already
  excludes `.env`, `_input/`, dependencies, and caches.

## Anti-Patterns

- writing feature code during init — this step is structure only
- filling placeholders with invented content instead of leaving `_TBD_`
- dropping the `_memory/` folder because it looks empty
- committing `_input/` raw material or secrets

## Related Skills

- `blueprint` — turn the now-structured idea into a buildable plan
- `plan-interview` — pressure-test that plan one question at a time
- `elephant` — the memory pattern `_memory/` is built on; use it to grow the
  project's memory over time
