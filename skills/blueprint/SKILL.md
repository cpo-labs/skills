---
name: blueprint
description: Turn a vague idea into a structured, testable build plan before any code is written. Use when the user describes a new feature or project in a sentence or a paragraph and wants a plan, not an immediate implementation.
---

# Blueprint

Convert a one-sentence or one-paragraph idea into a blueprint document that is
strong enough to build from. The blueprint exists to expose fuzzy thinking
before it becomes fuzzy code: untestable goals, hidden assumptions, phases
with no visible output, and risks nobody named.

Do not write implementation code while producing a blueprint. The output is
the document.

## Input

Anything from one sentence ("a CLI that dedupes my photo library") to a
paragraph of loose requirements. If the input is missing something critical
(who uses it, what problem it solves), ask one or two targeted questions
first, then write the blueprint. Do not interrogate, the blueprint itself
surfaces open points in its "Open decisions" section.

## Output: required sections

Produce a Markdown document with exactly these sections, in this order.

### 1. Goal

One sentence, and it must be testable. A reader should be able to look at the
finished work and answer yes or no.

- Bad: "Improve the photo workflow."
- Good: "A CLI that scans a folder tree, finds byte-identical and
  perceptually-similar duplicate photos, and moves them to a review folder
  without deleting anything."

### 2. Non-goals

Explicit list of things this project will not do, especially the things a
reader would otherwise assume are included. Non-goals prevent silent scope
growth. If you cannot name at least two non-goals, you have not understood
the scope yet.

### 3. Assumptions

Every assumption the plan rests on, each one tagged:

- `[verified]` with a one-line note on how it was verified (checked the code,
  ran the command, read the docs).
- `[unverified]` with a one-line note on how it could be verified.

An unverified assumption that the whole plan depends on is a risk, list it in
the Risks section too.

### 4. Phases

Break the work into phases. Hard rules:

- Every phase ends with something visible: a user can see it, run it, or
  click it. "Phase 1: project setup" is banned. Fold setup into the phase
  that first needs it.
- After every phase the project is deployable or demoable. Never leave the
  system broken between phases.
- Phase 1 tests the riskiest assumption. If the core idea fails, it must fail
  in phase 1, when abandoning it is cheap.
- Each phase is at most one to two days of work. If a phase is bigger,
  split it again.
- YAGNI: nothing goes into a phase because it "will probably be needed
  later". It goes in when a phase actually needs it.

Format per phase: a name, the visible result in one sentence, and 3 to 6
bullet points of work.

### 5. Risks

Each risk paired with a concrete countermeasure, not a wish. "Be careful with
performance" is not a countermeasure. "Benchmark with a 50k-file library in
phase 1, abort the approach if a scan takes over 5 minutes" is.

### 6. Open decisions

Decisions that do not block phase 1 but must be made eventually. For each:
the decision, your recommendation, and one line of reasoning. Never list an
open decision without a recommendation.

### 7. Success criteria

A checklist that can be verified mechanically at the end: run a command,
observe an output, measure a number. No criteria like "code is clean" or
"users are happy". If you cannot script or directly observe it, rewrite it
until you can.

## Example blueprint

A condensed example for a fictional mini project.

```markdown
# Blueprint: link-checker

## Goal
A CLI that crawls one website, follows internal links up to a configurable
depth, and prints every broken link (HTTP status >= 400) with the page it
was found on, exiting nonzero if any are found.

## Non-goals
- No JavaScript rendering, static HTML only.
- No fixing or rewriting links, report only.
- No scheduled or watch mode in v1, single run per invocation.

## Assumptions
- [verified] Target sites are static HTML, confirmed by inspecting the three
  sites this will run against.
- [unverified] Crawling at 10 requests/second will not trigger rate limiting.
  Verify in phase 1 against the smallest target site.

## Phases

### Phase 1: Single-page check (visible: working CLI on one URL)
- Fetch one URL, parse all <a href> values, request each, print failures.
- Exit code 1 when any link is broken, 0 otherwise.
- Run against the real smallest target site, observe rate-limit behavior.

### Phase 2: Recursive crawl (visible: full-site report)
- Follow internal links to a --depth limit, deduplicate visited URLs.
- Print a summary: pages crawled, links checked, broken links with source page.

### Phase 3: Practical hardening (visible: usable in CI)
- --timeout and --concurrency flags with sane defaults.
- Machine-readable --json output for CI pipelines.

## Risks
- Rate limiting by target servers. Countermeasure: default concurrency of 2,
  honor 429 responses with backoff, tested in phase 1.
- Redirect loops. Countermeasure: cap redirects at 5 per URL, count the URL
  as broken beyond that.

## Open decisions
- Should external links be checked too? Recommendation: yes, but only the
  link itself, never crawled, the cost is low and the value is high.

## Success criteria
- [ ] `link-checker https://example.org --depth 2` completes in under 60s on
      the smallest target site.
- [ ] A page with a known broken link is reported with the correct source URL.
- [ ] Exit code is 1 with broken links present, 0 on a clean site.
- [ ] `--json` output parses with `jq` without errors.
```

## Process

1. Read the idea. Research the project context briefly (existing code, stack,
   constraints) so assumptions can be tagged honestly.
2. Draft the blueprint with all seven sections.
3. Self-check before presenting: Is the goal testable in one sentence? Does
   phase 1 attack the riskiest assumption? Does every phase end visibly? Is
   every phase under two days? Does every risk have a real countermeasure?
   Can every success criterion be checked mechanically?
4. Present the blueprint and ask the user to confirm or adjust the open
   decisions. Only after confirmation does implementation start.

## Anti-patterns

- A "Phase 0: scaffolding" with nothing to show. Setup belongs inside the
  first phase that produces something visible.
- Assumptions stated as facts. Tag them, verify them, or move them to risks.
- Success criteria that restate the goal in vaguer words.
- Blueprints longer than the project deserves. A two-day tool gets one page,
  not five. Match ceremony to stakes.
