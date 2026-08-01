---
name: project-planner
description: Use when planning or scoping a new project. Create portable Plan and Roadmap documents and guide decisions from goals through delivery.
version: 1.0.0
author: Chase
license: MIT
metadata:
  hermes:
    tags: [project-planning, roadmaps, requirements, milestones]
    related_skills: []
---

# Project Planner

A portable project-planning workflow for agentic applications. It uses the bundled `references/Plan.md` and `references/Roadmap.md` templates as starting points, then guides the user through goals, scope, requirements, architecture, milestones, risks, and delivery.

## When to Use

Use when the user asks to plan, scope, kick off, structure, roadmap, or break down a project. Do not create project artifacts without confirming the target project directory and the proposed milestone structure.

## Resources

- `references/Plan.md` — detailed project plan template.
- `references/Roadmap.md` — strategic roadmap template.

When invoked from a project, copy both references into `<project>/docs/` as `Plan.md` and `Roadmap.md`. Create `docs/` if needed. Never overwrite existing files without warning and explicit confirmation.

## Workflow

1. **Confirm location.** Ask whether the current working directory is the project directory. If not, request an absolute path and verify it exists.
2. **Inspect existing planning state.** Check for existing `docs/Plan.md`, `docs/Roadmap.md`, and `.planning` metadata. Preserve existing work; ask before resetting or replacing it.
3. **Propose structure.** Summarize the project purpose and propose 2–4 milestones. Get confirmation before creating task lists or external tracking artifacts.
4. **Scaffold.** Copy the bundled templates into the project’s `docs/` directory, adapting only project title and known metadata. Report every created or skipped file.
5. **Plan interactively.** Work through goals and summary, scope, requirements, stack and architecture, milestones and timeline, risks and dependencies, and references. After each section, ask whether to continue or refine.
6. **Keep artifacts synchronized.** Record confirmed decisions in `Plan.md`; update `Roadmap.md` with Now/Next/Later priorities, releases, dependencies, dates, and risks. Do not invent decisions or dates.
7. **Deliver.** Present the completed documents, unresolved questions, key decisions, milestones, risks, and immediate next steps. If an external tracker is available, create issues only after confirmation and report returned URLs or IDs.

## Guardrails

- Do not plan in the wrong directory.
- Do not overwrite an existing plan or roadmap without confirmation.
- Do not create dozens of tasks at kickoff; start with 2–4 milestones.
- Keep scope explicit: distinguish in-scope work from out-of-scope work.
- Treat dates, owners, dependencies, and risks as user-confirmed facts.
- Keep templates application-neutral; Obsidian-specific syntax may be preserved in the templates but is not required for the workflow.

## Completion Checklist

- [ ] Target project directory was confirmed and verified.
- [ ] Existing planning files and cache were checked.
- [ ] Plan and roadmap were created or intentionally preserved.
- [ ] Goals, scope, requirements, milestones, risks, and decisions are recorded.
- [ ] Roadmap priorities and release plan are consistent with the project plan.
- [ ] Remaining unknowns and next actions are clearly listed.
