---
name: chezmoi-interagent-collab
description: Review chezmoi diffs before apply/update; check pulled changes for cross-machine conflicts using the shared AGENTS.md; report conflicts with actionable fixes.
---

# Chezmoi Interagent Collab

Cross-machine safety review for the chezmoi dotfiles repo. Shared context
lives in `AGENTS.md` at the repo root. Canonical repo path:
`~/.local/share/chezmoi/AGENTS.md` (never edit a deployed copy of AGENTS.md;
there should not be one — it is in `.chezmoiignore`).

## Identity & write rules

1. Determine this machine's hostname: `hostname` (or `chezmoi data | jq
   .chezmoi.hostname` — note chezmoi truncates at the first `.`).
2. Read `~/.local/share/chezmoi/AGENTS.md` in full.
3. You may edit ONLY the `## <your hostname>` section, and only its Change
   log / quirks / unmanaged-state entries. All other machine sections are
   read-only. Everything outside machine sections needs user approval per
   the user's one-decision-at-a-time preference.

## Review workflow (run before any `chezmoi apply`/`chezmoi update`, or when asked to review)

1. **Sync state:** `cd ~/.local/share/chezmoi && git fetch origin` then
   `git log --oneline HEAD..origin/<branch>` for unpulled commits, and
   `git status --short` for local uncommitted edits. Attribute each hunk to
   the correct side — hunk signs in a mixed diff do not tell you who changed
   what; confirm with `git show <commit> -- <file>`.
2. **Pull** (`git pull --ff-only`; if that fails, STOP and report — a
   diverged tree means someone else committed overlapping changes).
   - Shared-list conflicts (e.g. two agents appending to AGENTS.md's
     Architecture ideas tail) resolve as a UNION — all sides are
     candidates; never keep only one side.
   - When replaying a commit that INSERTS a section, verify the inserted
     section appears exactly once after the replay; a replayed pick whose
     diff comes back empty is redundant — `git rebase --skip` it.
3. **Diff:** `chezmoi diff`. Also `chezmoi managed` for the full target list
   if the diff is large. Classify every change:
   - **Expected** — matches the commit messages and this machine's section.
   - **Unexpected** — not explained by any commit you can find.
   - **Risky** — passes any check below.
4. **Risk checks:**
   - `.chezmoiignore` / `.chezmoi.toml.tmpl` / `.chezmoidata*` changed →
     re-derive what this machine would newly receive or lose; flag additions
     of previously-ignored paths.
   - Any `run_*` script added/modified → read it; flag sudo, network, or
     interactive prompts (headless machines hang on these).
   - Any path listed in THIS machine's "intentionally unmanaged" list now
     managed → CONFLICT candidate.
   - Any path claimed in ANOTHER machine's section being changed → flag as
     cross-machine concern; do not resolve unilaterally.
   - Template logic changed → render-check with `chezmoi cat <file>` on the
     affected files.
   - The change would delete files present on disk → flag explicitly.
   - Env-var config routers (STARSHIP_CONFIG etc.): verify the resolved
     value on THIS machine (e.g. `zsh -lic 'echo $STARSHIP_CONFIG'`);
     install-path markers can conflate omarchy version detection with
     machine-type detection (v3 = ~/.local/share/omarchy, v4 =
     /usr/share/omarchy).
5. **Report findings**, one line each:
   `[CONFLICT|CONCERN|INFO] <path> — <why> — <exact fix command>`.
   Fix vocabulary: `chezmoi apply -- <file>` (targeted; run from $HOME with
   ~-absolute targets — ANY chezmoi command taking a target arg
   (apply/cat/source-path/diff) fails with "not managed" for relative args
   from inside the source dir),
   `chezmoi merge <file>` (three-way destination/source/target),
   `chezmoi re-add <file>` (adopt local), ignore-rule edit in
   `.chezmoiignore`, or "ask other machine's agent" for cross-machine
   cases.
6. **Wait for user approval.** Then apply (prefer targeted applies over full
   `chezmoi apply`), verify with `chezmoi diff` (empty for applied targets),
   and record a dated one-line entry in your own machine section's Change
   log. Commit + push the section update.
7. **Never push source-file changes** made by another agent's instructions
   without review — the VCS is the cross-machine conflict detector: if two
   machines edited the same shared file, `git pull` will conflict, and that
   conflict must be resolved with both machines' AGENTS.md sections in view.

## Architecture proposals

Redesign ideas (e.g. migrating the hostname device table to
`.chezmoidata/machines/*.yaml`) go in AGENTS.md's "Architecture ideas"
section as a one-line candidate + rationale. Never implement without
explicit user approval of that specific change.

## Self-improvement

- This skill is versioned in the repo like any other source file. If the
  review workflow above missed something, gave a wrong fix, or a risk check
  proved false-positive on a real run, update this SKILL.md in the same
  commit as the change-log entry — the lesson goes where the workflow lives.
- Keep lessons imperative and generic (rules, not incident narration); one
  rule per bullet. Machine-specific facts belong in your AGENTS.md section,
  not here.
- New risk checks discovered on one machine: add them to the risk-check list
  here immediately so every other machine's agent inherits them on next
  `git pull`. If a change to this skill would alter another machine's
  review behavior, note it as a cross-machine concern in the commit body.
- After editing, verify `chezmoi diff` shows only this file as expected, then
  commit and push.

## Anti-patterns

- NEVER blind `chezmoi apply` / `chezmoi update` (the update command pulls
  AND applies in one step — split them: `git pull` then review then apply).
- NEVER edit the deployed AGENTS.md or a `.tmpl` file's rendered output.
- NEVER resolve a cross-machine disagreement by editing another machine's
  section — surface it to the user.
- NEVER bypass the `remote`/`desktop`/pinetab ignore gates to "fix" a missing
  config on the wrong machine.
- NEVER resolve a shared-list conflict by keeping only one side, and NEVER
  `git rebase --continue` a replayed pick without checking whether the
  pick's diff is empty (redundant replay → skip).