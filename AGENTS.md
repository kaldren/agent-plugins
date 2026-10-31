# agent-plugins

Kaloyan's skills and agents, packaged as plugins for Claude Code and Codex. Layout follows [dotnet/skills](https://github.com/dotnet/skills).

## Layout

- `plugins/<plugin>/skills/<skill>/SKILL.md`: skills in the open Agent Skills format. Shared by Claude and Codex unchanged.
- `plugins/<plugin>/agents/<agent>.md`: agents in Claude Code format. This is the only copy; `install-codex-agents.sh` converts them for Codex.
- `.claude-plugin/marketplace.json`: Claude marketplace. `.agents/plugins/marketplace.json`: Codex marketplace. Both are named `kaldren` and point at the same `./plugins/*` folders.
- Each plugin has `plugin.json`, `.claude-plugin/plugin.json` and, if it works in Codex, `.codex-plugin/plugin.json`. Keep them in sync; Claude finds `agents/` on its own, so no manifest lists agents.

## Adding things

- **Skill:** create `plugins/<plugin>/skills/<name>/SKILL.md` with `name` and `description` frontmatter. `name` must match the folder. No manifest changes needed. To make it manual-only (slash command, never auto-triggered), add `disable-model-invocation: true` (Claude) and an `agents/openai.yaml` with `policy.allow_implicit_invocation: false` (Codex), as `ai-sdlc` does.
- **Agent:** create `plugins/<plugin>/agents/<name>.md` with `name`, `description` and optionally `tools`, `model` and `codex-model` frontmatter. Use simple one-line `key: value` frontmatter; the converter doesn't read multi-line YAML. Run `./install-codex-agents.sh` to check it converts.
- **Plugin:** create `plugins/<name>/` with the three `plugin.json` files and add an entry to both marketplace files. Leave it out of the Codex marketplace if it only makes sense in Claude (like `learn`, which publishes claude.ai pages).
- Don't add a `version` field to manifests: without one, every commit counts as an update.

## Checks before committing

```
claude plugin validate .
for p in plugins/*/; do claude plugin validate "$p"; done
./install-codex-agents.sh
```
