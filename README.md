# agent-skills

Public collection of [Cursor Agent Skills](https://docs.cursor.com). Each folder is one skill — clone the repo, symlink the folders you want into `~/.cursor/skills/`.

## Skills

| Skill | What it does |
|-------|----------------|
| [`bootstrap-agentic-harness`](./bootstrap-agentic-harness/) | From a PRD or a paragraph, scaffold an agent-first repo: `AGENTS.md`, specs, sensors, hooks, CI. The agent then keeps that harness true — sensors fail, it fixes code and docs, and it encodes repeatable issues so they do not come back. |

## Install

```bash
git clone git@github.com:vinayteki95/agent-skills.git ~/Projects/agent-skills
mkdir -p ~/.cursor/skills

ln -sfn ~/Projects/agent-skills/bootstrap-agentic-harness \
        ~/.cursor/skills/bootstrap-agentic-harness
```

Restart Cursor or open a new agent chat, then attach the skill (`/bootstrap-agentic-harness`) or mention it by name.

## Add a skill

```
agent-skills/
├── README.md
├── bootstrap-agentic-harness/
│   └── SKILL.md
└── your-new-skill/
    └── SKILL.md
```

One folder per skill, `SKILL.md` at that folder’s root, so it can be symlinked into `~/.cursor/skills/`.

MIT — see [LICENSE](./LICENSE).
