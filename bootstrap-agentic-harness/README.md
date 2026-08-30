# bootstrap-agentic-harness

Cursor Agent Skill: turn a PRD / tech doc / one-paragraph vision into a fully wired **agent-first repository**.

This folder is what you install under `~/.cursor/skills/bootstrap-agentic-harness`.

| File | Role |
|------|------|
| [`SKILL.md`](./SKILL.md) | Procedure the agent follows (intake → scaffold → populate → wire → verify) |
| [`reference.md`](./reference.md) | Anatomy, module selection, why this is not a naive harness copy |
| [`scripts/bootstrap.sh`](./scripts/bootstrap.sh) | Scaffolder that copies `harness/` into a target repo |
| [`harness/`](./harness/) | Payload templates (`{{TOKENS}}` + `<!-- FILL -->` markers) |

**How to install, the folder tree a target repo gets, and how the harness self-learns and self-heals:** see the [repository README](../README.md).
