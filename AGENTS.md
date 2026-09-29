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

### Equilibria

- Role: Arch / omarchy desktop (falls through the default device branch of
  `.chezmoi.toml.tmpl`). Note: `.chezmoiignore` gates on the `profile` var
  (desktop/remote) while the device table and this file's write rule key on
  `.chezmoi.hostname` — check both.
- Profile: `desktop`, `omarchy=true`, device model = hostname, all cached in
  `~/.config/chezmoi/chezmoi.toml` (no prompted values to preserve on this
  machine). Omarchy 4.0.4; `includeTemplate "omarchyVersion"` resolves to
  `omarchy4`.
- Intentionally unmanaged: universal machine-local state per
  `.chezmoiignore` (node_modules, opencode.db, dconf, chromium/BraveSoftware,
  kitty, opencode runtime state); desktop gate ignores `.config/omarchy`,
  `.config/btop`, `.config/jolt`, `.config/mdt`; omarchy4 gate ignores
  `.config/waybar` and `.config/mako`; omarchy owns `.config/hypr/*.lua`
  (live config) — classic `.conf` hypr stack is ignored here.
- Quirks:
  - omarchy4 ⇒ the 4.x `.config/hypr/*.lua` files are desktop-truth; do not
    restore the vendored `.conf` copies.
  - Skill sources live in `dot_agents/skills/` and deploy to
    `~/.agents/skills/` (managed; `.agents` is NOT ignored).
  - Targeted `chezmoi apply` needs ~-absolute target paths: relative form
    (`chezmoi apply -- .agents/...`) fails with "not managed";
    `chezmoi apply -- ~/.agents/...` works.
- Change log:
  - 2026-09-29 — Section filled in from live verification on branch
    `agents/interagent-collab` (repo clean, up to date; `chezmoi diff` shows
    only the pending `.agents/skills/chezmoi-interagent-collab/` skill
    deployment, classified expected).
  - 2026-09-29 — Applied pending skill deployment (targeted), verified
    `chezmoi diff` empty and deployed SKILL.md identical to source.

### danctnix

- Role: PINE64 PineTab 2 tablet, Arch Linux ARM aarch64 bare metal
  (osRelease `id=archarm`; NOT postmarketOS — `danctnix` is the ALARM
  PineTab2 kernel package, `7.1.8-danctnix1-1-pinetab2`). Corrected
  2026-09-29 against live `/etc/os-release` and `uname -r`. Runs the classic
  Hyprland stack (Hyprland, hyprctl, foot, fuzzel, GTK, static waybar);
  NOT omarchy. Reached via Tailscale (100.106.230.125). Runs the Hermes
  agent as user service `hermes-gateway.service` (+ TUI); no Obsidian sync
  here.
- Profile: `desktop` — prompted once and cached in
  `~/.config/chezmoi/chezmoi.toml` — even though this is a non-omarchy
  tablet. Real gating keys off device data from the hostname-keyed table
  in `.chezmoi.toml.tmpl` (model pinetab2, type tablet, monitor DSI-1,
  scale 1.25, transform 3, portrait, touch, `omarchy=false`); these render
  the hypr monitor config (`dot_config/hypr/conf.d/01-monitors.conf.tmpl`).
- Intentionally unmanaged here (see `.chezmoiignore`): the inverse of the
  pinetab-only gate — omarchy-owned paths (`.config/omarchy`, btop, jolt,
  mdt), ghostty/uwsm + omarchy/minimal/narrow starship variants (non-omarchy
  gate), `.config/waybar/config.jsonc`, `.config/mako/symlink_config` —
  plus universal machine-local state (node_modules, `opencode.db*`,
  `.zcompdump*`, browser/Electron profiles, dconf, tailscale, go, carapace,
  herdr runtime state), `.config/opencode/package.json` (SDK downgrade
  guard), KDE/Plasma leftovers, and `AGENTS.md`/`docs/**` (repo-only). Zsh
  history (`~/.config/zsh/.zhistory`) is absent from source — its ignore rule
  only fires on the remote profile.
- Quirks:
  - `hostname` binary is not installed (exit 127) — use `hostnamectl`,
    `chezmoi data`, or `chezmoi execute-template
    '{{ .chezmoi.hostname }}'` (prints `danctnix`).
  - Data quirk: `.chezmoi.toml.tmpl` sets `is_tablet` from `$d.portrait` —
    true here only by coincidence (see Architecture ideas).
  - `git fetch`/`git pull` currently fail with `Permission denied
    (publickey)`; reviews here are local-only until SSH auth to the remote
    is fixed.
- Change log:
  - 2026-09-29 — Section filled in by the danctnix agent on
    `agents/interagent-collab`: OS corrected (postmarketOS → Arch Linux ARM;
    `/etc/os-release`, `linux-pinetab2 7.1.8.danctnix1-1`), device data and
    ignore gates verified against `.chezmoiignore` and `.chezmoi.toml.tmpl`;
    Hermes gateway service, Tailscale IP, missing `hostname` binary
    (`hostnamectl` present), and SSH fetch/pull auth failure recorded.

## Notes for non-chezmoi machines

Moshi (Android) does not run chezmoi. Do not create a section for it here;
its agent should treat this file as read-only reference.

## Architecture ideas (propose, never implement without approval)

- (candidate) Migrate the hostname→device table from `.chezmoi.toml.tmpl`
  into `.chezmoidata/machines/<hostname>.yaml` + merge template, per
  chezmoi discussion #3773, so all machine data is readable as plain data.
- (candidate) Collapse the omarchyVersion/device if-chains in
  `.chezmoiignore` (mako/waybar/hypr duplicate-target gates, ~L249–275) into
  per-machine claim lists derived from `.chezmoidata` — chezmoi rejects
  duplicate targets and these nested gates are the repo's highest-risk edit
  surface.
- (candidate) Surface `omarchyVersion` as a plain `chezmoi data` field
  (derive it in `.chezmoidata`/`.chezmoiscripts` instead of a template
  helper) so review agents can read machine truth without executing
  templates.

- (candidate) Collapse the ignore-matrix gate keys (`profile`,
  `.chezmoi.hostname`, `.omarchy`, `.device.model`, `omarchyVersion`
  template) into one machine-identity data block as part of the
  chezmoidata migration above — e.g. danctnix runs `profile = "desktop"`
  with `omarchy = false`, so gates on different keys can disagree.
- (candidate, danctnix, 2026-09-29) Fix `.chezmoi.toml.tmpl`:
  `is_tablet = {{ $d.portrait }}` derives tablet-ness from portrait
  orientation. Derive from `$d.type` (`eq $d.type "tablet"`) or `$d.touch`
  instead. Verified live on danctnix (portrait=true, so coincidentally
  correct); a portrait-orientation non-tablet host would render
  `is_tablet=true` and a landscape tablet `false`. No template currently
  consumes `.is_tablet` — low priority. Data change on all machines —
  needs per-machine review.
- (candidate, danctnix, 2026-09-29) Correct the "postmarketOS boot hostname"
  comment in `.chezmoi.toml.tmpl` — danctnix runs Arch Linux ARM with the
  ALARM danctnix kernel package. Documentation-only.
- (candidate, danctnix, 2026-09-29) Second equil-remote's
  `.chezmoidata/machines/<hostname>.yaml` migration: the hostname→device dict
  is currently hardcoded inside `.chezmoi.toml.tmpl`; external data would let
  agents edit machine facts without touching template logic.