---
name: plan-to-lessons
description: >
  Converts any project plan into a structured lesson plan whose depth is
  calibrated per concept and per tool based on the user's self-reported experience.
  Use this skill whenever the user says "turn this plan into lessons", "create a lesson plan from this",
  "teach me this plan", "build a learning path", "lesson plan for this project",
  "convert plan to lessons", "make lessons from this plan", or "I have a project plan and want to learn from it".
  Also triggers on variations or requests to transform implementation milestones into educational courses or tutorials.
---

# Plan to Lessons

Convert a structured or semi-structured project plan into a customized lesson plan calibrated to the user's specific experience with each concept and tool.

## Thinking Frame

Before generating any module, ask three questions:
1. **What did the previous module leave the learner able to do?** Module N's Concepts, Tools, and Exercise should assume exactly that capability.
2. **Which concept in this step is the load-bearing one?** If the learner fails to grasp it, the rest of the step collapses. That concept gets the deepest treatment even if rated high.
3. **What's the smallest exercise that proves the step's objective?** Not the most thorough exercise — the smallest one that fails informatively.

## Workflow

### Step 1 — Acquire the Plan
Plan source: file path or pasted inline. If neither, ask once.

### Step 2 — Parse the Plan
Extract: title + overall goal, ordered list of steps/milestones/phases, deduplicated list of distinct concepts (e.g., rate limiting, idempotency, routing), deduplicated list of distinct tools/frameworks/libraries (e.g., Postgres, FastAPI, Docker).

If the plan is loose prose with no clear steps, confirm the extracted step list with the user before continuing.

### Step 3 — Calibrate Experience
Present the concept and tool lists to the user. Ask them to rate each on a 1-5 scale:
- 1 = never used
- 2 = heard of it, no hands-on
- 3 = used once or twice
- 4 = comfortable
- 5 = expert

### Step 4 — Map Ratings to Depth

Apply the following mapping strictly:

| Rating | Concept Depth | Tool Depth |
|--------|---------------|------------|
| 1 | Full intro: what it is, why it matters here, mental model, glossary | Setup walkthrough, install, first minimal example, verify it works |
| 2 | Brief recap of the idea and the specific role it plays in this step | Setup pointer + minimum-viable usage for this step |
| 3 | One-paragraph refresh, focused on the gotcha for this step | Quick reference of the relevant commands/APIs, no setup |
| 4 | One-line callout only when a non-obvious behavior matters | Assume setup; surface only the specific call/flag needed |
| 5 | Skip unless there is a subtle pitfall | Skip unless there is a subtle pitfall |

### Step 5 — Generate Modules
One module per plan step, preserving execution order. Each module must include:
- **Objective** — what the learner can do after this module
- **Exercise** — one concrete hands-on task tied to this step
- **Checkpoint** — 2-4 verifiable success criteria

Add the following when the step has content for them:
- **Concepts** — for any concept appearing in this step, depth per Step 4
- **Tools** — for any tool appearing in this step, depth per Step 4
- **Estimated time** — scale by depth (more depth = more time)
- **Next** — one-line bridge to the next module

### Step 6 — Save
Print the full lesson plan in chat. Ask for save path (default `./lesson-plan-<slug>.md`, slug from plan title in kebab-case). Write the file on confirmation.

### Step 7 — Follow-ups
Offer: drill into any module, generate more exercises, or create spaced-repetition cards.

## Anti-Patterns

NEVER do any of these — each one is a lesson-plan failure mode:

- **NEVER rate experience for the user.** If context doesn't tell you, ask. Guessing makes depth calibration worthless.
- **NEVER produce a module with no exercise.** A module without a hands-on task is a reading assignment, not a lesson. Even depth-5 modules should include one challenge that integrates previous knowledge.
- **NEVER collapse every depth-5 item into "you know this."** The table says "skip *unless* there's a subtle pitfall" — surface those when they apply.
- **NEVER split a single plan step into multiple modules.** One step maps to one module. If a step feels too dense, chunk the exercise, not the modules.
- **NEVER generate exercises that aren't verifiable.** "Understand the concept" is not a checkpoint. Every checkpoint must be observable: a file exists, a test passes, a command returns X.
- **NEVER assume a depth-1 setup walkthrough for a tool the user can't install** (e.g., enterprise-only DB, hardware-specific tool). Flag the blocker in the module and offer an alternative path.

## Edge Cases

| Situation | Action |
|-----------|--------|
| Plan has no clear steps (pure prose) | Confirm extracted step list with user before proceeding |
| User rates everything 5 | Confirm intent: "Skip all explanations and surface only pitfalls?" Generate a pitfalls-only plan if confirmed |
| User rates everything 1 | Flag high total time; offer to defer some depth-1 modules to an appendix |
| Plan has >20 steps | Warn: "X modules will be generated. Want me to group into phases instead?" |
| Concept appears in multiple steps | Reference back, don't re-introduce — apply depth from the original rating |
