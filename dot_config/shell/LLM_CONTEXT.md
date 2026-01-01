# LLM Configuration Reference

Technical reference for AI agents working with this shell configuration.

## Core Facts
- **Framework**: Numbered modular loading (00-39)
- **Shells**: Bash, Zsh
- **Theme**: Rose Pine Moon
- **Structure**: XDG Base Directory compliant

## File Reference

| Component | Path | Edit | Template |
|-----------|------|------|----------|
| **Loader** | `shell/loader.sh` | Shell detection | ✅ Platform checks |
| **Environment** | `shell/00_env.sh` | Global vars | ❌ |
| **Aliases** | `shell/10_aliases.sh` | Shared shortcuts | ❌ |
| **Path** | `shell/20_path.sh` | Binary paths | ✅ Platform paths |
| **Functions** | `shell/15_functions/` | Utilities | ✅ Shell-specific |
| **Tools** | `shell/30_tools/` | Tool init | ✅ Conditional |

## Actual Commands
**Functions**: `rgf`, `fgb`, `zi`, `y`, `fy`, `zy`, `yz`, `yw`, `yah`
**Keybindings**: `Ctrl+T`, `Alt+C`, `Ctrl+R`, `Ctrl+Space`
**Aliases**: `zz`, `zh`

## Chezmoi Notes
- **Templates**: `20_path.sh`, `loader.sh`, `15_functions/01_starship.sh`
- **Shared**: Aliases, colors, base functions