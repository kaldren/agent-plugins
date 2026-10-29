# Governance, source of truth, metrics, docs

## Legacy systems and the source of truth

Existing processes already track these artifacts — just not in markdown: work items in Jira, requirements in a tool with regulatory traceability, designs in Figma, approvals with a change board. Auditors accept those systems and other teams depend on them, so the AI-native SDLC fits around them.

**For every artifact the process produces, name one system as the source of truth**; everything else holds a copy or a link. The choice can differ per artifact:

| Configuration | How it works | Good for |
|---|---|---|
| **Repo as source of truth** | Markdown artifacts are authoritative; the legacy system references files in commits | Engineering-led teams, solo devs — one tool, one timestamp authority |
| **Legacy system as source of truth** | Jira/ServiceNow/requirements tool is authoritative; markdown is a working copy. Claude reads the record at session start and writes the outcome back via an MCP connector in the same session | Regulated orgs with established tooling |
| **Linkage (minimum bar)** | Every artifact notes the record ID; every legacy record contains the commit SHA of the markdown file. Two sources of truth, accepted | The place to start when transitioning |

Record the choice per artifact in the progress file. For linkage, add `Tracker: <ID>` to the intent/spec/plan templates and have Claude post the commit SHA back to the record.

## The audit trail
Each stage commits one artifact; the chain of commits records who asked for what, what the agent produced, and who approved it:

| Stage | Artifact | Approved by | Recorded as |
|---|---|---|---|
| Plan | `intent.md` | Product owner | Merge / closed PR |
| Design | `spec.md` (+ skill versions) | Product owner (+ policy owners for concerns) | Merge |
| Build | `plan.md` | Engineer; tech lead for higher risk | Commit / merge |
| Build/Test | diff + tests + pasted check output | — | Commits, CI check runs |
| Deploy | PR with review findings | Code owner via branch protection | PR history |
| Deploy | Release | Release manager via hook | Hook log / pipeline log |
| Maintain | incident record → new `intent.md`, `lessons/*.md` | Service owner | Triage log, channel thread |

## Metrics cheat sheet

| Play | Leading indicator | Lagging indicator | Data source |
|---|---|---|---|
| P1 intent | First conversation → committed intent | Intent survival rate; intent edits after first spec commit | git log on `intent/` |
| P2 spec | intent commit → spec commit | spec commits after first plan commit | git log |
| P3 plan | Share merged from first pass; plan approval → merge | Rework cycles; diff still matches plan | PR metadata |
| P4 CLAUDE.md | Repeated mistakes | Time to first merged PR for new joiners | git, PR history |
| P5 skills | Policy approval → skill merged | Review findings citing the policy → 0 | PRs on skill folder, review findings |
| P7 parallel | Concurrent sessions per engineer; steering vs waiting | Merges per engineer/week vs rework | OpenTelemetry, PR history |
| P8 feedback loop | First-pass CI success | Review time per PR; change failure rate | CI, PRs, incident tracker |
| P9 evals | Pass rate over time; incident → eval time | Regressions caught in CI vs in prod | Eval runs, incident tracker |
| P10 review | Time to first review; comments resolved without human touching branch | Defects caught pre-merge vs escaped | PR history, incidents |
| P11 gates | Wait time per gate | Gate violations reaching prod | OpenTelemetry hook decisions |
| P12 CI/CD | Failures triaged without paging | DORA metrics | CI/CD logs |
| P13 loop | Breach → intent in queue | Findings → merged fixes; repeat incidents | Detection log, PRs |

Useful git one-liners to teach the user:
- Time between intent and spec for a change: `git log --diff-filter=A --format='%ad %s' --date=iso -- intent/<change>/intent.md intent/<change>/spec.md`
- Spec rework after planning: `git log --format='%ad' --date=iso -- intent/<change>/spec.md` compared with the first plan.md commit date.

## Official docs (rollout order for a platform team)
- Admin setup / decision map — code.claude.com/docs/en/admin-setup
- Settings reference & precedence (incl. managed-only keys) — code.claude.com/docs/en/settings
- Server-managed settings — code.claude.com/docs/en/server-managed-settings
- Permissions — code.claude.com/docs/en/permissions
- Sandboxing — code.claude.com/docs/en/sandboxing
- Hooks guide / reference — code.claude.com/docs/en/hooks-guide · code.claude.com/docs/en/hooks
- Skills — code.claude.com/docs/en/skills
- Plugins & private marketplaces — code.claude.com/docs/en/plugin-marketplaces
- Managed MCP — code.claude.com/docs/en/managed-mcp
- Bedrock / Vertex / Foundry — code.claude.com/docs/en/third-party-integrations
- Network config — code.claude.com/docs/en/network-config
- Monitoring (OpenTelemetry) — code.claude.com/docs/en/monitoring-usage
- Analytics dashboard — code.claude.com/docs/en/analytics
- Compliance API — platform.claude.com/docs/en/manage-claude/compliance-api
- Security model — code.claude.com/docs/en/security
