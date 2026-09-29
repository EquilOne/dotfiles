# AGENTS.md — Chezmoi Dotfiles Repo

Shared context file for AI agents working on this chezmoi repository
(`~/.local/share/chezmoi` on each machine). Source of truth is the file in the
repo, NOT the deployed copy if one exists. Read it in full before touching
anything managed by chezmoi.

## Global rules (all machines)

1. **Never run `chezmoi apply` / `chezmoi update` without review.** First run
   `chezmoi diff` (after `git pull`) and classify every change. See skill
   `chezmoi-interagent-collab` (in `dot_agents/skills/` once deployed, or read
   it directly from the repo) for the full review workflow.
2. **Machine section write rule:** each agent may ONLY edit the AGENTS.md
   section matching its own hostname (`.chezmoi.hostname`). All other machine
   sections are read-only. If a change you want conflicts with another
   machine's note, surface it to the user instead of editing.
3. **Never commit secrets.** Secrets come from Proton Pass via `protonPass`
   template helpers. Never paste rendered secret output into source files.
4. **Templates:** never use raw `cp` into the source; use `chezmoi re-add` for
   plain files and the `sync-template.sh` script pattern for `.tmpl` files
   (`chezmoi re-add` refuses templates). Verify with `chezmoi diff` (empty =
   clean).
5. **`run_*` scripts:** check whether a pulled change adds/modifies run
   scripts — they execute on next apply. Flag scripts that need sudo, network,
   or interactivity before applying on headless machines.
6. **Ignore matrix is high-risk:** edits to `.chezmoiignore`,
   `.chezmoi.toml.tmpl`, or `.chezmoidata*` change what machines receive and
   must be reviewed per-machine, not just locally.
7. **Commits:** conventional commits, one logical change per commit. The
   `agents/interagent-collab` branch is the agent workspace; `main` is stable
   backup. Merge to `main` only with user approval.
8. **Report format for review findings** — one line per finding:
   `[CONFLICT|CONCERN|INFO] <path> — <why> — <suggested action with exact command>`

## Machine sections

Add one `## <hostname>` section per machine that runs chezmoi. Keep entries
short and dated. Each section MUST include: role/OS, profile
(desktop/remote), intentionally-unmanaged local state, quirks/known pitfalls,
and a change log. Only this machine's agents write here.

### equil-remote

- Role: headless Fedora VM (droplet), profile `remote`. No GUI, no sudo
  password prompts wanted (bootstrap uses `sudo -n true` guard).
- Reached via Tailscale (100.85.47.109). Runs Hermes agent headless
  (profile: default) and Obsidian headless sync service.
- Intentionally unmanaged here: machine-local state per `.chezmoiignore`
  (node_modules, opencode.db, env files except `.config/shell/env.local`).
- Quirks:
  - Prompted values (git_user_name/email) are cached in
    `~/.config/chezmoi/chezmoi.toml`; do not force re-prompt.
  - Desktop-only paths (hypr, waybar, ghostty, mako, foot, fuzzel) are
    ignored by the `remote` profile branch — do not "fix" their absence here.
- Change log:
  - 2026-09-29 — Initial section created on branch
    `agents/interagent-collab` by equil-remote agent.

### EquilVega

- Role: Arch / omarchy desktop (falls through the default device branch).
  Agents on this machine: fill in role, unmanaged state, quirks.
- Change log: (empty)

### danctnix

- Role: PineTab2, postmarketOS (hostname `danctnix`), tablet, portrait,
  touch. Pinetab-only configs (foot, fuzzel, GTK, themes, classic hypr stack)
  apply here via `.chezmoiignore` gating; ignored everywhere else.
- Change log: (empty)

## Notes for non-chezmoi machines

Moshi (Android) does not run chezmoi. Do not create a section for it here;
its agent should treat this file as read-only reference.

## Architecture ideas (propose, never implement without approval)

- (candidate) Migrate the hostname→device table from `.chezmoi.toml.tmpl`
  into `.chezmoidata/machines/<hostname>.yaml` + merge template, per
  chezmoi discussion #3773, so all machine data is readable as plain data.