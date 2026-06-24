---
name: chezmoi-sync
description: >
  Sync edited config / dotfile changes into the chezmoi source so they
  survive re-apply and are tracked in dotfiles. After any config file edit,
  check whether chezmoi tracks the file and use `chezmoi re-add` to push
  the change back to the source.

  ALWAYS consider this skill after editing a config file with the edit/write
  tool — even if the user didn't ask. Fires on: user edits a config file;
  user says "update chezmoi", "sync dotfiles", "push to dotfiles",
  "save to chezmoi", "commit to dotfiles", "I edited X push it"; user
  mentions editing dotfiles, ~/.config/*, ~/.zshrc, ~/.bashrc, app settings,
  or runs any `chezmoi` command. Also fire when the model itself edits a
  config file in any tool call.
---

# Chezmoi Sync

After a config file is edited, sync the change into the chezmoi source so the
dotfile change survives the next `chezmoi apply`. Uses `chezmoi re-add`.
Chezmoi's `git.autoCommit`/`autoPush` settings can auto-commit and push each
re-add; this skill detects that and warns before bundling unrelated changes.

Quick reference: edit → `chezmoi re-add <file>` → `chezmoi diff` → commit.

**MANDATORY:** When troubleshooting a chezmoi error or unfamiliar command behavior, read [`references/commands.md`](references/commands.md) for detailed command reference and exit codes.

## Anti-patterns

- **NEVER run `chezmoi apply` without checking for local changes first.** It can destroy uncommitted edits in the destination.
- **NEVER edit files in the destination directly without `chezmoi re-add` afterward.** Those changes are lost on the next `chezmoi apply`.
- **NEVER use `chezmoi edit` for bulk changes.** It opens an interactive editor and breaks automation.
- **NEVER ignore the autoCommit pre-flight check.** It can commit secrets or broken state bundled with unrelated changes.

## Pattern: Tool

**Why Tool, not Process:** Chezmoi operations have one wrong command = lost data (high consequence → low freedom). A Process pattern would give too much freedom for operations where `chezmoi apply` overwrites local changes. The re-add vs edit decision tree is a Tool characteristic (maps scenarios to exact commands), not a phased workflow.

**Why Tool, not Mindset:** The value is in the exact commands and their failure modes, not in a thinking framework. Mindset skills are ~50 lines with high freedom; chezmoi needs ~165 lines with low freedom because precision matters.

**Pattern mapping:**
- Decision trees: re-add vs add vs edit, encrypted file handling ✓
- Code examples: exact bash commands with flags ✓
- Low freedom: one wrong command loses data ✓
- Reference file: references/commands.md for detailed command docs ✓
- ~165 lines (within Tool range) ✓

### Decision tree: which command?

| Condition | Command | Why |
|---|---|---|
| File is already tracked, plain file, edited in destination | `chezmoi re-add -- "$file"` | Preserves source attributes and refuses to overwrite templates. |
| File is returned by `chezmoi managed` but is `.tmpl` | `chezmoi edit -- "$file"` | Edit source template directly; never render template bytes back. |
| File is encrypted (`encrypted_*` or `.age`) | `chezmoi edit -- "$file"`, then `chezmoi re-add -- "$file"` | Edit decrypts in place; re-add re-encrypts automatically. |
| `chezmoi source-path` exits non-zero / empty stdout | `chezmoi add -- "$file"` | File is untracked; add registers it in source. |
| Need to deploy source to a fresh destination | `chezmoi apply -- "$file"` | Only after `chezmoi diff` shows no local modifications. |
| Need to update from upstream dotfiles | `chezmoi update` | Pulls git remote and applies; may overwrite local edits. |

### Examples

```bash
# Check whether a file is managed before doing anything else
chezmoi source-path -- "$HOME/.zshrc" >/dev/null 2>&1 && echo "managed" || echo "not managed"

# Push destination edit to source
chezmoi re-add -- "$HOME/.zshrc"

# Verify nothing leaked
chezmoi diff -- "$HOME/.zshrc"

# Add a brand-new config file
chezmoi add -- "$HOME/.config/newapp/config.toml"
```

## Thinking Frame

Before syncing changes, ask:
- **Source or destination?** Was the file edited in the chezmoi source (`~/.local/share/chezmoi`) or the destination (`~/.config`)? This determines whether you sync TO source or FROM source.
- **Template or plain?** Is the file a chezmoi template (`.tmpl` suffix)? Templates need special handling — don't break the template syntax.
- **Encrypted?** Files with `encrypted_` prefix or `.age` suffix need the passphrase and re-encrypt on re-add.
- **Managed?** Run `chezmoi managed` first — if the file isn't managed, `re-add` won't work.

## Workflow

Skip source code, files outside `$HOME`, and one-off scratch files.

For each edited file:

1. Confirm chezmoi exists. If `command -v chezmoi` fails, tell the user and stop.

2. Resolve absolute destination path. Chezmoi works with destination paths
   (e.g. `/home/user/.zshrc`), not source paths.

3. Check management:
   ```bash
   chezmoi source-path -- "$file"
   ```
   `chezmoi source-path` exits **non-zero** with stderr output if the file is not managed. Suppress stderr; treat empty stdout as **not managed**. Stop and offer `chezmoi add "$file"` if the user wants to track it. Non-empty stdout means managed — continue.

4. Detect template. If the source path ends in `.tmpl`:
   - Do NOT sync. Overwriting with rendered bytes would strip template logic.
   - Tell the user the file is templated and they should edit the source
     directly with `chezmoi edit -- "$file"`.
   - Stop.

5. Pre-flight git check (before any re-add):
   - Query `chezmoi data` for `git.autoCommit` and `git.autoPush`.
   - Run `chezmoi git -- status --porcelain` to list uncommitted source changes.
   - If `autoCommit` is ON and there are uncommitted changes that are NOT
     the file(s) about to be synced: STOP and warn. `re-add` will bundle all
     pending changes into one auto-commit with a concatenated message. Ask the
     user to commit pending changes first (`chezmoi git -- commit -am "..."`)
     or proceed anyway.
   - If `autoCommit` is ON and the source tree is clean: proceed; re-add will
     auto-commit just this file.
   - If `autoCommit` is OFF: proceed; re-add does not touch git.

6. Sync with re-add:
   ```bash
   chezmoi re-add -- "$file"
   ```
   - Empty output, no `[main <hash>]` line: file was already in sync.
   - Output containing `[main <hash>]`: auto-committed as `<hash>`.
   - Output containing `To <remote>`: pushed to remote.

7. Verify with diff (optional but useful):
   ```bash
   chezmoi diff -- "$file"
   ```
   Empty diff = clean sync.

8. Report accurately based on re-add output:
   - Auto-committed + pushed: `synced $file -> $src (commit $hash, pushed)`
   - Auto-committed, no push: `synced $file -> $src (commit $hash)`
   - No auto-commit: `synced $file -> $src (run \`chezmoi git -- commit\`)`
   - No output: `already in sync: $file`

## Encrypted files

Detect encrypted files by `.age` extension or `encrypted_` prefix in the source name. Edit them with `chezmoi edit -- <file>`; chezmoi decrypts on open and prompts for the passphrase. After editing, run `chezmoi re-add -- <file>`; chezmoi re-encrypts automatically. Do not edit encrypted source files directly.

## When the user runs `chezmoi apply`

Check `chezmoi diff`/`status` first, prompt if local destination changes exist,
then apply and verify with `chezmoi diff`.

## Multi-file edits

When several config files were edited in one turn, loop over each. Run the
pre-flight check ONCE before the loop (not per file). Summarize per-file
 results in one block:

```
synced:     ~/.zshrc -> ~/.local/share/chezmoi/dot_zshrc (commit abc1234, pushed)
already:    ~/.config/zed/settings.json
not managed: ~/.config/foo/config.toml
templates:  ~/.config/bar/settings.json
```

## Helper script

`scripts/chezmoi-sync.sh` runs the workflow above for one or more files.
For a single file, the workflow steps above are sufficient. For 2+ files
or when the user asks to "sync everything", prefer the script.

Exit codes: `0`=all processed; `1`=one or more re-adds failed; `2`=autoCommit on and source tree dirty (re-run with `--force`).

```bash
sh skills/chezmoi-sync/scripts/chezmoi-sync.sh ~/.zshrc ~/.config/zed/settings.json
sh skills/chezmoi-sync/scripts/chezmoi-sync.sh --force ~/.zshrc
```

## Error Recovery

- If `chezmoi re-add` fails with "not managed": the file was never added. Use `chezmoi add` first.
- If `chezmoi apply` overwrote local changes: recover from `chezmoi diff` output or git history of the source.
- If template syntax breaks after edit: `chezmoi forget` the file, then re-add as plain (non-template).

## Why `chezmoi re-add` and not `cp`

`chezmoi re-add` preserves `encrypted_` attributes, recurses into dirs, and
refuses to overwrite templates. A raw `cp` to the source risks corrupting state.

## What "managed" means

A file is managed if `chezmoi managed` lists it. Unmanaged files live only on
this machine and are lost on `chezmoi apply` from another host.
