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
| Carapace          | Go install (`github.com/carapace-sh/carapace-bin/cmd/carapace@latest`) | `go install` |

The OpenCode installer receives `OPENCODE_INSTALL_DIR="$HOME/.local/bin"` and `--no-modify-path`; the uv installer receives `--env UV_NO_MODIFY_PATH=1`. PATH management is handled by chezmoi's shell config, not by installer shell-profile edits. Existing OpenCode installs at `~/.opencode/bin` remain supported.

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

## OpenCode Remote Safety

The OpenCode config template (`opencode.json.tmpl`) disables the **Linear MCP** server when `profile == "remote"` to avoid automatic OAuth flow and token persistence on an untrusted or temporary machine.

```json
"linear": {
  "enabled": false
}
```

Other MCP servers (Exa, OpenRouter, Airtable) remain disabled by default or depend on external credential files not tracked by chezmoi. The Exa MCP is enabled in the rendered config; any service credentials required are external and not managed by chezmoi.

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
