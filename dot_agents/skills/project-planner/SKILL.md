---
name: project-planner
description: Use when planning or scoping work. Keep portable plans synchronized with Linear: ask before creating projects, log decisions as comments, publish progress updates, and track actionable tasks as issues.
version: 1.1.0
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

Use when the user asks to plan, scope, kick off, structure, roadmap, or break down a project. Start from the original prompt, produce a rough outline of the intended plan, obtain outline approval, then develop exactly one section or point at a time. Do not create project artifacts without confirming the target project directory and approved outline.

## Resources

- `references/Plan.md` — detailed project plan template.
- `references/Roadmap.md` — strategic roadmap template.

When invoked from a project, copy both references into `<project>/docs/` as `Plan.md` and `Roadmap.md`. Create `docs/` if needed. Never overwrite existing files without warning and explicit confirmation.

## Workflow

1. **Understand the original prompt.** Extract the user’s apparent goal, audience, desired outcome, constraints, and requested deliverable. Separate what is explicit from assumptions and unknowns. Do not silently fill gaps with commitments.
2. **Draft a rough outline.** Based on the original prompt, propose a concise outline of the sections or points needed to produce the full plan. Typical sections may include goals and success criteria, scope, requirements, architecture or approach, milestones, risks, dependencies, and open questions; tailor the outline to the request rather than forcing every section.
3. **Gate on outline approval.** Present the rough outline, assumptions, and open questions. Ask the user to approve it or request changes. Do not expand sections, create Linear projects/issues/documents/status updates, or scaffold plan artifacts until the outline is approved. Treat approval as approval of structure, not of all details.
4. **Confirm location.** Ask whether the current working directory is the project directory. If not, request an absolute path and verify it exists. Do this before writing local artifacts; location confirmation may happen alongside outline approval, but neither gate may be skipped.
5. **Inspect existing planning state.** Check for existing `docs/Plan.md`, `docs/Roadmap.md`, `.planning` metadata, and any existing Linear project/issue references. Preserve existing work; ask before resetting or replacing it.
6. **Develop one section at a time.** Follow the approved outline in order. For the current section, ask focused questions, propose a draft, identify assumptions and unresolved choices, and get confirmation or revisions. Do not jump ahead or batch unresolved sections. Keep the evolving draft in the conversation and local planning documents; do not use Linear as the drafting workspace.
7. **Synchronize confirmed sections incrementally.** After a section is confirmed, update Linear only when the durable information improves coordination: record decisions as comments, update an existing project summary when direction is clear, publish meaningful progress updates at checkpoints, and create issues only for confirmed actionable, verifiable work. Do not post tentative assumptions, every revision, or unresolved ideas.
8. **Create or reuse external artifacts deliberately.** Before creating a new Linear project, search for a relevant existing project and ask explicitly for approval, stating the proposed name, team, purpose, and why an existing project is insufficient. Prefer reusing the existing project. Outline approval does not authorize project creation or any other external mutation.
9. **Scaffold and synchronize.** After the outline and location gates, copy the bundled templates into the project’s `docs/` directory when needed, adapting only confirmed information. Record confirmed decisions in `Plan.md` and `Roadmap.md`. Before final delivery, reconcile the completed plan against Linear: update stale summaries, ensure only confirmed decisions and executable tasks are represented, and correct misleading or obsolete progress information.
10. **Verify and deliver.** After each Linear mutation, read back the created/updated object and retain its ID/URL. Present the completed documents, Linear project URL, issue IDs/URLs, decision comments, latest progress update, reconciliation changes, unresolved questions, risks, and next steps.

## Outline Approval Gate

The first planning response after understanding the original prompt must be an outline proposal, not a fully elaborated plan. Use this structure:

```text
What I understand:
- Goal:
- Desired outcome:
- Constraints:

Proposed outline:
1. <section or point>
2. <section or point>
...

Assumptions / unknowns:
- <item>

Please approve this outline or tell me what to change. I’ll then work through one section at a time.
```

After approval, maintain a single active section. The section is complete only when its content and important decisions are confirmed or explicitly marked unresolved. User approval of the outline does not authorize a new Linear project or other external mutation; those actions retain their own approval gates.

Linear is intentionally a hybrid record, not the drafting workspace:

- **Before outline approval:** make no Linear mutations.
- **During section review:** synchronize confirmed durable information when it improves coordination; keep drafts, tentative assumptions, and unresolved ideas local.
- **At final delivery:** reconcile Linear against the completed plan and publish the final meaningful progress state.

## Linear Integration Rules

- **Discovery before mutation:** identify the authenticated Linear workspace, team, existing project, issue statuses, and labels before writing.
- **Project creation gate:** never create a new Linear project implicitly. Ask first, stating the proposed name, team, purpose, and why an existing project is insufficient.
- **Decisions → comments:** comments are the canonical Linear decision log. Format: `Decision — <title>\nContext: ...\nDecision: ...\nConsequence: ...`.
- **Progress → status updates:** use status updates for meaningful project-level progress, not a stream of tool calls. Include `Completed`, `In progress`, `Next`, `Blockers/Risks`.
- **Issues → tasks:** create issues only for work that someone can complete and verify. Include outcome, acceptance criteria, dependencies, and suggested owner/state.
- **Incremental synchronization:** after outline approval, synchronize confirmed sections when useful; do not wait for the final plan when collaborators need durable decisions or actionable tasks, but do not expose drafts as facts.
- **Final reconciliation:** before delivery, compare the completed local plan with Linear and correct stale summaries, decisions, tasks, dependencies, and progress updates.
- **Prefer existing artifacts:** update an existing project or issue when it is the correct home. Do not create duplicate projects, phase issues, or “decision” issues.
- **Push back:** recommend a simpler document/comment/status workflow when Linear artifacts would add overhead without improving coordination; explain the tradeoff and wait for the user’s choice.
- **Mutation verification:** after creating or updating a project, issue, comment, document, milestone, or status update, fetch it or list it back and report the returned identifier/URL.

## Guardrails

- Do not plan in the wrong directory.
- Do not skip the rough-outline response or treat an unapproved outline as permission to continue.
- Do not mutate Linear before outline approval.
- Do not fully elaborate the plan before the user approves the outline.
- Do not work through multiple unresolved sections in one turn; keep one active section at a time.
- Do not use Linear as the drafting workspace or publish tentative assumptions as decisions.
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
