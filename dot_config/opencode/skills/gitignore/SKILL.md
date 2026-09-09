---
name: gitignore
description: >
  Generate and audit .gitignore files by auto-detecting the project's tech stack from
  manifest files. Use when the user says: "create a .gitignore", "set up gitignore",
  "what should I ignore", "review my .gitignore", "check my .gitignore",
  "fix the .gitignore", "add ignores", "project needs a gitignore",
  "init project with gitignore", "update the .gitignore",
  "what's missing from .gitignore". Also fire on new project setup where .gitignore
  is relevant — do not wait for the user to ask.
---

# Skill: gitignore

## When NOT to Use

- User asks about global gitignore config (`core.excludesFile`) — that is a git config question, not project-level
- User asks about git-crypt or secrets management — separate concern
- User wants to remove a tracked file from git — use `git rm --cached`, not .gitignore

## Why Tool, Not Process

.gitignore generation and audit is a precise format operation, not a phased
workflow. One wrong pattern permissively ignores files that should be tracked
(e.g., secrets, credentials, lockfiles for apps) — high consequence.

The detection table routes manifest files to exact template patterns: this
is a decision tree, not a multi-phase process with checkpoints. A Process
pattern would add unnecessary approval gates and iteration loops that don't
exist in the task. Tool is correct because the value is in the detection
decision tree, the exact gitignore patterns, and the checklist-based audit,
not in workflow orchestration.

## Workflow

Two modes: **Generate** (no .gitignore exists) and **Audit** (review existing one).

### Step 1: Detect Ecosystem

Scan project root and one level deep for manifest files. Match in priority order —
first match wins.

**MANDATORY — Read Entire File:** Before composing the .gitignore, load
[references/ecosystems.md](references/ecosystems.md) fully. It contains the
canonical github/gitignore templates for all ecosystems, their detection files,
key patterns, plus a fallback pattern-writing guide for when template URLs
are unreachable.

**Do NOT load** `references/ecosystems.md` after Step 2 is complete — it is
only needed during composition. Do not load it more than once per invocation.

### Before Detecting, Ask Yourself

1. **Generate or audit?** — Does a .gitignore already exist in the project
   root? If yes, run Audit mode (see section below). If no, run Generate mode.
2. **Single ecosystem or monorepo?** — Multiple manifest files at root
   (e.g., `package.json` + `Cargo.toml`) means monorepo. Generate a union of
   ecosystem templates, not just the first match. Also check for workspace
   files (`pnpm-workspace.yaml`, `lerna.json`, `nx.json`).
3. **App or library?** — Apps must commit lockfiles for reproducible installs.
   Libraries should ignore them. For Node.js, check `"private": true` in
   `package.json`. For Rust, `Cargo.lock` is committed for apps, ignored for
   crates (libraries).

| Manifest file(s)                      | Ecosystem       |
|---------------------------------------|-----------------|
| `package.json`                        | Node.js         |
| `pyproject.toml`, `setup.py`, `requirements.txt` | Python |
| `Cargo.toml`                          | Rust            |
| `go.mod`                              | Go              |
| `pom.xml`                             | Java (Maven)    |
| `build.gradle` / `build.gradle.kts`   | Java (Gradle)   |
| `*.csproj` or `*.sln` (glob project)  | .NET/C#         |
| `composer.json`                       | PHP             |
| `Gemfile`                             | Ruby            |
| `pubspec.yaml`                        | Dart/Flutter    |
| `Package.swift`                       | Swift           |
| `CMakeLists.txt`                      | C/C++           |
| `mix.exs`                             | Elixir          |
| `stack.yaml` or `*.cabal` (glob project) | Haskell      |
| `*.tf` (glob project)                 | Terraform       |
| no manifest found                     | Ask user        |

For Node.js projects, also check `package.json` dependencies for framework hints:

| Dependency pattern  | Framework template |
|---------------------|--------------------|
| `next`              | Next.js            |
| `@angular/core`     | Angular            |
| `vue`, `@vue/cli`   | Vue.js             |
| `svelte`, `@sveltejs/kit` | SvelteKit    |
| `nuxt`              | Nuxt.js            |
| `gatsby`            | Gatsby             |
| `react-native`      | React Native       |

If multiple ecosystems detected (monorepo), generate union of relevant templates.

### Step 2: Compose .gitignore

Build the .gitignore in this order:

1. **Universal patterns** — OS files, IDE files, logs, temp files (see below)
2. **Ecosystem-specific** — from template matching the detected manifest
3. **Framework-specific** — from Community template (if detected, Node.js only)
4. **Project-specific** — any user-requested additions

### Step 3: Preview

Show the full proposed content before writing. Format with section headers as comments.
If auditing an existing file, show a diff-style view: what stays, what is new,
what was removed.

### Step 4: Write

Write to `.gitignore` after user confirms. If file already exists, merge:
keep existing rules, add missing patterns, flag dangerous patterns.

## Universal Patterns (Always Include)

```gitignore
# OS files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
Desktop.ini

# Editor/IDE — only if no global excludesFile is configured
# Prefer global ~/.gitignore_global for personal IDE files
.vscode/
.idea/
*.swp
*.swo
*~
.~lock*

# Logs and temp
*.log
*.tmp
*.temp
```

## Audit Mode

When an existing .gitignore is present, run these checks:

1. **Missing ecosystem entries** — does it ignore `node_modules/`, `__pycache__/`, `target/`, `vendor/`?
2. **Tracked-file trap** — run `git check-ignore -v <file>` on files that should be ignored but are not
3. **Over-broad patterns** — `*` catches everything; `**/node_modules` is safer than bare `node_modules`
4. **Negation after ignored parent** — `!important/file` fails if `important/` is itself ignored
5. **Lockfile handling** — apps should commit lockfiles; libraries should ignore them
6. **Stale patterns** — entries for tools no longer in the project
7. **Missing secrets** — `.env`, `.env.local`, `*.key`, `*.pem`, `credentials.*`

Report findings in checklist format: [OK] or [MISSING] or [DANGER], with
one-line fix instructions for each issue found.

## Anti-Patterns

- **NEVER ignore lockfiles for applications.** `package-lock.json`, `yarn.lock`, `Cargo.lock` must be committed for reproducible installs. Only libraries (npm packages without `"private": true`, Rust crates) should ignore them.
- **NEVER put personal IDE/OS ignores in project .gitignore.** `.vscode/`, `.idea/`, `.DS_Store` belong in `~/.gitignore_global` via `git config --global core.excludesFile`. Project .gitignore is for team-shared patterns.
- **NEVER try to ignore a file already tracked by git.** `.gitignore` only affects untracked files. Use `git rm --cached <file>` first, then add to .gitignore.
- **NEVER use negation after a parent-directory ignore.** `build/` then `!build/important.cfg` silently fails because git does not descend into ignored directories.
- **NEVER use `*` as a blanket ignore.** It ignores everything including `.gitignore` itself. Use targeted globs like `*.o`, `build/`, `dist/`.
- **NEVER write a .gitignore without comments.** Grouped sections with `#` headers make maintenance possible. A wall of 50 uncommented patterns rots silently.
- **NEVER overwrite an existing .gitignore without preview.** Always show changes. The user may have project-specific patterns.
- **NEVER generate a .gitignore without detecting the ecosystem.** Scan the filesystem. Guessing wastes time and misses project-specific edge cases.

## Expert Notes

- **Lockfile decision tree:** If `package.json` exists but has no `"private": true`, it is likely a library — ignore lockfiles. If `"private": true` or has scripts/build section, it is an app — commit lockfiles.
- **Monorepo detection:** Multiple manifest files at root (e.g., `package.json` + `Cargo.toml`) indicate a monorepo. Generate union of patterns. Also check for workspace files (`pnpm-workspace.yaml`, `lerna.json`, `nx.json`).
- **Template freshness:** github/gitignore templates are the canonical source. Prefer their patterns over training-data guesses. See `references/ecosystems.md` for raw template URLs.
- **`git check-ignore` is your debugger:** When a file should be ignored but is not, run `git check-ignore -v <path>`. It shows which rule matches (or that none does). This catches pattern errors before they reach production.
