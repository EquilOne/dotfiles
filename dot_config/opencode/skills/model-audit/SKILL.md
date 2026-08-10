---
name: model-audit
description: >
  Audit opencode agent model config against live OpenRouter pricing and benchmarks.
  Recommends model swaps across six budget-to-best tiers so you can choose per agent.
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

Audit opencode agent model config against live OpenRouter pricing and benchmarks. Recommends model swaps at six tiers so you can choose per agent.

## Prerequisites

**OpenRouter MCP is intentionally DISABLED by default** in this repo's `opencode.json`. Before running this skill, enable it manually (`"enabled": true` on the `openrouter` entry under `mcp`) and restart opencode. The config comment says the same.

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

**Note on ZDR:** The `zdr: true` filter on `list-models` requires ZDR (Zero Data Retention) preferences to be configured in the user's OpenRouter account settings. This is not part of the MCP or opencode config. If the user hasn't configured ZDR in their OpenRouter dashboard, the filter will return unfiltered results. Verify by checking whether `list-models` with `zdr: true` returns fewer results than without.

## Why Process, Not Tool or Mindset

**Why Process, not Tool:** Model auditing is a multi-phase workflow with ordered steps and checkpoints (read config → query → assign tiers → present → apply). A Tool pattern would collapse this into a single decision tree, but each phase has its own sub-decisions and the output of one phase feeds the next. The value is in the workflow orchestration, not in a single precise operation.

**Why Process, not Mindset:** Auditing requires specific procedural knowledge (which MCP tools to call, which JSON paths to edit, which sort parameters to use). A Mindset pattern (~50 lines) would provide only thinking frameworks and miss the domain-specific steps that make the skill work. The procedures are not generic — they're specific to OpenRouter's MCP API and opencode's config structure.

**Pattern mapping:**
- Ordered phases with checkpoints ✓
- Medium freedom (judgment within fixed structure) ✓
- ~266 lines (within Process range) ✓
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
- `reference.md` — agent-to-model routing tables (consolidated)
- `agents/*.md` — extract any `model:` frontmatter overrides per agent

- Extract `provider.openrouter.models.*.options.provider` from `opencode.json` — fields: `sort` (latency/throughput/price), any `allow`/`block` lists
- For each model, note its `reasoningEffort` and `verbosity` settings — these must be preserved if switching to a new model that supports them

Build a map of: agent name → current model slug → role category.

Classify each agent into one role:

| Role | Description | What matters | Example agents |
|------|-------------|-------------|----------------|
| coding | Writes, refactors, reviews code | coding_index, tool support | coder, build, review |
| reasoning | Planning, architecture, design | intelligence_index, reasoning_effort | plan, conductor |
| agentic | Multi-step, tool use, orchestration | agentic_index, tool calling | fixer, general |
| lightweight | Simple lookups, search, exploration | low price, low latency | search, explore, scout |
| general | Chat, docs, explanation | balanced across all | docs, chat, socratic-mentoring |

### Phase 2: Query OpenRouter (ZDR-aware dual queries)

**Before Phase 2, ask yourself:**
- Which benchmark matters most for THIS agent? (coding for coder, intelligence for plan, price for search)
- Is this agent latency-sensitive or throughput-sensitive? (latency → prefer near providers, throughput → sort by throughput)
- Does this agent use structured outputs or tool calling? (if yes, must filter for those)

Define:
```
ZDR_EXEMPT_AUTHORS = [openai, anthropic, google, meta]
# ^ Configurable — the user said this may change. When in doubt, ask.
```

Run TWO parallel `list-models` queries per role:

**Track A — Non-frontier models (ZDR-filtered):**
```
list-models(sort=..., zdr: true, limit=20)
# Exclude authors in ZDR_EXEMPT_AUTHORS
```

**Track B — Frontier models (ZDR-exempt):**
```
list-models(sort=..., author: [openai, anthropic, google, meta], limit=20)
# No zdr parameter — these are exempt
```

Use per-role sort logic:
- coding role → `sort=coding-high-to-low`
- reasoning role → `sort=intelligence-high-to-low`
- agentic role → `sort=agentic-high-to-low`
- lightweight role → `sort=pricing-low-to-high`
- general role → `sort=coding-high-to-low` (balanced default)

For candidate models, filter by:
- Supports reasoning_effort if agent uses reasoning
- Supports structured_outputs and tools if agent is agentic/coding
- Context length >= 32K for all agents, >= 128K for reasoning/agentic

Also query for current model:
```
get-model(author: <author>, slug: <slug>)
```

**Error recovery:**
- If `list-models` returns an error or empty results: fall back to `get-model` for the current model only, and use known alternatives from training data. Note the data source in the output.
- If `get-model` fails for the current model: report that the model could not be found on OpenRouter and suggest the user verify the slug.
- If `list-model-endpoints` fails: proceed with base pricing from `get-model` and note that provider-level pricing is unavailable.
- If the user has zero credits: warn them and suggest checking their account before proceeding.
- If rate limited: wait 1 second and retry once. If rate limited again, fall back to `get-model` for the current model only and note the data source.
- If `list-models` with `zdr: true` returns empty for non-frontier authors: fall back to query without ZDR filter and note "No ZDR-compliant endpoints found for this category — showing all providers"
- If `list-model-endpoints` fails for a candidate: fall back to base pricing from `get-model` with `input_cache_read_price = input_price × 0.5` and note "Endpoint pricing unavailable — used estimated cache pricing"
- If the ZDR exemption list needs updating: present the current list (openai, anthropic, google, meta) and ask the user to confirm or adjust

### Phase 2b: Compute effective cost per 100 requests

For each top candidate model (top 10-15), call:
```
list-model-endpoints(author: <author>, slug: <slug>)
```

From the endpoints, extract:
- For non-frontier models: filter to ZDR-compliant endpoints only
- For frontier models: use all endpoints
- From each endpoint's `pricing` object: `prompt`, `completion`, `input_cache_read`, `input_cache_write`
- Pick the cheapest eligible endpoint

Use role-specific token profiles to estimate real-world cost:

| Role | Avg Input Tokens | Avg Output Tokens | Cache Hit Rate |
|------|-----------------|-------------------|----------------|
| coding | 8,000 | 3,000 | 30% |
| reasoning | 12,000 | 4,000 | 20% |
| agentic | 6,000 | 2,000 | 25% |
| lightweight | 1,500 | 500 | 40% |
| general | 4,000 | 1,500 | 35% |

**Cost formula:**
```
# Cache-adjusted per-request cost
non_cache_input_cost = input_tokens × (1 - cache_hit_rate) × input_price
cached_input_cost   = input_tokens × cache_hit_rate × input_cache_read_price
output_cost         = output_tokens × completion_price
eff_cost_per_req    = non_cache_input_cost + cached_input_cost + output_cost

cost_per_100_req    = eff_cost_per_req × 100
```

If `input_cache_read_price` is not available from the endpoint, fall back to `input_price × 0.5` (standard OpenRouter cache discount) and note the estimate.

### Phase 3: 6-Tier Ladder

For each agent role, pick candidates from the query results. Use `cost_per_100_req` as the primary cost metric for all tier calculations. Keep raw $/M tokens in the output table for reference.

Define 6 ladder rungs:

| Tier | Selection Rule |
|------|---------------|
| **Budget** | Cheapest model (lowest cost_per_100_req) with relevant benchmark > 10. No feature requirements. |
| **Budget+** | Next cheapest with relevant benchmark > 20. |
| **Budget++** | Best perf/$ under an affordability threshold (e.g., cost_per_100_req < 2× Budget's cost or < $2). |
| **Value ★** | Highest perf/$ — must support ALL features the agent needs (tools, structured_outputs, reasoning_effort if applicable). This is the default recommendation. |
| **Value+** | Near-best quality. Benchmark score within 90% of Best, cost_per_100_req < 2× Value's cost. |
| **Best** | Highest relevant benchmark score regardless of price. Full feature support required. |

**perf/$ formula:**
```
perf_per_dollar = relevant_benchmark_score / cost_per_100_req
```

**Error recovery:**
- If no candidates meet the budget tier threshold: relax the benchmark minimum by 10 points and retry. Note the relaxation in the output.
- If no candidates meet the value tier criteria: fall back to the budget pick and note that no true value option was found.
- If the query returns fewer than 3 candidates total: still assign what's available and note the limited selection.

### Phase 4: Present Results

Output format per agent:

```
## Agent: {name}
Role: {role} | Current: {current_model}
Benchmarks: coding {n}, intelligence {n}, agentic {n}

| Tier | Model | Provider | Eff $/100req | Prompt $/M | Out $/M | CacheSav | Coding | Intel | Agentic |
|------|-------|----------|-------------|-----------|---------|---------|--------|-------|---------|
| Current | {slug} | {prov} | {n} | {n} | {n} | {n}% | {n} | {n} | {n} |
| Budget | {slug} | {prov} | {n} | {n} | {n} | {n}% | {n} | {n} | {n} |
| Budget+ | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| Budget++ | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| Value ★ | {slug} | {prov} | {n} | ... | ... | ... | ... | ... | ... |
| Value+ | ... | ... | ... | ... | ... | ... | ... | ... | ... |
| Best | {slug} | {prov} | {n} | ... | ... | ... | ... | ... | ... |

>> Recommendation: {tier} — {reason}
>> Cheapest ZDR provider: {provider_name} at ${price}/$M prompt ({discount}% off base)
>> Cache savings: ~{n}% per request at {cache_hit_rate}% hit rate
```

Rules:
- Show all 6 rungs per agent
- Sort agents by cost impact (biggest savings first) in full audits
- If current model is already best in its tier, say so
- Include absolute benchmark numbers, not relative ranks
- Note if model is new (<30 days old)
- Note if cheapest provider has low uptime (<95% in last 3m)
- If any data source was a fallback (e.g., known alternatives from training data instead of live MCP), note it in the output

### Phase 5: Apply Changes (if authorized)

If the user says "apply" or "write changes" or equivalent:

1. Update `agent.<name>.model` in `opencode.json` for each changed agent
2. Add the new model to `provider.openrouter.models` with appropriate options (copy reasoning_effort, verbosity from the old model's config if applicable)
3. Remove the old model from `provider.openrouter.models` if no longer used by any agent
4. Report the diff: "Changed N models, saved ~$X/M tokens estimated"

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
- Do NOT skip the budget tier for "premium" agents — the user asked for all six tiers. Show them.
- Do NOT assume the current model is wrong — if the current model is already the best value pick, say so. Don't invent a change.
- Do NOT expand scope to non-OpenRouter providers (OpenAI direct, Anthropic direct, etc.) unless the user explicitly asks. The config uses `openrouter/` prefix, so stay in OpenRouter's catalog.
- Do NOT recommend a model that lacks structured_outputs or tools support for an agent whose config uses those features.
- Do NOT write changes without explicit authorization. Present the table first, then ask "Apply these changes?" with a summary of what changes.
- Do NOT recommend models with < 8K context for any agent — opencode agents regularly exceed this.
- Do NOT silently use fallback data — if you used known alternatives because MCP failed, say so in the output.
- Do NOT recommend a non-frontier model without verifying ZDR-compliant endpoint availability. A model with good benchmarks but no ZDR-compliant provider is unusable for this user's setup.
- Do NOT use raw $/M tokens as the primary cost comparator for tier ranking — use per-100-request cost which reflects real-world caching and token efficiency patterns.
- Do NOT hardcode the ZDR exemption list as a constant in the middle of the workflow — define it as a configurable variable at the top of Phase 2.
- Do NOT collapse the 6-tier ladder — the user explicitly wants all rungs (Budget, Budget+, Budget++, Value, Value+, Best) for informed decision-making.
- Do NOT assume frontier exemptions are permanent — the user said this may change. When in doubt between ZDR-filtered and unfiltered options for a model, show both and let the user decide.

(End of file — total 266 lines)
