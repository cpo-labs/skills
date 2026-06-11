---
name: voiceprint
description: Distill a reusable voice profile (VOICE.md) from 3 to 20 real writing samples, for use whenever AI-generated text should sound like a specific person instead of a generic model.
---

# Voiceprint

Build a durable, file-based voice profile from real writing samples. The profile is a single VOICE.md that any AI reads before writing, so the output matches how the author actually writes: their rhythm, their vocabulary, their habits, and the things they would never say.

A written profile beats prompt-time imitation because it is explicit, reviewable, version-controlled, and reusable across sessions and tools. Derive it once, refine it over time, read it everywhere.

## When to Use

- The user wants emails, posts, articles, or docs that sound like them
- A team wants consistent writing across many AI sessions
- Existing AI output keeps sounding generic or "off"
- An existing VOICE.md needs a refresh with newer samples

## Step 1: Collect Samples

Ask the user for texts they wrote themselves. Enforce these rules:

- Minimum 3 samples. With fewer, refuse and explain that the profile would be guesswork.
- Ideal is 10 or more. More samples mean more reliable patterns.
- Mixed formats beat a single format: emails, chat messages, posts, README intros, proposals.
- Prefer recent writing. If the user says older texts are more representative, follow that.
- Reject anything the user did not author: forwarded text, quotes, heavily edited AI drafts.

If the samples split into clearly different registers, for example public posts versus internal emails, ask whether to build one combined profile or one profile per register. Never silently merge incompatible voices.

## Step 2: Analyze

Read every sample in full, then extract findings along these dimensions. Quote short fragments from the samples as evidence. Never invent an observation you cannot point to in the material.

| Dimension | What to look for |
|---|---|
| Sentence length and rhythm | Average length, variance, fragments, one-word sentences |
| Paragraph shape | Short and punchy versus long and flowing, list usage |
| Lexicon, used | Recurring words, favorite verbs, idioms, technical terms |
| Lexicon, avoided | Words that fit the context but never appear |
| Tone | Direct, warm, dry, ironic, blunt; how strongly claims are made |
| Address | First or second person, formal or casual address, reader involvement |
| Recurring patterns | Typical openings, closings, transitions, formatting habits |
| Punctuation habits | Colons, parentheses, exclamation marks, ellipses |
| Personal no-gos | Styles and stock phrases that appear in zero samples |

Write findings as concrete, checkable statements. Example of the right level of precision:

```
Sentence length: short, average 9 to 12 words. Longest observed: 24 words.
Uses one-sentence paragraphs for emphasis ("That was the whole bug.").
Never opens an email with pleasantries; states the subject in the first line.
Says "ship" and "cut", never "deliver" or "remove".
```

## Step 3: Write VOICE.md

Create the profile from the template below. Fill every section with evidence from the samples. Where the samples give no signal, write "no signal in samples" instead of guessing. Use verbatim quotes in the example sections.

```markdown
# VOICE.md - <Author or Brand>

> Read this file in full before writing anything in this voice.
> Built from <N> samples on <YYYY-MM-DD>. Last verified: <YYYY-MM-DD>.

## Voice DNA
One sentence that captures the voice. Example: "Short declarative sentences,
concrete numbers, dry humor, zero corporate padding."

## Tone
- Register: formal | semi-formal | casual
- Person: first singular | first plural | second person
- Address: how the writer addresses the reader
- Mood: e.g. confident, skeptical, warm
- Claim strength: hedged | measured | blunt

## Rhythm and Length
- Sentence length:
- Paragraph length:
- Signature rhythm: e.g. "long setup sentence, then a three-word verdict"

## Lexicon
### Uses
- word or phrase (context where it shows up)
### Avoids
- word or phrase (what is used instead)

## Recurring Patterns
- Openings:
- Closings:
- Transitions:
- Formatting habits: lists, bold, headers, links

## Sentence Examples
### Sounds right (verbatim from samples)
- "..."
- "..."
### Sounds wrong (plausible for an AI, foreign to this author)
- "..."
- "..."

## Never Write (personal no-gos, from sample evidence)
- ...

## Banned AI Phrases (always, regardless of author)
See the Anti-Slop List in the voiceprint skill. Copy it here verbatim.

## Sources
- <N> samples, formats: <list>, date range: <range>
```

## Step 4: Self-Test

Do not hand over an untested profile.

1. Pick a format that exists in the samples, for example a short email or post.
2. Write a probe text of 80 to 150 words using only the rules in VOICE.md.
3. Place the probe next to 2 or 3 original samples and compare dimension by dimension: rhythm, lexicon, tone, openings, closings.
4. List every deviation. Example: "Probe used a question as a hook; zero of 12 samples open with a question."
5. Fix the profile, not just the probe. Every deviation means the profile was missing or too vague on that point.
6. If the deviations were major, run one more probe round after updating the profile.

Show the user the probe and the originals side by side and ask for a verdict. Their corrections are the most valuable input; write each correction back into the profile.

## Anti-Slop List

Every VOICE.md must contain this list under "Banned AI Phrases". These are generic AI tells and they are banned no matter whose voice is being modeled:

- "delve", "dive in", "let's dive in", "deep dive" as filler
- "in today's fast-paced world" and any "in the world of X" opener
- "game-changer", "seamless", "robust", "cutting-edge", "elevate", "unlock", "empower"
- "leverage" as a verb when "use" works
- "I hope this email finds you well"
- "Great question!", "Absolutely!", "Certainly!" as openers
- "It's important to note that", "It's worth mentioning that"
- "not just X, but Y" as a rhetorical crutch
- "Whether you're a beginner or an expert" constructions
- adjective triples like "fast, reliable, and secure"
- "In conclusion", "To sum up" as final-paragraph glue
- exclamation marks doing the work that content should do
- bullet lists where the author would write prose, and vice versa

When reviewing a draft, search for these literally. One hit means rewrite the sentence.

## Using the Profile

- Read VOICE.md in full before every writing task in that voice. Do not write from memory of it.
- After drafting, check the draft against "Never Write" and "Banned AI Phrases" before showing it.
- When the user edits your output, treat the edited version as a new sample. Update the profile and bump the "Last verified" date.
- Keep one VOICE.md per voice. A person and their company brand are usually two different profiles.

## Maintenance

Refresh the profile when any of these happen:

- The user supplies 3 or more new samples
- Two drafts in a row needed the same kind of correction
- The profile is older than roughly six months of active use

Update in place. Never fork a second profile for the same voice; that recreates the drift the profile exists to prevent.
