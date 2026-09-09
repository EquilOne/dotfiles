---
name: prompt-judge
description: >
  Evaluate any agent prompt, system prompt, or LLM instruction file for quality, clarity, and intent alignment. Score it on a multi-dimensional rubric, then auto-rewrite with improvements applied.
  Use when the user says "review this prompt", "check my agent prompt", "evaluate this system prompt", "improve my prompt", "rewrite this prompt", "prompt too vague", "prompt not working", "agent misbehaving", "fix my agent instructions", "judge this prompt", "audit my agent config", "review my CLAUDE.md", "check my AGENTS.md", "is this system prompt good", "check my custom instructions", "review my rules file", or pastes a prompt and asks "is this good?".
  Also trigger when the user writes a new agent prompt and wants validation before deploying it. Covers OpenCode agent configs, custom system prompts, chatbot instructions, CLAUDE.md, AGENTS.md, system instructions, rules files, custom instructions, and any LLM-facing instruction text.
---

# Prompt Judge

Evaluate agent prompts against a multi-dimensional rubric, then auto-rewrite with fixes. Each evaluation: score, diagnose problems, produce an improved version. One pass, no looping — the user iterates manually.

## Pattern: Tool

This skill is a **Tool pattern**:

**Why Tool, not Process:** Prompt evaluation is a precise operation on text — the rubric maps to exact scores. A Process pattern would add workflow phases, but evaluation is a single-pass scoring operation. Tool is correct because the value is in the rubric (decision tree) and report template (exact output format).

**Why Tool, not Mindset:** The value is in the multi-dimensional scoring rubric and the NEVER list, not a thinking framework. Mindset is ~50 lines; prompt-judge needs ~250 for the rubric and report template.

**Pattern mapping:**
- Decision trees: 8-dimension rubric with score bands
- Code examples: report template, JSON structure
- Low freedom: scoring follows published bands; report follows template
- ~250 lines (within Tool range)
- Precise operations on prompt text — the task is to analyze, score, and rewrite a static input, not to hold a conversation or improvise.

## Do NOT Load

- Do NOT use for evaluating skills (SKILL.md files) — use skill-judge instead
- Do NOT use for evaluating code — use the review subagent
- Do NOT use for evaluating naming — use naming-analyzer

## Intent

Before scoring, establish what the prompt is meant to achieve. If the user states the intent, use it. If not, infer it from the prompt's role declaration, scope, and output format — then note the inferred intent in the output and flag it for confirmation. Intent Alignment (dimension 6) is scored against this.

## Thinking Frame

Before evaluating a prompt, ask:

- **Audience:** Who will run this prompt? (developer? end user? another agent?)
- **Stakes:** What happens if the prompt fails? (low: retry; high: irreversible action)
- **Domain:** Is this a general-purpose prompt or domain-specific? Domain prompts need more context injection.
- **Format:** Does the prompt specify output format, or leave it open? Ambiguous format = inconsistent output.
- **Downstream consumers:** Will this prompt's text be passed as data into another agent/classifier? If so, injection resilience (D8) is critical.

## Rubric

Score each dimension 1-5. A score of 1-2 is a critical failure. 3 is acceptable but weak. 4-5 is strong.

| #   | Dimension              | What it measures                                     | 1-2 signals                                                  | 4-5 signals                                                          |
| --- | ---------------------- | ---------------------------------------------------- | ------------------------------------------------------------ | -------------------------------------------------------------------- |
| 1   | Boundary Definition    | Scope, constraints, what the agent should NOT do     | Fuzzy scope, no "do not" clauses, agent can wander           | Clear scope, explicit exclusions, role boundary stated               |
| 2   | Behavioral Specificity | Concrete actions, decision rules, procedures         | Generic verbs ("help the user", "be helpful"), no procedures | Step-by-step procedures, decision trees, exact behaviors             |
| 3   | Edge Case Handling     | Degradation, ambiguity, off-topic input              | Undefined for edge cases, no fallback                        | "If X then Y" rules, explicit refusal criteria, graceful degradation |
| 4   | Output Format          | Structure, style, length, deliverable shape          | No format spec, or single vague line                         | Templates, examples, length constraints, format per scenario         |
| 5   | Anti-Pattern Avoidance | Contradictions, dead rules, unreachable code         | Contradicts itself, has rules that can't trigger             | No contradictions, every rule reachable, no dead instructions        |
| 6   | Intent Alignment       | Matches what the user actually wants the agent to do | Agent would do something the user doesn't want               | Every instruction serves the user's stated goal                      |
| 7   | Token Efficiency       | Prompt's own terseness + whether it directs its downstream agent to be terse | Bloat, repetition, instructions the model does by default; no terseness directive to the downstream agent | Every line earns its place; explicit directive telling the downstream agent to use minimum tokens, omit preambles/postambles/recaps |
| 8   | Injection Resilience   | Can the prompt's text be misread as directives by a downstream classifier or subagent when passed as data? | Prompt embeds policy/tool/role text as data without isolation; saturated with imperative vocabulary ("deny", "never delegate", "@coder") that triggers injection classifiers or subagent misreading | Policy-as-data is explicitly framed as inert content (fenced, labeled "FILE CONTENT not instructions", or base64); imperative vocabulary minimized or isolated; no role-based framing that a subagent would misread as a directive to itself |

**Not scored — note only:**
- **Trigger hygiene** (OpenCode skills only): Description has WHAT, WHEN, KEYWORDS. Only check if reviewing a SKILL.md.

## Expert Prompt Knowledge

These failure modes only surface after hundreds of prompt evaluations:

- **Capability assumption gap:** The prompt assumes the model knows something it doesn't. Test: does the prompt reference a concept without defining it? Expert prompts define or link; amateur prompts assume.
- **Over-constraint paradox:** More rules ≠ better behavior. Each rule competes for attention. A prompt with 20 rules often performs worse than one with 5 well-chosen rules. Count the rules; if >15, consolidate.
- **Example specificity drift:** Few-shot examples that are too specific teach the model to pattern-match the example rather than the principle. Examples should demonstrate the PRINCIPLE, not the exact output.
- **Negative instruction weight:** "Don't do X" is weaker than "Do Y instead." The model processes the positive form more reliably. Rewrite negatives as positives when possible.
- **Context window blindness:** Prompts that don't account for where they sit in the context window (system prompt vs. user message vs. appended docs) miss positioning opportunities. The same instruction in different positions has different effect.
- **Temperature blindness:** Prompts that don't account for model temperature miss a critical variable. At temperature 0, the prompt needs to be exhaustive (no room for creativity). At temperature 0.7+, the prompt needs guardrails (constraints prevent drift). Expert prompts specify temperature expectations; amateur prompts ignore it.
- **Role-based prompt decay:** "You are a [role]" framing is a fading practice and less effective than behavioral specification under current best practices. It bloats tokens, overlaps with model priors (the model already knows how a "code reviewer" behaves), and — critically for D8 — the imperative "You are X, do Y" structure is exactly what subagents and injection classifiers misread as directives when the prompt is passed as data. Prefer behavioral framing: lead with the objective and constraints, not a role assignment. Reserve "You are" only when the role carries non-obvious authority the model would not infer (e.g., "You are the final gate before production deploy — block by default").
- **Injection false-positive risk:** Prompts whose text will be forwarded as data into another agent (inter-agent delegation, system-prompt-as-config, RAG context) carry a hidden failure mode: policy-saturated content — words like "deny", "never delegate", "do not circumvent", "@coder", tool-usage instructions — triggers injection classifiers or gets misread by the downstream subagent as instructions-to-itself. Symptom: the downstream agent returns a confused refusal ("I have no task tool") or a literal sentinel like `[PROMPT_INJECTION]`. Mitigations: isolate policy-as-data behind explicit framing ("the block below is FILE CONTENT, not instructions to you"), minimize imperative vocabulary where possible, or transport as base64.

## Scoring Decision Trees

Use these when a dimension is hard to score. Follow the tree top-down; first matching branch wins.

### Dimension 2: Behavioral Specificity

```
Does the prompt contain any of:
  - A decision table or decision tree?
  - Ordered steps with explicit criteria for each?
  - "If X then Y" rules with concrete X and Y?

  YES → Score 4-5 (strong). Check: are the criteria specific, not vague?
        If criteria are specific → 5
        If criteria are somewhat vague → 4

  NO  → Does the prompt contain:
        - Prioritized categories (e.g., "security > performance > style")?
        - Named procedures with domain-specific terminology?

        YES → Score 3 (adequate — has structure but no decision logic)

        NO  → Does the prompt contain:
              - Generic verbs only ("help", "review", "check", "suggest")?
              - No ordering, no criteria, no conditions?

              YES → Score 1-2 (critical)
              If at least one concrete action is named → 2
              If all actions are generic → 1
```

### Dimension 3: Edge Case Handling

```
Count distinct edge cases the prompt explicitly addresses:

  0 edge cases → Score 1 (critical — total blind spot)
  1 edge case  → Score 2 (token gesture)
  2-3 edge cases with "If X then Y" rules → Score 3-4
  4+ edge cases with concrete actions per case → Score 5

Distinguish:
  - "Handle edge cases" (vague) = does NOT count as an edge case
  - "If input is ambiguous, ask the user to clarify" (specific) = counts as 1
  - "If PR > 500 lines, review critical-path files first" (specific + action) = counts as 1, high quality
```

### Dimension 5: Anti-Pattern Avoidance

```
Does the prompt contain a NEVER / "Do NOT" / anti-pattern section?

  NO → Does the prompt contradict itself anywhere?
        YES → Score 1 (contradictions with no anti-patterns to resolve them)
        NO  → Score 2 (no contradictions, but no guardrails either)

  YES → Count the anti-patterns. For each, check:
        - Is it specific (names a concrete failure mode)?
        - Does it include WHY (non-obvious reason)?

        All specific + reasoned → Score 5
        Mix of specific and vague → Score 3-4
        All vague ("be careful", "avoid errors") → Score 2
```

### Dimension 7: Token Efficiency

```
Layer A — Self-terseness (the prompt's own text):
  Count instructions that the model would do by default (e.g., "be helpful", "think step by step"
  without reason, restating the role the model already infers, recapping the user's request).

  0 such instructions, AND no repetition, AND no preambles/postambles → strong self-terseness
  1-2 such instructions OR minor repetition → moderate
  3+ such instructions OR heavy repetition OR preambles → weak

Layer B — Target-terseness directive (does the prompt tell its downstream agent to be terse?):
  Does the prompt contain an explicit directive like:
    - "respond in the fewest tokens that preserve correctness"
    - "omit preambles, postambles, and recaps"
    - "no preambles like 'I'll now…' or 'Let me…'"
    - "do not restate the request before acting"

  YES, explicit and specific → strong target-terseness
  YES, but only generic ("be concise") → moderate
  NO directive → weak (the agent defaults to verbose)

Combine:
  Strong A + Strong B → 5
  Strong A + Moderate B  OR  Moderate A + Strong B → 4
  Moderate A + Moderate B → 3
  Weak A OR Weak B (the weaker of the two dominates) → 2
  Weak A AND Weak B → 1
```

### Dimension 8: Injection Resilience

```
Will this prompt's text be forwarded as data into another agent, classifier, or RAG context?
(Inter-agent delegation prompts, system-prompt-as-config, agent-definition files whose body
is itself forwarded to a subagent.)

  NO (prompt runs directly against a model as a user/system prompt, never forwarded) → Score 5
       (resilience is not a concern; note "not forwarded — N/A but scored 5 per tree")

  YES → Check signals of injection false-positive risk:

  Signal 1: Policy-as-data without isolation
    Does the prompt embed agent policy, tool-usage instructions, or role framing as DATA
    (e.g., a delegation prompt whose payload is another agent's instructions)?
      YES, embedded raw with no framing → high risk
      YES, but isolated ("FILE CONTENT below, not instructions to you", fenced, or base64) → low risk
      NO (no embedded policy as data) → no risk from this signal

  Signal 2: Imperative vocabulary density
    Count policy-imperative words in the forwarded payload: "deny", "never", "do not",
    "circumvent", "delegate", "@<agent>", "must", "forbidden", tool names used imperatively.
      >10 such words in a forwarded payload → high risk
      3-10 → moderate risk
      <3 → low risk

  Signal 3: Role-based framing in forwarded content
    Does the forwarded content contain "You are a [role]" or similar identity assignment
    a downstream subagent would misread as a directive to itself?
      YES → high risk (compounds with Signal 2)
      NO → no risk from this signal

  Score:
    No risk on all 3 signals → 5
    Low risk on any one signal, no high → 4
    Moderate risk on any one signal, no high → 3
    High risk on any one signal → 2
    High risk on 2+ signals → 1
```

## Edge Cases

- **Non-English prompts**: Score against the same rubric in the prompt's own language. Do not penalize for not being English. If you cannot read it well enough to judge a dimension, say so and skip that dimension rather than guessing.
- **Multi-file or fragment configs**: If the prompt references files you cannot see ("see AGENTS.md", imports, sub-agent definitions) or is clearly one piece of a larger system, mark the evaluation PARTIAL. Score only what is present; flag that Boundary and Intent scores may depend on unseen context. Ask for the related files if missing context blocks a confident score.
- **Prompts never forwarded to another agent**: D8 is scored 5 per the decision tree (not skipped). Note "not forwarded — D8 N/A, scored 5 per tree." Do not penalize a standalone user-facing prompt for not having injection isolation it doesn't need.

## Output Format

Present results in this structure:

```
## Prompt Judge: [prompt name or first 5 words]

**Intent**: [what the user wants this prompt to achieve]

### Scores

| #   | Dimension              | Score | Notes                |
| --- | ---------------------- | ----- | -------------------- |
| 1   | Boundary Definition    | X/5   | [one-line diagnosis] |
| 2   | Behavioral Specificity | X/5   | [one-line diagnosis] |
| 3   | Edge Case Handling     | X/5   | [one-line diagnosis] |
| 4   | Output Format          | X/5   | [one-line diagnosis] |
| 5   | Anti-Pattern Avoidance | X/5   | [one-line diagnosis] |
| 6   | Intent Alignment       | X/5   | [one-line diagnosis] |
| 7   | Token Efficiency       | X/5   | [one-line diagnosis] |
| 8   | Injection Resilience   | X/5   | [one-line diagnosis] |

**Overall**: X/40 [verdict: Critical / Needs Work / Solid / Strong]
**Trigger hygiene**: [only if SKILL.md — "Pass" or specific gaps]

### Critical Issues (scores 1-2)

1. **[Dimension]**: [what's wrong + concrete example from the prompt]
2. ...

### Improvements Applied

[Bulleted list of every change made in the rewrite, each with a one-line rationale]

### Rewritten Prompt

[Full improved prompt, ready to paste/deploy]

---

**Changes diff**:
- [section or line]: [old behavior] → [new behavior]
- ...
```

**Condensed format**: For prompts under 20 lines with no critical issues (no dimension scored 1-2), a condensed output is acceptable — scores table + one-paragraph rewrite rationale + rewritten prompt. Skip the Critical Issues and Changes diff sections.

## Scoring Rules

- Be blunt. A score of 3 means "survives but does not excel" — do not round up to be nice.
- If a dimension is not applicable to the prompt type, skip it and note why. Do not give a default score. (D8 is an exception: standalone non-forwarded prompts score 5 per the decision tree, not skipped — see Edge Cases.)
- A score of 2 or below on any dimension makes the overall verdict "Critical" regardless of other scores.
- If all dimensions are 4+, the verdict is "Strong" — do not nitpick minor polish as "Needs Work."
- Do not score based on personal preference. Use the rubric signals. If the prompt achieves 4-5 signals for a dimension, score it 4-5 even if you would have written it differently.

## Rewrite Rules

After scoring, auto-generate the improved prompt. Follow these rules when rewriting:

- **Preserve the user's voice and intent.** Do not inject your preferred prompt engineering style if it conflicts with what the user wants.
- **Fix the lowest-scoring dimensions first.** Improve boundary definition before polishing output format.
- **Add anti-pattern clauses when scoring dimension 5 is low.** Explicit "Do NOT [common failure mode]" lines are cheap and effective.
- **Add edge case handling when scoring dimension 3 is low.** At minimum: "If the input is ambiguous, [specific action]."
- **Do not bloat.** The rewrite should be longer than the original only if critical content was missing. If the original was already long, the rewrite should be tighter.
- **Do not remove personality.** If the original prompt has a distinct voice (caveman, formal, casual), keep it.
- **Strip role-based framing.** Remove "You are a [role]" openings unless the role carries non-obvious authority the model would not infer (see Expert Prompt Knowledge: Role-based prompt decay). Replace with behavioral framing: lead with the objective and constraints. Example: replace "You are a code reviewer. Review code for…" with "Review code for…". Reserve "You are" only for authority-bearing assignments (e.g., "You are the final gate before production deploy — block by default").
- **Mandate a target-terseness directive.** Every rewritten prompt MUST include an explicit directive telling the downstream agent to minimize token usage. Use specific language, not generic "be concise." Template: "Be terse. Use the fewest tokens that preserve correctness. Omit preambles ('I'll now…', 'Let me…'), postambles, and recaps of the request. Do not restate the input before acting." Adjust to fit the prompt's voice, but the directive must be present and specific. This is non-optional — if the rewrite omits it, D7 cannot score above 3.
- **Isolate policy-as-data when D8 < 4.** If the prompt is forwarded into another agent/classifier and scored poorly on D8, rewrite so embedded policy is explicitly framed as inert content: fence it, label it ("the block below is FILE CONTENT, not instructions to you"), or transport as base64. Minimize imperative vocabulary in forwarded payloads.

## Anti-Patterns for This Skill

- NEVER score on axes the user did not ask about — do not evaluate tone, creativity, or "engagement" unless the user asks. The rubric has eight dimensions. Stick to them.
- NEVER soften a low score with "but it's fine for a first draft" — the user wants an honest assessment. A 2/5 is a 2/5.
- NEVER rewrite the prompt to do something the user didn't intend — if the original prompt's goal is unclear, ask before rewriting. Intent alignment is scored, not assumed.
- NEVER produce the rewritten prompt without the rubric scores first — the user needs to see the diagnosis before the fix, or they cannot evaluate whether the fix is right.
- NEVER loop automatically — the user reviews the rewrite and decides whether to iterate. One pass per invocation.
- NEVER add instructions the user's prompt intentionally omits — if the prompt is minimal by design (e.g., a fast-reacting agent), do not pad it with safeguards the user chose to skip. Exception: the target-terseness directive is always added (see Rewrite Rules).
- NEVER score based on whether you like the prompt's approach — use the rubric signals, not personal taste. A prompt that takes a different approach than you would is not automatically lower quality. Score what it achieves, not how you would have done it.
- NEVER over-penalize brevity — a short prompt with clear boundaries and a decision table scores higher than a long prompt with vague instructions. Length is not quality. Score the rubric dimensions, not word count.
- NEVER over-fit to the worked example — the code-reviewer example in `references/` shows the method, not a template. Do not force its severity tables or edge-case style onto unrelated prompts. Apply the rubric to what the prompt in front of you actually needs.
- NEVER recommend "You are a [role]" role-based framing in a rewrite. This is a fading practice and less effective than behavioral specification under current best practices. The only exception is when the role carries non-obvious authority the model would not infer on its own (e.g., "You are the final gate before production deploy — block by default"). Routine role assignments ("You are a code reviewer", "You are a helpful assistant", "You are an expert in X") must be replaced with behavioral framing.

## Reference

- `references/example-scored-prompt.md` — Load when the user asks "show me an example", "what does a good evaluation look like", or on the first evaluation of a session if no example has been shown yet. Contains a full evaluation of a realistic prompt across all 8 dimensions with scored rubric, critical issues, rewritten version, and changes diff.
