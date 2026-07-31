# Project Planner

Plan new projects with Linear-backed structure. Scaffold reference docs,
create Linear project/issues, guide interactive planning, and deliver a
tracked plan.

## Triggers

Fire on: user says "plan a new project", "scope this", "project kickoff",
"help me plan", "start a project", "I need a plan", "let's plan this out",
"project planning session", "create a project plan", "set up a new project",
"break down this idea", "help me scope", "new project plan", "plan with
linear", "linear plan", "create issues for this plan".

## Template Path

`~/.config/opencode/templates/project-planner/docs/`

## Workflow

### Phase 1 — Setup

1. Determine project directory:
   - Ask: "Is CWD your project directory?"
   - Yes -> use CWD. No -> ask for absolute path. Validate it exists.
2. Scaffold reference docs:
   - Copy `Plan.md` and `Roadmap.md` from template to `<project>/docs/`.
   - Create `docs/` if missing. Report what was created.

### Phase 2 — Linear Structure

1. **Select team** — call `linear_list_teams`, present options, let user pick.
2. **Create Linear Project** — ask for project name (default: "<name> Plan"),
   call `linear_save_project` with name, summary, team. Note project ID.
3. **Ensure labels** — check `linear_list_issue_labels` for `phase`,
   `decision`, `blocker`. Create missing ones via `create_issue_label`.
4. **Create phase Issues** — propose 2-4 phases, get confirmation, then
   call `linear_save_issue` for each with labels: ["phase"] and state: backlog.
   Note returned issue IDs.
5. **Create Findings Document** — `linear_save_document` in the project
   with title "Findings — <name>".
6. **Post kickoff** — `linear_save_status_update` (project, health=onTrack,
   body summarizing the plan).
7. **Cache** — store `.planning` state (project ID, phase issue IDs, etc.)
   so the skill can resume later.

### Phase 3 — Plan Interactively

For each topic, update BOTH the reference docs AND Linear:

A. **Goals & Summary** — ask purpose/audience/goals. Update Plan.md.
   Update Linear project summary. Log decisions as comments on phase-1
   issue with `decision` label.

B. **Scope** — in-scope vs out-of-scope. Update Plan.md. Create Linear
   sub-issues under the relevant phase issue. Wire `blockedBy` for
   dependencies.

C. **Stack & Architecture** — technical choices. Update Plan.md (Stack
   table, Architecture). Add findings to the Linear Document. Comment
   on the phase issue with arch decisions.

D. **Milestones & Timeline** — break into milestones, assign target dates.
   Update phase issue target dates in Linear. Update Plan.md Timeline table.
   Update Roadmap.md (Now/Next/Later, Release Plan).

E. **Risks** — blockers. Update Plan.md Risks table. Create `blocker`
   issues in Linear with `blockedBy` relations.

F. **Iterate** — after each section, ask: "Ready to move on or refine?"

### Phase 4 — Deliver

1. Present completed Plan.md and Roadmap.md.
2. Present Linear project URL.
3. List phase issues with IDs and states.
4. Summarize key decisions and next steps.
5. Suggest follow-ups: review issues, start dev on phase 1, add granular
   sub-issues.

## Anti-Patterns

- Do NOT skip the directory check — wrong directory is the most common
   error. Always ask.
- Do NOT create Linear issues without confirmation on phase breakdown
   — phases define the project structure. Get buy-in first.
- Do NOT overwrite existing `.planning` cache without warning — the user
   may have an active plan. Ask before resetting.
- Do NOT hardcode workflow state names — teams can rename states. Fetch
   dynamically via `linear_list_issue_statuses`.
- Do NOT create labels that already exist — check first.
- Do NOT plan in isolation — every decision must be confirmed before
   creating artifacts.
- Do NOT skip Roadmap.md — it's the strategic overlay. Without it, the
   plan lacks time horizon and prioritization.
- Do NOT create dozens of issues in one pass — start with 2-4 phase
   issues. Granular tasks can be added during execution.
