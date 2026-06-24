---
name: project-planner
description: >-
  Produce milestone-based, dependency-ordered project plans that an agent can
  execute on. Enter "plan mode" — read-only exploration, constraint gathering,
  milestone decomposition with DAG dependencies, verification checkpoints, and
  user approval before any execution. MUST use when user says "plan this
  project", "create a plan", "make a plan", "break this into tasks", "what are
  the phases", "make a roadmap", "how should I approach this", "scope this out",
  "create a project plan", "design the implementation plan", "plan mode",
  "need a plan", "outline the work", "what's the approach", "sequence of
  steps", "design the implementation", or asks the agent to tackle a complex
  multi-step task without a clear plan. Also fires pre-execution when the user
  describes a multi-step feature or task that would benefit from upfront
  planning before any code is written. Enters read-only plan mode — explores
  constraints, decomposes into milestones with dependencies (DAG), adds
  verification checkpoints, and presents the plan for user approval before any
  execution begins. Use ONLY for project planning — not for converting plans
  into lessons (use plan-to-lessons), not for writing code (that's coder), and
  not for planning tutoring sessions (use socratic-mentoring).
---

# Project Planner

## Why Process Pattern

Project planning is a phased workflow with explicit validation gates. Each phase feeds into the next: gather constraints before decomposing, decompose before structuring dependencies, validate before presenting. Skipping a phase produces a plan the agent cannot execute on.

**Pattern mapping:**
- Ordered phases with checkpoints: 7-step workflow with validation at gate 5 and approval at gate 7
- Medium freedom: the workflow is fixed, but the content (milestones, tasks, dependencies) is creative and context-dependent
- ~180 lines (within Process range)

## Core Workflow — 7 Phases

Execute these phases in order. Do NOT skip any phase. Do NOT start execution until phase 7 produces user approval.

### Phase 1: Enter Plan Mode

Restrict yourself to read-only exploration. You may read files, search the codebase, and ask the user questions. Do NOT execute any code, create any files, or run any commands.

**What to explore:**
- Read existing project files (README, existing plans, config files)
- Search for relevant code structure (if the plan is for a code project)
- Ask the user clarifying questions about scope and constraints

**Output of this phase:** A summary of what you found and what still needs clarification.

### Phase 2: Gather Constraints

Collect these inputs before decomposing. For each, ask the user if not already clear:

- **Scope boundaries** — what is IN scope and what is explicitly OUT
- **Success criteria** — how will you know the plan is complete?
- **Resources** — time budget, team size (or single agent), tooling available
- **External dependencies** — libraries, APIs, services, approvals needed
- **Risk areas** — what could go wrong and where is uncertainty highest?
- **Granularity preference** — high-level phases or detailed task breakdown?

**Output of this phase:** A structured constraint list ready for decomposition.

### Phase 3: Decompose into Milestones

Break the work into zero-duration milestones — checkpoints that represent state changes, not task completion.

**Rules for milestones:**
- Each milestone has a clear verification gate: "how do we know this is done?"
- Each milestone has 2-5 tasks (no more — more means the milestone is too broad)
- Milestones are ordered so completion of one enables the next
- If tasks within a milestone can run in parallel, note this explicitly

**Output of this phase:** A milestone list with names, verification gates, and initial task ideas.

### Phase 4: Structure as DAG

Map dependencies between milestones. Every milestone should explicitly list its dependencies.

**DAG rules:**
- No circular dependencies — validate before presenting
- Flag parallelization opportunities: "Milestones 3 and 4 have no dependencies on each other and can run in parallel"
- If the plan has more than 7 milestones, group them into phases (2-3 milestones per phase)

**Output of this phase:** A dependency graph with parallelization notes.

### Phase 5: Add Verification Checkpoints

Integrate verification into the plan itself. Each milestone's verification gate must be explicit enough that the agent (or a reviewer) can determine pass/fail unambiguously.

**Verification types:**
- For code milestones: "All tests pass", "Linter produces no errors", "Feature works in staging"
- For research milestones: "Decision documented with 3 options and tradeoffs"
- For setup milestones: "Dependency confirmed running", "Config validated against schema"

**Then run a plan-level validation check:**
- [ ] No missing dependencies (every referenced milestone exists and is reachable)
- [ ] No unrealistic sequencing (milestone ordering respects preconditions)
- [ ] No scope creep (all tasks map to stated scope boundaries)
- [ ] No ambiguous success criteria (each verification gate is testable)

**Output of this phase:** The validated plan ready for storage.

### Phase 6: Store the Plan

Write the plan to `PLAN.md` in the project root (or user-specified path). Use this format:

```markdown
# Project Plan: [Name]

## Constraints
- Scope in: [what's included]
- Scope out: [what's explicitly excluded]
- Success: [how completeness is measured]
- Resources: [time, people, tools]
- Key risks: [top 2-3 risks]

## Milestone 1: [Short Name]
**Verification:** [explicit pass/fail gate]
**Dependencies:** (none / Milestone X)
**Parallelizable:** yes/no

- [ ] Task 1.1: [actionable description]
- [ ] Task 1.2: [actionable description]
- [ ] Task 1.3: [actionable description]

## Milestone 2: [Short Name]
**Verification:** [explicit pass/fail gate]
**Dependencies:** Milestone 1
**Parallelizable:** no

- [ ] Task 2.1: [actionable description]
- [ ] Task 2.2: [actionable description]
```

The format must be both human-readable and agent-actionable: the agent can check off tasks and milestones as it executes.

### Phase 7: Present for Approval

Show the user the plan with a clear ask:

```
## Plan Summary: [Milestone count] milestones, [task count] tasks, [parallelization opportunities]

First milestone: [name] — [verification gate]
Riskiest milestone: [name] — [why]

**Shall I proceed with this plan?**
```

Do NOT begin execution until the user explicitly approves. If the user requests changes, loop back to the relevant phase, update the plan, and re-present.

## Do NOT Load

- Do NOT use for converting plans into learning paths — use plan-to-lessons for that
- Do NOT use for planning tutoring sessions — use socratic-mentoring
- Do NOT use for writing code — use the coder subagent
- Do NOT use for planning meetings or schedules — that's outside this skill's scope

## Reference Files

**MANDATORY:** If the user asks about the research backing for this skill, or if you need help diagnosing why a plan failed in execution, load `references/research-backing.md`.

**Do NOT load** the reference file on every invocation — only on explicit request or when the plan failed during execution and you need diagnostic support.

## NEVERS

- NEVER start execution before the user approves the plan — approval is a hard gate. Violating this turns planning into wasted tokens.
- NEVER create circular dependencies — validate the DAG before presenting. Circular dependencies cause agents to deadlock (waiting for each other indefinitely).
- NEVER accept vague scope like "build the app" without decomposing into milestones — the agent will over-commit and under-deliver on what matters.
- NEVER produce a flat list of tasks without dependencies — the agent will execute sequentially even when tasks could run in parallel.
- NEVER skip verification gates per milestone — without verification, the agent doesn't know "done" from "not done" and drifts into infinite refinement loops.
- NEVER ask the user for every implementation detail — gather enough to plan, propose reasonable defaults, and flag only critical decisions that block the plan.
- NEVER silently expand scope beyond the user's stated boundaries — document scope creep if you discover it's needed, but flag it explicitly rather than absorbing it.
- NEVER exceed 7 milestones without grouping into phases — more than 7 ungrouped milestones causes planning depth degradation in the agent's context window.
