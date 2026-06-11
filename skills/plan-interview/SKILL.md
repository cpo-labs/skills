---
name: plan-interview
description: Interview the user one question at a time until a plan or design is genuinely solid. Use when the user wants to pressure-test an idea, asks to be interviewed about a plan, or a design has too many unknowns to start building.
---

# Plan Interview

Run a structured interview that turns a half-formed plan into a set of explicit,
agreed decisions. Your job is not to collect answers, it is to resolve every
decision that the plan depends on, in dependency order, until nothing
load-bearing is left open.

## Step 1: Research before you ask

Before asking the user anything, spend a short amount of time answering
questions yourself:

- Read the relevant parts of the codebase, configs, and docs in the project.
- Check package manifests, existing patterns, and prior decisions in the repo.
- Note what you found, you will reference it in your questions.

Never ask the user something the project can answer. Asking "which database do
you use?" when there is a `docker-compose.yml` with Postgres in the repo wastes
a turn and signals you did not look. Reserve the user's attention for questions
only they can answer: intent, priorities, constraints, taste, and tolerance for
risk.

## Step 2: Map the decision tree

Identify the structure of the decisions in the plan:

- The root is the decision everything else depends on. Examples: "is this a
  library or a service?", "do we build or buy?", "is this for one user or many?"
- Branches are decisions that only matter once the root is settled. Choosing a
  queueing strategy is pointless before knowing whether the system is
  synchronous at all.
- Leaves are details that can be safely deferred to implementation time.

Work the tree root first, then branch by branch, dependencies before
dependents. Do not jump around. If the user tries to discuss a leaf while the
root is unresolved, briefly park it: "Noted, we will get to caching, but first
we need to settle whether this runs client-side or server-side."

## Step 3: Ask one question at a time

Rules for every question:

1. One question per message. Never bundle two questions, even related ones.
2. Always attach your own recommendation. You have context from your research,
   use it. A question without a recommendation pushes all the work back onto
   the user.
3. Offer 2 to 3 alternatives, each with its trade-off in one line. The user
   should be able to answer with "go with your recommendation" or "option B"
   and nothing more.

Question format:

```
Question: How should authentication work for the admin panel?

My recommendation: Reuse the existing session middleware from the public app
(it is already tested and the admin panel runs on the same domain).

Alternatives:
- B: Separate JWT-based auth. Cleaner isolation, but you maintain two auth
  systems and two token lifecycles.
- C: Basic auth behind the VPN. Five minutes to set up, but no audit trail
  and no per-user permissions.
```

## Step 4: Push back on vague and contradictory answers

Vague answers are not answers. When you get one, convert it into something
measurable before moving on:

- "It should be fast" becomes "What does fast mean in numbers: under 100ms,
  under 1s, or just not noticeably slow for a single user?"
- "It needs to scale" becomes "Scale to what: 10 users, 10k users, or 10k
  requests per second? These lead to very different designs."
- "Make it secure" becomes "Which threat are we defending against: curious
  coworkers, internet-wide scanners, or a motivated attacker with time?"

Contradictions get challenged immediately, not noted silently:

- "Earlier you said this must ship this week, but you just asked for a
  migration path covering three legacy formats. Those conflict. Which one
  wins, the deadline or the migration coverage?"

Do not let politeness produce a plan built on a contradiction. Surfacing the
conflict is the entire value of the interview.

## Step 5: Know when to stop

Stop when every branch of the decision tree is resolved: no load-bearing
decision remains open, and the remaining unknowns are implementation details
that do not change the shape of the plan.

Then write the closing summary as a numbered list of decisions. Each item is
one settled decision in one sentence, concrete enough that someone could start
planning or building from the list alone:

```
Shared understanding, decisions made:
1. The tool is a CLI, not a web app, single-user, no auth.
2. Input is CSV only for v1, JSON import is explicitly out of scope.
3. Performance target: process a 100k-row file in under 10 seconds.
4. Errors abort the run with a line number, no partial-write recovery in v1.
5. Distribution via a single static binary, no installer.
```

Offer to turn this list into a full plan or task breakdown as the next step.

## Example dialog

```
You: I looked at the repo first. You already have a worker queue (BullMQ) and
Redis configured, so background processing is available without new infra.

Question: When a user uploads a file, should processing block the request or
run in the background?

My recommendation: Background job with a status endpoint. Files can be large
and your current request timeout is 30s, which a big file would blow past.

Alternatives:
- B: Synchronous processing. Simplest possible flow, but large uploads will
  time out and retries get messy.
- C: Background job with websocket push. Best UX, but adds a websocket layer
  you do not have yet.

User: Background is fine. It just needs to feel fast.

You: "Feel fast" needs a number. Is it acceptable if the status flips to done
within 30 seconds for a typical file, or do users watch the screen and need
under 5 seconds?

User: 30 seconds is fine, they get an email anyway.

You: Noted, and that answers the next branch too: email on completion, no
polling UI needed for v1.

Question: What happens when processing fails halfway through a file?
...
```

## Anti-patterns

- Asking a list of five questions in one message. The user answers two,
  ignores three, and the tree gets holes.
- Asking questions whose answers sit in the repo. Research first.
- Accepting "whatever you think is best" for a root decision without stating
  what you think is best and why, then confirming it.
- Continuing the interview after everything is resolved. Padding questions
  erode trust. Stop, summarize, hand over the decision list.
