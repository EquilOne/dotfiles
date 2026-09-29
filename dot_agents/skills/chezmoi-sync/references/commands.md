# Chezmoi Command Reference

Quick reference for commands used by the `chezmoi-sync` skill. Read this when troubleshooting or when command behavior is unfamiliar.

## Inspect state

| Command | Purpose |
|---|---|
| `chezmoi managed` | List every destination path chezmoi owns. Empty output means no files are managed. |
| `chezmoi status` | Show modified files. Left column: ` `=unchanged, `M`=modified, `A`=added, `D`=deleted, `R`=run script. Second char compares source vs destination (` ` or `M`). |
| `chezmoi diff <file>` | Show exact per-line diff between source state and destination file. Empty output means they match. |
| `chezmoi source-path -- <file>` | Print the source path for a destination file. Exits non-zero with stderr output if the file is not managed. |

## Sync changes

| Command | Purpose |
|---|---|
| `chezmoi re-add <file>` | Push destination changes back to source. Preserves templates by refusing to overwrite `.tmpl` files. Recurses into dirs. Re-encrypts encrypted files automatically. |
| `chezmoi add <file>` | Register a new untracked file into the source tree. Use only when `chezmoi source-path` shows the file is not managed. |
| `chezmoi apply` | Deploy source state to destination. **Destructive**: overwrites any local destination edits without prompting unless `--dry-run` is used. |
| `chezmoi update` | Pull latest source from the git remote and run `apply`. Equivalent to `chezmoi git pull && chezmoi apply`. |

## Edit source

| Command | Purpose |
|---|---|
| `chezmoi edit <file>` | Open the source file in your editor. For templates, opens the `.tmpl` source. For encrypted files, decrypts in place for editing. Re-encrypts on save. |
| `chezmoi forget <file>` | Remove a file from source management. **Does not delete** the destination file. Use to convert a template back to plain. |

## Inspect configuration

| Command | Purpose |
|---|---|
| `chezmoi data` | Dump chezmoi's configuration data. Query for `git.autoCommit` and `git.autoPush` with `chezmoi data --format json \| jq '.git'`. |
| `chezmoi git -- <git-cmd>` | Run a git command in the source directory (usually `~/.local/share/chezmoi`). Example: `chezmoi git -- status --porcelain`. |

## Exit codes and common errors

| Exit code | Common cause |
|---|---|
| `0` | Success, unchanged, or no-op. |
| `1` | Generic error: file not found, permission denied, source tree dirty and operation refused, template render failed, encryption failed. |
| `2` | `--force` required, or operation cancelled by user.

### Common error patterns

- **`chezmoi: <file>: not managed`**  
  The destination file is not tracked. Use `chezmoi add <file>` first, then `chezmoi re-add <file>` for future edits.

- **`chezmoi: cannot overwrite template file ...`**  
  `re-add` refuses to overwrite `.tmpl` files. Edit the template source with `chezmoi edit <file>` instead.

- **`chezmoi: source state cannot be modified because the working tree is dirty`**  
  The source git tree has uncommitted changes and autoCommit is enabled. Commit the pending changes first (`chezmoi git -- commit -am "..."`), then retry.

- **`chezmoi: <file>: no such file or directory`**  
  The destination path does not exist or is misspelled. Ensure the path is absolute and under `$HOME`.

- **Encryption errors (`age: no identity matched recipient`, etc.)**  
  The age identity or passphrase is unavailable. Run in a terminal where the key agent or `age` passphrase is present before editing/re-adding.

- **`apply` overwrote local changes**  
  Recover from `chezmoi diff <file>` output captured before apply, or restore from the git history of the source directory (`chezmoi git -- log --patch -- <source-path>`).
