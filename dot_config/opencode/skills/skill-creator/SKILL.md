---
name: skill-creator
description: >
  Create new skills from scratch and improve existing skills using conversation context.
  Use this skill whenever the user asks to create a skill, save a workflow as a skill,
  turn a conversation into a skill, or fix/update/improve an existing skill. Also
  trigger when the user says "remember this for next time", "make this a skill",
  "create a skill for this", "update the X skill", or anything about making the
  current approach reusable. If the user seems to be doing repetitive work that
  could be automated by a skill, ask if they want to create one.
  Do NOT use for evaluating skills — use skill-judge instead. Do NOT use for editing
  opencode config — use customize-opencode. Do NOT use for refactoring agent instruction
  files — use agent-md-refactor.
---

# Skill Creator
Create new skills and iteratively improve them from chat context. The loop: draft a skill, test it, improve based on what went wrong, repeat.

## Capture Intent

When the user wants a new skill, understand what they're after before writing anything.

Ask:
1. What should this skill enable?
2. When should it trigger? (keywords, contexts, user phrases)
3. What does the output look like?

If the current conversation already shows the workflow the user wants captured, extract answers from it first — tools used, steps taken, corrections made. Confirm the extracted understanding before drafting.

Before writing anything, ask yourself:
- **Indispensability**: What would make this skill indispensable vs. redundant with AGENTS.md or another skill? If the answer is "nothing," the skill shouldn't exist.
- **Smallest viable scope**: What's the smallest scope that covers 80% of the user's use cases? Start there. Scope creep kills skills faster than bad content.
- **Expert validation**: Would an expert in this domain say "yes, this captures how I think"? If not, you're writing a tutorial, not a skill.

## Research Phase

After clarifying intent but before choosing a pattern, research the domain:

1. **Library/API/CLI-targeting skills** — use `general` subagent with find-docs skill (`npx ctx7@latest`) to fetch current docs, API signatures, and usage patterns.
2. **Domain/convention skills** (no specific library) — use `research` subagent to investigate conventions, terminology, pain points, and existing patterns in the domain.
3. **Simple factual lookups** — use `search` subagent directly.
4. **Multiple angles** — fan out all three in parallel via `task` calls. Batch up to 10 at once.

Merge findings with captured intent before proceeding to pattern selection.

## Create from Chat Context

When the user says "turn this into a skill" or "make a skill from what we just did":

1. Read back through the conversation to extract the workflow.
2. Identify the tools used, the order of operations, and any decisions made along the way.
3. Note any corrections the user made — those are strong signals about what the skill should explicitly handle.
4. If the chat context mentions a specific library, API, framework, or CLI tool, load find-docs and verify the user's workflow against current documentation before synthesizing.
5. Synthesize a draft SKILL.md.
6. Present the draft to the user before writing it. Ask if anything's missing or wrong.

## Do NOT Load
- Do NOT use skill-creator for evaluating skills — use skill-judge instead
- Do NOT use for editing opencode config — use customize-opencode
- Do NOT use for refactoring agent instruction files — use agent-md-refactor

## Progressive Disclosure Template
When a skill needs >150 lines, split into:
- `SKILL.md` — core workflow, description, anti-patterns (<150 lines)
- `references/<topic>.md` — detailed examples, extended decision trees
- `scripts/<name>.sh` — executable workflows (if any)
Add MANDATORY loading triggers in SKILL.md for each reference file.

## Choose the Right Pattern

Pick the pattern that matches the task before writing. Pattern sets length, tone, and structure.

| Task characteristic | Pattern | Length | When to use |
|---|---|---|---|
| Creative work requiring taste | Mindset | ~50 lines | Principles over rules |
| Multiple distinct sub-scenarios | Navigation | ~30 lines | Branch by signal, stay terse |
| Art/creation requiring originality | Philosophy | ~150 lines | Freedom within constraints |
| Complex multi-step project | Process | ~200 lines | Ordered phases, checkpoints |
| Precise ops on specific format | Tool | ~300 lines | Exact steps, examples, edge cases |

Mindset and Navigation stay short. Tool and Process can run longer, but split into reference files once they cross the line budget. Misreading the pattern wastes a draft: a Tool skill written as Mindset will lack the exact steps that make it reliable.

**Why Process pattern:** Skill creation is a multi-step workflow (analyze → choose pattern → draft → validate → iterate) with checkpoints (validation gate). Medium freedom — the workflow is fixed but content is creative.

## Draft the SKILL.md
Skills live in `skills/<name>/SKILL.md`. Match the style of existing skills in this repo (caveman, find-docs).

Rules:
- Imperative tone ("Do X", not "You should do X").
- No emojis.
- Concise sections, each focused on one thing.
- Examples when the output format matters — show input and output.
- Keep under 250 lines. If approaching that, split into reference files and link to them.
- Embed loading triggers at the decision point where the reference is needed, not in a list at the end.

## Bundled Resources (scripts/, references/, assets/)
Skills can bundle additional files in subdirectories. Knowing when to use each is expert knowledge:

- **scripts/** — Use for executable workflows that must run identically every time (e.g., a Python script that processes files in a specific order). The skill invokes the script; the script does the work. Trade-off: harder to debug, but guarantees consistency.
- **references/** — Use for documentation loaded on-demand (e.g., a 200-line scoring rubric, platform-specific syntax rules). The skill loads it conditionally. Trade-off: requires explicit MANDATORY loading triggers or it sits unused.
- **assets/** — Use for templates, examples, or static files the skill copies or references (e.g., a README template, an example plan).

**Anti-pattern:** Don't put content in references/ that's always needed — that forces an extra read every invocation. If it's always needed, inline it in SKILL.md.

## Craft the Description

The `description` field is the trigger mechanism. The model reads name + description to decide whether to use the skill, so the description is where the skill lives or dies.

Apply the three-question framework:
- WHAT: the capabilities the skill provides
- WHEN: the scenarios that should activate it
- KEYWORDS: the specific phrases and contexts the user might say

Good: "Refactor bloated AGENTS.md files into progressive disclosure structure. Use when the user says 'clean up AGENTS.md', 'too long', or 'split this file'. Also fire on CLAUDE.md or similar agent instruction files over 200 lines."
Bad: "Helps with agent documentation." (no triggers, no keywords, no scenarios — will almost never fire)

Include multiple user phrases — the model pattern-matches on them. Bias toward over-triggering: a skill that fires when not needed costs one wasted turn, but a skill that fails to fire when it would help loses the workflow entirely. The costs are asymmetric, so lean toward more triggers, not fewer.

Checklist:
- WHAT stated as capabilities
- WHEN stated as scenarios
- KEYWORDS are specific user phrases, not generic
- Includes edge cases and adjacent phrases
- Reads as a little pushy, not tentative

## Freedom Calibration

Skill creation requires different freedom at different stages:

| Stage | Freedom | Why |
|-------|---------|-----|
| Choosing a pattern (Mindset/Tool/Process) | Low | Wrong pattern = structural failure. Follow the decision tree. |
| Writing the description | Low | Description quality is binary — it either triggers or doesn't. Follow the checklist. |
| Writing expert knowledge | High | Domain expertise is creative — let the expert flow. |
| Writing anti-patterns | Medium | Specific rules needed, but the model chooses which landmines to include. |
| Validation | Low | Follow the validation checklist exactly. Don't skip steps. |

**Key insight:** The description and pattern choice are low-freedom because they're load-bearing. The expert content is high-freedom because that's where value lives. Don't over-constrain the expert content with rigid templates.

## Improve from Chat Context

When the user asks to update, fix, or improve a skill:

1. Read the current `SKILL.md` (and any files in its directory).
2. Review the current conversation for signals:
   - Corrections the user made when the skill ran.
   - Preferences they expressed.
   - Output that came out wrong and what was wrong about it.
   - Patterns they kept having to re-explain.
3. Propose specific changes — not "make it better" but "change line X to do Y because you said Z."
4. Apply the changes after the user agrees.

Changes can be to SKILL.md content or to directory structure (adding `scripts/`, `references/`, etc.) if the conversation shows the skill needs bundled resources.

## Iteration Loop

The user tests the skill on a real prompt, reports what went wrong, and you update based on the signal. Repeat until satisfied.

Heuristics for each iteration:
- **First draft will be wrong** — encourage the user to try 2-3 real prompts before judging.
- **Same correction twice** → the skill has a wrong constraint. Find it and fix it, don't just polish.
- **Vague feedback** ("it's not quite right") → ask which specific output was wrong and what they expected instead.
- **Skill works on simple prompts but fails on complex ones** → the skill is under-specified. Add decision trees or edge case handling.
- **User keeps overriding the skill** → the skill conflicts with their mental model. Ask what they'd do without the skill, then align to that.

## When Iteration Fails / Edge Cases

**MANDATORY - READ ENTIRE FILE**: If iteration hits friction, the user reports persistent problems, or the request is ambiguous, read [`references/diagnostic-tables.md`](references/diagnostic-tables.md) completely. It contains symptom/cause/fix tables and edge case decision trees.

**Do NOT load** on every invocation — only when diagnosis is needed.

## Expert Validation Questions

Before finalizing a skill, validate against these expert questions:

1. **Knowledge delta test:** "Would a general-purpose LLM without this skill produce the same output?" If yes, the skill has no value — it's compressing what the model knows.
2. **Trigger precision test:** "Does the description contain the exact words the user would say?" Vague descriptions ("helps with X") never trigger; specific ones ("when user says 'format this markdown'") always trigger.
3. **Anti-pattern authenticity test:** "Would an expert say 'I learned this the hard way'?" If the anti-pattern is obvious to everyone, it's not expert knowledge.
4. **Progressive disclosure test:** "Is the SKILL.md body under 500 lines?" If over, move detail to references/ with loading triggers.

## Validate Before Declaring Done
Run these checks before telling the user the skill is ready:
- Description has WHAT, WHEN, and KEYWORDS (all three, not just one)
- Description includes multiple specific user phrases the model can pattern-match
- Body is under 250 lines (split to reference files if over)
- At least 3 anti-patterns, each with reasoning for why it fails
- Tested on 2-3 real prompts the user actually expects to run
- No generic advice Claude would derive on its own without the skill
- Bundled resources only when the skill genuinely needs them
- Research was conducted (if domain-specific) — skill doesn't rely on incomplete or outdated assumptions

## Anti-Patterns

- NEVER write a skill that only handles the conversation's specific examples — generalization test: read the skill without the conversation, do the procedures still make sense? If no, it is too narrow. The skill must work on prompts the user has not run yet.
  - Example failure: skill says "if the user pastes a function, format it with prettier" — fails when the user pastes a class, JSON, or config.
- NEVER over-constrain with rigid MUSTs without reasoning — the model follows the letter and misses the spirit. Explain *why* each constraint matters so the model adapts when context shifts.
  - Example failure: skill says "MUST use tab indentation" with no reason — model tab-indents a project that uses spaces, breaking the codebase.
- NEVER add features the user did not ask for — a focused skill beats a kitchen-sink skill. Extra features dilute the trigger and add surface area for bugs.
  - Example failure: skill for "explain this code" gains a "refactor" mode because the user asked once — now the skill fires on every refactor request and explains less.
- NEVER create a skill for a one-off task — the bar is "you would use this 3+ times across different prompts." One-offs belong in chat, not in a skill directory.
  - Example failure: skill for "format this CSV" with one column shape — when the CSV has different columns, the skill fails and the user has to re-explain every time.
- NEVER write a description with only WHAT — the skill will rarely trigger. WHEN and KEYWORDS are what make the model pick it up.
  - Example failure: description "Skill for code refactoring" — never fires because the model has no signal for when to load it.
- NEVER duplicate content already in AGENTS.md or another skill — each skill owns one workflow. Duplication drifts apart and both copies rot.
  - Example failure: two skills both explain "how to commit" — one updates to use commit-work, the other stays stale.
- NEVER explain what a skill is or how skills work — the skill body is for domain knowledge the model lacks, not skill mechanics. Opening with "a skill is a markdown file that..." is pure token waste.
  - Example failure: skill opens with "Skills are knowledge externalization mechanisms that allow you to..." — the model skips this, tokens wasted, no knowledge transferred.
