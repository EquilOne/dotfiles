---
name: structured-learning
description: >
  Transform ANY content into a structured learning plan. Two modes:
  (A) project plan → tutorial-style lesson modules with worked examples,
      faded exercises, and verifiable checkpoints.
  (B) learning content (transcripts, articles, tutorials, course notes) →
      actionable implementation plans with defined quests, reps, and reflection triggers.
  MUST use when user says "turn this plan into lessons", "create a learning path",
  "convert plan to lessons", "make a lesson plan",
  "build a learning path", "tutorial from plan", "create a course from this",
  OR when user provides a YouTube transcript, article, tutorial, or course notes
  and wants action steps, reps, or a learning quest.
  Also triggers on: "turn this into something I can learn from", "create an implementation plan",
  "I want to ship this", "make this actionable".
  Does NOT handle: one-off tasks with no learning goal, fiction/entertainment content,
  pure study plans (no implementation), ad-hoc conceptual teaching (use direct-instruction),
  interactive plan delivery (use teach-from-lesson), or general code explanation (use explain-code).
---

# Structured Learning

Convert project plans into tutorial-style lesson modules, or learning content into actionable implementation plans. Two paths, same goal: turn passive consumption into demonstrable ability.

## When NOT to Use

- General tutoring or ad-hoc Q&A — use socratic-mentoring instead
- Skill evaluation — use skill-judge instead
- No source material and no plan to convert from
- Writing code directly — use the coder subagent
- One-off tasks with no learning goal (just do the task)
- Pure study plans with no implementation component
- Fiction or entertainment content (no actionable advice)

## Freedom Calibration

This skill uses **medium-low freedom**. The structure is fixed (detect → calibrate → generate), but content within each step is adaptive:
- **Path A**: Walkthrough template (Full → Faded → Self-Explanation → Final) is fixed; the worked example content, exercise design, and self-explanation prompts are creative choices.
- **Path B**: The 5-step rep structure (Quest → Rep → Resources → Reflection → Next) is non-negotiable; each step's implementation adapts to user feedback.
- **Input detection**: Low freedom — follow the decision tree exactly. Wrong routing wastes a full cycle.
- **Anti-patterns**: Low freedom — the NEVER list is non-negotiable.

## Pattern: Process

This skill follows the Process pattern because module/rep creation is a phased workflow with checkpoints.

**Why Process, not Tool:** Content within each module is adaptive (example choice, exercise design) — a Tool pattern would require exact scripts that don't fit varied learning material. Process is correct because Path A and Path B have fixed detection and generation steps but adaptive content design.

**Pattern mapping:**
- Phased workflow: 2 paths with ordered steps ✓
- Checkpoints: calibrate before generate, verify after ✓
- Medium-low freedom: structure fixed, content adaptive ✓

## 1. Input Detection

Route to the correct path by detecting the input type. Read the user's message and classify:

### Decision Tree

```
Input provided by user
├─ Has explicit steps/milestones/phases (e.g. "Step 1: install", "Phase 2: deploy")
│  OR user says "turn this plan into lessons", "make a lesson plan from this"
│  → Path A: Plan → Lesson Modules
├─ Is a transcript, article, tutorial, course notes, or video summary
│  OR user says "make this actionable", "I want to ship this", "create a learning quest"
│  → Path B: Content → Implementation Plan
└─ Neither clearly identifiable
   → Ask one clarifying question: "Do you have a project plan you want turned into
      lessons, or learning material you want turned into an actionable plan?"
```

If the input is loose prose with no clear structure and the user hasn't specified intent, ask before assuming.

## 2. Calibrate

Before generating the output, gather calibration data. This section applies to both paths.

### Experience Rating (Path A)

Present the extracted concept and tool lists to the user. Ask them to rate each on a 1–5 scale:
- 1 = never used
- 2 = heard of it, no hands-on
- 3 = used once or twice
- 4 = comfortable
- 5 = expert

**Important:** If the user rates everything 4 or 5, ask one applied calibration question before accepting. Learners often overestimate expertise. A question like "Can you describe how X handles edge case Y?" reveals actual gaps.

### Action Density (Path B)

When processing learning content, calculate advice-per-minute. Low density (<1 actionable item per 5 minutes of content) = skip that section. High density = prioritize.

**No source material (Path B only):** If the user wants a plan from scratch, skip action density extraction. Start quest definition directly. Ask: "What's the smallest thing you could ship in 7 days that would teach you the loop?"

## 3. Path A: Plan → Lesson Modules

Convert a structured or semi-structured project plan into tutorial-style modules calibrated to the user's self-reported experience.

### Step A1 — Acquire & Parse

Plan source: file path or pasted inline. If neither, ask once.

Extract from the plan: title + overall goal, ordered milestone list, deduplicated concepts, deduplicated tools. If the plan is loose prose with no clear steps, confirm extracted steps with the user before continuing.

### Step A2 — Map Ratings to Depth

Apply the following mapping strictly:

| Rating | Walkthrough Style | Exercise Style |
|--------|-------------------|----------------|
| 1 | **Build from first principles.** Start with raw problem. Show naive approach. Add abstraction layer by layer. Include "predict the output" moments. 3–5 paragraphs + code mid-explanation. | Guided — starter code, 1–2 gaps to fill. |
| 2 | **Brief recap + one focused worked example.** 2 paragraphs + focused code walkthrough. | Semi-guided — clear prompt, one hint available. |
| 3 | **One-paragraph reminder + one gotcha.** 1 paragraph + inline snippet. | Minimal scaffolding — state task, offer hint only if asked. |
| 4 | **One-line callout** only for non-obvious behavior. Otherwise skip. | Self-directed — no hints, just acceptance criteria. |
| 5 | **Skip** unless subtle pitfall exists. Surface as one-liner. | Skip unless subtle pitfall exists. |

**Mixed-depth within a module:** If concepts span ratings 1–2 AND tools span ratings 3–5, the Walkthrough style follows the LOWEST concept rating. Tools at rating 3+: inline only the one relevant command or flag. Do NOT split into separate sections. If concepts span both rating 1 AND rating 5: default to "Full" fade stage.

### Step A3 — Generate Modules

One module per plan step, preserving execution order. Each module must use the following structure.

#### Module Template

```
## Module N: [Title]

**Objective:** One sentence describing what the learner can do after this module.

### Walkthrough

Build the tutorial in four moves:

1. **Full Worked Example** — State the problem concretely. Solve it with fully
   annotated code. The learner watches and absorbs the pattern.
   Walk through the problem in 1–2 paragraphs, then show the full solution.

2. **Faded Worked Example** — Same concept, different context. Show partial code
   with 1–2 gaps the learner fills. Mark gaps clearly with `# TODO: learner fills this`.
   Follow with one paragraph framing what they just did.

3. **Self-Explanation Prompt** — Ask the learner to explain a design choice.
   Provide the answer below so they can check:
   > Why did we use a set here instead of a list?
   > *(Think about it, then check your understanding below)*
   > **Answer:** A set gives O(1) membership checks and enforces uniqueness.
   Include 1 self-explanation prompt per concept. Minimum 1, maximum 3.

4. **Final Solution** — Show assembled, annotated solution. One annotation per key line.

**Depth adaptation by module rating:**
- Depth 1: Include all 4 moves
- Depth 2: Skip move 4; combine moves 1+2 into one narrative
- Depth 3: Use only move 3 (self-explanation) referencing prior modules
- Depth 4+: Skip Walkthrough entirely unless a subtle pitfall exists

**Fade stage annotation:**

| Stage | Walkthrough Style | Exercise Scaffolding |
|-------|-------------------|----------------------|
| Full | Full + faded + self-explanation | Starter code, 1–2 gaps |
| Guided | Faded example + self-explanation only | Acceptance criteria, one hint |
| Independent | Problem statement only | No starter code, no hints |

**Rule:** A concept introduced at stage Full MUST reappear in the NEXT module at stage Guided or Independent — unless rated 5.

### Your Turn

One concrete hands-on exercise. The **smallest exercise that proves the objective**. At stage Full: starter code with 1–2 gaps. At stage Guided: acceptance criteria + one hint. At stage Independent: problem statement only.

### Checkpoint

2–4 verifiable success criteria. Every criterion must be an observable yes/no question:
- [ ] `curl -N -X POST ...` shows tokens arriving line-by-line
- [ ] The last line of the stream is `data: [DONE]`
No "understand X" or "be familiar with Y" checkpoints.

### Next

One-line bridge to the next module: "The server works but forgets everything between messages. Next module: add session memory."

```

#### Fade Progression Across Modules

After generating all modules, verify:

| Module | First Encounter | Second Encounter |
|--------|-----------------|------------------|
| N | Walkthrough: Full | Your Turn: Guided or Independent |
| N+1 | — | Walkthrough references back with reduced support |

Each concept appears at least twice: once scaffolded, once with reduced support.

### Step A4 — Follow-ups

After presenting the module plan, offer: drill into any module for deeper explanation, generate additional exercises, create spaced-repetition cards, or convert any module to a Socratic mentoring session.

## 4. Path B: Content → Implementation Plan

Transform learning content (transcripts, articles, tutorials, notes) into a structured implementation plan using reps.

### Step B1 — Define the Quest

One sentence: what are you trying to ship/learn? Make it measurable ("ship Y by Z date" not "learn X").

**If the user says "I want to learn X" without specifying what they'll ship:**
- Push back: "Learning X isn't measurable. What would shipping X look like?"
- Offer 2–3 concrete quest options
- Don't proceed until quest is measurable

### Step B2 — Design Rep 1

Keep it small. Goal of rep 1 is to learn the loop, not achieve the final outcome. Reps should sit between boredom threshold and frustration threshold.

**Key question:** "What's the smallest rep that would teach you the loop?"

**3-attempt rule:** If the user tries three times and learns nothing new, the rep is wrong, not them. Signs a rep is stuck: 3+ failed attempts, no new learning, avoidance behavior. In that case, cut the rep in half.

### Step B3 — Identify Resources for Current Rep Only

List only resources the user will use this week. Anything else is procrastination fuel.

### Step B4 — Set Reflection Trigger

Define when/how the user will reflect (after each rep, weekly, etc.). Without reflection, reps don't compound.

**Key questions:**
- "How will you know this rep worked?"
- "What would make you abandon this rep?"
- "Is this rep too easy or too hard?"

### Step B5 — Plan Next 5 Reps Max

Never plan more than 5 reps ahead. Plans beyond five reps are fiction.

#### Rep Management Decision Trees

| Situation | Action |
|-----------|--------|
| Both reps teach same skill AND one is <2 hours AND combined doesn't exceed 7 days | **Merge.** Example: "Write email" + "Send email" → "Write and send 10 emails" |
| Rep has >3 distinct skills AND each needs its own feedback loop AND total exceeds 7 days | **Split.** Example: "Build a website" → "Design homepage" + "Write copy" + "Set up hosting" |
| 3+ failed attempts AND no new learning AND avoidance AND smaller version exists | **Abandon.** Cut rep in half. Ship the smaller version today. |

### Step B6 — Save and Revisit

Save the plan to a file. Ask the user to confirm rep 1 is achievable. Set a reminder to revisit. Offer to adjust based on feedback.

## 5. Anti-Patterns

NEVER do any of these:

- **NEVER rate experience for the user.** If context doesn't tell you, ask. Guessing makes depth calibration worthless.
- **NEVER produce a module with no Your Turn exercise.** A module without a hands-on task is a reading assignment, not a lesson.
- **NEVER produce a Walkthrough that reads like a README.** If you write "X is a tool that does Y. Here are its features," restart from the problem it solves.
- **NEVER collapse every depth-5 item into "you know this."** The mapping says "skip unless there's a subtle pitfall" — surface those when they apply.
- **NEVER generate checkpoints that aren't verifiable.** Every checkpoint must be observable: a file exists, a command returns X, a test passes.
- **NEVER assume the learner knows their own knowledge gaps.** Learners overestimate expertise because metacognition is hard — knowing what you don't know is itself a learned skill. Always ask applied calibration questions rather than accepting self-ratings.
- **NEVER skip the "surprise" moment.** Every module/rep should have at least one moment where the learner encounters an unexpected behavior. Misconceptions that aren't surfaced compound.
- **NEVER use boilerplate explanations.** If the learner rated 3+, don't re-explain from scratch — re-explaining wastes attention budget and signals the learner isn't being respected, causing disengagement. Say "you've seen this — here's what's different."
- **NEVER let a Walkthrough exceed 8 paragraphs.** If it doesn't fit, split into two modules.
- **NEVER plan more than 5 reps ahead.** Plans beyond five reps are fiction — learning velocity changes faster than any plan can predict. Rep 6's design will be based on information that's obsolete by the time you reach it.
- **NEVER accept "I'll learn X" as a goal.** Learning is not measurable. Require a shippable output.
- **NEVER skip the reflection step.** Without reflection, reps don't compound.
- **NEVER make rep 1 too ambitious.** Goal of rep 1 is to learn the loop, not achieve the final outcome.
- **NEVER list resources the user won't use this week.** That's procrastination fuel.

## 6. Edge Cases

**MANDATORY:** When encountering an ambiguous or edge-case scenario during Path A or Path B, read [`references/edge-cases.md`](references/edge-cases.md) for the full decision table.

**Do NOT load** this reference for routine Path A or Path B flows where the input is clear and the user's intent is unambiguous.

## 7. Learning Design Knowledge

**MANDATORY:** Before generating Path A modules (Step A3), read [`references/learning-design-knowledge.md`](references/learning-design-knowledge.md) for spacing, interleaving, minimal-viable exercise, the surprise principle, and worked example fading. For Path B, load when designing reps (Step B2).

**Do NOT load** this reference during Steps A1-A2 (Acquire & Parse, Map Ratings) or Step B1 (Quest Definition) — the pedagogical design principles apply only during content generation.