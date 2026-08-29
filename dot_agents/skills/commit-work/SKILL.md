---
name: commit-work
description: "Hands-off git commit workflow executed end-to-end by the `commit` subagent. Use when the user asks to commit, stage changes, craft a commit message, split work into commits, says 'run commit-work' or 'run skill' in a working directory, or explicitly loads this skill. Invocation itself is the commit instruction: the primary immediately delegates and does not ask setup questions or run git."
---

# Commit work

## Goal
Make commits that are easy to review and safe to ship:
- only intended changes are included
- commits are logically scoped (split when needed)
- commit messages describe what changed and why

## Hands-off delegation

Invoking this skill is the instruction to commit the current working tree. The primary immediately delegates via the task tool (subagent type `commit`); it does not wait for a separate commit request.

- The `commit` subagent is the **EXECUTOR**: it runs everything end-to-end (inspect, decide boundaries, stage, review, message, verify, commit) and holds the git + verification permissions.
- The primary is **HANDS-OFF**: it does not re-read or explain this skill, ask setup questions, inspect or run git, or decide commit boundaries. The executor derives commit count, boundaries, conventions, and checks from the working tree.

The primary acts again only if the executor returns a COMMIT PLAN:

- If the plan is sound → resume the task with its task_id, instructing "execute the plan as presented".
- If the plan needs changes → resume the task with the corrected plan or instructions.
- If a human decision is required (ambiguous boundaries, secrets, scope judgment) → surface the plan to the user and resume only with their decision.

Never redo the executor's work or route its git work to another subagent. Everything below is the executor's workflow.

## Thinking Frame

Before committing, ask:

- **Audience:** Who reads this message? (maintainer doing code review? future archaeologist in `git blame`? CI bot parsing conventional commits?)
- **Atomicity:** Does this diff do ONE thing? If you need "and" in the subject, split the commit.
- **Reversibility:** Can `git revert` on this commit produce a clean rollback? If not, the commit boundary is wrong.
- **Convention:** Does the project use Conventional Commits? Check the last 10 commits — match their style. (The executor checks `git log --oneline -10` itself.)

## Workflow (executor checklist)
1) Inspect the working tree
   - `git status`
   - `git diff --stat`
   - `git diff`
   - `git log --oneline -10`
2) Decide commit boundaries (split if needed)
   - Split by: feature vs refactor, subsystem, formatting vs logic, tests vs prod code, dependency bumps vs behavior.
3) **PLAN GATE**
   - Multiple unrelated changes, intra-file mixed hunks, or any complicated situation (merge/rebase in progress, secrets/tokens in the diff, ambiguous intent, very large diff) → stage NOTHING, return a COMMIT PLAN (format below) and stop; continue only on approval.
4) Stage only the plan's next commit
   - `git add <paths>` (whole files). Never `git add -p` here — interactive; propose combined-or-deferred in the plan instead.
5) Review what will be committed
   - `git diff --cached`
   - Sanity checks: no secrets/tokens, no accidental debug logging, no unrelated formatting churn.
6) Describe the staged change in 1-2 sentences (before writing the message)
   - "What changed?" + "Why?"
   - If you cannot describe it cleanly, the boundary is wrong → go back to step 2.
7) Write the commit message
   - Conventional Commits: types feat|fix|docs|style|refactor|test|chore; imperative subject ≤72 chars; scopes only when the repo has >3 subsystems, primary subsystem only, never multi-scope; breaking changes get `!` after the type plus a `BREAKING CHANGE:` footer; body explains why (the diff shows what), one paragraph max.
   - For multi-line messages read [`references/commit-message-template.md`](references/commit-message-template.md). **Do NOT load** for single-line commits.
8) Commit NON-interactively
   - `git commit -m "<subject>" -m "<body>"` (multiple `-m` flags). NEVER `git commit -v` (opens an editor — hangs in a subagent).
9) Verify
   - Run the repo's fastest meaningful check (test, lint, or build) before each commit; if none exists or it isn't permitted, run `git diff --check` and report what was skipped.
10) Repeat until the working tree is clean, then report.

## COMMIT PLAN format

The executor's final message when gating:

```
COMMIT PLAN — awaiting approval
1. type(scope): subject — paths included — why
2. ...
Nothing staged, nothing committed.
```

Each line must describe exactly one commit. If a line needs "and", it must be split.

## Deliverable

- Executor report after executing: `Committed N commit(s):` — per commit, short hash + subject + one-line what/why — then `Checks run:` (command + result, or "none — repo has no test/lint/build command", or "skipped: <reason>").
- For plan returns, the deliverable is the COMMIT PLAN itself and nothing staged/committed.

## NEVER Do

- **NEVER commit secrets, tokens, or API keys.** Even if removed in the next commit, they remain in history. Use `git filter-branch` or `BFG Repo-Cleaner` if this happens — don't just "fix it later."
- **NEVER mix unrelated changes in one commit.** A commit that renames a function AND fixes a bug AND updates dependencies is impossible to review or revert cleanly. If you can't describe it in one sentence, it's too big.
- **NEVER use vague messages** ("fix stuff", "wip", "updates", "misc changes"). Future-you (and every reviewer) needs to know *what* changed and *why* without opening the diff. The subject line alone should be meaningful in `git log --oneline`.
- **NEVER skip `git diff --cached` before committing.** The staging area can contain surprises — partial hunks from `git add -p`, accidentally staged files, or leftover debug code. Always review what will actually be committed.
- **NEVER commit formatting changes alongside logic changes.** A commit that reformats 50 files AND changes one function hides the real change in noise. Split formatting into its own commit so reviewers can skip it.
- **NEVER force-push shared branches without coordination.** `git push --force` rewrites history that others may have based work on. Use `--force-with-lease` at minimum, and communicate first.
- **NEVER use interactive git (`git add -p`, `git commit -v`) in this role.** The executor runs non-interactively; mixed hunks are surfaced in the plan, never decided unilaterally.
- **NEVER commit before plan approval when a plan was returned.**

## Edge Cases

| Situation                              | Action                                                                                                                       |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Merge conflict in progress             | Resolve conflicts first, then commit. Don't commit conflict markers (`<<<<<<<`).                                               |
| Detached HEAD state                    | Create a branch before committing: `git checkout -b <branch-name>`. Commits on detached HEAD are lost if you switch branches.  |
| Pre-commit hook fails                  | Read the hook output. Fix the issue (lint, format, test). Don't use `--no-verify` unless you're certain the hook is wrong.     |
| Nothing to commit (working tree clean) | Nothing to do. Don't create empty commits unless the team convention requires them (e.g., merge commits).                    |
| Need to amend the last commit          | `git commit --amend -m "..." ...` — non-interactively (`-m` flags, no editor). For staged file changes, `git commit --amend --no-edit`. Only amend if not yet pushed. |
| Interactive rebase needed              | Not this skill's scope. Suggest `git rebase -i HEAD~N` and let the user decide.                                                |
| Plan returned                          | The executor's final message IS the COMMIT PLAN; nothing staged or committed. The primary resumes the task (same task_id) to approve, revise, or surface to the user. |

## Expert Commit Knowledge

- **Scope decisions:** Only use Conventional Commit scopes when the repo has >3 subsystems (e.g., `feat(auth):`, `fix(parser):`). Without distinct subsystems, scopes add noise. Multi-scope commits are a signal to split: use the PRIMARY subsystem only; never `feat(auth,api):` — split into separate commits instead.
- **Squash merge behavior:** Squash merges collapse N commits into 1 and discard intermediate messages. If the branch will be squash-merged, the final commit message must be self-contained; never reference "as discussed in commit 3 of 4."
- **Amend vs new commit vs rebase:** Amend if pushing to a PR within 5 minutes and no one pulled. Create a new commit if the branch is shared. Use interactive rebase (`git rebase -i`) if cleaning up >3 messy commits before merge.
- **Co-author attribution:** Add `Co-authored-by:` trailers only when a human or distinct agent contributed meaningfully. Don't add co-authorship for every tool invocation or automated check.

## Pattern: Process

This skill follows the Process pattern:

- **Multi-step workflow:** inspect → decide boundaries → stage → message → verify → commit.
- **Checkpoints:** confirm scope and content at each step before proceeding; enforce the plan gate — plans are returned to the primary for approval at every boundary decision.
- **Medium freedom:** conventions like Conventional Commits exist, but judgment is required for split decisions, scope choice, and message framing.