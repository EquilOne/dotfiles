---
name: improve-lesson
description: >
  Takes a course lesson (Codecademy, Boot.dev, or any tutorial) and returns a
  SHORT boost: one plain-language clarification plus a few useful extras —
  gotchas, real-world uses, nice-to-knows. Use this skill whenever the user
  says "improve this lesson", "clarify this lesson", "add edge cases",
  "nice to knows", "what am I missing", or pastes lesson content asking for
  more depth. The boost is always much shorter than the lesson itself.
---

# Improve Lesson

Take a course lesson and return a SHORT boost: one clarification plus useful bits. Companion notes, not a rewrite.

## Core rule

The boost must be much shorter than the lesson — roughly a third of its length, never longer. Cut anything that restates the lesson.

## Output shape

```markdown
## Boost: <topic>
**In one line:** the core idea said more plainly than the lesson said it — only if the lesson's explanation was muddy
**Gotchas:** up to 3 one-liners; real mistakes with the observable symptom (error text/behavior)
**Where it's used:** 2-3 one-liners; what this is actually for in real code
**Nice to know:** 1-2 one-liners; non-obvious facts that prevent later confusion
```

Skip any section with nothing genuinely useful. Never pad to fill the shape.

## Workflow

1. Get the lesson: pasted text, a topic summary, or a link to free public content. Never fetch paywalled course pages (Boot.dev, Codecademy) — ask for a paste instead.
2. Spot the ONE murkiest idea and clarify it plainly. If nothing was muddy, say so and skip.
3. Add gotchas / uses / nice-to-knows the lesson didn't cover but the learner will hit.
4. Version-sensitive claims (language/library behavior): verify or omit. Never invent error messages.
5. Output in chat. Offer to save to the Obsidian vault (`~/obsidian`) only if asked.

## Calibrate

- Skip clarifying what the learner already knows; his curriculum is TS-first (Boot.dev backend, Odin frontend).
- Every line should change what he'd do or notice — no volume for its own sake.

## Anti-Patterns

- Restating lesson content as "extras"
- More than 3 items in any section
- Trivia that doesn't prevent a mistake or confusion
- Turning the boost into a study guide or rewrite

## Twin Skill

Hermes copy: `~/.hermes/skills/learning/improve-lesson/SKILL.md`. Keep the Core rule and Output shape identical in both.
