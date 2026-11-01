# agent-plugins

My skills and agents for Claude Code and Codex.

| Plugin | Contents | Claude | Codex |
|---|---|---|---|
| `sdlc` | `ai-sdlc` skill (manual only: `/sdlc:ai-sdlc`, `$sdlc:ai-sdlc`), `code-reviewer` agent | yes | yes |
| `learn` | `page-teach-me` skill (publishes claude.ai pages), `use-case-lab` skill | yes | no |
| `agent-plugins` | `create` skill: adds skills, agents and plugins to this repo | yes | yes |
| `devenv` | `parallel-worktrees` skill: per-worktree `*.localhost` dev URLs (Caddy), one shared DB, auto-boot via Claude Code hooks | yes | yes (scripts only; run `scripts/boot.sh` yourself) |

Both tools prefix plugin skills with the plugin name: `sdlc:ai-sdlc`, `learn:page-teach-me`. Agents keep their plain names in Codex (`code-reviewer`) and get the prefix in Claude (`sdlc:code-reviewer`).

## Install

The repo is private, so git needs GitHub credentials first:

```
gh auth login
gh auth setup-git
```

**Claude Code**

```
/plugin marketplace add kaldren/agent-plugins
/plugin install sdlc@kaldren
/plugin install learn@kaldren
/plugin install agent-plugins@kaldren
/plugin install devenv@kaldren
```

**Codex**

```
codex plugin marketplace add kaldren/agent-plugins
codex plugin add sdlc@kaldren
codex plugin add agent-plugins@kaldren
codex plugin add devenv@kaldren
```

Codex plugins can't carry agents, so install those from a clone:

```
git clone https://github.com/kaldren/agent-plugins ~/Projects/agent-plugins
~/Projects/agent-plugins/install-codex-agents.sh
```

## Update

- Claude: `/plugin marketplace update kaldren`, then restart.
- Codex skills: `codex plugin marketplace upgrade`.
- Codex agents: `cd ~/Projects/agent-plugins && git pull && ./install-codex-agents.sh`.

## Add a skill, agent or plugin

Ask Claude or Codex to "create a skill/agent for my plugins repo": the `agent-plugins:create` skill handles the folder layout, manifests, checks and updates. Conventions are in [AGENTS.md](AGENTS.md).
