---
name: brandkit
description: Define a brand once as two plain text files (DESIGN.md for visuals, VOICE.md for language) and enforce them as the binding source on every render job such as landing pages, slide decks, and documents.
---

# Brandkit

Treat a brand as data, not as vibes. Two markdown files hold everything an AI needs to produce on-brand output:

- DESIGN.md: the visual contract. Colors as exact hex values, fonts, type scale, spacing, radius, logo rules, anti-patterns.
- VOICE.md: the language contract. Tone, lexicon, sentence patterns, banned phrases. Build it with the voiceprint skill.

Both files live with the brand's assets, for example in a `brand/` folder inside the project. Every render job reads them first and follows them exactly. No render without reading; no value invented that the files do not contain.

This skill has two modes. Pick the mode from the request:

- "define": the user wants to set up or update a brand, or no DESIGN.md exists yet.
- "render": the user wants visual output (page, deck, document) for a brand that already has the files.

## Mode: Define

### 1. Collect material

Ask the user for everything that already encodes the brand:

- Website URL (the strongest source: computed CSS carries real colors and fonts)
- Logo files (SVG preferred; extract exact fill colors from the markup)
- An existing brand or style guide, if any
- Screenshots of products, decks, or print material
- Any CSS, design tokens, or theme files from existing projects

### 2. Extract real values

Pull concrete values out of the material instead of estimating:

- Hex colors from CSS, SVG fills, or sampled screenshots
- Font families from stylesheets or font files
- Border radius, shadow style, and spacing rhythm from existing components

Record where each value came from. A color with a source ("from main stylesheet, button background") is trustworthy; a color without one is a guess.

### 3. Ask instead of inventing

Anything the material does not answer goes to the user as a direct question. Typical gaps:

- "I found two blues, #1A4FD8 on buttons and #2563EB in the logo. Which one is primary?"
- "No semantic colors (success, warning, error) exist anywhere. Want me to derive them from the palette, or do you have defined ones?"
- "Headings use a serif on the website but a sans-serif in the deck you sent. Which is current?"

Never fill a gap with a plausible default and move on. A wrong value in DESIGN.md poisons every future render.

### 4. Write DESIGN.md

Fill this template. Mark unresolved fields as "open: <question>" rather than leaving them silently empty.

```markdown
# DESIGN.md - <Brand Name>

> Visual single source of truth. Read in full before rendering anything for this brand.
> Last updated: <YYYY-MM-DD>

## Identity
- Name:
- Tagline / positioning:
- Industry / domain:
- Visual attitude in one sentence: e.g. "engineered calm: lots of air, one loud accent"

## Colors
### Primary
- --color-primary: #XXXXXX (usage: ...)
- --color-primary-contrast: #XXXXXX (text on primary)
### Accent
- --color-accent: #XXXXXX (usage: ...)
### Neutrals
- --color-bg: #XXXXXX
- --color-surface: #XXXXXX
- --color-text: #XXXXXX
- --color-text-muted: #XXXXXX
- --color-border: #XXXXXX
### Semantic
- --color-success: #XXXXXX
- --color-warning: #XXXXXX
- --color-error: #XXXXXX

## Typography
### Headings
- Family: (with source: hosted URL or local file)
- Weights:
### Body
- Family:
- Weights:
### Mono / UI
- Family:
### Scale
| Level | Size | Line height | Weight |
|---|---|---|---|
| Display | clamp(...) | | |
| H1 | clamp(...) | | |
| H2 | clamp(...) | | |
| Body | | | |
| Small | | | |

## Spacing and Layout
- Base unit: e.g. 8px
- Spacing scale: e.g. 8 / 16 / 24 / 32 / 48 / 64
- Container max width:
- Grid:

## Logo
- Primary file:
- Variants (dark / light / icon):
- Minimum size, clear space, allowed backgrounds:

## Visual Patterns
- Border radius:
- Shadows / depth:
- Icon set: one set only, e.g. a single outline library
- Motion: e.g. "fade and 150ms ease-out, nothing bouncy"
- Imagery style:

## Never Do
- Brand-specific anti-patterns, e.g. "no gradients", "never set text on the accent color"

## References
- Website:
- Source files:
```

## Mode: Render

### Before rendering

1. Read DESIGN.md and VOICE.md of the brand, in full, every time. Do not render from memory of a previous session.
2. If either file is missing, switch to define mode or ask the user. Never substitute a generic theme.
3. Map every DESIGN.md token to a CSS custom property at the top of the output.

### While rendering

- Colors: only hex values that appear in DESIGN.md. No "close enough" shades, no opacity tricks to fake new palette entries unless DESIGN.md allows them.
- Fonts: exactly the defined families with sensible fallback stacks. Load hosted fonts in the head; never swap in a lookalike.
- Radius, spacing, shadows: from the defined scale only. If the scale says 8/16/24, a 20px gap is a bug.
- All copy passes VOICE.md: tone, lexicon, banned phrases.
- Output is a single self-contained HTML file: inline CSS, inline or linked fonts, no build step, opens by double-click.

### After rendering: self-check

Verify the output against DESIGN.md mechanically, not by eyeballing:

```bash
# every hex color used in the output
grep -oiE '#[0-9a-f]{3,8}' output.html | tr 'A-F' 'a-f' | sort -u

# every font-family declaration
grep -oiE 'font-family:[^;]+' output.html | sort -u
```

Compare both lists against DESIGN.md. For every value not defined there, either fix the output or, if it is a legitimate derived value (for example a rgba shadow), state why it is acceptable. Report the check result to the user in one short block:

```
Self-check: 7 hex values in output, 7 match DESIGN.md. Fonts: 2 declared, 2 match.
No violations.
```

## Anti-Generic Rule

Default framework styling is a failure state, even when it looks clean. Apply this test to every render: if you swapped the logo for a competitor's, would anyone notice the page is the wrong brand? If not, the render is generic and must be reworked.

Concretely:

- No default component-library look with the brand color sprayed on top
- No interchangeable hero-section template that every AI produces
- Typography, spacing rhythm, and at least one signature element must come from the brand, not from the framework
- Two different brands rendered by this skill must be distinguishable at a glance with logos removed

## Updating the Kit

When the user corrects a render ("our blue is darker", "we never round corners that much"), fix the output and write the correction into DESIGN.md in the same step, then bump its date. The files are the memory; corrections that only land in the output are lost by the next session.
