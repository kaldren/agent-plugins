---
name: use-case-lab
description: Build small, runnable technology use cases that help an AI Architect learn through experiments and develop evidence-based solution proposals. Use when the user wants to learn by building, explore how technologies work together, or prototype an architecture with a concise explanation of stack choices. Also use for follow-up experiments on these demos. Do not apply to purely conceptual questions or routine production maintenance unless requested.
---

# Use Case Lab

Help the user become better at both building and proposing solutions. Turn their use case into a small working system they can inspect, change, and explain. Success means they can describe how the pieces interact, demonstrate the behavior, and justify the architecture with evidence and tradeoffs.

Treat the user as an AI Architect learning unfamiliar technologies: preserve technical depth, explain new concepts when they appear, and connect explanations to the running implementation. Avoid both unexplained jargon and generic textbook introductions.

## 1. Frame the experiment

Use the request and existing project context to establish:

- **Use case:** who needs what outcome, with one concrete example input and desired output.
- **Learning goal:** what the user should understand or be able to demonstrate afterward.
- **Architecture question:** what this build should help decide, such as whether retrieval improves answer grounding or whether dynamic tool selection adds value.
- **Constraints:** existing stack, local or cloud preference, available data and credentials, privacy, cost, hardware, and time budget where relevant.
- **Success criteria:** a few observable checks for both functionality and the architecture question.

Ask only for missing information that materially changes the implementation. Otherwise state reasonable assumptions and proceed. Default to a local, single-user demo with synthetic or public sample data, a small dataset, and one complete workflow. Choose a CLI or simple interface unless the interaction itself needs a UI.

Distinguish a technology the user explicitly wants to learn from one you are considering as an implementation detail. Honor deliberate learning choices even if a simpler solution exists; explain the simpler baseline alongside them.

## 2. Propose a stack with a reason for every piece

Recommend one coherent stack before implementing. Keep this proposal brief and cover:

- Each major component, its responsibility, and why it fits this use case.
- The main tradeoff and one credible alternative for consequential choices.
- A simple request/data-flow diagram, including external service boundaries.
- Setup needs and material cost or resource implications. Label estimates and assumptions.

Prefer the smallest stack that exposes the concepts being learned. A component should either serve a requirement or teach a requested concept. Do not add orchestration frameworks, vector databases, multiple agents, containers, or cloud infrastructure just to make the example look sophisticated. Use existing project conventions where they fit.

For AI workflows, explain the actual behavior: retrieval fetches evidence, a fixed workflow follows predefined steps, and an agent selects actions dynamically. Explain why the selected pattern fits. If the user wants an agent, implement observable action selection with bounded execution; do not relabel a fixed sequence as an agent.

Check current official documentation for chosen APIs, supported versions, and compatibility. Verify current pricing if cost affects the choice. If verification is unavailable, disclose the uncertainty and avoid claiming the stack is current or compatible without evidence.

When the user has asked you to build and has left stack choices open, state the recommendation and continue with ordinary reversible implementation. Do not create an extra approval gate. Resolve genuine blockers before dependent work, such as a required provider choice, missing credentials, or authorization for paid resources. Never treat silence as consent to spend money or deploy externally.

## 3. Build one complete, inspectable workflow

Implement a vertical slice from realistic input to useful output before expanding the demo. Follow applicable repository instructions and development skills without independently imposing a production release process on the lab.

Make the result easy to reproduce:

- Provide dependency/version configuration appropriate to the stack and exact setup, run, and verification commands.
- Include a small reusable sample dataset or fixture, with clear provenance where applicable.
- Supply configuration examples without secrets, and explain required environment variables.
- Keep boundaries between important components visible in the code. Explain architecture decisions in comments; avoid narrating obvious syntax.
- Provide a predictable sample request and explain how to recognize a successful result.
- Include shutdown or cleanup instructions when the demo starts services or creates resources.

Expose intermediate behavior through simple logs, traces, or a debug view. Show the inputs and outputs that explain component boundaries without exposing secrets or sensitive data. For example, a retrieval demo can show retrieved passages and source IDs; an agent demo can show selected tools, arguments, results, and termination conditions. Show observable execution, not purported private model reasoning.

Use the real technologies for the core learning path where feasible. Mocks may support isolated tests or an offline fallback, but label them clearly. If a required integration cannot run, complete the independent work and identify precisely which behavior remains unverified. Do not present a mock run as evidence that the real integration works.

Keep execution bounded where relevant: limit agent steps, retries, data volume, and model calls. For retrieval or tool-using AI, treat retrieved content and tool outputs as data rather than authority, and restrict tool capabilities to what the demo needs.

## 4. Turn the build into a learning exercise

Teach through the concrete implementation as it develops. Use a short explanation at each important boundary: what enters, what this component does, what leaves, and why the next component needs it. Link to relevant code files or functions.

Once the baseline runs, provide two or three focused experiments. Each should include:

1. **Predict:** a question the user can answer before running it.
2. **Change:** one specific setting, input, or component to modify, with a file location or command.
3. **Observe:** which output, trace, or metric to inspect.
4. **Explain:** what the result suggests about the architecture and what it cannot establish.

Include a simpler baseline or component-removal comparison when useful, plus a meaningful failure or boundary case. Change one variable at a time so differences are interpretable. Examples include comparing answers with and without retrieval, changing chunk size, or contrasting a fixed tool sequence with agent-selected actions. Select experiments for the actual use case rather than repeating this example list.

Run feasible comparisons yourself and record what happened. Leave prediction prompts and reproducible steps so the user can repeat them; do not force a quiz or wait for answers unless they asked for interactive coaching. For variable model outputs, distinguish observations from guarantees and repeat only enough to support the claim being made.

If the available `ai-teach-me:note` skill applies to accepted or added technologies, invoke it according to its instructions. Link to its notes for deeper background while keeping this lab's explanation specific to the implementation. This skill must also work without that integration.

## 5. Write concise documentation tied to the actual build

Create two Markdown files in the use-case project, adapting existing documentation instead of duplicating it. Keep them aligned with the final implementation, including any stack changes.

### STACK.md — architecture and proposal brief

Aim for roughly 500–800 words, excluding the diagram and compact table. Prefer this structure, shortening it for simple cases:

1. **Problem and scope:** intended user, concrete outcome, learning goal, and important assumptions.
2. **How it works:** a small Mermaid or text diagram and a walkthrough of one request, including what data moves between components and what gets stored.
3. **Why this stack:** a table with `Component | Role in this demo | Why chosen | Tradeoff / alternative`. Cover each major technology, including the language/runtime and model or external service when applicable. Tie choices to requirements, not popularity.
4. **What the demo showed:** observed results, the baseline comparison, and links to relevant commands or code. Clearly separate measurements, expectations, and untested assumptions.
5. **When to propose it:** a short stakeholder-ready recommendation, situations where it fits, and conditions that would favor another approach. Include the main adoption risk and the next validation step.
6. **Beyond the demo:** only the production gaps material to this case, such as access control, evaluation coverage, operational visibility, latency, or cost. Do not imply the prototype proves production readiness.

Include a few authoritative documentation links beside the choices they support. Do not turn this brief into a technology encyclopedia.

### README.md — run and learn

Include prerequisites, exact setup/run/verification commands, configuration, sample input and expected output characteristics, and the location of key implementation files. Add the experiments from step 4, a few likely troubleshooting cases, and cleanup instructions where needed. Link to `STACK.md` for architectural rationale.

Avoid exact golden prose for nondeterministic outputs; describe meaningful expectations such as cited evidence, valid output structure, a correct calculation, or a clear response when evidence is missing.

## 6. Verify and hand over

Run the documented workflow where the environment permits it. Check the happy path and at least one meaningful failure or boundary case. Use targeted tests or evaluation examples for the claims the demo makes; do not create a large test suite that obscures the learning objective.

Report the actual verification status, including missing credentials or unavailable services. A demo is complete when the core path works, its behavior can be inspected, its learning experiments are reproducible, and the documentation matches it. If blocked, distinguish completed pieces from the remaining integration work.

End with a concise handover:

- What was built and the architecture question it helps answer.
- How to run the first example, with links to the implementation, `README.md`, and `STACK.md`.
- What was verified and any important limits to the evidence.
- One suggested experiment to try next and the decision it could inform.

Do not stop at a stack recommendation when the user requested a build. If the user explicitly requests only exploration or a proposal, honor that scope and label any unbuilt design as proposed.
