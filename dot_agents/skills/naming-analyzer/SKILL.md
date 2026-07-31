---
name: naming-analyzer
description: Expert naming decisions for non-obvious cases — verb selection (get vs fetch vs load vs retrieve), side-effect-revealing names, refactoring-safe identifiers, scope-calibrated brevity, and domain-specific noun choice. MUST use when user asks to rename, review naming quality, or decide what to call something. Use when user asks to rename variables/functions/classes, review naming quality, fix inconsistent conventions, or decide what to call something. Triggers: rename these variables, what should I call this, naming suggestion, naming convention review, improve these names, bad variable names, naming advice, should I rename.
---

# Naming Analyzer

Expert naming decisions, not basic conventions. The model already knows camelCase — this skill injects the judgment an experienced engineer uses when names actually matter.

## The Naming Mindset

A name is a contract. Before naming or renaming anything, ask:

1. What does it promise?
2. Does the implementation keep that promise?
3. Will the promise survive refactoring?
4. Would a new teammate guess the purpose from the name alone in 6 months?

If the answer to any of these is unclear, the name is wrong.

## Verb Selection Decision Tree

| Verb | Implied contract | Misuse consequence |
|---|---|---|
| `get` | Pure accessor; no I/O, no computation beyond a field read | `getUser()` that hits the database hides latency from every caller |
| `fetch` | Network/disk I/O; may fail or be slow | Callers expect error handling; using it for a memory read causes pointless anxiety |
| `load` | Deserialization or heavy initialization (config, file parse, module boot) | Using it for a lightweight lookup suggests unnecessary cost |
| `retrieve` | Keyed lookup from a store (cache, DB, registry) | Using it for an in-memory field is overpromising |
| `compute` / `calculate` | Non-trivial CPU work | Callers may want to cache; misuse makes trivial work look expensive |
| `find` | Search through a collection; may return null/empty | Using it when the result is guaranteed invites null-check panic |
| `parse` | Converts untrusted input to a typed result; may throw | Using it for safe casts hides failure modes |

The most expensive naming lie is misusing `get` for I/O. Fixing that alone often pays for the whole rename.

## NEVER Do

- **NEVER** name functions `process` / `handle` / `manage` / `do`. They signal unclear responsibility and become dumping grounds for unrelated code. If you cannot pick a stronger verb, the function does too much.
- **NEVER** use `Helper` / `Util` / `Manager` / `Service` suffixes as a default. They are namespaces for orphaned functions. Redistribute by responsibility; if you truly need one, the name should still describe the domain (`PaymentAuthorizer`, not `PaymentHelper`).
- **NEVER** use `data` / `info` / `temp` / `value` / `item` / `obj` as standalone names. Every variable is data. Add the domain: `userData`, `parsedTempFile`, `pendingValue`.
- **NEVER** encode type in the name (`strName`, `intCount`, `arrUsers`). It duplicates the type system and silently lies after a refactor that changes the type.
- **NEVER** name a function for its implementation (`bubbleSortArray`, `mysqlGetUser`). Name it for its contract (`sortItems`, `getUser`) so changing the algorithm or backend does not break every caller's mental model.
- **NEVER** use negated booleans (`isNotEmpty`, `isDisabled`). Affirmative form (`isEmpty`, `isEnabled`) reads naturally in conditions and avoids double-negation traps like `if (!isNotEmpty)`.

## Scope-Calibrated Brevity

| Scope | Acceptable brevity | Reasoning |
|---|---|---|
| <3 lines (lambda, short block) | Single letters: `i`, `x`, `e`, `it` | Comprehension cost is near-zero; reader holds the whole context |
| 3-20 lines (small function) | Short names: `user`, `req`, `res` | Context is still local; full names add noise |
| 20-100 lines | Full descriptive names: `authenticatedUser`, `incomingHttpRequest` | Reader loses track; searchability matters |
| >100 lines / cross-module | Fully qualified: `authenticatedUserSession`, `paymentAuthorizationRequest` | Names must stand alone without surrounding context |

Exempt everywhere: loop counters (`i`, `j`, `k`) and well-known abbreviations (`url`, `id`, `html`, `api`, `db`). They are denser than their long forms without losing clarity.

## Refactoring-Safe Naming

Test every name against this question: *If I change the implementation, does the name still lie?*

| Lies after refactor | Honest alternative |
|---|---|
| `getUserFromDatabase` | `getUser` (backend is an implementation detail) |
| `sendEmailViaSmtp` | `sendEmail` (transport is a detail) |
| `parseConfigYaml` | `parseConfig` (format is a detail) |

Exception: when callers must choose between multiple public implementations, include the distinction (`getUserFromCache` vs `getUserFromDb`). Otherwise, name the **what**, not the **how**.

## Boolean Naming

Use the right prefix for the right relationship:

- `is` for state: `isActive`, `isVisible`
- `has` for possession: `hasPermission`, `hasError`
- `can` for ability: `canEdit`, `canDelete`
- `should` for decisions: `shouldRender`, `shouldValidate`

Anti-pattern: `user.active` is a data field, `user.isActive` is a promise. Prefer the affirmative form (`isEnabled`) over the negative (`isDisabled`) so conditions read naturally and double negatives cannot hide bugs.

## Naming Smell Test

Before finalizing a name, apply this 3-second smell test:

1. **Can you explain what it does WITHOUT using the name?** If not, the name is doing too much conceptual work — it's hiding complexity behind a word.
2. **Would a new team member guess the name from the behavior?** If not, the name doesn't match the mental model.
3. **Does the name appear in the error message?** Good names produce readable errors: `config.timeout` is clear; `cfg.t` is not.

## Pattern: Mindset

This is a **Mindset** skill because effective naming is a judgment skill, not a procedure:

- Thinking > technique. The rules below shape how to reason about a name; they do not produce a single correct output.
- Strong NEVER list. The constraints are explicit about what to avoid, not what to generate.
- High freedom. Multiple valid names can exist for the same thing. The skill calms judgment through principles, not by prescribing one name.

**Why Mindset, not Tool:** Naming is a judgment skill — there's no script that produces the right name. A Tool pattern would require decision trees that map to exact outputs, but naming requires taste and context. Mindset is correct because the value is in the verb-contract decision framework and the NEVER list, not in a procedure.

**Pattern mapping:**
- Thinking > technique: verb-contract decisions, scope-calibrated brevity ✓
- Strong NEVER list: 6+ rules with reasoning ✓
- High freedom: multiple valid names exist ✓
- Short (~116 lines, close to Mindset ideal of ~50) ✓

## Edge Cases

- **Conflicting conventions in legacy codebase:** When a module mixes camelCase and snake_case, prioritize consistency within the MODULE over global uniformity. Don't rename to match a convention that's already violated in the same file.
- **Abbreviations the domain uses:** Domain-specific abbreviations (e.g., `cfg` for config, `ctx` for context) are acceptable if the team uses them consistently. Don't expand to full words if the codebase convention is abbreviated.
- **Single-letter variables in tight scopes:** `i`, `j`, `k` in loops <5 lines are fine. Single letters in scopes >10 lines are not. The rule is scope-length-dependent, not absolute.
- **Renaming public APIs:** Public API names are contracts. Renaming breaks consumers. Flag as a breaking change, suggest deprecation path (new name + old name delegates to new).

## When to Load the Report Template

**MANDATORY — READ ENTIRE FILE**: If the user wants a structured written analysis report (not inline suggestions), load [`references/report-template.md`](references/report-template.md) before generating the report. For quick inline rename suggestions, do NOT load it.

## Quick Decision: What Should I Call This?

```
Boolean?     → is/has/can/should prefix, affirmative form
Function?    → verb from the selection tree, contract not implementation
Class?       → noun describing responsibility, not category
               (PaymentAuthorizer, not PaymentThing)
Constant?    → UPPER_SNAKE_CASE with unit if applicable
               (MAX_RETRY_ATTEMPTS, CACHE_DURATION_MS)
Collection?  → plural noun, or *List/*Map suffix when type is not obvious
Otherwise?   → descriptive noun phrase, scope-calibrated brevity from table above
```
