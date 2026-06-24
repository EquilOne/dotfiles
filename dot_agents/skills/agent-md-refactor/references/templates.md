# Templates

Load this file **only** when actually writing the refactored root and linked files after triage. Not needed for contradiction audits or deletion-only passes.

## Root File Template

```markdown
# Project Name

One-sentence description of the project.

## Quick Reference

- **Package Manager:** pnpm (only if not npm)
- **Build:** `pnpm build`
- **Test:** `pnpm test`
- **Typecheck:** `pnpm typecheck`

## Detailed Instructions

- [Code Style](.claude/code-style.md)
- [Testing](.claude/testing.md)
- [Architecture](.claude/architecture.md)
- [Git Workflow](.claude/git-workflow.md)
- [Security](.claude/security.md) — see before touching auth
```

## Linked File Template

```markdown
# {Topic} Guidelines

Brief context for when these guidelines apply.

## Rules

### {Rule Category}
- Specific, actionable instruction
- Specific, actionable instruction

## Examples

### Good
\`\`\`typescript
// correct pattern
\`\`\`

### Avoid
\`\`\`typescript
// anti-pattern
\`\`\`
```

## Example Groupings

Group by task axis, not language:

- `code-style.md`, `testing.md`, `architecture.md`, `git-workflow.md`, `security.md`
- `frontend.md`, `backend.md`, `data-layer.md`, `deployment.md`
- `domain-a.md`, `domain-b.md` — when the codebase is large and domain boundaries matter more than concerns

## Before/After

### Before

```markdown
# CLAUDE.md

This is a React project.

## Code Style
- Use 2 spaces
- Use semicolons
- Prefer const over let
... (200 more lines)

## Testing
- Use Jest
- Coverage > 80%
... (100 more lines)
```

### After

```markdown
# CLAUDE.md

React dashboard for real-time analytics visualization.

## Quick Reference

- `pnpm dev` — start development server
- `pnpm test` — run tests with coverage
- `pnpm build` — production build

## Detailed Instructions

- [Code Style](.claude/code-style.md)
- [Testing](.claude/testing.md)
- [TypeScript](.claude/typescript.md)
```
