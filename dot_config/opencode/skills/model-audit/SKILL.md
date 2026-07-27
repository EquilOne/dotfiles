---
name: model-audit
description: >
  Audit opencode agent model config against live OpenRouter pricing and benchmarks.
  Recommends model swaps at three tiers (budget, value, best) so you can choose per agent.
  MUST use when the user asks to review, audit, or optimize their opencode agent models.
  Use when the user asks: "review my models", "audit my models", "model suggestions",
  "better model for X", "cheaper model", "model pricing", "optimize model spend",
  "model recommendations", "update my agent models", "opencode model config",
  "budget model", "value model", "best model", "what models should I use",
  "model performance review", "benchmark my models", "cut model costs", "model audit".
  Also triggers when the user wants to compare model pricing, check benchmark scores,
  or find cost-effective alternatives for their agents.
---

# Model Audit — OpenRouter Model Suggestion Skill

Audit opencode agent model config against live OpenRouter pricing and benchmarks. Recommends model swaps at three tiers so you can choose per agent.

## Prerequisites

OpenRouter MCP must be configured and enabled in `opencode.json`:
```json
"mcp": {
  "openrouter": {
    "type": "remote",
    "url": "https://mcp.openrouter.ai/mcp",
    "enabled": true
  }
}
```
If disabled, tell the user and offer to enable it (with authorization).

## Why Process, Not Tool or Mindset

**Why Process, not Tool:** Model auditing is a multi-phase workflow with ordered steps and checkpoints (read config → query → assign tiers → present → apply). A Tool pattern would collapse this into a single decision tree, but each phase has its own sub-decisions and the output of one phase feeds the next. The value is in the workflow orchestration, not in a single precise operation.

**Why Process, not Mindset:** Auditing requires specific procedural knowledge (which MCP tools to call, which JSON paths to edit, which sort parameters to use). A Mindset pattern (~50 lines) would provide only thinking frameworks and miss the domain-specific steps that make the skill work. The procedures are not generic — they're specific to OpenRouter's MCP API and opencode's config structure.

**Pattern mapping:**
- Ordered phases with checkpoints ✓
- Medium freedom (judgment within fixed structure) ✓
- ~163 lines (within Process range) ✓
- Output of one phase feeds the next ✓
- Authorization gate in Phase 5 as a checkpoint ✓

## Workflow

### Phase 1: Read Current Config

**Before Phase 1, ask yourself:**
- What kind of audit is this? (full sweep across all agents vs single-agent deep dive)
- What's the user's primary goal? (cost reduction, quality improvement, or both)
- Which agents are most cost-sensitive? (search, explore, scout consume more tokens per call)

Then read these files:
- `opencode.json` — extract `agent.*.model`, `small_model`, `provider.openrouter.models`
- `agent_stack.md` — extract agent-to-model mapping table
- `agents/*.md` — extract any `model:` frontmatter overrides per agent

Build a map of: agent name → current model slug → role category.

Classify each agent into one role:

| Role | Description | What matters | Example agents |
|------|-------------|-------------|----------------|
| coding | Writes, refactors, reviews code | coding_index, tool support | coder, build, review |
| reasoning | Planning, architecture, design | intelligence_index, reasoning_effort | plan, conductor |
| agentic | Multi-step, tool use, orchestration | agentic_index, tool calling | fixer, general |
| lightweight | Simple lookups, search, exploration | low price, low latency | search, explore, scout |
| general | Chat, docs, explanation | balanced across all | docs, chat, mentor |

### Phase 2: Query OpenRouter

**Before Phase 2, ask yourself:**
- Which benchmark matters most for THIS agent? (coding for coder, intelligence for plan, price for search)
- Is this agent latency-sensitive or throughput-sensitive? (latency → prefer near providers, throughput → sort by throughput)
- Does this agent use structured outputs or tool calling? (if yes, must filter for those)

Then fan out these queries in parallel via OpenRouter MCP tools:

1. **list-models** with `sort=coding-high-to-low` (for coding role), `sort=intelligence-high-to-low` (for reasoning), `sort=agentic-high-to-low` (for agentic), `sort=pricing-low-to-high` (for lightweight). Use `limit=20` per query.
2. **get-model** for the current model to get its benchmarks and pricing.
3. **list-model-endpoints** for the current model to see provider-level pricing and uptime.

For candidate models, filter by:
- Supports reasoning_effort if agent uses reasoning
- Supports structured_outputs and tools if agent is agentic/coding
- Context length >= 32K for all agents, >= 128K for reasoning/agentic

**Error recovery:**
- If `list-models` returns an error or empty results: fall back to `get-model` for the current model only, and use known alternatives from training data. Note the data source in the output.
- If `get-model` fails for the current model: report that the model could not be found on OpenRouter and suggest the user verify the slug.
- If `list-model-endpoints` fails: proceed with base pricing from `get-model` and note that provider-level pricing is unavailable.
- If the user has zero credits: warn them and suggest checking their account before proceeding.
- If rate limited: wait 1 second and retry once. If rate limited again, fall back to `get-model` for the current model only and note the data source.

### Phase 3: Tier Assignment

For each agent role, pick candidates from the query results:

**Budget tier** (lowest price):
- For lightweight role: cheapest model with any benchmark > 10
- For other roles: cheapest model with the relevant benchmark > 30
- Flag if the model lacks tool support or structured outputs

**Value tier** (best perf/$ - default recommendation):
- Compute rough perf/$ = (relevant benchmark score) / (avg prompt+completion price per M tokens)
- Pick the model with highest perf/$ ratio
- Must support all features the agent needs (tools, structured_outputs, reasoning_effort if applicable)

**Best tier** (highest quality):
- Highest relevant benchmark score regardless of price
- Must support all features the agent needs
- Note the price delta vs. current model

**Error recovery:**
- If no candidates meet the budget tier threshold: relax the benchmark minimum by 10 points and retry. Note the relaxation in the output.
- If no candidates meet the value tier criteria: fall back to the budget pick and note that no true value option was found.
- If the query returns fewer than 3 candidates total: still assign what's available and note the limited selection.

### Phase 4: Present Results

Output format per agent:

```
## Agent: {name}
Role: {role} | Current: {current_model} (${prompt_price}/$M in, ${completion_price}/$M out)
Benchmarks: coding {n}, intelligence {n}, agentic {n}

| Tier | Model | Prompt $/M | Output $/M | Coding | Intel | Agentic | Context |
|------|-------|-----------|------------|--------|-------|---------|---------|
| Current | {slug} | {price} | {price} | {n} | {n} | {n} | {n} |
| Budget | {slug} | {price} | {price} | {n} | {n} | {n} | {n} |
| Value ★ | {slug} | {price} | {price} | {n} | {n} | {n} | {n} |
| Best | {slug} | {price} | {price} | {n} | {n} | {n} | {n} |

>> Recommendation: {tier} — {reason}
```

If the current model is already the best pick for its tier, say so and skip the recommendation.

If the cheapest provider endpoint has notably better pricing (e.g., 40%+ discount via a specific provider), note it:
```
>> Cheapest provider: {provider_name} at ${price} prompt (${discount}% off base)
```

### Phase 5: Apply Changes (if authorized)

If the user says "apply" or "write changes" or equivalent:

1. Update `agent.<name>.model` in `opencode.json` for each changed agent
2. Add the new model to `provider.openrouter.models` with appropriate options (copy reasoning_effort, verbosity from the old model's config if applicable)
3. Remove the old model from `provider.openrouter.models` if no longer used by any agent
4. Report the diff: "Changed N models, saved ~$X/M tokens estimated"

## Output Rules

- Show all three tiers per agent even when the recommendation is clear. Give the user choice.
- Sort agents by potential savings (biggest cost impact first) when doing a full audit.
- When the user asks about one specific agent, only audit that one.
- Include absolute benchmark numbers, not relative ranks. Ranks change daily; index scores are more stable.
- Note when a model is new (< 30 days old) — higher risk of instability.
- Note when a model's cheapest provider has low uptime (< 95% in last 30m) — reliability trade-off.
- If any data source was a fallback (e.g., known alternatives from training data instead of live MCP), note it in the output.

## Freedom Calibration

Each phase constrains the model differently. The consequence of a mistake determines the freedom level:

| Phase | Freedom | Why |
|-------|---------|-----|
| Phase 1: Read Config | Low | Exact file paths and specific fields to extract. Missing a field means the audit is incomplete. |
| Phase 2: Query OpenRouter | Medium | Specific MCP tools and parameters, but results are unpredictable. Model must adapt to what's available. |
| Phase 3: Tier Assignment | Medium | perf/$ formula is fixed, but candidate selection requires judgment. Two valid candidates may differ in trade-offs. |
| Phase 4: Present Results | Low | Output template is prescriptive for consistency. A wrong table format confuses the user. |
| Phase 5: Apply Changes | Low | JSON edits must be exact. One wrong path or typo breaks the config. |

**Why this calibration:** The most fragile operations (config edits, file reads, output formatting) have the lowest freedom because a single mistake corrupts state. The most judgment-heavy operations (selecting candidates, choosing providers) have medium freedom because the model's judgment is the value-add.

## Anti-Patterns

- Do NOT recommend models without checking tool support — a cheap model that can't call tools is useless for agentic/coding roles.
- Do NOT recommend based on benchmark rank alone — a model ranked #1 with 0.5% market share may be overfitted or unreliable.
- Do NOT skip the budget tier for "premium" agents — the user asked for all three tiers. Show them.
- Do NOT assume the current model is wrong — if the current model is already the best value pick, say so. Don't invent a change.
- Do NOT expand scope to non-OpenRouter providers (OpenAI direct, Anthropic direct, etc.) unless the user explicitly asks. The config uses `openrouter/` prefix, so stay in OpenRouter's catalog.
- Do NOT recommend a model that lacks structured_outputs or tools support for an agent whose config uses those features.
- Do NOT write changes without explicit authorization. Present the table first, then ask "Apply these changes?" with a summary of what changes.
- Do NOT recommend models with < 8K context for any agent — opencode agents regularly exceed this.
- Do NOT silently use fallback data — if you used known alternatives because MCP failed, say so in the output.
