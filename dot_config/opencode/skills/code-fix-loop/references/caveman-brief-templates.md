# Caveman Brief Templates for Code Fix Loop

Use these templates when delegating each step to a subagent. All briefs are written in caveman mode: terse tokens, location-problem-fix structure, no greetings, no summaries.

## Brief Format Rules

```
ACTION <files>
  key: value
  key: value
  return: format
```

- `ACTION` is uppercase: `REVIEW`, `FIX`, `TEST`, `REVIEW-FINAL`, etc.
- `<files>` are space-separated paths, no commas unless the path contains one.
- Keys are lowercase, indented two spaces.
- Values stay on one line when possible; lists use `- ` bullets with extra indent.
- `return:` tells the subagent exactly what output format you expect.
- Omit anything the subagent does not need to act.

## Step 1: Initial Review

```
REVIEW <file_paths>
  user: <one-line goal>
  focus: <security|perf|style|all>
  return: file:line findings only. no intro. no summary.
```

Good:
```
REVIEW src/auth.ts src/session.ts
  user: harden auth
  focus: security
  return: file:line findings only. no intro. no summary.
```

Bad — too verbose:
```
Please review these files carefully for security issues that might be present. Let me know what you find and where each issue is located.
```

Bad — missing location:
```
REVIEW src/auth.ts
  focus: security
  return: list problems
```

## Step 2: Ask Which Fixes to Apply

No subagent brief. Present findings grouped by severity and ask:

```
Apply which fixes? (all / list the ones to skip / cancel)
```

## Step 3: Apply Fixes

```
FIX <file_paths>
  findings:
    - <file:line> <problem> → <fix>
    - <file:line> <problem> → <fix>
  do not touch: <files/sections to leave alone>
  return: diff only. changed files. line count.
```

Good:
```
FIX src/auth.ts
  findings:
    - src/auth.ts:23 null guard missing on user object → add early return
    - src/auth.ts:45 hardcoded JWT secret → read from env
    - src/auth.ts:78 race in token refresh → lock or atomic update
  do not touch: src/session.ts, public API surface
  return: diff only. changed files. line count.
```

Bad — missing problem:
```
FIX src/auth.ts
  findings:
    - src/auth.ts:23 fix this
    - src/auth.ts:45 fix this
  return: patch
```

Bad — too much context:
```
The user reviewed src/auth.ts and found three issues. They want you to fix them. The file is part of the authentication pipeline and we need to be careful not to break login for existing users...
```

## Step 4: Ask About Tests

No subagent brief unless the user agrees. If yes:

```
TEST <file_paths>
  - cover: <functions/edge cases if user specified>
  - framework: <detect from project or accept user's>
  - return: pass/fail count. new test file paths.
```

Good:
```
TEST src/auth.ts
  - cover: token refresh race, null user guard
  - framework: vitest
  - return: pass/fail count. new test file paths.
```

Bad — missing what to cover:
```
TEST src/auth.ts
  - framework: vitest
  - return: results
```

## Step 5: Ask About Final Review

No subagent brief unless the user agrees. If yes:

```
REVIEW-FINAL <file_paths>
  prior findings: <list to confirm resolved>
  new issues: any
  return: file:line only. severity prefix.
```

Good:
```
REVIEW-FINAL src/auth.ts
  prior findings: L23 null guard, L45 hardcoded secret, L78 token race
  new issues: any
  return: file:line only. severity prefix.
```

Bad — no prior findings list:
```
REVIEW-FINAL src/auth.ts
  new issues: any
  return: file:line findings
```

## Step 6: Summary

No subagent brief. Report to the user in one line:

```
<file> changed. <N> findings fixed. <M> tests added. Final review <verdict>.
```

## Common Compression Mistakes

1. **Too verbose.** Full sentences, explanations, or greetings bloat the brief and waste tokens.
2. **Missing location.** The subagent needs file:line targets, not abstract problems.
3. **Missing problem.** "Fix this" gives no clue what is wrong.
4. **Including rejected findings.** Only pass findings the user wants fixed.
5. **Mixing conversation history.** Do not include prior subagent responses unless the current step explicitly needs them.
6. **Letting the user override format.** If the user says "just do it," still produce the brief and delegate through the gate.

## Good vs Bad Compression Examples

### Review

| Good | Bad |
|------|-----|
| `REVIEW src/auth.ts`<br>`  user: harden auth`<br>`  focus: security`<br>`  return: file:line only.` | "Please take a look at src/auth.ts. The user is concerned about security. Can you identify any vulnerabilities and tell me where they are?" |

### Fix

| Good | Bad |
|------|-----|
| `FIX src/auth.ts`<br>`  findings:`<br>`    - L23 null guard missing → add check`<br>`  return: diff only.` | "We need to fix src/auth.ts. The reviewer found a null guard issue around line 23. Make sure you don't break anything else in the auth flow and keep the public API stable." |

### Test

| Good | Bad |
|------|-----|
| `TEST src/auth.ts`<br>`  - cover: null guard, token race`<br>`  - framework: vitest`<br>`  return: pass/fail count.` | "Can you write some tests for the auth file? There was this issue with null checks and a race condition. We use vitest I think. Also make sure the tests are thorough." |
