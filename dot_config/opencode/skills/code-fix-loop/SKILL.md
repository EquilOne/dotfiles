---
name: code-fix-loop
description: >
  Human-in-the-loop review → fix → test cycle. Conventional review-fix cycle
  for code review then fix workflows. Orchestrates coder, review, and generate-test
  subagents with caveman-compressed context. MUST use when user says "review and fix"
  or "review then fix". Also use when user says "review cycle", "review loop",
  "code fix loop", "/review-fix", "review before changes", or asks to review
  findings before changes and then apply fixes. Always pauses for user confirmation
  between steps. Does not auto-loop, does not auto-apply fixes from review findings.
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

## Progressive Disclosure

This skill loads the caveman skill at start (stays in context). For detailed brief templates:

**MANDATORY:** When writing a caveman brief for a subagent delegation, read [`references/caveman-brief-templates.md`](references/caveman-brief-templates.md) for format rules, good vs bad examples, and common compression mistakes.

**Do NOT load** the brief templates when: the user has already provided the brief text, or you've loaded it earlier in this session.

**When to load additional skills:**
- If the code spans multiple unfamiliar languages → consider loading `explain-code` for the review brief
- If the fix involves config files → the `customize-opencode` skill may provide schema context
- If tests need a specific framework → let the `generate-test` subagent detect it

## Pattern: Process

This skill follows the Process pattern because the review-fix-test cycle is a phased workflow:
- **Phase 1:** Review (delegate to review subagent)
- **Phase 2:** Triage (user selects which findings to fix)
- **Phase 3:** Fix (delegate to coder subagent)
- **Phase 4:** Test (delegate to generate-test subagent, optional)
- **Phase 5:** Final review (confirm fixes resolved findings, optional)
- **Phase 6:** Summary (report what changed)

Checkpoints between every phase — user confirmation required to advance. Medium freedom: the 6-step sequence is fixed, but the caveman briefs within each step are adaptive. The human-in-the-loop gate is the core safety mechanism that distinguishes this from an automated loop.

**Why Process, not Tool:** A Tool pattern requires exact scripts and low freedom — but the caveman briefs are adaptive templates, not fixed scripts. The skill's value isn't "run this exact command" (Tool); it's "orchestrate these subagents in this order with these confirmation gates" (Process). The caveman compression is a MEDIUM-freedom mechanism: it constrains format (terse, location-problem-fix) but adapts content per finding. This is structurally Process, not Tool.

**Why Process, not Mindset:** Mindset skills transfer thinking patterns with no workflow (~50 lines, high freedom). This skill's value is the WORKFLOW itself — the 6-step sequence with gates is the expert knowledge, not just a thinking frame. Remove the workflow and you have nothing; that's the signature of Process, not Mindset. The human-in-the-loop gate is the non-obvious structural insight: it converts an automated loop (which would be a Tool) into a Process by inserting judgment checkpoints that require human confirmation.

**Why Process, not Navigation:** Navigation skills route to sub-files for distinct scenarios (~30 lines). This skill has ONE scenario (review-fix-test) with a fixed sequence — there's nothing to navigate between. The 6 steps aren't alternative routes; they're a mandatory pipeline.

**Pattern mapping:**
- Phased workflow: 6 steps with mandatory confirmation gates ✓
- Checkpoints: User confirms scope, findings, tests, and final review at each gate ✓
- Medium freedom: Caveman briefs constrain format, adapt content ✓
- ~247 lines (within Process range) ✓
- Non-obvious insight: The human-in-the-loop gate is what makes this Process not Tool ✓

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

## Thinking Frame

Before starting a review-fix-test cycle, ask:
- **Scope:** Is this a single-file fix or a cross-cutting refactor? Single-file may not need the full loop.
- **Risk:** If the fix is wrong, what breaks? High-risk changes (auth, payments, data migration) always warrant the full loop; low-risk (typo, comment) don't.
- **Testability:** Can the fix be verified by tests? If not, the loop degrades to review-only.
- **Stakeholders:** Who needs to review the diff before merge? The loop's confirmation gates exist to surface this.
**Freedom calibration:** The 6-step workflow is fixed (low freedom) because skipping a gate risks unreviewed changes. Within each step, the caveman briefs are adaptive (medium freedom) — the model chooses what to include based on the finding. The user confirmation gates are the lowest-freedom element: they cannot be skipped or automated.

**Expert insight:** The most common loop failure is not a bad fix — it's a bad triage. When the user selects "all" findings to fix without reading them, the coder gets a mixed-bag of severity levels and the fix quality drops. Always present findings grouped by severity (critical → important → minor) and recommend fixing critical first, even if the user said "all."

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

### Why Loops Fail

Review-fix-test loops have three characteristic failure modes that only experience reveals:

1. **Finding drift:** The coder "fixes" a finding by reframing it as a non-issue rather than addressing it. Detect by checking if the diff actually changes the flagged line.
2. **Test theater:** Tests pass but don't cover the edge case that triggered the finding. Detect by asking: "Does this test fail if I revert the fix?"
3. **Scope creep via findings:** Each review cycle generates new findings, creating an endless loop. Detect by tracking finding count per cycle — if it's not converging toward zero, stop and reset scope.

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
