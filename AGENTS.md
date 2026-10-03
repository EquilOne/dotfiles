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
   `agents/interagent-collab` branch is the shared agent workspace; `main` is
   stable backup. Each machine's agent works on its own subbranch
   `agents/<hostname>` created from `agents/interagent-collab` — flat
   sibling names only (git cannot nest a branch under an existing branch
   name). Merge subbranch → `agents/interagent-collab` only with user
   approval; merge to `main` only with user approval. The collab branch
   doubles as the cross-device test line: apply from
   `agents/interagent-collab` on each machine to validate changes before
   anything merges to `main`.
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
  - 2026-09-29 — Restored ~/.npm-global/bin PATH entry in
    20_path.sh (fixes `ob`); created this subbranch per rule 7.
  - 2026-09-29 — Fixed hermes-env-keys script: pass-cli bare output
    captured directly, bounded with timeout 15; keys upserted (verified
    live; vault resolution intermittently flaky — one transient 'vault
    not found' failure retried OK).
  - 2026-09-29 — Corrected cached machine data (omarchy=true →
    false in ~/.config/chezmoi/chezmoi.toml); omarchy-only files
    dropped from managed set; diff re-classified pending.
  - 2026-09-29 — De-hardcoded /home/equilone in herdr config
    (→ template) and pane-move scripts (→ $HOME).
  - 2026-09-29 — Reverted shared GOPATH to $HOME/go
    (Equilibria's go-bin path was machine-specific); Equilibria
    needs an env.local override before next apply.
  - 2026-09-29 — Made herdr plugins.manifest.toml source-only via
    root .chezmoiignore (per-dir ignore never existed).
  - 2026-09-29 — Fixed dead remote-gate ignore rules (source
    names → target names); eza rule dropped (relative symlink
    resolves everywhere); removed dangling btop theme symlink
    locally.
  - 2026-09-29 — Full chezmoi apply after review; diff empty
    post-apply; ob/GOPATH/herdr paths verified. pass-ssh-agent
    units installed, NOT enabled (decision pending).
  - 2026-09-29 — Same apply: first run aborted on a
    destination-changed conflict for .config/opencode/agents
    (headless, no TTY for the prompt); re-ran with --force —
    that target's delta was already in the reviewed pre-apply
    diff (30 lines). No source changes; targets only.
  - 2026-09-29 — Synthesized starship router with collab's restructure:
    01_starship.sh is now a .tmpl keyed on device.model at render time —
    pinetab gets the foot set at all widths (foot_minimal/narrow/foot);
    omarchy desktops and remote get starship_minimal/narrow with
    starship.toml at wide (foot prompt and starship_omarchy both ruled
    out for remote). .chezmoiignore starship gates adopted from collab's
    split (omarchy-variant ignored on non-omarchy; minimal/narrow not
    ignored on remote).
  - 2026-10-03 — Fixed stale cached data via `chezmoi init`
    (omarchy=true/localhost4 → omarchy=false/headless); omarchy-only
    targets (uwsm, starship_omarchy.toml) dropped from managed set.
    Applied collab batch: SKILL.md lesson, 07_zsh_autosuggestions
    re-style fix, hermes-env-keys re-run (keys verified, perms 600).
    .hermes/memories/*.md source-stale vs local Hermes writes —
    applies withheld pending shared-memory decision. Source fixes:
    .chezmoiignore mako/config gate keyed on omarchy-or-not-pinetab2;
    omarchyVersion probe now emits "none" on omarchy-less machines
    (renders identical on omarchy hosts — verify at next pull).

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
  - 2026-09-29 — Created agent subbranch `agents/Equilibria` from
    `agents/interagent-collab` (1fac526), pushed with upstream tracking;
    documented the flat `agents/<hostname>` convention in rule 7.
  - 2026-09-29 — Ghost-text Tab-accept investigation: root cause = herdr
    remote bridges deliver keystrokes as coalesced bursts, zle defers the
    redraw fetch hook, Tab landed with empty/stale POSTDISPLAY →
    expand-or-complete fallback ("origin" symptom). Fix 80f64f2 (sync
    refetch + direct accept from POSTDISPLAY in
    autosuggest-accept-next-word, widget moved to IGNORE list), merged to
    collab (1cb9b7d) and applied; pty-validated 6/6 accepts.
  - 2026-09-29 — Full collab apply (f5e344b batch, 20+ targets incl.
    run_once_after_30_hermes-env-keys.sh): diff empty post-apply. Starship
    router now device-keyed tmpl — wide resolves starship.toml
    (disk-identical to starship_omarchy.toml, no visible change);
    GOPATH=$HOME/go (~/go exists; remote's env.local note was inverted —
    no override needed); herdr paths de-hardcoded to /home/equildev; keys
    upserted.
  - 2026-09-29 — f5e344b widget rework zpty-validated here: burst Tab
    accept 5/5 (0.15–1.0 s), stale leading-space case clean, menu
    open/`^I` cycle/`^Y` accept-no-execute verified.
  - 2026-09-29 — Secrets fix f744891 (user-approved): hermes-env-keys tmpl
    share URI → name-based protonPass refs (pass://api-keys/agent-search-*),
    URI no longer in tracked files; applied, keys verified, run-once
    re-runs on rotation by design.

### EquilVega

- Role: Arch Linux (rolling, kernel 7.2.7-arch1-1), omarchy v3 / Hyprland
  desktop, profile `desktop`. Falls through the default device branch of
  `.chezmoi.toml.tmpl` (device.model = hostname, omarchy = true). Chezmoi
  2.72.2. Planned: upgrade to omarchy v4 once Equilibria's v4 config is
  stable.
- Intentionally unmanaged here: omarchy-owned paths per the `.chezmoiignore`
  desktop gate (jolt, mdt, btop, .config/omarchy) — omarchy rewrites them on
  theme switch, never re-add; omarchy v3 gates: hypr *.lua ignored (v3 runs
  hyprland.conf as live entrypoint), waybar/config ignored,
  .config/mako/config ignored but mako/symlink_config MANAGED on v3;
  machine-local state (node_modules, opencode.db*, opencode notifier
  state/logs, package manifests, env files except `.config/shell/env.local`,
  KDE leftovers).
- Quirks:
  - `.chezmoiignore` comment claims `.config/shell/env.local` is managed via
    an env.local.tmpl, but no such source file exists (verified 2026-09-29);
    env.local exists on disk and is unmanaged.
  - omarchy v3→v4 upgrade flips the whole ignore matrix + templates:
    `omarchyVersion` = `test -d /usr/share/omarchy` (omarchy4 if present).
    After upgrading, re-run the full diff review before applying (hypr
    .conf↔.lua, waybar/mako gating, ghostty/uwsm/hermes-skin/nvim templates).
  - Equilibria is a separate omarchy v4 desktop machine (not this hostname);
    its AGENTS.md section is read-only from here; cross-machine conflicts go
    to the user.
- Change log:
  - 2026-09-29 — Section created; first interagent diff review run on branch
    `agents/interagent-collab`: 4 differing targets — starship.toml clobber
    traced to 2eda38f, cli.json permissions drop, 10_aliases.sh hrdr drift;
    awaiting approval.
  - 2026-09-29 — Created machine subbranch `agents/equilvega` from
    `agents/interagent-collab` (db7a9ae); each agent works on its own
    subbranch, collab branch is the shared integration line.
  - 2026-09-29 — SKILL.md lessons added per self-improvement clause
    (union-resolve for shared-list conflicts, rebase-replay duplicate/
    empty-pick check, ~-absolute targets for all chezmoi target-arg
    commands); skill deployed via targeted apply, `chezmoi diff` verified.
  - 2026-09-29 — Decision outcomes recorded: starship.toml normalized via
    targeted apply (prompt unaffected — STARSHIP_CONFIG pins
    starship_omarchy.toml on omarchy); hrdr/hrdrpine adopted upstream by the
    user (ba90ebf — earlier re-add was a no-op); cli.json autoaccept drift
    left in place per the toggleables policy (see Architecture ideas); zsh
    autosuggestions + zshenv targets intentionally left pending.
  - 2026-09-29 — CORRECTION: earlier "prompt unaffected" claim was wrong.
    `01_starship.sh` routes omarchy vs pinetab by testing
    `/usr/share/omarchy` — the omarchy v4 marker; v3 installs to
    `~/.local/share/omarchy`, so this machine takes the PINETAB branch
    (STARSHIP_CONFIG resolved to starship_foot_minimal.toml in a live
    shell). Restored starship.toml (disk + source) to the common rose-pine
    preset via re-add; switcher fix proposed in Architecture ideas.
  - 2026-09-29 — Switcher fix applied and verified live: `01_starship.sh`
    omarchy test now accepts the v3 install path
    (`~/.local/share/omarchy`); STARSHIP_CONFIG resolves to
    starship_omarchy/minimal/narrow.toml by width as intended on this
    machine.
  - 2026-09-29 — Zsh ghost-text fix parked by user decision: reverted on
    `agents/interagent-collab` (382188f, 3cc4b12) so the live shell keeps
    its current behavior; fixes preserved on branch
    `feat/zsh-ghost-text-fix` (e659497). Revive later with
    `git revert 3cc4b12 382188f`. cli.json drift and .zshenv/SKILL.md
    targets remain pending as before.
  - 2026-09-29 — User applied all pending targets except cli.json
    (SKILL.md + .zshenv now live; diff is cli.json-only, tolerated per
    toggleables policy). collab branch re-designated by the user as the
    cross-device test line: apply from collab on each machine to validate
    before main.
  - 2026-09-29 — cli.json toggleables policy implemented: file unmanaged
    (`chezmoi forget`), replaced by
    `run_once_after_14_opencode-cli-seed.sh` which deep-merges the embedded
    hard config into the live file on content change — hard keys win,
    app-written keys (session.permissions autoaccept) preserved; verified
    live: `chezmoi diff` completely empty, cli.json byte-identical to
    pre-migration backup. Other machines: script runs on next apply from
    collab, preserving their runtime keys.
  - 2026-09-29 — User ruled the foot prompt pinetab-only: 01_starship.sh
    router restructured to per-class variant sets (omarchy set / foot set
    via file-presence probe / starship.toml-tiered fallback for remote) and
    .chezmoiignore split so starship_minimal/narrow deploy on non-omarchy
    non-pinetab hosts (equil-remote gains real width tiers). Fix committed
    on agents/interagent-collab; machines pull, review, and apply from
    collab (cross-device test line).
  - 2026-09-29 — Applied collab f5e344b after full review: fish-style
    autosuggestions fix — removed the stale-response
    `_zsh_autosuggest_suggest` override that killed as-you-type ghost text
    (accepted occasional stale ghost per user decision), menu toggle
    wrappers restore the ghost after C-e close, menuselect Tab cycles items
    (wraps), ^Y/^M/^J use complist's accept-line (the old custom
    menu-accept widget made Enter execute the line). KEYBINDINGS.md
    deployed to match. All 8 spec items zpty-verified before apply;
    `chezmoi diff` empty post-apply. Same apply: hermes-env-keys re-ran
    (content changed in 8a8bfda); .hermes/.env perms 600, keys upserted.
  - 2026-09-29 — Confirmed intentional (user decision): the device-keyed
    starship router (1697020) is live here — wide terminals now resolve
    starship.toml (rose-pine preset); starship_omarchy.toml stays deployed
    but unreferenced. Supersedes the earlier "wide = starship_omarchy.toml
    as intended" note above. Open item: local agents/equilvega branch
    diverged from collab (duplicate config commits bc210c4/38c32a4 vs
    collab's 6fb9451/20bf5a6) — needs reset-to-collab or rebase cleanup.

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
  - 2026-09-29 — SSH sync restored after key diagnosis (fetch/pull verified
    current at dd101b1; github_pinetab key still unregistered on GitHub —
    open item, access works via the Proton Pass agent keys). 8 pending
    targets reviewed all-Expected and applied via targeted apply (7 file
    targets + run_once_after_14_opencode-cli-seed.sh, which ran via its
    prefix-stripped target form); `chezmoi diff` empty afterwards; cli.json
    seed merged hard config with `session.permissions.autoaccept` preserved;
    HERDR_REMOTE_KEYBINDINGS=server and STARSHIP_CONFIG resolved to the
    foot_minimal variant as expected.
  - 2026-09-29 — Branch re-synced to collab (ff to 1e32882, upstream set to
    origin/agents/interagent-collab); user decision: danctnix pinetab prompt
    at all widths (router non-omarchy >=80 now starship_foot.toml);
    cross-machine impact on equil-remote wide prompt flagged in commit body.
  - 2026-09-29 — SSH open item closed: github_pinetab confirmed registered on
    GitHub as an Authentication key (API-verified, key id 164864973; earlier
    denials were Signing-only registration then client-side passphrase
    encryption in non-interactive runs); IdentityAgent
    ~/.ssh/proton-pass-agent.sock persisted in the github.com block of
    ~/.ssh/config (unmanaged, machine-local) — headless git verified with
    agent env stripped (ls-remote exit 0). Optional leftovers: register
    agent's equil-pinetab key (SHA256:MkKA8XRV…) for device attribution;
    remove stale on-disk ~/.ssh/id_ed25519.
  - 2026-09-29 — Full collab batch applied after review (21 targets; full
    apply used deliberately — every target individually classified Expected
    this cycle): remote's router synthesis renders pinetab foot set at all
    widths (verified 30/60/120), herdr paths de-hardcoded, GOPATH=$HOME/go
    (~/go exists here), hermes-env-keys re-ran (env.local/API keys created,
    headless-safe), plugins.manifest.toml source-only, new skills deployed.
    User un-parked the zsh ghost-text fix (f5e344b) — 07_zsh_autosuggestions.sh
    + KEYBINDINGS.md applied.

### Notes for other systems

- (2026-09-29, from equil-remote) **Equilibria:** add
  `export GOPATH="$HOME/.local/opt/go-bin-v1.25.3"` to
  `~/.config/shell/env.local` before next apply — commit 5d59abb
  reverted the shared GOPATH to `$HOME/go`; your `~/go` no longer
  exists, so without the override go tooling falls back to a
  nonexistent path. See also the machines-table architecture
  candidate.

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
- (candidate) Shared configs that drift per machine (e.g. starship.toml
  differs between source and disk on EquilVega) → either per-machine variants
  gated like the existing starship_foot*.toml pattern, or machine-varying
  values moved into `.chezmoidata` (same machinery as the machines-table
  candidate above).
- (implemented on feat/opencode-cli-toggleables, EquilVega, 2026-09-29, user-directed) opencode cli.json:
  split app-written toggleables (e.g. `session.permissions` autoaccept)
  from "hard" config — hard config injected via chezmoi (apply or a
  Hermes-config-style seed script), toggleables left unmanaged so runtime
  drift is tolerated by policy instead of flagged each review. Needs a
  split mechanism; per-machine review required.
- (implemented e659497, EquilVega, 2026-09-29) Fix the omarchy test in
  `dot_config/shell/15_functions/01_starship.sh`:
  `[[ -d /usr/share/omarchy || -d ~/.local/share/omarchy ]]` — the current
  test only matches the v4 system-wide path, so v3 omarchy machines route
  to the pinetab prompt branch. Prompt-affecting on all omarchy machines —
  per-machine review required.
