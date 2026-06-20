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
---

# Skill Creator

Create new skills and iteratively improve them from chat context.

The loop: draft a skill, test it, improve based on what went wrong, repeat.

## Capture Intent

When the user wants a new skill, understand what they're after before writing anything.

Ask:
1. What should this skill enable?
2. When should it trigger? (keywords, contexts, user phrases)
3. What does the output look like?

If the current conversation already shows the workflow the user wants captured, extract answers from it first — tools used, steps taken, corrections made. Confirm the extracted understanding before drafting.

## Create from Chat Context

When the user says "turn this into a skill" or "make a skill from what we just did":

1. Read back through the conversation to extract the workflow.
2. Identify the tools used, the order of operations, and any decisions made along the way.
3. Note any corrections the user made — those are strong signals about what the skill should explicitly handle.
4. Synthesize a draft SKILL.md.
5. Present the draft to the user before writing it. Ask if anything's missing or wrong.

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

## Write the SKILL.md

Skills live in `skills/<name>/SKILL.md`. Match the style of existing skills in this repo (caveman, find-docs) — they're the reference examples.

Structure:

```yaml
---
name: <kebab-case>
description: >
  <What the skill does. When to trigger — include specific phrases and contexts
  the user might say. Be a little pushy here. The description is how the skill
  gets picked up, so include edge cases and adjacent phrases.>
---
```

Body rules:
- Imperative tone ("Do X", not "You should do X").
- No emojis.
- Concise sections, each focused on one thing.
- Examples when the output format matters — show input and output.
- Keep under 200 lines. If approaching that, split into reference files and link to them.

Bundled resources (optional):
- `scripts/` for deterministic or repetitive work the model would otherwise reinvent each time.
- `references/` for docs the model should read on demand.
- `assets/` for templates, icons, files used in the output.

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

The user tests the skill, reports what went wrong or what they wish it did differently, and you update the skill based on the new context. Repeat until the user is happy.

Encourage the user to try the skill on a few real prompts before judging it. The first draft will rarely be right — that's expected.

## When Iteration Fails

The skill will not be right on the first draft. When the user reports problems, diagnose before fixing:

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Skill fires when it shouldn't | Description is too broad, no negative triggers | Tighten KEYWORDS; add "Use ONLY when..." to description |
| Skill doesn't fire when it should | Description missing WHEN or specific phrases | Add 3+ concrete user phrases; remove generic verbs |
| Skill fires but output is wrong | Body has generic advice, not domain-specific knowledge | Rewrite body with concrete procedures only the model would not know |
| User keeps correcting the same thing | Skill is over-constrained or under-constrained | Find the constraint that is wrong — loosen rigid MUSTs, tighten vague advice |
| Description is fine but skill feels redundant | Skill duplicates content already in AGENTS.md or another skill | Cut the duplication; point to the canonical source |

Do not auto-loop. Each fix needs user confirmation before applying.

## Handle Edge Cases

Use this decision tree when the request is unclear or the iteration hits friction:

| Situation | First Move | If That Fails |
|-----------|-----------|---------------|
| Request is ambiguous | Ask one clarifying question about WHAT the skill should enable. | Propose 2-3 candidate scopes and let the user pick. Default to the smallest viable scope rather than guessing wide. |
| Skill exists but is bad | Read it first. Identify what's wrong (description? structure? triggers?). Propose specific fixes. | If the user disagrees with the diagnosis, ask which symptom they want fixed first. Do not rewrite from scratch unless the structure is fundamentally broken. |
| User wants a one-off | Push back. The bar is: "you'd use this 3+ times across different prompts." | If under that, suggest chat-only or a slash command instead. If the user insists, make it anyway but mark it `experimental` in frontmatter metadata. |
| Forking a skill | Copy the directory, rename in frontmatter, update triggers to match the new scope, keep the parent's good parts. | If the parent changes later, note the divergence so the user can rebase manually. |
| User rejects iteration changes | Ask which specific change they reject and why. Update only that part — do not revert everything. | If the user rejects 2+ iterations on the same section, that section needs a different approach, not more polish. |
| Skill passes validation but never triggers | Description is the problem. Apply the three-question framework — usually WHEN or KEYWORDS are missing. | Add 2-3 more trigger phrases the user might say. Bias toward over-triggering. |

## Validate Before Declaring Done

Run these checks before telling the user the skill is ready:
- Description has WHAT, WHEN, and KEYWORDS (all three, not just one)
- Description includes multiple specific user phrases the model can pattern-match
- Body is under 200 lines (split to reference files if over)
- At least 3 anti-patterns, each with reasoning for why it fails
- Tested on 2-3 real prompts the user actually expects to run
- No generic advice Claude would derive on its own without the skill
- Bundled resources only when the skill genuinely needs them

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
