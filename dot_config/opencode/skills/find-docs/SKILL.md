---
name: find-docs
description: >-
  Retrieves up-to-date documentation, API references, and code examples for any
  developer technology. Use this skill whenever the user asks API syntax
  questions, configuration options, version migration issues, setup
  instructions, CLI tool usage, or debugging that involves a specific library,
  framework, SDK, CLI tool, or cloud service. MUST use when the user asks "how
  do I use X", reports a library-specific error, or needs to verify current API
  syntax. Prefer this skill over web search for library documentation and API
  details. Do not rely on training data for API details, signatures, or
  configuration options as they are frequently outdated.
---

# Documentation Lookup

Make sure the CLI is up to date before running commands:

```bash
npm install -g ctx7@latest
```

Or run directly without installing:

```bash
npx ctx7@latest <command>
```

## Quick Reference: Symptom → Fix

| Error Code / Symptom | Cause | Fix |
|---|---|---|
| Quota exceeded | Rate limit hit | Wait or switch library |
| Network timeout | ctx7 unreachable | Retry with backoff |
| Empty results | Library not indexed | Use WebSearch fallback |
| Stale docs | Version mismatch | Specify version explicitly |

## Progressive Disclosure

**This skill is self-contained** — no reference files needed. The ctx7 CLI is invoked directly.

**When to load additional context:**
- If the user asks about a library NOT in ctx7's index → load WebSearch as fallback
- If ctx7 returns version-specific docs → check the user's package.json/requirements.txt for the exact version
- If the user asks "how do I use X" for a framework → also check if there's a relevant skill (e.g., omarchy for Hyprland)

## Pattern: Tool

**Why Tool, not Process:** Doc retrieval is a precise operation on ctx7's index — one wrong library ID returns wrong docs. A Process pattern would add unnecessary workflow phases. Tool is correct because the value is in the decision tree (which library? which doc type?) and exact CLI commands.

**Why Tool, not Mindset:** The value is in ctx7 operational knowledge (coverage gaps, stale docs detection, version-specific queries), not a thinking framework. Mindset is ~50 lines; find-docs needs ~200 for the command reference and error handling.

**Pattern mapping:**
- Decision trees: library selection rules, error → fix table ✓
- Code examples: exact ctx7 CLI commands ✓
- Low freedom: wrong library ID = wrong docs ✓
- ~200 lines (within Tool range) ✓

## Do NOT Load

- Do NOT use for general web search (non-library queries) — use the search subagent
- Do NOT use for explaining existing code — use explain-code
- Do NOT use for tutorial-style learning — use socratic-mentoring

## When to Use This Skill

Use this skill for any question tied to a specific technology and its current docs.

## Thinking Frame (Expert)

- **Before searching:** Is this a library-specific question or a general concept? Library-specific → ctx7. General concept → answer directly or use search. The distinction matters: ctx7 returns API docs, not conceptual explanations.
- **During search:** Am I getting docs or just API signatures? If only signatures, query with "guide" or "tutorial" keywords. If getting stale docs, specify the version explicitly: `resolve-library-id --library "react@18"`.
- **After search:** Do I need to verify against current source or is the doc sufficient? For version-specific behavior, cross-check with the changelog. For stable APIs, the doc is enough.
- **Failure mode:** If ctx7 returns nothing, DON'T fall back to training data silently. Tell the user: "ctx7 has no index for this library. I can search the web or use my training data — which do you prefer?"

Also ask yourself:
- **Does the user mention a specific version?** → Use version-specific library ID (`/org/project/version`).
- **Is the question about behavior or syntax?** → Behavior questions need broader queries; syntax questions need precise API names.
- **Could the answer be in multiple libraries?** → Run `ctx7 library` once, pick the best match, don't query all of them.

## When NOT to Use This Skill

- **General web search** → Use a search subagent or WebSearch for news, comparisons, or opinion.
- **Code explanation** → Use the `explain-code` skill when the user wants to understand existing code.
- **Tutorial-style learning** → Use the `socratic-mentoring` skill for guided lessons and concept exploration.

## Workflow

Two-step process: resolve the library name to an ID, then query docs with that ID.

```bash
# Step 1: Resolve library ID
ctx7 library <name> <query>

# Step 2: Query documentation
ctx7 docs <libraryId> <query>
```

You MUST call `ctx7 library` first to obtain a valid library ID UNLESS the user explicitly provides a library ID in the format `/org/project` or `/org/project/version`.

## NEVER

- **NEVER** run `ctx7 docs` without first running `ctx7 library` — the command requires a resolved library ID, not a package name. It will fail silently or return garbage.
- **NEVER** omit the `/` prefix on library IDs — `/facebook/react` works, `facebook/react` does not. This is the #1 cause of "library not found" errors.
- **NEVER** use single-word queries like "hooks" or "auth" — ctx7 ranks results by query specificity. Vague queries return generic, unhelpful snippets. Use the user's full question.
- **NEVER** include API keys, passwords, or proprietary code in queries — queries are sent to Context7's servers.
- **NEVER** retry more than 3 times per question — if 3 attempts fail, the library likely isn't indexed. Use your best result and note the limitation.
- **NEVER** silently fall back to training data on quota errors — always tell the user Context7 was unavailable and why.
- **NEVER** query the same library twice with slightly different phrasing — ctx7 results are deterministic per query; rephrasing wastes your 3 attempts.
- **NEVER** assume the indexed version is the latest release — always check returned version metadata.

## Step 1: Resolve a Library

Resolves a package/product name to a Context7-compatible library ID and returns matching libraries.

```bash
ctx7 library react "How to clean up useEffect with async operations"
ctx7 library nextjs "How to set up app router with middleware"
ctx7 library prisma "How to define one-to-many relations with cascade delete"
```

Always pass a `query` argument — it is required and directly affects result ranking. Use the user's intent to form the query, which helps disambiguate when multiple libraries share a similar name. Do not include any sensitive or confidential information such as API keys, passwords, credentials, personal data, or proprietary code in your query.

### Result fields

Each result includes:

- **Library ID** — Context7-compatible identifier (format: `/org/project`)
- **Name** — Library or package name
- **Description** — Short summary
- **Code Snippets** — Number of available code examples
- **Source Reputation** — Authority indicator (High, Medium, Low, or Unknown)
- **Benchmark Score** — Quality indicator (100 is the highest score)
- **Versions** — List of versions if available. Use one of those versions if the user provides a version in their query. The format is `/org/project/version`.

### Selection rules

When multiple libraries match:
1. Prefer **exact name match** over partial
2. Prefer **higher benchmark score** (max 100) — indicates doc quality
3. Prefer **higher code snippet count** — more examples available
4. Prefer **High/Medium source reputation** over Low/Unknown
5. If still ambiguous, acknowledge alternatives but proceed with the best match

### Version-specific IDs

If the user mentions a specific version, use a version-specific library ID:

```bash
# General (latest indexed)
ctx7 docs /vercel/next.js "How to set up app router"

# Version-specific
ctx7 docs /vercel/next.js/v14.3.0-canary.87 "How to set up app router"
```

The available versions are listed in the `ctx7 library` output. Use the closest match to what the user specified.

## Step 2: Query Documentation

Retrieves up-to-date documentation and code examples for the resolved library.

```bash
ctx7 docs /facebook/react "How to clean up useEffect with async operations"
ctx7 docs /vercel/next.js "How to add authentication middleware to app router"
ctx7 docs /prisma/prisma "How to define one-to-many relations with cascade delete"
```

### Output format

Results contain two types of content: **code snippets** (titled, with language-tagged blocks) and **info snippets** (prose explanations with breadcrumb context).

## Expert Tips: Coverage, Querying, and Staleness

- **Coverage varies by ecosystem.** Large, well-documented projects with public GitHub-hosted docs tend to have good coverage (e.g., React, Next.js, Prisma, Tailwind, Django, Spring Boot). Smaller npm packages, private libraries, and brand-new releases are often absent or only partially indexed.
- **Query strategy matters.** Combine the library name with the specific API, option, or error message. "Prisma relationMode" or "Next.js middleware matcher" returns focused results; "database config" or "routing" returns noise.
- **Detect stale docs by version.** If the returned snippet mentions an older version than the user is running, or if the API shape conflicts with the library's current source, the index is lagging. Check the version field in `ctx7 library` output and prefer an explicit `/org/project/version` ID.
- **Handle unindexed libraries.** If `ctx7 library` returns nothing after a broader query and alternative names, the library is likely not indexed. Fall back to WebSearch for current docs, or answer from training knowledge with a clear "not indexed" caveat.
- **Version drift detection:** When ctx7 returns docs for "react" without a version, it defaults to the latest indexed version. If the user's package.json specifies react@17 but ctx7 returns react@18 docs, the API signatures may differ (e.g., `useEffect` cleanup timing changed in 18). Always cross-check: if the user mentions a version, pass it explicitly: `resolve-library-id --library "react@17"`.

## Authentication

Works without authentication. For higher rate limits:

```bash
# Option A: environment variable
export CONTEXT7_API_KEY=your_key

# Option B: OAuth login
ctx7 login
```

## Error Handling

**Quota error** ("Monthly quota reached" / "quota exceeded"):
1. Inform the user their Context7 quota is exhausted
2. Suggest `ctx7 login` for higher limits
3. If they decline, answer from training knowledge and clearly note it may be outdated

**No results** (`ctx7 library` returns empty):
1. Try a broader query — drop specific version or feature details
2. Try alternative names — ctx7 indexes by GitHub org/project, not npm names (e.g., "vue" → "vuejs", "svelte" → "sveltejs", "nextjs" → "next.js", "react-router" → "react router dom")
3. If still empty, the library isn't indexed — answer from training knowledge with a note

**Network error** (timeout, connection refused):
1. Check if `npx ctx7@latest --version` works — confirms CLI is reachable
2. Retry once after a brief pause
3. If persistent, answer from training knowledge and note the outage

**Rate limiting** (429 errors):
1. Slow down — space queries apart
2. If repeated, treat as quota error (suggest authentication)

**Edge case: Library name collisions:** Some library names collide across ecosystems (e.g., "redis" exists in npm, pip, and go modules). When resolving, include the ecosystem: `resolve-library-id --library "redis" --topic "python"` to disambiguate. If the user doesn't specify the ecosystem, infer from the project's package manager.

Do not silently fall back to training data — always tell the user why Context7 was not used.
