---
name: create
description: Create a new skill, agent or plugin in Kaloyan's agent-plugins repo (github.com/kaldren/agent-plugins, marketplace "kaldren") and put it in the right folder structure for both Claude Code and Codex. Use whenever the user wants to create, add, scaffold or write a skill or agent "for my plugins", "for my plugins repo", "for agent-plugins" or "for the kaldren marketplace", or wants to move an existing skill or agent into that repo, or start a new plugin there. Also use for "where should this skill/agent go?" questions about that repo.
---

# Create a skill, agent or plugin in agent-plugins

You add things to the user's `agent-plugins` repo so they install in Claude Code and Codex on every laptop. The repo's `AGENTS.md` holds the conventions. Read it first; if it disagrees with this file, `AGENTS.md` wins.

## 1. Find the repo and sync it

- Use `$AGENT_PLUGINS_DIR` if set, else `~/Projects/agent-plugins`.
- Not there? Ask before cloning: `git clone https://github.com/kaldren/agent-plugins ~/Projects/agent-plugins`.
- `git pull` before changing anything. If the working tree has uncommitted changes you didn't make, stop and ask.

## 2. Work out what to create

Ask only for what you can't infer from the request (one short round of questions, not an interview):

- **Kind.** A *skill* is instructions the main agent loads when a task matches (a procedure, conventions, a workflow, a reference). An *agent* is a separate worker with its own prompt and tools that the main agent delegates to (a reviewer, a researcher, a verifier). When unsure, suggest a skill.
- **Purpose and triggers.** What it does, and the phrases or situations that should make it fire.
- **Name.** Lowercase kebab-case, at most 64 characters, e.g. `write-intent`, `pr-reviewer`. Must not clash with an existing skill or agent in the repo.
- **Plugin.** List the current plugins from `.claude-plugin/marketplace.json` with their descriptions and suggest the best fit. If none fits, propose a new plugin (step 4). Keep in mind that the plugin name becomes the prefix in both tools, as in `sdlc:sdlc-loop`.
- **Tools.** Both Claude and Codex unless it depends on something only one has (e.g. claude.ai artifacts, Claude-only MCP tools). A Claude-only skill goes in a plugin that's left out of the Codex marketplace; don't put it in a plugin Codex installs.

State your choices in one or two lines (kind, name, plugin, tools) and carry on unless the user objects.

## 3. Write the files

### Skill → `plugins/<plugin>/skills/<name>/SKILL.md`

```markdown
---
name: <name>
description: <What it does, then when to use it: trigger phrases and situations. Third person. Specific enough to fire when needed and stay quiet otherwise. Max 1024 characters.>
---

# <Title>

<Instructions as steps or rules. Imperative voice. Say why where it isn't obvious.>
```

- `name` must equal the folder name.
- The description is the only part loaded until the skill fires, so it decides whether the skill triggers at all. Put the trigger words there, not in the body.
- Keep `SKILL.md` under ~500 lines. Move long reference material to `references/<topic>.md`, reusable files to `templates/` or `assets/`, and deterministic steps to `scripts/`. Link each one from `SKILL.md` and say when to read or run it.
- If it runs in both tools, write tool-neutral instructions: "ask the user", "read the file", "run the command", not Claude- or Codex-specific tool names. Refer to another skill by name and purpose, not by a slash command, since the invocation differs (`/sdlc:ai-sdlc` in Claude, `$sdlc:ai-sdlc` in Codex).
- No manifest changes are needed: `skills/` is picked up automatically.

### Agent → `plugins/<plugin>/agents/<name>.md`

```markdown
---
name: <name>
description: <What it does and when to delegate to it. One line.>
tools: Read, Grep, Glob, Bash
---

<System prompt: role, what it must and must not do, steps, the exact output format it returns.>
```

- Frontmatter must be **single-line `key: value` pairs**. `scripts/agent_md_to_toml.py` doesn't read multi-line YAML.
- Optional keys: `model` (a Claude model, Claude only) and `codex-model` (becomes `model` in the Codex TOML).
- `tools` limits what the agent can do in Claude. A read-only agent gets `Read, Grep, Glob` (plus `Bash` if it must run commands). Leave `tools` out to inherit everything. Codex ignores it, so say any restrictions in the prompt as well (e.g. "never edit files").
- The prompt should say what the agent returns, because its final message is all the caller sees.
- Agents never go in the Codex plugin manifest. Codex gets them through `install-codex-agents.sh`.

## 4. New plugin (only if no existing plugin fits)

1. Create `plugins/<plugin>/` with `skills/` and/or `agents/`.
2. Write three identical manifests: `plugin.json`, `.claude-plugin/plugin.json` and, if it's for Codex too, `.codex-plugin/plugin.json`:
   ```json
   {
     "name": "<plugin>",
     "description": "<One sentence naming what's inside.>",
     "author": { "name": "Kaloyan" },
     "skills": ["./skills/"]
   }
   ```
   No `version` field, so every commit counts as an update. No `agents` field, so Claude finds `agents/` on its own.
3. Add `{ "name", "source": "./plugins/<plugin>", "description" }` to `.claude-plugin/marketplace.json` and, if it's for Codex, to `.agents/plugins/marketplace.json`.

## 5. Update the README

Keep the plugin table in `README.md` in step: the plugin row lists its skills and agents and whether it's in Claude and/or Codex. For a new plugin, add its `install` line to the "Set up a new laptop" section.

## 6. Check

Run from the repo root and fix anything that fails:

```
claude plugin validate .                       # if the claude CLI is installed
for p in plugins/*/; do claude plugin validate "$p"; done
python3 -m json.tool <each manifest you touched> > /dev/null
./install-codex-agents.sh                      # if you added or changed an agent
```

Ignore the "no version", "README missing", "LICENSE missing" and "icon" warnings; they only matter for the public plugin directory. Without the `claude` CLI (e.g. a Codex-only laptop), check JSON validity and frontmatter by hand.

## 7. Commit, push, update

1. Show the user the new files (and the diff for anything changed), then **ask before committing and pushing**.
2. Commit with a message like `Add <name> skill to <plugin>` and push to `main`.
3. Refresh the installed copies on this laptop, since both tools run cached copies, not the repo folder:
   - Claude: `claude plugin marketplace update kaldren`. For a new plugin, also `claude plugin install <plugin>@kaldren`. Restart Claude to load it.
   - Codex: `codex plugin marketplace upgrade`. For a new plugin, also `codex plugin add <plugin>@kaldren`. Agents: `./install-codex-agents.sh`.
4. Tell the user what was added, its full name in each tool (e.g. `sdlc:write-intent`), and that other laptops pick it up with the same update commands.
