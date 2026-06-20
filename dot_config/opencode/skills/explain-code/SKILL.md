---
name: explain-code
description: >
  Explains code in natural language at configurable depth levels.
  Use when the user asks "explain this code", "what does this do",
  "how does this work", "break this down for me", "explain like I'm 5",
  "what's going on in this function", "walk me through this file",
  "what does this snippet mean", "understand this code",
  "can you tell me what this does", "help me read this code",
  "explain this to a beginner", or pastes a code block and asks about it.
  Also trigger when the user is reading someone else's code in a pair
  programming session and asks for help making sense of it.
---

# Explain Code

Explain code at a depth the user can actually use.

## Depth Levels

Pick the level that matches the user. Default to `intermediate` when in doubt.

- `beginner` — Conceptual. Real-world analogies. Plain language. Assumes the user is new to the language, the framework, or the domain. Define jargon inline when it can't be avoided.
- `intermediate` — Logic, control flow, data transformations, library usage, inputs/outputs, edge cases. Assumes the user can read code but didn't write this particular piece.
- `expert` — Architecture decisions, trade-offs, performance (Big O when relevant), security concerns, alternative approaches, refactoring opportunities.

The user can prefix their request ("explain this like I'm 5", "explain at an expert level"). If they didn't specify, ask before starting.

## Output Format

Always summary first, then breakdown, then notable details.

1. **Summary** — One paragraph. What this code does, its inputs and outputs, its role.
2. **Breakdown** — Sections for logical blocks (function by function, or step by step within a single function). Reference line numbers when they help. Explain intent (the "why"), not syntax (the "what"). The reader can see what the code does; your job is to tell them why it does it that way.
3. **Notable details** (only when relevant) — Edge cases, non-obvious behavior, potential pitfalls, surprising library quirks.

Keep it scannable. Use bold for section names, short paragraphs, and code references like `file_path:line` so the user can jump to the source.

## Explain from Snippet

When the user pastes a code block:

- Explain the snippet as-is.
- If the snippet references things outside itself (imports, variables from other files, framework patterns, language features that aren't obvious), briefly note what additional context would make the explanation more precise. Don't demand the context — just flag the gap and proceed.

## Explain from File

When the user shares a full file:

- Start with the file's role — what is it for, where does it fit in the project.
- Then break down the public API surface (exports, classes, main functions).
- Then drill into internals only for the parts that matter.

## Explain from Chat Context

If the conversation already discussed this code before the "explain" request, use that history. The user has been thinking about this — earlier confusion, related files they showed, corrections they made — all of it sharpens the explanation. Don't treat the request as isolated.

## Boundaries

- Does not write new code or refactor unless the user asks. The skill explains; it does not edit.
- Does not run analysis tools, linters, or formatters.
- When the code is ambiguous or could mean multiple things, flag the ambiguity rather than guessing.
- For library or framework behavior you're not certain about, use the `find-docs` skill to verify before explaining. Bad explanations of framework quirks are worse than no explanation.

## Example

Same function at three depths — a JWT auth middleware in Express.

**Beginner:**
> This is a security checkpoint. Before someone is allowed to use a protected part of the app, this code checks their ID card (the token) to make sure they're really who they say they are. If the ID card is missing, fake, or expired, they're turned away. If it's valid, we stamp the request with their name (`req.user`) and let them through to the next step.

**Intermediate:**
> Middleware that validates a JWT from the `Authorization` header. It strips the `Bearer ` prefix, calls `jsonwebtoken.verify()` with the secret from the env, attaches the decoded payload to `req.user`, and calls `next()` to hand off to the next handler. On any verification failure (missing, malformed, expired), it returns 401 with a specific error message. Note that errors and expired tokens produce different responses, which leaks information about why auth failed.

**Expert:**
> Synchronous `verify()` on the request path blocks the event loop on every call — `jsonwebtoken` supports a callback form if you want async. The secret is loaded from `process.env.JWT_SECRET` without a startup check, so a missing secret will only surface as a runtime throw on the first request. No `audience` or `issuer` validation means the same signing key could be reused across services without isolation. The split error messages (line 18 vs 23) are a minor timing/info-leak vector but probably acceptable for an internal API. Consider wrapping in `try` and returning a single generic 401 if you want to harden it.
