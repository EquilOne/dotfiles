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

## Do NOT Load

Use this skill ONLY for explaining existing code. Do NOT use when:
- The user wants API reference or library docs → use `find-docs`
- The user wants to learn by discovery (Socratic questioning) → use `socratic-mentoring`
- The user wants to write new code → use `coder` subagent
- The user wants a code review → use `review` subagent

The distinction: explain-code gives a direct explanation at a chosen depth. socratic-mentoring makes the user reason to the answer themselves.

# Explain Code

Explain code at a depth the user can actually use.

## Depth Levels

**Quick depth selection:**

| User Signal | Depth | Format |
|-------------|-------|--------|
| "ELI5" / "I'm new to this" / "explain like I'm 5" | beginner | Analogy + simple example, define jargon |
| "How does X work?" / "what does this do" (no qualifier) | intermediate | Summary + breakdown + notable details |
| "Walk me through the internals" / "architecture" / "trade-offs" | expert | Full architecture + trade-offs + edge cases + alternatives |

When in doubt, default to `intermediate` and ask if they want more or less depth.

Pick the level that matches the user. Default to `intermediate` when in doubt.

- `beginner` — Conceptual. Real-world analogies. Plain language. Assumes the user is new to the language, the framework, or the domain. Define jargon inline when it can't be avoided.
- `intermediate` — Logic, control flow, data transformations, library usage, inputs/outputs, edge cases. Assumes the user can read code but didn't write this particular piece.
- `expert` — Architecture decisions, trade-offs, performance (Big O when relevant), security concerns, alternative approaches, refactoring opportunities.

The user can prefix their request ("explain this like I'm 5", "explain at an expert level"). If they didn't specify, ask before starting.

## Calibration

Before explaining, ask yourself (don't ask the user unless depth is unclear):
1. **What does the user already know?** (language, framework, codebase familiarity)
2. **What do they need to do after understanding this?** (debug, refactor, review, learn)
3. **What's the one thing they'd miss without help?** (that's where you add value)

## Explanation Failure Modes

Three cognitive biases ruin code explanations. Watch for them:

- **Curse of knowledge:** Once you understand something, you can't remember what it was like not to. This makes you skip steps that the reader needs. Fix: always include a "why this matters" framing before diving into mechanics. If you can't explain why it matters to a beginner, you don't understand it well enough.
- **False consensus:** Assuming the reader knows the same background you do. This produces explanations that reference unstated concepts. Fix: explicitly state prerequisites at the top ("This assumes you know what a callback is"). If unsure, ask the calibration questions.
- **Anchoring bias:** Leading with implementation details when the reader needs the concept first. The first thing you say becomes the reader's anchor — if that's a line of code, they'll think in code, not in concepts. Fix: start with the "what" and "why" before the "how." Summary-first format exists to break this bias.

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

## NEVER Do

- **NEVER guess when code is ambiguous.** If a variable name could mean two things, a function call could be sync or async, or a pattern could be intentional or accidental — flag the ambiguity explicitly. "This could mean X or Y; I'll assume X but confirm" is honest. Guessing silently erodes trust.
- **NEVER explain what the code does when the user asks why.** "What" is syntax — the reader can see that. "Why" is intent — the design decision, the trade-off, the constraint that made this approach necessary. If they ask "what does this do," they want the "why" underneath.
- **NEVER explain at the wrong depth.** A beginner asking "what does this do" doesn't need Big O analysis. An expert asking "walk me through this" doesn't need a for-loop explanation. The depth levels exist for a reason — match the user's level, not your default.
- **NEVER use the `find-docs` skill to verify library behavior you're confident about.** Only verify when genuinely uncertain about framework quirks, version-specific behavior, or undocumented edge cases. Over-verification wastes time and signals lack of confidence.
- **NEVER explain the entire file when the user points at a function.** If they paste a snippet or point at specific lines, explain those. Drilling into unrelated code is scope creep. Note what's relevant and move on.
- **NEVER produce explanations longer than the code itself** (unless the code is trivially short and the user needs conceptual grounding). If your explanation is 3x the code's length, you're probably explaining syntax, not intent.
- **NEVER explain without first checking the user's level.** Because: explaining at the wrong depth wastes everyone's time — too shallow bores the expert, too deep confuses the beginner. The calibration questions take 5 seconds and save a useless explanation.
- **NEVER use jargon without defining it on first use.** Because: undefined jargon creates false understanding — the reader nods along but didn't actually follow. Define on first use even at expert depth, because "expert" in one domain may be "beginner" in another.

## Example

Same function at three depths — a JWT auth middleware in Express.

**Beginner:**
> This is a security checkpoint. Before someone is allowed to use a protected part of the app, this code checks their ID card (the token) to make sure they're really who they say they are. If the ID card is missing, fake, or expired, they're turned away. If it's valid, we stamp the request with their name (`req.user`) and let them through to the next step.

**Intermediate:**
> Middleware that validates a JWT from the `Authorization` header. It strips the `Bearer ` prefix, calls `jsonwebtoken.verify()` with the secret from the env, attaches the decoded payload to `req.user`, and calls `next()` to hand off to the next handler. On any verification failure (missing, malformed, expired), it returns 401 with a specific error message. Note that errors and expired tokens produce different responses, which leaks information about why auth failed.

**Expert:**
> Synchronous `verify()` on the request path blocks the event loop on every call — `jsonwebtoken` supports a callback form if you want async. The secret is loaded from `process.env.JWT_SECRET` without a startup check, so a missing secret will only surface as a runtime throw on the first request. No `audience` or `issuer` validation means the same signing key could be reused across services without isolation. The split error messages (line 18 vs 23) are a minor timing/info-leak vector but probably acceptable for an internal API. Consider wrapping in `try` and returning a single generic 401 if you want to harden it.

## Example 2: Python Data Pipeline

**Beginner:**
> This function takes messy data from a spreadsheet and cleans it up. It removes empty rows, fixes inconsistent date formats, and makes sure all the numbers are actually numbers (not text that looks like numbers). Think of it as a quality-control checkpoint before the data gets used.

**Intermediate:**
> A pandas pipeline that chains three transformations: `dropna()` on the index to remove empty rows, `pd.to_datetime()` with `format='mixed'` to normalize date strings, and `pd.to_numeric(errors='coerce')` to convert non-numeric values to NaN. The `pipe()` pattern keeps it composable — each step receives and returns a DataFrame. Note that `errors='coerce'` silently converts bad values to NaN, which may hide data quality issues.

**Expert:**
> The `format='mixed'` flag on `pd.to_datetime` (pandas 2.0+) parses heterogeneous date strings without a fixed format — useful but slower than specifying an exact format. The `errors='coerce'` on `to_numeric` is a deliberate choice to degrade gracefully rather than fail, but it means downstream code must handle NaN. Consider adding a logging step that counts coerced values so data quality doesn't silently deteriorate. The `pipe()` chain is clean but doesn't short-circuit — if the first step eliminates 90% of rows, the subsequent steps still process the full DataFrame before filtering.

## Example 3: Rust Memory Ownership

**Beginner:**
> This code handles a book in a library. When you check out a book, only one person can have it at a time. When you're done, you give it back. The rules make sure no one tries to read a book that doesn't belong to them, and the library always knows who has it.

**Intermediate:**
> The function takes ownership of a `String`, lends it temporarily as a read-only reference (`&String`) to a helper, and then returns the original value so the caller keeps owning it. Rust's borrow checker enforces that only one mutable reference can exist at a time, so this pattern avoids data races without a garbage collector.

**Expert:**
> Ownership is transferred into `process()` and then back out via the return value, a common RAII idiom. The immutable borrow inside `helper()` is scoped to the call, so it cannot outlive the owned value; the compiler proves this statically with lifetimes. No `Clone` or `Rc` is needed because the single-owner discipline is sufficient. If this were a hot loop, returning the owned value avoids heap allocation overhead compared to cloning, but it forces the caller to handle the moved value explicitly.
