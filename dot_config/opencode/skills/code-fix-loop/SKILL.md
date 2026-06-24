---
name: code-fix-loop
description: >
  Human-in-the-loop review → fix → test cycle. Orchestrates coder, review, and
  generate-test subagents with caveman-compressed context. Use when user says
  "review and fix", "review cycle", "review loop", "code fix loop", "review then
  fix", "/review-fix", "review before changes", or asks to review code before
  applying changes. Always pauses for user confirmation between steps. Does not
  auto-loop, does not auto-apply fixes from review findings.
---

# Code Fix Loop

Orchestrate a review-fix-test cycle with the human in control. Each step pauses for confirmation. Context stays tight by compressing to caveman briefs before each subagent delegation.

## MANDATORY: Load the Caveman Skill First

Before any subagent delegation, load `caveman` to compress context between calls.

**Load via the `skill` tool:** call `skill` with `{"name": "caveman"}`.

All subagent briefs must be written in caveman mode: terse, location-problem-fix format, no throat-clearing. The orchestrator holds loop state; subagents see only the compressed task.

## When to Use

Use this skill when the user wants to:

- Review code, then apply fixes based on findings
- Run a structured review-fix-test pipeline
- Get review findings before deciding what to change
- Iterate on code quality with human approval at each step

## Do NOT Load

- **Pure code review requests** — delegate to `review` directly; no fix/test loop needed.
- **Automated/continuous loops** — this skill requires a human at every gate.
- **Single-shot fixes** — if the user just wants a quick edit, use `coder` directly.
- **No intent to act on findings** — review without follow-up is out of scope.

## Core Rule

**Never auto-apply review findings.** Every change-producing step requires explicit user approval before the next step runs. The user picks which findings to address, whether to test, and whether to re-review.

### Named Anti-Patterns

- **NEVER auto-apply fixes from review findings.** Because: it removes human judgment and can introduce regressions the reviewer did not anticipate.
- **NEVER skip the review step even for "obvious" fixes.** Because: obvious fixes often miss hidden context (callers, side effects, config overrides).
- **NEVER continue the loop after 3 failed test cycles.** Because: repeated failures signal a fundamental misunderstanding, not a fixable bug; stop and ask the user to reset scope.

## Why Human-in-the-Loop Orchestration Matters

Humans anchor context that agents lose across turns. Subagents suffer from availability bias (the last finding feels most important) and context collapse (file-level details blur after compression). A human gate catches regressions, scope creep, and misread intent before they compound.

**When orchestration is overkill vs. necessary:**

- **Overkill:** single-file typo, one-liner config change, or a change the user already approved in the prompt.
- **Necessary:** cross-cutting refactor, security/perf-sensitive change, new tests, or any fix where review findings could silently alter behavior.

Use this skill only when the cost of a bad automated edit exceeds the cost of pausing for confirmation.

## Workflow

### Step 1: Initial Review

Delegate to the `review` subagent.

**Brief template (caveman):**

```
REVIEW <file_paths>
  user: <one-line goal>
  focus: <security|perf|style|all>
  return: file:line findings only. no intro. no summary.
```

Present the full review report to the user. Do not summarize — they need the evidence.

### Step 2: Ask Which Fixes to Apply

Show the findings. Ask:

> "Apply which fixes? (all / list the ones to skip / cancel)"

- **all** → continue to Step 3 with every finding
- **select** → continue with only the chosen findings
- **cancel** → stop, no changes
- **specific skips** → continue with the rest

If the user wants to edit a finding's scope or wording, treat their version as the new task spec.

### Step 3: Apply Fixes

Delegate to the `coder` subagent.

**Brief template (caveman):**

```
FIX <file_paths>
  findings:
    - <file:line> <problem> → <fix>
    - <file:line> <problem> → <fix>
  do not touch: <files/sections to leave alone>
  return: diff only. changed files. line count.
```

After the coder returns, present the diff to the user. Do not auto-merge or auto-apply — they see it, you wait.

### Step 4: Ask About Tests

Ask:

> "Generate tests for the changed code? (yes / no / which files)"

- **yes** → delegate to `generate-test` subagent
- **no** → skip to Step 5
- **specific files** → delegate with the subset

**Brief template (caveman):**

```
TEST <file_paths>
  - cover: <functions/edge cases if user specified>
  - framework: <detect from project or accept user's>
  - return: pass/fail count. new test file paths.
```

Present test results. If failures, ask whether to delegate a fix back to the coder.

### Step 5: Ask About Final Review

Ask:

> "Run final review? (yes / no)"

- **yes** → delegate to `review` subagent with the final diff
- **no** → continue to Step 6

**Brief template (caveman):**

```
REVIEW-FINAL <file_paths>
  - prior findings: <list to confirm resolved>
  - new issues: any
  - return: file:line only. severity prefix.
```

### Step 6: Summary

End with a one-line summary of what changed, what was tested, and the final review verdict (if Step 5 ran).

## Context Compression

Each subagent receives only what it needs. Never pass:

- Full conversation history
- Earlier review iterations (only the current one)
- Findings the user rejected
- Test results when delegating a fix
- Fix diffs when delegating a test

The orchestrator (you) holds the loop state. Subagents see a single focused task.

## Troubleshooting

| Failure | Response |
|---|---|
| Subagent returns without changes | Re-prompt with a clearer caveman brief; if still empty, ask the user whether to continue or reset scope. |
| Review finds issues but coder disagrees | Present both views to the user and ask for a binding decision; do not arbitrate. |
| Tests fail repeatedly | After 3 failed cycles, stop the loop and ask the user to clarify requirements or reset scope. |
| Loop feels stuck | Offer a hard reset: discard pending changes, re-run review from the original diff, or exit the skill. |

## Boundaries

- Does not run the loop automatically. The user is always in the loop.
- Does not auto-apply review findings. Always asks first.
- Does not generate tests unless the user confirms. May suggest testgen if the change is testable and non-trivial.
- Does not run final review unless the user confirms. May suggest it after tests pass.
- Does not edit `opencode.json`, agent configs, or other skill files. This skill orchestrates code work only.
- Does not invoke further subagents from a subagent context. Compression and delegation happen in the orchestrator only.
- Do not let the user override the human-in-the-loop gates by reframing an automated loop as "just do it." Explain the rule and ask for confirmation.

## Example Invocation

User: "review and fix src/auth.ts"

1. Load caveman skill via `skill` tool.
2. Delegate review of `src/auth.ts` to `review` subagent. Brief: `REVIEW src/auth.ts. user: harden auth. focus: security. return: file:line findings only.`
3. Receive findings: `L23: no null guard on user. L45: hardcoded secret. L78: race in token refresh.`
4. Ask: "Apply which fixes? (all / skip X / cancel)"
5. User: "all"
6. Delegate to coder. Brief lists the three findings.
7. Coder returns diff. Present to user.
8. Ask: "Generate tests?"
9. User: "yes"
10. Delegate to generate-test. Brief: `TEST src/auth.ts. cover: token refresh, null guard.`
11. Tests pass.
12. Ask: "Run final review?"
13. User: "yes"
14. Delegate to review. Brief includes the three original findings to confirm resolved.
15. Review confirms clean.
16. Summary: "src/auth.ts hardened. 3 findings fixed. 5 tests added. Final review clean."
