---
name: direct-instruction
description: >-
  Teach any non-code concept from scratch using direct instruction with
  worked examples and faded scaffolding. Default: explain, show annotated
  example, then let learner fill gaps in a partially worked example.
  Use when user says "teach me about X", "explain how X works"
  (conceptual, not code snippet), "walk me through this concept",
  "I want to learn X", "help me understand X" (learning-oriented),
  "what is X and how does it work", "break down this concept for me",
  "how does X actually work" (no code attached).
  Does NOT handle: code explanation — use explain-code (code snippets,
  files, or "what does this code do").
  Does NOT handle: Socratic guided reasoning — use socratic-mentoring
  ("guide me don't tell me", "help me reason through it").
  Does NOT handle: interactive delivery of a pre-existing lesson plan —
  use teach-from-lesson ("walk me through this plan").
  Does NOT handle: creating a multi-session learning plan —
  use structured-learning ("turn this into a course").
  Delegates to socratic-mentoring when learner is stuck after 2
  direct instruction attempts. Delegates to structured-learning when
  learner wants a full multi-module plan.
---

## When NOT to Use

- User provided a code snippet or file — use explain-code
- User wants guided discovery ("guide me", "don't give the answer") — use socratic-mentoring
- User has a lesson plan — use teach-from-lesson
- User wants a multi-session learning plan — use structured-learning
- User wants API reference or library docs — use find-docs
- User just wants a quick answer, not a teaching session

## Pattern: Process

Phased workflow with checkpoints: Calibrate → Explain → Show → Practice → Verify → Next. Each phase has an exit condition. Medium freedom within phases (example choice, depth, analogy).

## Thinking Frame

Before responding to a learner, ask yourself:

- **Calibration check:** Did I ask what they already know? If not, do that before teaching.
- **Move check:** What move am I in? (Explain / Worked Example / Faded Example / Verify). Stay in the current move until its exit condition is met. Do not advance early.
- **Delegation check:** Has the learner failed the faded example twice or said "I don't know" twice? If yes, offer Socratic delegation — do NOT keep re-explaining.
- **Gap check:** Did the learner answer correctly but cannot explain why? Return to Faded Example with a new context. Correct answer without reasoning is not understanding.

## Phase 1: Calibrate

Before teaching, ask 2 quick questions. Do NOT skip.

1. **Familiarity:** "What do you already know about X?" (never heard of it / heard the term / used it a few times / comfortable)
2. **Goal:** "What do you want to do with this?" (understand conceptually / use it in a project / prepare for something)

**Routing check:** If during calibration the user reveals they actually want a quick answer (not a teaching session), switch to concise explanation. If they show a code snippet, flag that explain-code would be better.

**Exit condition:** User's familiarity and goal are clear enough to calibrate depth.

## Phase 2: Direct Instruction

Three moves, delivered one at a time. Never dump all three in one response.

### Move A — Explain

One paragraph (max 5 sentences). Answer:
- What is X? (definition in plain language)
- Why does X matter? (the problem it solves)
- When would you use X? (concrete scenario)

**Depth calibration:**
- Never heard of it: start with analogy, define all jargon
- Heard the term: brief definition + focus on what's non-obvious
- Used it before: skip Explain, go straight to Worked Example

### Move B — Worked Example

Fully annotated example showing X in action. One paragraph framing the scenario, then the example with step-by-step annotation.

Rules:
- The example must be DIFFERENT from the scenario used in Explain.
- Annotations explain WHY, not WHAT. The learner can see what the code/step does; tell them why it's done that way.
- If the concept has multiple forms, choose the most common one.

### Move C — Faded Example

Same concept, different context. Show a partial example with 1-2 gaps clearly marked.

Framing: "Now try this one. Same concept, different situation. Fill in the gaps."

Mark gaps clearly. After the learner responds:
- Correct: "Right. Why did that work here? Same concept as before?"
- Partially correct: Identify what's right, probe the gap.
- Wrong: "Let's look at the worked example again. In that case, we did X because Y. How is this case different?"

**Exit condition:** Learner completes the faded example with understanding (can explain why their answer works).

**Stuck rule:** If the learner fails the faded example twice or says "I don't know" twice:
- Offer 1: "Let me show you a simpler version." (adjust difficulty)
- Offer 2: "This might work better as guided discovery. Want me to switch?" → delegate to socratic-mentoring

## Phase 3: Verify

One verification check. Ask the learner to explain the concept back in their own words, or apply it to a slight variation.

**Grading:**
- Correct + can explain reasoning → advance to Next
- Correct but can't explain why → return to Faded Example with a new context
- Wrong → return to Worked Example, highlight the key insight they missed

## Phase 4: Next

Bridge to next concept or offer next steps:
- "Now that you understand X, want to learn Y?" (related concept)
- "Want more practice?" (additional faded examples)
- "Want to go deeper?" (more advanced aspects)
- "Want me to build a full learning plan?" → delegate to structured-learning

## Delegation Rules

| Learner signal                       | Delegate to         | How to offer                                                |
| ------------------------------------ | ------------------- | ----------------------------------------------------------- |
| Stuck after 2 faded example attempts | socratic-mentoring  | "This works better as guided discovery. Want me to switch?" |
| Wants a full multi-session plan      | structured-learning | "Want a structured learning plan with multiple modules?"    |
| Shows a code snippet mid-session     | explain-code        | "That's code-specific. Let me explain this directly."       |
| Has a lesson plan                    | teach-from-lesson   | "You have a plan — let me walk through it interactively."   |

## Anti-Patterns

### 1. Skipping the Faded Example
Jumping from worked example to independent practice with no intermediate scaffold. Most learners can't bridge from watching to doing without a transitional step.
Fix: Always include a faded example where the learner fills 1-2 gaps targeting the key insight.

### 2. Same Example for Worked and Faded
Using the same scenario for both. The learner copies the pattern without understanding — pattern-matching, not learning.
Fix: Always change the context (different domain, different data) between worked and faded examples.

### 3. Confirming Without Verifying
Learner fills the gap correctly. You say "Correct!" without checking their reasoning. They may have guessed.
Fix: After a correct fill, always ask "Why does that work?" or "What would happen if we changed X?"

### 4. Teaching the Abstraction Before the Problem
Starting with "X is a concept that..." before explaining what problem X solves. No anchor for why it matters.
Fix: Start with the problem: "Imagine you need to do Y but can't because of Z. X solves this by..."

### 5. Staying Too Long in Direct Instruction
Learner is stuck (wrong answers, "I don't know", silence). You keep re-explaining. Diminishing returns.
Fix: After 2 failed attempts, offer the Socratic delegation. When the learner needs to discover the concept themselves, direct instruction has a ceiling.

### 6. Using Direct Instruction When Another Mode Fits

The user provides a lesson plan or says "guide me, don't tell me." You ignore the signal and continue teaching directly. The learner gets frustrated because their request was ignored.

Fix: If the user mentions a plan, file, or prior material — ask "Do you have a lesson plan you want me to walk through?" If yes, delegate to teach-from-lesson. If they say "guide me" or "don't give the answer," delegate to socratic-mentoring.

### 7. Teaching Syntax Before Concept

The user asks "teach me about async/await." You immediately show code and explain syntax instead of teaching the conceptual model first (event loop, non-blocking I/O, why JavaScript needs this). The learner memorizes syntax but can't reason about when to use it.

Fix: Teach the concept first (what problem it solves, how it works at a high level), then show the worked example. Code without concept context is memorization, not learning.

## Edge Cases

**MANDATORY — READ ENTIRE FILE:** When the learner's response doesn't fit the standard moves (calibrate → explain → show → practice → verify), or when you encounter any non-standard scenario, read [`references/edge-cases.md`](references/edge-cases.md) completely before responding.

Scenarios that require loading this reference:
- Learner says "just tell me how to do it"
- Learner says "I already know this"
- Learner asks something that's really a code snippet
- Learner wants a quick answer, not a session
- Mixed-mode request (concept + code together)

**Do NOT load** this reference for routine flows where the learner is engaged and the standard moves are progressing normally.
