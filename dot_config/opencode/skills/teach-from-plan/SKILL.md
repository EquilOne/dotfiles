---
name: teach-from-plan
description: >-
  Convert a project plan into a cohesive lesson plan that actually teaches.
  Produces tutorial-style modules with narrative walkthroughs, worked examples,
  and reasoning pauses — not reference docs or checklist instructions.
  MUST use when user says "turn this plan into lessons", "create a learning
  path", "convert plan to lessons", "create a lesson plan from this", "teach me
  this plan", "build a learning path", "lesson plan for this project",
  "make lessons from this plan", "tutorial from plan", "educational course",
  or "I have a project plan and want to learn from it".
  Also triggers on variations or requests to transform implementation milestones
  into educational courses or tutorials.
---

# Teach from Plan

Convert a structured or semi-structured project plan into a cohesive, tutorial-style lesson plan calibrated to the learner's self-reported experience with each concept and tool.

## Thinking Frame

Before generating any module, ask four questions:

1. **What did the previous module leave the learner able to do?** Module N's Walkthrough and Your Turn should assume exactly that capability.

2. **What is the single load-bearing idea in this step?** If the learner fails to grasp it, the rest of the step collapses. That idea gets the deepest treatment — even if the learner rated it high. The deepest treatment means: build from first principles, show the naive solution first, then layer on the abstraction.

3. **What's the smallest exercise that proves the step's objective?** Not the most thorough exercise — the smallest one that fails informatively if the concept is missed.

4. **Does this module's Walkthrough flow like a tutorial, or like documentation?** If the learner could get the same information from a README, restructure. A tutorial has a narrative thread: problem → naive attempt → insight → solution → reflection.

## Pattern Summary

This skill follows the **Process** pattern:
- **7-step workflow with checkpoints** — each step has clear inputs, outputs, and a go/no-go condition.
- **Medium freedom** — the sequence is fixed, but depth and pedagogical style adapt to the user's ratings.
- **Phased approach** — assess the learner, design the module content, sequence by dependency, and validate with observable checkpoints.

**Why Process pattern:** This skill manages a complex multi-step transformation (plan → analyzed concepts → sequenced lessons → validated curriculum). The phased approach with checkpoints ensures each phase completes before the next begins. Medium freedom because module structure is constrained but depth adaptation is domain-sensitive.

## Workflow

### Step 1 — Acquire the Plan
Plan source: file path or pasted inline. If neither, ask once.

### Step 2 — Parse the Plan
Extract: title + overall goal, ordered list of steps/milestones/phases, deduplicated list of distinct concepts (e.g., rate limiting, idempotency, routing), deduplicated list of distinct tools/frameworks/libraries (e.g., Postgres, FastAPI, Docker).

If the plan is loose prose with no clear steps, confirm the extracted step list with the user before continuing.

### Step 3 — Calibrate Experience
Present the concept and tool lists to the user. Ask them to rate each on a 1–5 scale:
- 1 = never used
- 2 = heard of it, no hands-on
- 3 = used once or twice
- 4 = comfortable
- 5 = expert

**Important:** If the user rates everything 4 or 5, ask one applied calibration question before accepting. Learners often overestimate expertise. A question like "Can you explain how X handles edge case Y?" reveals actual gaps.

### Step 4 — Map Ratings to Depth

Apply the following mapping strictly:

| Rating | Walkthrough Style | Exercise Style |
|--------|-------------------|----------------|
| 1 | **Build from first principles.** Start with the raw problem. Show the naive approach. Add abstraction layer by layer. Include "predict the output" moments. 3–5 paragraphs + code that appears mid-explanation (not in a separate block). | Guided — provide scaffolding (starter code, hints). Expect the learner to complete 1–2 key gaps. |
| 2 | **Brief recap + one focused worked example.** Assume prior exposure. Show the specific shape/pattern needed *for this step only*. Don't re-explain from scratch. 2 paragraphs + focused code walkthrough. | Semi-guided — a clear prompt with one hint available. Expect the learner to produce the solution with the worked example as reference. |
| 3 | **One-paragraph reminder + one gotcha.** "You've used this before — here's the specific thing that trips people up in this context." 1 paragraph + inline code snippet. | Minimal scaffolding — state the task and trust the learner to execute. Offer a hint only if asked. |
| 4 | **One-line callout** only when a non-obvious behavior matters. Otherwise skip. | Self-directed — no hints, just the acceptance criteria. |
| 5 | **Skip** unless there is a subtle pitfall. If there is, surface it as a one-liner. | Skip unless there is a subtle pitfall. |

### Step 5 — Generate Modules

One module per plan step, preserving execution order. Each module must use the following structure — **no separate Concepts/Tools/MisconceptionTrap sections**. Everything is woven into the Walkthrough narrative.

#### Module Template

```
## Module N: [Title]

**Objective:** One sentence describing what the learner can do after this module.

### Walkthrough

A flowing tutorial narrative that:

1. **States the problem** this module solves — ideally in concrete terms ("Right now the server returns a raw response. But the user can't see the response being built — they stare at a blank screen until the whole thing arrives. We need to stream tokens as they're generated.")

2. **Builds the solution incrementally**. Code appears as part of the explanation, not in a separate code block. Show the first attempt, explain why it's incomplete, then refine:
   ```python
   # First attempt — what's wrong here?
   @app.post("/chat")
   async def chat():
       result = await get_chat_response(...)
       return {"response": result}  # Problem: client waits for the whole response
   ```

3. **Introduces each concept and tool at the moment it's needed.** Don't define SSE before showing the streaming problem — define it when the learner hits the "why is my response slow?" wall.

4. **Includes reasoning pauses.** Use inline questions:
   > Before you move on: why would this break if the client sent a message while the stream was still running? What state do we need to protect?

5. **Shows the final assembled solution** at the end of the walkthrough, with a brief annotation of each key part.

**Depth adaptation:** At depth 1, the Walkthrough is 3–5 paragraphs with incremental code evolution. At depth 3, it's a paragraph and a gotcha. At depth 5, it's skipped.

### Your Turn

One concrete hands-on exercise tied to this step. The **smallest exercise that proves the objective**. Not "build the todo app" — "change the system prompt, restart the server, and verify the new behavior in curl."

At depth 1, include starter code and one hint. At depth 3+, state the task without scaffolding.

### Checkpoint

2–4 verifiable success criteria. Every criterion must be an observable yes/no question:
- [ ] `curl -N -X POST ...` shows tokens arriving line-by-line (not all at once)
- [ ] The last line of the stream is `data: [DONE]`

No "understand X" or "be familiar with Y" checkpoints.

### Next

One-line bridge to the next module. Answer the question "why am I doing this next thing?":
- "The server works but forgets everything between messages. Next module: add session memory so conversations have context."
```

### Step 6 — Save
Print the full lesson plan in chat. Ask for save path (default `lesson-plan-<slug>.md`, slug from plan title in kebab-case). Write the file on confirmation.

### Step 7 — Follow-ups
Offer: drill into any module for deeper explanation, generate additional exercises, create spaced-repetition cards, or convert any module to a Socratic mentoring session.

## Do NOT Load

- Do NOT use for general tutoring or ad-hoc Q&A — use socratic-mentoring for that
- Do NOT use for skill evaluation — use skill-judge instead
- Do NOT use if there's no source plan to convert from
- Do NOT use for writing code — use the coder subagent

## Anti-Patterns

NEVER do any of these:

- **NEVER rate experience for the user.** If context doesn't tell you, ask. Guessing makes depth calibration worthless. Detect early when the user mentions a technology but never supplies a 1–5 rating.

- **NEVER produce a module with no Your Turn exercise.** A module without a hands-on task is a reading assignment, not a lesson. Even depth-5 modules should include one challenge that integrates previous knowledge.

- **NEVER produce a Walkthrough that reads like a README.** If you find yourself writing "X is a tool that does Y. Here are its features. Here is the syntax," you've lost the narrative. Restart from the problem it solves.

- **NEVER collapse every depth-5 item into "you know this."** The mapping says "skip *unless* there's a subtle pitfall" — surface those when they apply. Experts still trip over non-obvious edge cases.

- **NEVER generate checkpoints that aren't verifiable.** "Understand the concept" is not a checkpoint. Every checkpoint must be observable: a file exists, a command returns X, a test passes.

- **NEVER assume the learner knows their own knowledge gaps.** Learners often overestimate expertise because metacognition is hard. Ask one applied calibration question before accepting a high self-rating. Detect early when a user rates everything 4 or 5 without examples.

- **NEVER skip the "surprise" moment.** Every module should have at least one moment where the learner encounters an unexpected behavior — either through a reasoning pause ("what do you think happens if...") or through a designed failure in Your Turn. Misconceptions that aren't surfaced compound into later lessons.

- **NEVER use boilerplate explanations.** If the learner rated a concept 3+ ("used it before"), don't re-explain from scratch. Say "you've seen this before — here's the specific thing that's different in this step." If you can't find the thing that's different, skip the explanation entirely.

## Expert Knowledge

### Spacing Effect
Distribute practice across time. A learner who practices a concept for 30 minutes on Monday, Wednesday, and Friday retains more than one who practices for 90 minutes on Monday. When generating modules, add a suggestion: "Revisit this concept in 2 days with a new exercise — try changing X to Y and observe the difference."

### Interleaving
Mix related concepts within a session rather than blocking them. Instead of "learn all about SSE, then all about CORS," interleave in the walkthrough: "We're building an SSE endpoint — but when you open it from the browser, the CORS policy blocks it. Let's solve both at once." Interleaving feels harder but transfers better.

### Minimal Viable Exercise
The smallest exercise that proves a module's objective is not the most thorough one. It's the one that fails informatively if the concept isn't understood. "Make a button that increments a counter" is minimal. "Build a todo app with CRUD operations" is not — it tests too many things at once.

### The "Surprise" Principle
The most valuable learning moment is when the learner's mental model predicts one thing and reality shows another. Design at least one such moment per module. In the SSE module, the surprise is "without `data: [DONE]`, the stream hangs forever." The learner predicted it would end on its own. The server proved otherwise.

## Edge Cases

| Situation | Action |
|-----------|--------|
| Plan has no clear steps (pure prose) | Confirm extracted step list with user before proceeding |
| User rates everything 5 | Confirm intent: "Skip all explanations and surface only pitfalls?" Generate a pitfalls-only plan if confirmed |
| User rates everything 1 | Flag high total time; offer to defer some depth-1 modules to an appendix |
| Plan has >20 steps | Warn: "X modules will be generated. Want me to group into phases instead?" |
| Concept appears in multiple steps | Reference back, don't re-introduce — apply depth from the original rating |
| Plan references proprietary/internal tools | Flag as "may not be available." Provide open-source alternatives. Never assume the learner has access |
| Plan is purely theoretical (no code) | Add a "Thought Exercise" section per module — a question the learner answers in writing |

## Quick Start

For the common case (user has a project plan and wants to learn from it):

1. **Acquire**: Ask for the plan file or inline paste
2. **Parse**: Extract steps, concepts, and tools
3. **Calibrate**: Ask the user to rate each concept/tool 1–5
4. **Generate**: One module per step, Walkthrough narrative per depth mapping
5. **Save**: Write to `lesson-plan-<slug>.md`

Skip to Step 3 if the plan is already structured. Skip to Step 2 if the user pastes the plan inline.

Base directory for this skill: /home/equilone/.config/opencode/skills/teach-from-plan
