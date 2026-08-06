# Remote Fedora Profile

This document describes the `remote` chezmoi profile for Fedora 44 (x86_64) provisioned on a DigitalOcean Droplet. It covers what the profile configures, how to bootstrap, and what is intentionally excluded.

## Profile Selection

The profile is chosen at first-time `chezmoi init`:

```sh
chezmoi init --promptString "Profile (desktop or remote)=remote" <source-repo-url>
```

The key before the `=` is the exact prompt text that `promptStringOnce` displays; the value after `=` is the answer. The answer is persisted in `~/.config/chezmoi/chezmoi.toml` (generated from `.chezmoi.toml.tmpl`) via `promptStringOnce`. Subsequent `chezmoi init` and `chezmoi apply` runs do **not** re-prompt.

## What the Profile Includes

The remote profile applies shared shell and CLI tooling. Managed files include:

- **Shell** — Bash/Zsh config (`~/.config/shell/`), `.bashrc`, `.bash_profile`, `.zshenv`
- **Neovim** — editor config (Lua plugin tree, mappings, LSP)
- **Herdr** — terminal multiplexer config (`~/.config/herdr/config.toml`)
- **Yazi** — file manager config
- **CLI tools** — fzf, ripgrep, fd, bat, eza, zoxide, direnv, Starship, uv, Carapace
- **OpenCode** — AI agent CLI config (`~/.config/opencode/`)

## What the Profile Excludes

The `.chezmoiignore` template conditionally skips these paths when `profile == "remote"`:

- **Desktop GUI** — Hyprland, Waybar, Omarchy themes, Ghostty, Mako
- **GitHub private config** — `~/.config/gh/config.yml` and `~/.config/gh/hosts.yml` (source names carry `private_` prefixes; chezmoi strips them on render)
- **Hermes** — state and config (`~/.hermes/`)
- **Tmux** — remains in the source tree as a manual fallback; `~/.config/tmux` is **not** deployed remotely
- **Desktop-only completions** — `25_completions/03_hyprctl.sh`
- **Backgrounds and assets** — wallpaper files under `~/.config/*/`
- **Shell history** — `~/.config/zsh/.zhistory`

## Bootstrap Script

`run_once_before_10_remote-fedora-setup.sh.tmpl` runs automatically during `chezmoi apply` on first install. It only executes when `profile == "remote"`.

### Behaviors

- **Root refusal** — exits immediately if run as root
- **Fedora detection** — reads `/etc/fedora-release` or `ID_LIKE` in `/etc/os-release`; fails on non-Fedora-family systems
- **Package installation** — installs missing packages via `dnf install -y` only for packages not already present (idempotent)
- **No full system upgrade** — only installs the specific package list; does not run `dnf upgrade`
- **Fallback installers** — tools not available in Fedora repos (Starship, OpenCode, Herdr, Proton Pass CLI) are fetched from their official install URLs. uv is dnf-first with the Astral installer as fallback

Herdr and certain tools use `try_optional_dnf_package()`: if the package exists in Fedora repos it is installed via dnf; otherwise it falls through to the dedicated installer function.

### Installed System Packages

Installed via `dnf`:

```
git curl jq zsh neovim fzf ripgrep fd-find bat zoxide direnv gh
dnf-plugins-core gawk golang rust cargo
gcc gcc-c++ make cmake pkgconf-pkg-config openssl-devel libffi-devel
zlib-ng-compat-devel bzip2-devel xz-devel sqlite-devel readline-devel
libyaml-devel tar unzip patch findutils ca-certificates
```

### Installed via Dedicated Installers (Fallback)

These tools are installed via dnf when available in Fedora repos; the URLs below are the fallback when no dnf package exists:

| Tool              | Fallback URL                                                    | Installer |
|-------------------|----------------------------------------------------------------|-----------|
| OpenCode          | `https://opencode.ai/install`                                   | `bash`    |
| Herdr             | `https://herdr.dev/install.sh`                                  | `sh`      |
| Proton Pass CLI   | `https://proton.me/download/pass-cli/install.sh`                | `bash`    |
| Starship          | `https://starship.rs/install.sh`                                | `sh`      |
| uv                | `https://astral.sh/uv/install.sh`                               | `sh`      |
| Carapace          | Homebrew (`brew install carapace`), with Go install fallback (`github.com/carapace-sh/carapace-bin/cmd/carapace@latest`) | `brew` / `go install` |

Homebrew is installed on demand with the official Linux installer (`NONINTERACTIVE=1`) when Carapace needs it and no Homebrew installation is detected. The script initializes Homebrew only for the current bootstrap run; persistent PATH management is handled by chezmoi's shell config, not by installer shell-profile edits. The OpenCode installer receives `OPENCODE_INSTALL_DIR="$HOME/.local/bin"` and `--no-modify-path`; the uv installer receives `--env UV_NO_MODIFY_PATH=1`. Existing OpenCode installs at `~/.opencode/bin` remain supported.

### Eza Installation

Installed via dnf if available in Fedora repos; otherwise compiled from source via `cargo install --locked --root "$HOME/.local" eza`.

### Yazi Installation

Installed via the [lihaohong/yazi COPR](https://yazi-rs.github.io/docs/installation/): `dnf copr enable -y lihaohong/yazi` then `dnf install -y yazi`. Requires `dnf-plugins-core`.

### Idempotence

- Each tool function checks `command -v <tool>` and skips if already present
- Package installation checks `rpm -q` per package
- The script exits non-zero if any step fails; `run_once_before` semantics mean chezmoi will retry on the next `chezmoi apply`

## Herdr Initialization

After bootstrap, first Herdr launch performs plugin initialization (theme, keybindings from `config.toml`).

### herdr-splits Plugin

The bootstrap script installs the Herdr-side `herdr-splits` plugin:

```sh
herdr plugin install lmilojevicc/herdr-splits.nvim --yes
```

It then verifies the plugin is enabled via `herdr plugin list --json`. If the plugin is installed but disabled, bootstrap reports the failure and exits.

The config binds:

- `Ctrl+h/j/k/l` — navigate splits
- `Alt+h/j/k/l` — resize splits

### First Neovim Launch

The Neovim-side of `herdr-splits` is installed separately by lazy.nvim on first Neovim startup. Bootstrap provisions only the Herdr side; the Neovim plugin sync is automatic on first launch and may take 30–60 seconds depending on network speed.

## Proton Pass CLI (pass-cli)

### Installation

Bootstrap installs `pass-cli` to `~/.local/bin` from the official installer at `https://proton.me/download/pass-cli/install.sh` using the `stable` channel. Requires `jq`.

### Best Practices

- **Do not login during bootstrap** — `pass-cli` installation does not authenticate. Login is a manual step.
- **Do not embed secrets in chezmoi templates** — use `pass://` reference URIs and pass them through `pass-cli run --env-file ... -- command`.
- **Do not export secrets in shell startup** — shell config files (`~/.bashrc`, `~/.zshenv`, `00_env.sh`) must not source or export Proton Pass credentials.
- **Keep local env files secure** — any `.env` files containing secrets must be mode `0600` and gitignored. The chezmoi ignore list already excludes `**/*.env` and `**/env.*`.
- **Interactive limitations** — `pass-cli run` forwards basic I/O for non-interactive commands and scripts, but is not a full TTY solution. Interactive login or biometric/PIN authentication must be performed directly in an interactive SSH session (run `pass-cli login` there). For production secrets, use per-command or per-service injection rather than a single long-lived `pass-cli run` session.

## SSH Agent (keychain + Proton Pass keys)

SSH keys live in the Proton `ssh-keys` vault — portable and off disk — and a persistent `keychain`-managed ssh-agent receives them via `pass-cli ssh-agent load`.

### On-login flow

`~/.config/shell/30_tools/03_keychain_init.sh` starts/persists the ssh-agent with `keychain --eval --quiet` (no keyfile args, so keychain acts as an agent provider only). It then runs `pass-cli ssh-agent load --vault-name ssh-keys` to load the Proton-stored keys into the agent. The load is gated on the agent having no identities (`! ssh-add -l`), so it fires roughly once per agent lifetime. The script runs from interactive login shells, guarded on `[[ -t 0 && -t 1 ]]`.

### Prerequisites

- **keychain** — installed by the bootstrap as a distro package if available (`try_optional_dnf_package keychain`), otherwise the single-script release is fetched into `~/.local/bin` from `https://github.com/danielrobbins/keychain` (no EPEL — EPEL is Enterprise-Linux-only and does not apply to Fedora). On an existing box the manual install is `sudo dnf install -y keychain`, or if absent from the base repo: `curl -fsSL https://raw.githubusercontent.com/danielrobbins/keychain/2.9.8/keychain -o "$HOME/.local/bin/keychain" && chmod 0755 "$HOME/.local/bin/keychain"`.
- **pass-cli authenticated** — `pass-cli` must be logged in before the load can run.
- **filesystem key provider** — `PROTON_PASS_KEY_PROVIDER=fs` (set in `00_env.sh`); the kernel keyring is revoked in SSH/headless sessions and would otherwise break the `protonPass` render in `chezmoi apply`.
- **PAT `viewer` grant** on the `ssh-keys` vault: `pass-cli pat access grant --pat-name <pat> --vault-name ssh-keys --role viewer`.

### Verify

In an interactive shell:

```sh
echo "$SSH_AUTH_SOCK"   # should point at a live agent socket
ssh-add -l              # lists the Proton-stored identities
```

### Troubleshooting

| Symptom | Likely Cause | Resolution |
|---|---|---|
| `SSH_AUTH_SOCK` empty | keychain absent or non-interactive shell | `command -v keychain`; ensure keychain installed (bootstrap does it; manual: dnf or the raw-script install above) |
| `pass-cli ssh-agent load` silently no-ops | PAT missing `viewer` on `ssh-keys`, or not logged in | Check `pass-cli info`; grant `viewer` on the vault |
| `chezmoi apply` fails with `error calling protonPass … NoStorageAccess(KeyRevoked)` | key provider on the kernel keyring | Ensure `PROTON_PASS_KEY_PROVIDER=fs` (already in `00_env.sh`); re-login, or `chezmoi apply --skip-secrets` to defer opencode.json |
| Keys not loaded after reboot | keychain agent restart cleared memory | Run `pass-cli ssh-agent load --vault-name ssh-keys` in an interactive shell |

## OpenCode Remote Safety

The OpenCode config template (`opencode.json.tmpl`) keeps the **Linear MCP** server enabled on every profile, differing only in auth mode:

- `remote` (headless) — an `Authorization: Bearer` header is rendered at apply time from Proton Pass via `{{ protonPass "pass://FxKgFOnQtTaXOEnWzbQP4sPtNAqInfXIk56pzYde03onl9btfTgmI9hHoTH07GXkv7-Euj27Y0qPiXEdEeBlYg==/SvWLUqs2yNztw5xe7sQzWJ56L2nZhNYf24sa6FOvDaPmMtcyXFyG9L2qJjgwZMEMG7p5mVIAcpOC-csgNsHQOA==/API Key" }}`, avoiding an interactive OAuth flow and keeping the token out of the repo.
- any other profile — no header; opencode uses its standard browser OAuth flow.

The Proton Pass reference requires `pass-cli` authenticated on the machine (PAT) with `viewer` access to the `equil-remote` vault.

Other MCP servers (Exa, OpenRouter, Airtable) are disabled by default or depend on external credential files not tracked by chezmoi; any credentials needed at runtime are external and not managed by chezmoi.

## Verification and Recovery

```sh
# Verify profile is set
chezmoi data | jq '.profile'

# Review pending changes
chezmoi diff

# Apply without prompting
chezmoi apply

# Rerun the bootstrap script (if it failed previously)
chezmoi apply   # run_once_before scripts retry automatically on failure
```

### Manual Tmux Fallback

Tmux config is part of the source repo but **not deployed** remotely. If you need tmux on the Droplet:

```sh
sudo dnf install -y tmux
cp -r ~/.local/share/chezmoi/dot_config/tmux ~/.config/tmux
```

Replace `~/.local/share/chezmoi` with the actual source path if different.

## Troubleshooting

| Symptom | Likely Cause | Resolution |
|---|---|---|
| Bootstrap script exits with `Fedora-family system` error | OS is not Fedora/RHEL/CentOS/Rocky/Alma | Use the `desktop` profile or edit detection logic |
| `dnf install` fails for a package | Package name mismatch or COPR not enabled | Verify name with `dnf search`; file an issue if it is a Fedora 44 regression |
| Herdr not found after bootstrap | `$HOME/.local/bin` not in PATH | Source shell config or re-login; verify with `command -v herdr` |
| `pass-cli` not found | Install failed silently | Re-run manually: `curl -fsSL https://proton.me/download/pass-cli/install.sh \| env PROTON_PASS_CLI_INSTALL_CHANNEL=stable PROTON_PASS_CLI_INSTALL_DIR="$HOME/.local/bin" bash` |
| Proton Pass login fails | No TTY or missing biometric device | Run `pass-cli login` directly in an interactive terminal |
| Neovim plugins not loaded on first launch | lazy.nvim sync incomplete | Run `nvim --headless "+Lazy! sync" +qa` |
| OpenCode not found | Install binary location not in PATH | Verify `$HOME/.local/bin/opencode` or run `command -v opencode`; re-source shell config if needed |
| `run_once_before` script fails | Dependency not met or network issue | Fix the error and run `chezmoi apply` again; the script retries automatically |
| Droplet has no `sudo` | Base image variation | Log in as root, install sudo (`dnf install -y sudo`), log out, then run `chezmoi apply` as the intended non-root user |
