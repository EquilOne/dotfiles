# Learning Design Knowledge

## Spacing Effect
Distribute practice across time. For Path A: suggest "Revisit this concept in 2 days with a new exercise — try changing X to Y." For Path B: space reps across days, not hours. Do NOT enforce spaced practice as a structural requirement — add as suggestions.

## Interleaving
Mix related concepts rather than blocking them. In Path A Walkthroughs: "We're building an SSE endpoint — but the browser's CORS policy blocks it. Let's solve both at once." For Path B: ensure each rep draws on at least one skill from a prior rep. Interleaving feels harder but transfers better.

## Rep Difficulty Calibration (Path B)
Reps sit between boredom threshold (too easy, no learning) and frustration threshold (too hard, stuck). If the user says a rep is too easy, add a constraint. If too hard, find a smaller version.

## Minimal Viable Exercise
The smallest exercise that proves the objective is not the most thorough one. It's the one that fails informatively if the concept isn't understood. "Change the system prompt and restart the server" is minimal. "Build a todo app" tests too many things at once.

## The "Surprise" Principle
The most valuable learning moment is when the learner's mental model predicts one thing and reality shows another. Design at least one such moment per module/rep. In an SSE module, the surprise is "without `data: [DONE]`, the stream hangs forever." The learner predicted it would end on its own.

## Deliberate Practice Conditions (Path B)
Every rep must have: (1) specific goal, (2) focused attention, (3) immediate feedback, (4) refinement loop. Most "practice" fails due to absence of one of these.

## Worked Example Fading (Path A)
Novices benefit most from seeing full worked examples before attempting problems. Sequence: watch (full example) → complete (faded with gaps) → explain (self-explanation prompt). This builds schema more effectively than jumping to independent problem-solving.