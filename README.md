# claude-skills

Six working skills for [Claude Code](https://claude.com/claude-code), distilled
from daily use. Built at [AppSales Labs](https://labs.appsales-consulting.de).
No frameworks, no dependencies: each skill is one Markdown file that changes
how the agent works.

## The skills

| Skill | What it does |
|---|---|
| **plan-interview** | Interviews you one question at a time, with a recommendation per question, until your plan actually holds up |
| **blueprint** | Turns a one-sentence idea into a buildable plan: phases with visible results, risks, testable success criteria |
| **baton** | Saves the state of a working session as a handoff file and picks it up seamlessly in the next session |
| **voiceprint** | Distills a reusable voice profile from your real writing samples, so AI output sounds like you |
| **brandkit** | Defines your brand once as two text files (design + voice) and enforces them on every rendered output |
| **elephant** | Persistent project memory as plain Markdown files with an index: no database, readable by humans and agents |

## Install

```bash
git clone https://github.com/cpo-labs/claude-skills.git
cd claude-skills
./install.sh
```

This copies the skills into `~/.claude/skills/`. Start a new Claude Code
session and they are available. To install a single skill, copy its folder:

```bash
cp -R skills/baton ~/.claude/skills/baton
```

## How skills work

Claude Code reads `SKILL.md` files from `~/.claude/skills/` and triggers them
based on the `description` in the frontmatter. No configuration needed. Each
skill in this repo is self-contained and documented inside its own file.

## License

MIT. See [LICENSE](LICENSE).
