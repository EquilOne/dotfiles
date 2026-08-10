---
name: commit-work
description: "Conventional Commits, git message, split commits, and staging for high-quality git commits. Use when the user asks to commit, craft a commit message, stage changes, or split work into multiple commits. MUST use when the user asks to commit, craft a commit message, or split work into multiple commits."
---

# Commit work

## Goal
Make commits that are easy to review and safe to ship:
- only intended changes are included
- commits are logically scoped (split when needed)
- commit messages describe what changed and why

## Inputs to ask for (if missing)
- Single commit or multiple commits? (If unsure: default to multiple small commits when there are unrelated changes.)
- Commit style: Conventional Commits are required.
- Any rules: max subject length, required scopes.

## Thinking Frame

Before committing, ask:

- **Audience:** Who reads this message? (maintainer doing code review? future archaeologist in `git blame`? CI bot parsing conventional commits?)
- **Atomicity:** Does this diff do ONE thing? If you need "and" in the subject, split the commit.
- **Reversibility:** Can `git revert` on this commit produce a clean rollback? If not, the commit boundary is wrong.
- **Convention:** Does the project use Conventional Commits? Check the last 10 commits — match their style.

## Workflow (checklist)
1) Inspect the working tree before staging
   - `git status`
   - `git diff` (unstaged)
   - If many changes: `git diff --stat`
2) Decide commit boundaries (split if needed)
   - Split by: feature vs refactor, backend vs frontend, formatting vs logic, tests vs prod code, dependency bumps vs behavior changes.
   - If changes are mixed in one file, plan to use patch staging.
3) Stage only what belongs in the next commit
   - Prefer patch staging for mixed changes: `git add -p`
   - To unstage a hunk/file: `git restore --staged -p` or `git restore --staged <path>`
4) Review what will actually be committed
   - `git diff --cached`
   - Sanity checks:
     - no secrets or tokens
     - no accidental debug logging
     - no unrelated formatting churn
5) Describe the staged change in 1-2 sentences (before writing the message)
   - "What changed?" + "Why?"
   - If you cannot describe it cleanly, the commit is probably too big or mixed; go back to step 2.
6) Write the commit message
   - Primary path: delegate drafting to the `commit` subagent via the task tool (subagent type `commit`). It runs `git diff --cached` itself and returns only the final message — pass no diff context. When the subagent drafted the message, the mandatory template read below can be skipped: the subagent enforces the same format (subject ≤72 chars, imperative, body what/why, BREAKING CHANGE footer).
   - Fallback path (subagent unavailable): draft it yourself with Conventional Commits (required):
     - `type(scope): short summary`
     - blank line
     - body (what/why, not implementation diary)
     - footer (BREAKING CHANGE) if needed
   - Prefer an editor for multi-line messages: `git commit -v`
   - **MANDATORY when drafting multi-line messages yourself**: read [`references/commit-message-template.md`](references/commit-message-template.md) for the full Conventional Commits template with scope examples and breaking-change footer format. **Do NOT load** for single-line commits.
7) Run the smallest relevant verification
   - Run the repo's fastest meaningful check (unit tests, lint, or build) before moving on.
8) Repeat for the next commit until the working tree is clean

## Deliverable
Division of labor: the `commit` subagent returns only the commit message; the orchestrating agent assembles the full deliverable:
- the final commit message(s)
- a short summary per commit (what/why)
- the staging/review/verify commands actually run (at minimum: `git diff --cached`, plus any tests run)

## NEVER Do

- **NEVER commit secrets, tokens, or API keys.** Even if removed in the next commit, they remain in history. Use `git filter-branch` or `BFG Repo-Cleaner` if this happens — don't just "fix it later."
- **NEVER mix unrelated changes in one commit.** A commit that renames a function AND fixes a bug AND updates dependencies is impossible to review or revert cleanly. If you can't describe it in one sentence, it's too big.
- **NEVER use vague messages** ("fix stuff", "wip", "updates", "misc changes"). Future-you (and every reviewer) needs to know *what* changed and *why* without opening the diff. The subject line alone should be meaningful in `git log --oneline`.
- **NEVER skip `git diff --cached` before committing.** The staging area can contain surprises — partial hunks from `git add -p`, accidentally staged files, or leftover debug code. Always review what will actually be committed.
- **NEVER commit formatting changes alongside logic changes.** A commit that reformats 50 files AND changes one function hides the real change in noise. Split formatting into its own commit so reviewers can skip it.
- **NEVER force-push shared branches without coordination.** `git push --force` rewrites history that others may have based work on. Use `--force-with-lease` at minimum, and communicate first.

## Edge Cases

| Situation                              | Action                                                                                                                       |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Merge conflict in progress             | Resolve conflicts first, then commit. Don't commit conflict markers (`<<<<<<<`).                                               |
| Detached HEAD state                    | Create a branch before committing: `git checkout -b <branch-name>`. Commits on detached HEAD are lost if you switch branches.  |
| Pre-commit hook fails                  | Read the hook output. Fix the issue (lint, format, test). Don't use `--no-verify` unless you're certain the hook is wrong.     |
| Nothing to commit (working tree clean) | Nothing to do. Don't create empty commits unless the team convention requires them (e.g., merge commits).                    |
| Need to amend the last commit          | `git commit --amend` for message changes. For staged file changes, `git commit --amend --no-edit`. Only amend if not yet pushed. |
| Interactive rebase needed              | Not this skill's scope. Suggest `git rebase -i HEAD~N` and let the user decide.                                                |

## Expert Commit Knowledge

- **Scope decisions:** Only use Conventional Commit scopes when the repo has >3 subsystems (e.g., `feat(auth):`, `fix(parser):`). Without distinct subsystems, scopes add noise. Multi-scope commits are a signal to split: use the PRIMARY subsystem only; never `feat(auth,api):` — split into separate commits instead.
- **Squash merge behavior:** Squash merges collapse N commits into 1 and discard intermediate messages. If the branch will be squash-merged, the final commit message must be self-contained; never reference "as discussed in commit 3 of 4."
- **Amend vs new commit vs rebase:** Amend if pushing to a PR within 5 minutes and no one pulled. Create a new commit if the branch is shared. Use interactive rebase (`git rebase -i`) if cleaning up >3 messy commits before merge.
- **Co-author attribution:** Add `Co-authored-by:` trailers only when a human or distinct agent contributed meaningfully. Don't add co-authorship for every tool invocation or automated check.

## Pattern: Process

This skill follows the Process pattern:

- **Multi-step workflow:** review → stage → message → commit.
- **Checkpoints:** confirm scope and content at each step before proceeding.
- **Medium freedom:** conventions like Conventional Commits exist, but judgment is required for split decisions, scope choice, and message framing.
