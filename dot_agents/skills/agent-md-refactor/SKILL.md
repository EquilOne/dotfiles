---
name: agent-md-refactor
description: "Refactor bloated agent instruction files (AGENTS.md, CLAUDE.md, COPILOT.md, GEMINI.md, .cursorrules) into a minimal root file plus linked, topic-focused files using progressive disclosure. Use when: the user says 'refactor/split/organize/clean up my AGENTS.md/CLAUDE.md', 'my agent instructions are too long', 'apply progressive disclosure to my agent config', or any root instruction file exceeds ~100 lines or mixes unrelated topics (code style, testing, architecture, git workflow). MUST use before adding new instructions to an already-bloated root file."
license: MIT
---

# Agent MD Refactor

Refactor bloated root agent-instruction files into a minimal root that every task loads and a small set of topic-focused linked files that task-specific agents retrieve on demand. The goal is to maximize signal and minimize always-loaded context.

## Triggers

Use this skill when the user says:
- "refactor my AGENTS.md / CLAUDE.md / COPILOT.md / GEMINI.md / .cursorrules"
- "split / organize / clean up my agent instructions"
- "my agent instructions are too long"
- "apply progressive disclosure to my agent config"
- before adding new instructions to an already-bloated root file

## Thinking Frame — Before Refactoring, Ask Yourself

- **Frequency.** What % of tasks touch this instruction? >70% → root candidate; <30% → split candidate; 30-70% → judgment call, use the decision tree.
- **Load vs. retrieval cost.** Is it cheaper to always-load in root (tokens on every task) or on-demand-load from a linked file (tokens only when relevant)?
- **Override strength.** Does this override a model default? If yes and frequent → root. If yes and rare → linked file with a one-line pointer in root.
- **Conflict surface.** Does this instruction conflict with another? Resolve BEFORE moving, not after.
- **Co-change.** Do two instructions reference or depend on each other? They belong in the *same* file, even if they'd otherwise split by topic. Splitting co-dependent rules forces the agent to load two files for one task — a silent tax.
- **Negative vs. positive framing.** A negative rule ("NEVER use `any`") carries more signal than a positive one ("use specific types"). Before routing, convert weak positives to strong negatives where possible — the converted rule may then qualify for deletion (if it merely restates a default) or become compact enough for root.

## Triage Decision Tree

```
>70% of tasks AND overrides a default     -> ROOT
>70% of tasks AND restates a default      -> DELETE
<30% of tasks                              -> LINKED FILE
Vague ("write clean code")                 -> DELETE (or specify on the spot)
Conflicts with another instruction         -> RESOLVE WITH USER FIRST
Project-specific command/build/test        -> ROOT QUICK REFERENCE
Ambiguous frequency                        -> LINKED FILE (on-demand is cheaper)
```

## Consolidation Rule (Inverse of Splitting)

After triage, if any two linked-file candidates would each be <15 lines OR share >50% of their task context, merge them. Two tiny files cost more to discover and load than one focused file. Signs you should merge:

- Both are consulted by the same task axis (e.g., `code-style.md` and `naming.md` are both "write code" → merge).
- One file's rules always require the other's to make sense (co-change, see above).
- The combined file stays under ~60 lines.

Conversely, split a linked file if it exceeds ~80 lines or spans two unrelated task axes.

## Workflow

### Phase 1: Resolve Contradictions

Before moving anything, surface conflicts:

```markdown
## Contradiction Found

**Instruction A:** [quote]
**Instruction B:** [quote]

**Question:** Which should take precedence, or should both be conditional?
```

Let the user resolve; do not proceed until contradictions are settled.

If the user refuses to pick a winner or is unsure, do not stall the whole refactor: document both instructions as conditional ("use A when X; use B when Y") and route the pair to the same linked file. Record the unresolved conflict in the deletion/output table so it stays visible.

### Phase 2: Triage Every Instruction

Apply the decision tree to every instruction. Output:

| Instruction | Decision (root/split/delete) | Reason |
|-------------|------------------------------|--------|
| ...         | ...                          | ...    |

### Phase 3: Group Split-Candidates

Group by **task axis** (testing, code-style, architecture, git-workflow), NOT by file type (typescript.md, python.md). Agents load by task, not by language. A `typescript.md` consulted on every task is worse than keeping it in root. See [`references/templates.md`](references/templates.md) for example groupings.

### Phase 4: Write the Root + Linked Files

Write a minimal root file with a Quick Reference section and a Detailed Instructions section pointing to each linked file.

**MANDATORY — READ ENTIRE FILE**: Before writing any linked file, read [`references/templates.md`](references/templates.md) for the root-file template, linked-file template, and a worked before/after example. Do NOT load it for pure contradiction-resolution or deletion-only passes.

**Do NOT load** templates.md if the user only wants a deletion pass or contradiction audit.

### Phase 5: Flag for Deletion

Delete if the model already does this by default **and** no override is needed. Vagueness alone isn't enough — "write clean code" is deletable; "write clean code with no comments in this codebase" is an override worth keeping.

Output a deletion table:

| Instruction | Reason |
|-------------|--------|
| ...         | ...    |

## NEVER Do

- **NEVER split by file type/language.** Agents load by *task*, not by language. A `typescript.md` consulted on every task is worse than the same content in root — you've added a retrieval hop with no load savings.
- **NEVER keep an instruction in root because it's "important".** Importance ≠ frequency. A critical-but-rare security rule belongs in `security.md` with a one-line pointer in root ("See security.md before touching auth").
- **NEVER split into more than 8 files.** Beyond 8, the agent can't hold the link map in working memory and starts missing relevant files. Consolidate first.
- **NEVER delete an instruction without surfacing it.** Always output a deletion table the user can veto — silent deletion destroys intent.
- **NEVER resolve contradictions by picking a winner silently.** Surface the conflict with both quotes and ask the user. Auto-resolving breaks the user's mental model of their own config.
- **NEVER move instructions into a linked file the agent won't discover.** Every linked file MUST be linked from the root's "Detailed Instructions" section; unlinked files are dead weight.
- **NEVER refactor without a clean git state.** Refactoring touches many files at once; the user must be able to `git diff` and roll back. Refuse to proceed if `git status` is dirty.

## Monorepo / Nested Root Case

In a monorepo where sub-projects need their own agent context, apply the same rules at *each* level:

- Repo root file: cross-cutting rules that apply to every sub-project (CI, shared tooling, top-level commands).
- Sub-project root file (`apps/web/AGENTS.md`): only rules unique to that sub-project, plus a one-line pointer to the repo root.
- Never duplicate a rule at both levels — if it applies to all sub-projects, it belongs at repo root only.

If a sub-project has no unique rules, do NOT create an empty root file — link to the repo root from the sub-project's primary doc instead.

## Verification Checklist

- [ ] Root file contains only >70% frequency instructions, project commands, and links
- [ ] Every linked file is reachable from the root via one link
- [ ] Deletions were surfaced in a table the user could veto
- [ ] No contradictions remain between root and linked files
- [ ] File count is 3-8; if >8, consolidate before declaring done
- [ ] User had a clean git state before files were changed
