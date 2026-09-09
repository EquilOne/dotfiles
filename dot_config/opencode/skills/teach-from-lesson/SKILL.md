---
name: teach-from-lesson
description: >
  Delivers an existing lesson plan interactively, walking the user through each module
  step-by-step with back-and-forth engagement. Only fires when a lesson plan is provided or referenced. Use when the user says
  "walk me through this plan",
  "take me through module 1", "teach me from this plan",
  "go through this lesson with me", "lead me through this tutorial",
  "I have a lesson plan, teach me from it", "let's work through this module",
  "walk me through the lesson step by step", "teach me — here's my plan",
  "take me through this material".
  Also fires when user pastes a structured learning plan or tutorial and asks
  for interactive delivery. Does NOT replace socratic-mentoring (purely Socratic,
  no lesson plan), structured-learning (creates plans, doesn't teach them),
  or direct-instruction (teaches concepts from scratch without a plan).
---

# Teach From Lesson

Deliver any lesson plan interactively. Present content in chunks, check
understanding after each, adapt pacing and depth based on the learner's
responses. One module at a time. Never dump everything at once.

## When NOT to Use

- User says "just give me the answer" or "I need to get this done fast" —
  direct instruction, not interactive teaching
- User wants purely Socratic guided reasoning with no lesson plan —
  use socratic-mentoring
- User wants to CREATE a lesson plan from scratch —
  use structured-learning
- No lesson plan provided (user just says "teach me Python") —
  ask for a plan, or offer to teach directly from scratch (use direct-instruction)
- One-off code explanation with no lesson structure —
  use explain-code or general subagent

## Pattern: Process

Phased workflow with checkpoints. The 3 phases (Detect → Calibrate → Deliver)
are fixed and sequential. Within Delivery, adaptation decisions (pace, depth,
scaffolding) are medium-freedom based on learner signals.

## Freedom Calibration

This skill uses medium freedom, varying by phase:

- **Low freedom:** Phase ordering (Detect → Calibrate → Deliver) is fixed. Chunk size rule (60-second read) is non-negotiable. Scaffolding fade rule (3 consecutive correct = drop one level) must be followed exactly. Calibration questions must be asked before module 1.
- **Medium freedom:** Within Delivery, pacing adaptation, check type selection (see adaptation table), and extension depth are judgment calls based on learner signals.
- **High freedom:** Analogy choice, example selection, and re-explanation framing are creative choices — adapt to what the learner responds to.

## Phase 1: Detect & Parse

Accept the lesson plan. Source: file path, inline text, or a reference to
a previously generated structured-learning plan.

Extract the structure. A lesson plan has:
- **Title / goal** — one line describing what the learner achieves
- **Modules** — ordered sections, each with a heading/objective
- **Content** — explanations, examples, code snippets, exercises
- **Checkpoints** (optional) — verifiable success criteria

If the plan is unstructured prose with no clear sections, confirm the
extracted module boundaries with the user before proceeding.

If the user says "teach me X" with no plan attached: respond with
"This skill requires an existing lesson plan. Do you have one, or
would you like me to teach this directly from scratch?"

## Phase 2: Calibrate

Before teaching, ask 2-3 quick calibration questions:

1. **Familiarity** — "How familiar are you with this topic? (new / some exposure / comfortable)"
2. **Pacing** — "Pacing preference: fast (skim known parts), normal, or thorough (deep dive on each step)?"
3. **Goal** — "Are you learning for understanding, or do you need to ship something afterward?"

Record the answers. They control adaptation throughout delivery.

**If the learner says "comfortable" + "fast":** skip detailed walkthroughs.
Present module summaries and jump to exercises or checkpoints.

**If the learner says "new" + "thorough":** deliver full content, pause
frequently, ask verification questions after each concept.

**If the learner says "some exposure" + "normal":** default balanced mix
(explain → check → adapt). This is the most common profile.

## Phase 3: Delivery Loop

One module at a time. Three moves per module:
**Before presenting anything, ask yourself:**
- Is this chunk the right size? (60-second read max)
- What's the one thing the learner must understand from this chunk?
- What question will I ask to verify they got it?


### Move A — Present

Deliver the module's content in **2-3 digestible chunks**. After each chunk,
pause. Do NOT dump the entire module at once.

**Chunk size rule:** No chunk longer than the learner could read in 60 seconds
(~15 lines of text or ~10 lines of code). If a module's walkthrough is longer,
split into sub-chunks with natural pause points.

**Presentation mode** depends on calibration:
- New + Thorough: Full explanation, annotated examples, "why this matters"
- Some exposure + Normal: Brief recap, focus on what's different/new
- Comfortable + Fast: One-paragraph summary, jump to Your Turn

### Move B — Check Understanding

After each chunk, verify. Choose one check type based on learner response:

| Learner Signal                | Check Type                   | Example                                                           |
| ----------------------------- | ---------------------------- | ----------------------------------------------------------------- |
| Silent / no reaction          | Open probe                   | "What did that line do? In your own words."                       |
| "OK" / "Got it"               | Verification question        | "What would happen if we changed X to Y?"                         |
| "I think it works because..." | Self-explanation prompt      | "Can you explain why that pattern works, not just what it does?"  |
| Confident + correct           | Quick confirmation + advance | "Right. Ready for the next part?"                                 |
| Wrong answer                  | Diagnostic probe             | "What led you to that conclusion? Walk me through your thinking." |
| "I'm confused"                | Scaffold                     | Offer a simpler analogy or break the concept down further         |

**Adaptation rule:** After 2 consecutive "got it" with correct checks,
increase pace (combine chunks, skip the next check).
After 1 wrong answer or "confused" signal, decrease pace (split
further, add more scaffolding).

**Anti-sycophancy:** Never confirm without reason. Learner says
"I think X causes Y" → "What makes you say that?" — don't confirm
until they articulate the mechanism.

### Move C — Advance Gate

Before moving to the next module, confirm readiness:

- "Ready to move on, or do you want to go deeper on this one?"

Learner choices:
- **Advance** → next module
- **Go deeper** → offer extension: harder example, edge cases, transfer to
  a different context. Max 2 extension rounds per module.
- **Review** → re-present the core concept with a different explanation or
  analogy. Max 1 review per module.
- **Skip** → move on without further checks. Only if learner explicitly
  requests it.

**Module stuck rule:** If learner has been on one module for >15 minutes
AND is still confused despite 2+ re-explanations AND 2+ scaffold attempts:
offer to skip the module and move on. Some concepts click later when seen
in context.

**Expert calibration:** The 15-minute threshold is a guideline, not a law.
If the learner is making progress (asking better questions, narrowing the
scope), extend to 20 minutes. If they are spinning at minute 3 (repeating
the same wrong approach, going silent), intervene earlier. Signs of
productive struggle: testing hypotheses, asking focused questions. Signs
of spinning: repeating the same error, silence, re-reading same docs.

### Module End

After advancing: one-line bridge to the next module.
"Next module builds on this — instead of one user, you'll handle a list."

## Adaptation Reference

### Calibration → Behavior Mapping

**MANDATORY - READ ENTIRE FILE:** During Phase 2 (Calibrate) and the first
module of Phase 3 (Delivery), read
[`references/adaptation-table.md`](references/adaptation-table.md) (~15 lines)
completely. It maps every familiarity + pacing combination to presentation
style, check frequency, and module pace.

**Do NOT load** this reference after module 1 completes, or when the learner
profile is "comfortable + fast" (skipping detailed walkthroughs).

### Scaffolding Levels

| Level  | Behavior                                             | When to Use                                |
| ------ | ---------------------------------------------------- | ------------------------------------------ |
| Low    | Probe-based: ask, never tell.                        | Learner confident and correct on 2+ checks |
| Medium | Present chunk, ask verification question.            | Default for "some exposure" learners       |
| High   | Present chunk, verify step by step, offer analogies. | Learner is new, confused, or hesitant      |

**Scaffolding fade rule:** After 3 consecutive correct checks at current
level, drop one level. After 2 consecutive wrong checks, raise one level.

## Anti-Patterns

### 1. Module Dump
Dumping all content at once. The learner gets overwhelmed, can't process,
and the interactive back-and-forth collapses into a lecture.
Fix: Split into 2-3 chunks. Pause after each. Check before continuing.

### 2. Forced Pace
Pressing forward despite signals of confusion (short answers, hesitation,
wrong answers). The learner checks out and learns nothing.
Fix: Watch for 2+ confusion signals in a row. Slow down, re-scaffold.

### 3. Skipping Calibration
Starting to teach without knowing the learner's level or pacing preference.
The content is either too simple (boredom) or too advanced (lost).
Fix: Always ask 3 calibration questions before module 1. No exceptions.

### 4. Lecturing Instead of Teaching
Presenting the material uninterrupted like a README or slide deck. No
check-ins, no probing, no adaptation. This is what the model does
by default — the skill exists to prevent this.
Fix: After every chunk, ask something. Even "Does that make sense?"
is better than silence. Better: ask a specific question about the chunk.

### 5. Confirming Wrong Answers to Be Nice
Learner gives wrong reasoning. You say "close!" or "almost there" instead
of correcting. The learner encodes the wrong model.
Fix: "That's not quite right. Walk me through your thinking — where did
that assumption come from?"

### 6. Letting One Module Drag On Endlessly
Learner is stuck on module 1 for 20+ minutes, cycling through re-explanations.
Diminishing returns kick in hard after the 3rd attempt.
Fix: Apply the module stuck rule at 15 minutes. Offer to skip and revisit.
Some concepts only click when seen applied in a later module.

## Edge Cases

**User says "just teach me, stop asking questions":**
Respect it. Drop checks to a minimum. Deliver content in normal chunks but
don't interrupt for verification. Offer one check at module end: "Quick check
before we move on?" If they say no, advance.

**User interrupts with a tangential question:**
Note the current position in the module. Answer the tangent briefly
(max 2 exchanges). Offer: "Shall I connect this back to the lesson, or
explore this more first?" Then return to the saved position.

**User already knows part of the module:**
"Skip ahead to the exercise?" or "This is review for you — jump to the
Your Turn section?" Trust the learner's self-assessment here (unlike in
structured-learning calibration, the cost of overestimating is just
repeating the module).

**Lesson plan has no exercises:**
After presenting content, generate an ad-hoc verification question or
mini-exercise based on the material. "Let me test: how would you do X
with what we just covered?" Don't skip the check just because the plan
has no Your Turn section.

**Lesson plan only has code (no prose, no explanations):**
Treat the code as the content. Walk through it line by line in chunks.
After each chunk: "What does this line do?" "Why is this pattern used?"
Let the code be the curriculum.
