# agent-plugins

My skills and agents for Claude Code and Codex, kept in one place so every laptop gets the same set.

| Plugin | Contents | Claude | Codex |
|---|---|---|---|
| `sdlc` | `ai-sdlc` and `sdlc-loop` skills, `code-reviewer` agent | yes | yes |
| `learn` | `page-teach-me` skill (publishes claude.ai pages) | yes | no |

Both tools prefix plugin skills with the plugin name: `sdlc:sdlc-loop`, `learn:page-teach-me`. Agents keep their plain names in Codex (`code-reviewer`) and get the prefix in Claude (`sdlc:code-reviewer`).

## Set up a new laptop

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
```

**Codex**

```
codex plugin marketplace add kaldren/agent-plugins
codex                      # then /plugins → kaldren → install sdlc
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

See [AGENTS.md](AGENTS.md).
