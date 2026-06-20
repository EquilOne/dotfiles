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
dotfile change is captured. Uses `chezmoi re-add`. Chezmoi's `autoCommit`
and `autoPush` settings (if enabled in `~/.config/chezmoi/chezmoi.toml`)
will auto-commit and push each re-add — this skill detects that and warns
before bundling unrelated changes.

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
   `chezmoi source-path` prints an error to **stderr** and exits **non-zero**
   if the file is not managed. Suppress stderr and ignore the exit code; treat
   empty stdout as **not managed**. Stop for that file; offer `chezmoi add
   "$file"` if the user wants to start tracking it. Non-empty stdout is the
   source path → managed, continue.

4. Detect template. If the source path ends in `.tmpl`:
   - Do NOT sync. Overwriting with rendered bytes would strip template logic.
   - Tell the user the file is templated and they should edit the source
     directly with `chezmoi edit -- "$file"`.
   - Stop.

5. Pre-flight git check (before any re-add):
   - Query `chezmoi data` for `git.autoCommit` and `git.autoPush`.
   - Run `chezmoi git -- status --porcelain` to list uncommitted source changes.
   - If `autoCommit` is ON and there are uncommitted changes that are NOT
     the file(s) about to be synced: STOP and warn. `re-add` will bundle
     ALL pending changes into one auto-commit with a default concatenated
     message (e.g. "Update fileA Update fileB Update fileC"). Ask the user:
     - Commit the pending changes first with a clean message
       (`chezmoi git -- commit -am "..."`), then re-add.
     - Proceed anyway and accept the bundled commit.
   - If `autoCommit` is ON and the source tree is clean: proceed; re-add
     will auto-commit just this one file (clean commit).
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
   - Auto-committed + pushed: `synced $file -> $src (commit $hash, pushed to remote)`
   - Auto-committed, no push: `synced $file -> $src (commit $hash)`
   - No auto-commit: `synced $file -> $src (run \`chezmoi git -- commit\` to commit)`
   - No output, no commit: `already in sync: $file`

## Multi-file edits

When several config files were edited in one turn, loop over each. Run the
pre-flight check ONCE before the loop (not per file). Summarize per-file
results in one block:

```
synced:
  ~/.zshrc -> ~/.local/share/chezmoi/dot_zshrc (commit abc1234, pushed)
already in sync:
  ~/.config/zed/settings.json
not managed:
  ~/.config/foo/config.toml
templates (use `chezmoi edit`):
  ~/.config/bar/settings.json
```

## Helper script

`scripts/chezmoi-sync.sh` runs the workflow above for one or more files.
For a single file, the workflow steps above are sufficient. For 2+ files
or when the user asks to "sync everything", prefer the script.

Exit codes:
- 0: all files processed (synced, already-in-sync, unmanaged, or template)
- 1: one or more re-add operations failed
- 2: pre-flight warning — autoCommit is on and source tree has uncommitted
     changes that would be bundled. Re-run with `--force` to proceed anyway.

```bash
sh skills/chezmoi-sync/scripts/chezmoi-sync.sh ~/.zshrc ~/.config/zed/settings.json
sh skills/chezmoi-sync/scripts/chezmoi-sync.sh --force ~/.zshrc
```

## Why `chezmoi re-add` and not `cp`

`chezmoi re-add` is the official path: it preserves `encrypted_` attributes,
recurses into directories, and refuses to overwrite templates. A raw `cp` to
the source path would skip all of that and risk corrupting the source state
on encrypted or attribute-bearing entries.

## What "managed" means

`chezmoi managed` lists every destination file chezmoi owns. Files outside
that list live only on this machine and will be lost on `chezmoi apply` from
another host.
