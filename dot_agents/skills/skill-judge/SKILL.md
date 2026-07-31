---
name: skill-judge
description: Evaluate Agent Skill quality against official specifications and 17+ example patterns. Multi-dimensional scoring (120 points across 8 dimensions), knowledge delta analysis, failure pattern detection, and actionable improvement suggestions. Automatically tracks evaluation history in evaluations.json (keeps most recent 3 per skill). Use when reviewing, auditing, scoring, or improving SKILL.md files and skill packages; comparing skills; or asking "is this skill well-designed?" Triggers: evaluate skill, review SKILL.md, audit skill, score skill, skill quality, how to improve skill, skill evaluation.
---

# Skill Judge

Evaluate Agent Skills against official specifications and patterns derived from 17+ official examples.

---

## Core Philosophy

A Skill is not a tutorial — it is a **knowledge externalization mechanism**. Instead of retraining a model (costly, slow), you edit a Markdown file in natural language and the model's behavior changes instantly: a general agent plus an excellent Skill becomes a domain expert. The distinction from Tools matters: Tools define what the model CAN do (execute actions like `bash`, `read_file`, `WebSearch`), while Skills inject what the model KNOWS how to do (guide decisions like PDF processing, frontend design).

### The Core Formula

> **Good Skill = Expert-only Knowledge − What the model already knows**

A Skill's value is measured by its **knowledge delta** — the gap between what it provides and what the model already knows.

- **Expert-only knowledge**: Decision trees, trade-offs, edge cases, anti-patterns, domain-specific thinking frameworks — things that take years of experience to accumulate
- **What the model already knows**: Basic concepts, standard library usage, common programming patterns, general best practices

When a Skill explains "what is PDF" or "how to write a for-loop", it's compressing knowledge the model already has. This is **token waste** — context window is a public resource shared with system prompts, conversation history, other Skills, and user requests.

### Activation Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│  SKILL ACTIVATION FLOW                                              │
│                                                                     │
│  User Request → Agent sees ALL skill descriptions → Decides which  │
│                 (only descriptions, not bodies!)     to activate    │
│                                                                     │
│  If description doesn't match → Skill NEVER gets loaded            │
│  If description is vague → Skill might not trigger when it should  │
│  If description lacks keywords → Skill is invisible to the Agent   │
└─────────────────────────────────────────────────────────────────────┘
```

This is why the `description` field is load-bearing — referenced by D4.

### Three Types of Knowledge in Skills

When evaluating, categorize each section:

| Type | Definition | Treatment |
|------|------------|-----------|
| **Expert** | The model genuinely doesn't know this | Must keep — this is the Skill's value |
| **Activation** | The model knows but may not think of | Keep if brief — serves as reminder |
| **Redundant** | The model definitely knows this | Should delete — wastes tokens |

The art of Skill design is maximizing Expert content, using Activation sparingly, and eliminating Redundant ruthlessly.

---

## Evaluation Dimensions (120 points total)

### D1: Knowledge Delta (20 points) — THE CORE DIMENSION

The most important dimension. Does the Skill add genuine expert knowledge?

**Scoring brief**: See `references/scoring-bands.md` D1 section for full criteria, red/green flags, and evaluation questions.

**Decision process**: Tag each paragraph as [E]/[A]/[R]. Compute ratio. Apply scoring decision tree above. Map to 0-20 band.



---

### D2: Mindset + Appropriate Procedures (15 points)

Does the Skill transfer expert **thinking patterns** along with **necessary domain-specific procedures**?

**Scoring brief**: See `references/scoring-bands.md` D2 section for full criteria, red/green flags, and evaluation questions.

**Decision process**: Tag each paragraph as [E]/[A]/[R]. Compute ratio. Apply scoring decision tree above. Map to 0-15 band.

---

### D3: Anti-Pattern Quality (15 points)

Does the Skill have effective NEVER lists?

**Scoring brief**: See `references/scoring-bands.md` D3 section for full criteria, red/green flags, and evaluation questions.

**Decision process**: Tag each paragraph as [E]/[A]/[R]. Compute ratio. Apply scoring decision tree above. Map to 0-15 band.

---

### D4: Specification Compliance — Especially Description (15 points)

Does the Skill follow official format requirements? **Special focus on description quality.**

**Scoring brief**: See `references/scoring-bands.md` D4 section for full criteria, red/green flags, and evaluation questions.

**Decision process**: Tag each paragraph as [E]/[A]/[R]. Compute ratio. Apply scoring decision tree above. Map to 0-15 band.

**Frontmatter requirements**:
- `name`: lowercase, alphanumeric + hyphens only, ≤64 characters
- `description`: **THE MOST CRITICAL FIELD** — determines if skill gets used at all

---

**Description must answer THREE questions**:

1. **WHAT**: What does this Skill do? (functionality)
2. **WHEN**: In what situations should it be used? (trigger scenarios)
3. **KEYWORDS**: What terms should trigger this Skill? (searchable terms)

Worked examples of excellent, poor, and useless descriptions are in `references/scoring-bands.md`.

---

**Description quality checklist**:
- [ ] Lists specific capabilities (not just "helps with X")
- [ ] Includes explicit trigger scenarios ("Use when...", "When user asks for...")
- [ ] Contains searchable keywords (file extensions, domain terms, action verbs)
- [ ] Specific enough that Agent knows EXACTLY when to use
- [ ] Includes scenarios where this skill MUST be used (not just "can be used")

---

### D5: Progressive Disclosure (15 points)

Does the Skill implement proper content layering?

Skill loading has three layers:
```
Layer 1: Metadata (always in memory)
         Only name + description
         ~100 tokens per skill

Layer 2: SKILL.md Body (loaded after triggering)
         Detailed guidelines, code examples, decision trees
         Ideal: < 500 lines

Layer 3: Resources (loaded on demand)
         scripts/, references/, assets/
         No limit
```
**Scoring brief**: See `references/scoring-bands.md` D5 section for full criteria, red/green flags, and evaluation questions.

**Decision process**: Tag each paragraph as [E]/[A]/[R]. Compute ratio. Apply scoring decision tree above. Map to 0-15 band.

**For simple Skills** (no references, <100 lines): Score based on conciseness and self-containment.

---

### D6: Freedom Calibration (15 points)

Is the level of specificity appropriate for the task's fragility?

Different tasks need different levels of constraint. This is about matching freedom to fragility.

| Score | Criteria |
|-------|----------|
| 0-5 | Severely mismatched (rigid scripts for creative tasks, vague for fragile ops) |
| 6-10 | Partially appropriate, some mismatches |
| 11-13 | Good calibration for most scenarios |
| 14-15 | Perfect freedom calibration throughout |



**skill-judge's own calibration**: Scoring interpretation = medium freedom (judgment within the published bands). Report generation = low freedom (follow the report template exactly). Evidence selection = medium freedom.

**Why this calibration**: Incorrect evaluation misleads skill authors about their skill quality — medium-high consequence. Scoring needs judgment (medium freedom) because skill quality is multidimensional. Report format needs exact compliance (low freedom) because a malformed report creates confusion. Evidence selection is judgment-based (medium freedom) because relevance depends on context.

---

### D7: Pattern Recognition (10 points)

Does the Skill follow an established official pattern?

Through analyzing 17 official Skills, we identified 5 main design patterns:

| Pattern | ~Lines | Key Characteristics | Example | When to Use |
|---------|--------|---------------------|---------|-------------|
| **Mindset** | ~50 | Thinking > technique, strong NEVER list, high freedom | frontend-design | Creative tasks requiring taste |
| **Navigation** | ~30 | Minimal SKILL.md, routes to sub-files | internal-comms | Multiple distinct scenarios |
| **Philosophy** | ~150 | Two-step: Philosophy → Express, emphasizes craft | canvas-design | Art/creation requiring originality |
| **Process** | ~200 | Phased workflow, checkpoints, medium freedom | mcp-builder | Complex multi-step projects |
| **Tool** | ~300 | Decision trees, code examples, low freedom | docx, pdf, xlsx | Precise operations on specific formats |

| Score | Criteria |
|-------|----------|
| 0-3 | No recognizable pattern, chaotic structure |
| 4-6 | Partially follows a pattern with significant deviations |
| 7-8 | Clear pattern with minor deviations |
| 9-10 | Masterful application of appropriate pattern |

**Why Process, not Tool**: Skill evaluation is a judgment task with structured phases (Pin → Scan → Score → Calculate → Report → Record). Each phase has its own output and gates. A Tool pattern would collapse this into a single rigid operation, but scoring requires judgment within each phase. The 6-step protocol provides checkpoints (Step 3 completion → Step 4, Step 5 completion → Step 6) that are characteristic of Process patterns.

**Why Process, not Mindset**: At 448 lines, this skill exceeds Mindset's ~50-line ideal by 9x. The 6-step evaluation protocol provides procedural structure that a pure Mindset would lack. The score computation, report template, and persistence rules are low-freedom procedures that require structured guidance, not just thinking patterns.

---

### D8: Practical Usability (15 points)

Can an Agent actually use this Skill effectively?

**Scoring brief**: See `references/scoring-bands.md` D8 section for full criteria, red/green flags, and evaluation questions.

**Decision process**: Tag each paragraph as [E]/[A]/[R]. Compute ratio. Apply scoring decision tree above. Map to 0-15 band.

**Check for**:
- **Decision trees**: For multi-path scenarios, is there clear guidance on which path to take?
- **Code examples**: Do they actually work? Or are they pseudocode that breaks?
- **Error handling**: What if the main approach fails? Are fallbacks provided?
- **Edge cases**: Are unusual but realistic scenarios covered?
- **Actionability**: Can Agent immediately act, or needs to figure things out?


---

## NEVER Do When Evaluating

- **NEVER** give high scores just because it "looks professional" or is well-formatted
- **NEVER** ignore token waste — every redundant paragraph should result in deduction
- **NEVER** let length impress you — a 43-line Skill can outperform a 500-line Skill
- **NEVER** skip mentally testing the decision trees — do they actually lead to correct choices?
- **NEVER** forgive explaining basics with "but it provides helpful context"
- **NEVER** overlook missing anti-patterns — if there's no NEVER list, that's a significant gap
- **NEVER** assume all procedures are valuable — distinguish domain-specific from generic
- **NEVER** undervalue the description field — poor description = skill never gets used
- **NEVER** put "when to use" info only in the body — Agent only sees description before loading
- **NEVER** score before confirming you are reading the canonical SKILL.md — not a sibling README.md, an outdated copy, or a reference file. A wrong-file read silently manufactures false "critical issues" (e.g., reporting "no frontmatter" when the real SKILL.md has it).
- **NEVER** accept a skill's self-reported quality or score as ground truth — always verify by re-reading the actual SKILL.md content. A skill can claim "expert-level" but contain only activation content. The evidence is in the file, not the claim.
- **NEVER** score a dimension on the basis of a single section or paragraph — a skill might have a strong NEVER list but terrible knowledge delta. Each dimension must be scored independently. A strong D3 does not compensate for a weak D1, and you must not let a section's quality bleed into adjacent dimensions.

---

## Evaluation Protocol

### Step 0: Pin the subject

Before any scoring, confirm you have the right file:
1. Locate the canonical `SKILL.md` (verify it is not a sibling `README.md`, an outdated copy, or a reference file).
2. Confirm the YAML frontmatter is present and parseable.
3. Note the total line count.
4. List all reference files bundled with the skill.

All of the above MUST be done BEFORE scoring begins.

### Step 1: First Pass — Knowledge Delta Scan

Read SKILL.md completely and for each section ask:
> "Does the model already know this?"

Mark each section as:
- **[E] Expert**: The model genuinely doesn't know this — value-add
- **[A] Activation**: The model knows but brief reminder is useful — acceptable
- **[R] Redundant**: The model definitely knows this — should be deleted

Calculate rough ratio: E:A:R
- Good Skill: >70% Expert, <20% Activation, <10% Redundant
- Mediocre Skill: 40-70% Expert, high Activation
- Bad Skill: <40% Expert, high Redundant

### Step 2: Structure Analysis

```
[ ] Check frontmatter validity
[ ] Count total lines in SKILL.md
[ ] List all reference files and their sizes
[ ] Identify which pattern the Skill follows
[ ] Check for loading triggers (if references exist)
```

### Step 3: Score Each Dimension

For each of the 8 dimensions:
1. Find specific evidence (quote relevant lines)
   **MANDATORY — Load reference:** `references/common-failure-patterns.md` (the 9 named patterns). Load it once before scoring the first dimension. **Do NOT load** after scoring the last dimension — the patterns are only needed during diagnostic analysis.
2. Assign score with one-line justification
3. Note specific improvements if score < max

**MANDATORY — Load reference:** `references/scoring-bands.md` (the per-dimension red/green flags, examples, and evaluation questions). Load ONLY the `## DN` section for the dimension you are currently scoring. **Do NOT load the entire file** (it is ~269 lines) and **Do NOT load sections for dimensions you have already scored** — load one section per dimension, on demand, as you score it.

#### How to score a dimension

1. Read the target section(s) for that dimension.
2. Tag each paragraph as **[E]** Expert / **[A]** Activation / **[R]** Redundant.
3. Compute the E:A:R ratio.
4. Map the ratio + that dimension's red-flag / green-flag indicators to a score band.
5. Quote at least one line of evidence justifying the chosen band.

> **D1-specific note:** Explicitly count Expert vs Activation vs Redundant paragraphs to derive the band — the E:A:R ratio is the primary driver of the D1 score.

> **Scoring decision tree (E:A:R → band mapping):**
> After tagging paragraphs and computing the E:A:R ratio, map to the score band using the worst applicable row:
> 
> | E:A:R ratio                      | Allowed band | Condition                                                      |
> | -------------------------------- | ------------ | -------------------------------------------------------------- |
> | E < 40%, R > 20%                 | 0-5          | Redundant-heavy — most content the model already knows         |
> | E 40-70%, high Activation        | 6-10         | Mixed; diluted by obvious content                              |
> | E 40-70%, low Activation         | 11-15        | Mostly expert with minimal redundancy                          |
> | E > 70%, A < 20%, R < 10%        | 16-20        | Pure knowledge delta — every paragraph earns its tokens        |
> | E > 70% but A ≥ 20% or R ≥ 10%  | 11-15        | High expert but significant activation overhead pulls down     |
> | E ≥ 90%                          | 16-20        | Near-perfect knowledge delta                                   |
> 
> **If scoring an edge case**: when dimension has < 5 paragraphs, use the ratio of lines (expert-line-count / total-line-count) as a coarse proxy. Flag the estimate in your evidence notes.
> 
> **When red flags and green flags conflict**: flags override the E:A:R ratio by ±1 band. One red flag (e.g., "what is X" section) moves the band down by 1. One green flag (e.g., domain-specific decision tree) moves the band up by 1.

> **D8 fallback:** If you cannot decide whether content is Expert vs Redundant, default to Redundant (per D1 red flags) and flag the uncertainty in your notes.

#### When failure patterns are ambiguous

The 9 patterns in `common-failure-patterns.md` are diagnostic labels, not a perfect taxonomy. Handle ambiguity explicitly:
- **Partial match**: if a pattern fits some symptoms but not all, record it as the primary pattern and note the mismatch in your evidence — do not force a clean fit.
- **Two patterns conflict**: name both (primary + secondary) and explain which symptoms map to each. Do not pick one and ignore the other.
- **No pattern fits**: say so ("none of the 9 named patterns apply") and describe the issue in plain language under Critical Issues instead of inventing a label.
- **Never** bend a skill's observed behavior to match a pattern — bend the diagnosis to match the behavior.

#### When the skill being evaluated is skill-judge itself (self-evaluation)

Evaluating skill-judge with skill-judge is a meta-case that needs explicit handling to stay objective:
- **Declare it**: state in the report title/verdict that this is a self-evaluation. Do not pretend the evaluator is independent.
- **Bias check**: do NOT inflate scores because "we improved it" or deflate them to seem rigorous. Score the evidence, not the intent. If a prior iteration's recorded improvements were applied, judge whether they actually moved the evidence — not whether they were meant to.
- **Arithmetic is non-negotiable**: compute `total_score` as the literal sum of the 8 dimension scores; derive `percentage` and `grade` from that sum. A self-evaluation that reports a total not equal to the sum of its dimensions is a calibration failure of the skill it is evaluating.
- **Persistence follows the same Step 6 rules** as any evaluation: append (do not blanket-remove), then trim to the 3 most recent entries for skill-judge. Keeping prior entries lets the before/after delta be audited.

### Step 4: Calculate Total & Grade

Total = D1 + D2 + D3 + D4 + D5 + D6 + D7 + D8 (max 120). Grade scale: A ≥ 90% (108+), B ≥ 80% (96+), C ≥ 70% (84+), D ≥ 60% (72+), F < 60%.

### Step 5: Generate Report

**MANDATORY — Load reference:** `references/quick-reference-checklist.md`. Load only during Step 5 report generation. **Do NOT load** during scoring — it is a report verification tool, not a scoring guide.

**MANDATORY for first-time evaluators**: If this is your first evaluation using this skill, or if you want a worked example, load `references/example-evaluation.md` (~180 lines) before starting Step 0. Read it completely to understand the expected output format and reasoning depth. **Do NOT load** if you have already used this skill before — the example is a teaching tool, not a scoring reference.

See `references/example-evaluation.md` for the report template format. The template is embedded in the example for immediate reference.

### Step 6: Record Results

**MANDATORY**: After generating the report, persist the evaluation to the tracker. This step is NOT optional — every evaluation must be recorded.

**File:** `evaluations.json` (in the skill-judge directory, alongside SKILL.md)

**Procedure (append-then-trim — do NOT blanket-remove):**
1. Read `evaluations.json` and parse it as JSON. Shape is `{ "evaluations": [...] }`. If it is malformed or not that shape, STOP and surface the error — do not overwrite.
2. Compute the new entry's `total_score` as the EXACT sum of its 8 `dimension_scores` values. Verify `sum(dimension_scores) == total_score` before continuing; derive `percentage` and `grade` from this sum, not from a separately-chosen number. Mismatch = a bug; fix it before writing.
3. If an existing entry has the SAME `skill_name` AND SAME `evaluated_at` timestamp, replace it in place (this is the only removal case).
4. Otherwise APPEND the new entry to the `evaluations` array. Do NOT remove other entries for the same skill — history is retained.
5. After appending, if more than 3 entries exist for the same `skill_name`, keep only the 3 most recent by `evaluated_at` and drop older ones. Preserve ALL entries for other skills untouched.
6. Write the updated JSON back with 2-space indentation, preserving the `{ "evaluations": [...] }` envelope.

**Entry structure:**

**NEVER** skip this step. **NEVER** blanket-remove a skill's prior entries (only replace an exact same-timestamp match, or trim to the 3 most recent). **NEVER** store more than 3 entries per skill. **NEVER** write a `total_score` that does not equal the sum of the `dimension_scores`. **NEVER** edit the JSON in a way that breaks the `{ "evaluations": [...] }` envelope.

---

## References

- `references/common-failure-patterns.md` — **MANDATORY during Step 3 (Score Dimensions)**. Use the 9 named patterns to diagnose specific issues. ~100 lines.
- `references/scoring-bands.md` — **MANDATORY during Step 3 (Score Dimensions)**. Per-dimension red/green flags, worked examples, and evaluation questions moved out of SKILL.md for progressive disclosure. ~250 lines.
- `references/quick-reference-checklist.md` — **Load during Step 5 (Generate Report)** for output verification. ~30 lines.
- `references/example-evaluation.md` — **Load when user asks "show me what a good evaluation looks like"** or for first-time evaluators wanting a worked example. ~180 lines.
- `evaluations.json` — **Updated MANDATORY during Step 6 (Record Results)**. Tracks evaluation history (most recent 3 per skill). Read when user asks to compare skills, review evaluation history, or see past evaluations.

---

## The Meta-Question

When evaluating any Skill, always return to this fundamental question:

> **"Would an expert in this domain, looking at this Skill, say:**
> **'Yes, this captures knowledge that took me years to learn'?"**

If the answer is yes → the Skill has genuine value.
If the answer is no → it's compressing what the model already knows.

The best Skills are **compressed expert brains** — they take a designer's 10 years of aesthetic accumulation and compress it into 43 lines, or a document expert's operational experience into a 200-line decision tree.

What gets compressed must be things the model doesn't have. Otherwise, it's garbage compression.


