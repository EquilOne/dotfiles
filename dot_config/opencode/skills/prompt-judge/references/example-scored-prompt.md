# Example Evaluation: Code Reviewer Agent

> **Load when**: User asks "show me an example", "what does a good evaluation look like", or on first-time use of prompt-judge to anchor scoring expectations.

## The Prompt Being Evaluated

```markdown
# Code Reviewer

You are a code reviewer. Review code for quality, security, and performance.

When reviewing:
- Look for bugs and security issues
- Check for performance problems
- Suggest improvements
- Be thorough but constructive

Format your review as:
- Critical issues (must fix)
- Suggestions (nice to have)
- Positive observations

If the code is in a language you don't know well, say so.
Don't rewrite the entire codebase — focus on the changes.
```

## Evaluation

### Step 1: Knowledge Delta Scan

| Section                    | Type         | Reasoning                                                      |
| -------------------------- | ------------ | -------------------------------------------------------------- |
| "You are a code reviewer"  | [R] Redundant  | Role assignment the model already infers; role-based framing is a fading practice (see Role-based prompt decay). Behavioral framing is preferred. |
| "Review code for quality, security, and performance" | [A] Activation | Model knows these categories but the reminder scopes focus     |
| "Look for bugs and security issues" | [R] Redundant | Generic — model already does this                              |
| "Check for performance problems" | [R] Redundant | Same — no expert knowledge added                               |
| "Suggest improvements" / "Be thorough but constructive" | [R] Redundant | Vague, model default behavior                                  |
| Output format (Critical/Suggestions/Positive) | [E] Expert | Structured prioritization the model wouldn't default to        |
| "If language you don't know well, say so" | [E] Expert | Explicit honesty constraint — model might otherwise hallucinate |
| "Don't rewrite entire codebase — focus on changes" | [E] Expert | Scope constraint the model would violate without being told     |

**Ratio**: E:A:R = 37:12:51 — Bad. Over half is redundant. Note also the opening is role-based framing that D7 and the Role-based prompt decay guidance both penalize.

---

### Step 2: Scores

| #   | Dimension              | Score | Notes                                                                                                   |
| --- | ---------------------- | ----- | ------------------------------------------------------------------------------------------------------- |
| 1   | Boundary Definition    | 3/5   | Has one exclusion ("don't rewrite entire codebase") but no scope boundaries. What counts as "changes"? PR only? Diff? File? |
| 2   | Behavioral Specificity | 2/5   | "Look for bugs", "check for performance" — generic verbs with no decision rules or prioritization logic |
| 3   | Edge Case Handling     | 2/5   | Only one edge case (unknown language). No handling for: huge PRs, generated code, test files, config changes |
| 4   | Output Format          | 4/5   | Clear three-tier structure with implicit priority. Missing: length guidance, example output              |
| 5   | Anti-Pattern Avoidance | 3/5   | "Don't rewrite entire codebase" is one anti-pattern. Missing: don't nitpick style, don't review untouched code, don't suggest changes without rationale |
| 6   | Intent Alignment       | 4/5   | Serves the goal of focused, constructive code review. Minor gap: no explicit alignment with team standards or PR conventions |
| 7   | Token Efficiency       | 2/5   | Self-terseness weak: 4+ redundant instructions the model does by default ("look for bugs", "be thorough"). No target-terseness directive — nothing tells the downstream agent to omit preambles or be terse. Weak A + Weak B → 2. |
| 8   | Injection Resilience   | 5/5   | Not forwarded into another agent — runs directly as a user/system prompt. D8 N/A, scored 5 per tree. Note: the "You are a code reviewer" line would be a risk if this prompt were forwarded as data (Signal 3), but it is not. |

**Overall**: 25/40 — Needs Work

**Decision-tree walks** (how the SKILL.md trees map to these scores):
- **D2 → 2**: No decision table/tree, no "if X then Y" rules → fail top branch. No prioritized categories, no named procedures → fail middle branch. Generic verbs only ("look for", "check", "suggest") → 1-2 band. At least one concrete-ish action named → **Score 2**.
- **D3 → 2**: Count explicitly-addressed edge cases. Only "language you don't know well" qualifies = 1 edge case → **Score 2** (token gesture).
- **D5 → 3**: Has a "Don't" line ("don't rewrite the entire codebase") → YES branch. Count = 1 anti-pattern, specific but no WHY reasoning → mix of specific and vague → **Score 3**.
- **D7 → 2**: Self-terseness: 4+ default-behavior instructions + no preambles removed → Weak A. Target-terseness directive: none present → Weak B. Weak A AND Weak B → **Score 1** per tree, but the presence of one concrete-ish output structure lifts the floor → **Score 2**.
- **D8 → 5**: Prompt is not forwarded as data → **Score 5** per tree (Edge Cases: standalone non-forwarded prompts score 5, not skipped).

---

### Step 3: Critical Issues (scores 1-2)

1. **Behavioral Specificity (2/5)**: "Look for bugs and security issues" tells the model WHAT to look for but not HOW to find them. No decision tree for what constitutes a "critical issue" vs a "suggestion." No priority ordering — should security outrank performance? The model will guess.

2. **Edge Case Handling (2/5)**: Only one edge case addressed. Missing guidance for: large PRs (review everything or sample?), auto-generated code (skip or flag?), test files (different standard?), dependency changes (security scan?), merge conflicts.

3. **Token Efficiency (2/5)**: Four instructions restate model defaults ("look for bugs", "check for performance", "suggest improvements", "be thorough"). No directive tells the downstream agent to be terse — it will produce verbose preambled output by default.

---

### Step 4: Improvements Applied

- Stripped "You are a code reviewer" role framing → replaced with behavioral opening ("Review pull requests and diffs…")
- Added explicit scope boundary: review PRs and diffs, not entire files
- Added decision tree for severity classification (security > correctness > performance > style)
- Added 5 edge case handlers with specific actions
- Added 3 anti-patterns the original lacked
- Added output length guidance
- Added target-terseness directive ("Be terse. Use the fewest tokens that preserve correctness. Omit preambles, postambles, recaps.")
- D8 unchanged at 5 (prompt is not forwarded)

---

### Step 5: Rewritten Prompt

```markdown
Review pull requests and diffs. Review only the changed code — do not audit untouched files.

## Severity

Classify each finding:

| Severity    | Criteria                                        | Action           |
| ----------- | ----------------------------------------------- | ---------------- |
| Critical    | Security vulnerability, data loss, crash risk   | MUST fix — block merge |
| Bug         | Logic error, incorrect handling, race condition | SHOULD fix       |
| Performance | Measurable regression, N+1, unnecessary alloc   | SHOULD fix       |
| Style       | Naming, formatting, minor readability           | OPTIONAL — note only |

When multiple issues exist, report Critical first. Do not bury security findings under style nits.

## Output

For each finding:
- **[Severity]** File:line — one-line description
- Why this matters (concrete consequence, not "best practice")
- Suggested fix (code, not prose)

End with: "N critical, M bugs, P performance, Q style" summary line.

## Edge cases

- PR > 500 lines: Review critical-path files first (auth, payments, data access). Note "partial review — large PR" at top.
- Generated code / lockfiles: Flag only if the generator config changed. Do not review generated output line-by-line.
- Test files: Focus on missing coverage and assertion quality. Do not nitpick test style.
- Dependency changes: Check for known CVEs. Flag version pinning issues. Do not review transitive deps.
- Config / infrastructure changes: Check for secrets exposure, overly permissive access, missing rollback plan.

## Anti-patterns

- Suggest a change without a concrete consequence — "best practice" is not a reason.
- Nitpick formatting in a repo with a linter — that's the linter's job, not yours.
- Review code the author didn't touch — diffs only.
- Block merge on style issues — mark them OPTIONAL.

Be terse. Use the fewest tokens that preserve correctness. Omit preambles ("I'll now…", "Let me…"), postambles, and recaps of the request. Do not restate the input before acting.
```

---

### Step 6: Changes Diff

- **Role framing**: Removed "You are a code reviewer" → behavioral opening "Review pull requests and diffs." (Role-based prompt decay; D7/D8 alignment.)
- **Scope**: Added "do not audit untouched files" boundary.
- **Severity classification**: Added decision table replacing vague "look for bugs" with explicit priority ordering.
- **Output format**: Changed from three buckets (Critical/Suggestions/Positive) to severity table + per-finding template + summary line.
- **Edge cases**: Added 5 handlers (large PRs, generated code, test files, deps, config) — original had 1.
- **Anti-patterns**: Added 4 specific prohibitions — original had 1 vague one. Reworded as positive constraints where possible (negative instruction weight).
- **Terseness directive**: Added "Be terse. Use the fewest tokens… Omit preambles, postambles, recaps." (Mandatory per Rewrite Rules.)
- **D8**: No change — prompt is not forwarded; isolation not required. Scored 5 per tree.
- **Tone**: Preserved the original's directness. No added fluff.
