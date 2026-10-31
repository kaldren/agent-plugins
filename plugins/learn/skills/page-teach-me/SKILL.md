---
name: page-teach-me
description: Teach the user any subject, technical or not, through one published claude.ai page that covers everything they need to know and nothing they don't. Use when the user says "teach me X", "explain X", "I don't get X", "help me learn X", "what do I need to know about X", or wants to understand something well enough to use, discuss, recommend, or decide on it. Works for tools, science, history, finance, health, cooking, law, sports, anything.
---

# Page: teach me

This is the user's go-to place for learning anything. Build one page that takes them from confused to competent on the subject. Include everything they need, with no filler, hype, padding, or hedging. Publish it on claude.ai as an Artifact.

## 1. Frame the subject

Work out from the request and the conversation:
- **Subject**, and how wide to go. "Teach me options trading" means what a beginner needs to trade safely, not a textbook.
- **Starting level.** Assume a smart newcomer unless the conversation shows more.
- **Why they want it**, if stated or obvious: to use it, to talk about it, to decide, to recommend, or out of curiosity. This shapes the closing sections.
- **Deadline**, if any. It sizes the learning plan.
- **Personal context**, if it helps. If they're working on a related project or mentioned their situation, use it for examples. Otherwise keep it general. Never force a connection.

Ask a question only when the subject itself is ambiguous. Infer everything else and state your assumptions on the page.

## 2. Research, then decide what matters

Use the most reliable sources available, and verify before you write:
- **Authoritative sources first:** official docs, specs, standards bodies, peer-reviewed or institutional sources, original data. Use web search, and send several searches at once.
- **For technical subjects you can touch:** run `--help`, read type definitions or schemas, scaffold an example in the scratchpad, and run it. What actually happens beats what the docs say.
- **Numbers:** get real figures with a source and date for anything quantitative: prices, adoption, performance, risk, timelines, comparisons. Never invent or estimate numbers and present them as data.
- **Disagreement:** where experts or sources disagree, say so and give the main positions.

Then cut. Keep what a competent person in this area actually uses or needs to know (the 80/20). Drop trivia, history that doesn't explain anything, and rare edge cases. Before writing, ask: "would they miss this if it weren't there?"

## 3. Page structure

Adapt section names and order to the subject. Leave out whatever doesn't apply, and never pad a section to fill the template.

1. **The short version.** Three to five sentences on what it is and why it matters. A reader who stops here should still come away with the core.
2. **Mental model.** The handful of concepts that explain most of the subject, as a definition list. Then a diagram (inline SVG, or a mermaid block) when the subject has a structure, process, cycle, or hierarchy.
3. **How it works.** The mechanism, explained step by step with one concrete worked example: real code, a real calculation, a real case, a real recipe.
4. **The numbers.** Include this when the subject has meaningful data. Load the `dataviz` skill first, then draw bar charts, comparisons, stat tiles, or timelines from real, sourced figures. Put a source line under every chart. If there is no real data, skip the section instead of making something up.
5. **Comparisons.** How it compares to the alternatives, as a table. Include this when the user will have to choose.
6. **What people get wrong.** Common misconceptions and mistakes, each with the correct version.
7. **Doing it.** The practical part: commands, steps, rules of thumb, checklists, vocabulary to use. Make it something they can act on.
8. **Purpose-specific close.** Choose by purpose:
   - *Decide or recommend*: strengths next to honest risks and costs.
   - *Talk about it*: the five things to know, and the questions to ask.
   - *Use it*: pitfalls, and what to learn next.
   - *Curiosity*: the most surprising or useful thing to remember.
9. **Learning path.** Steps to go further, sized to any deadline. Include one hands-on exercise that teaches through doing, ideally something they try and watch fail or succeed.
10. **Sources.** Each with its date, plus a line that marks anything inferred or unverified.

## 4. No bullshit

- Every sentence teaches something. Cut throat-clearing, motivational filler, and restating.
- Be specific: real names, numbers, examples, and units of measure.
- Say how sure you are. Mark uncertain or contested points clearly, and never present a guess as fact.
- Put limitations, risks, and downsides on the page itself, at full strength.
- Use plain words. Define jargon the first time it appears, then use it consistently.
- Health, legal, and financial subjects get accurate facts and a clear line for when to see a professional. Don't dilute the content.

## 5. Build and publish on claude.ai

- Before writing, read the artifact publishing tool's own guidance on page rules and design (e.g. its `guide` topics `pages` and `design`). Load `dataviz` before drawing any chart.
- Write one self-contained HTML page in the scratchpad. Treat it as a polished reference rather than a landing page:
  - narrow reading column;
  - sticky table of contents on wide screens, hidden on phones;
  - code blocks and tables that scroll inside their own containers;
  - chips for status, cost, or risk;
  - charts that read well in light and dark themes.
- Give the visual identity a nod to the subject's own world, kept to typefaces and accents rather than decoration.
- Publish with the Artifact tool. Use a short, specific `<title>` that names the subject, a one-sentence description, and a fitting one-word icon.

## 6. Reply in chat

Keep the reply short. The page is where the teaching happens.
- The link, and a note that the page is private until the user shares it.
- The core idea in about five bullets.
- Anything that couldn't be verified, and the one or two points the user must not miss.
- One offer of a sensible next step: go deeper on a section, run the exercise together, or quiz them.
