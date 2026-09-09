# Socratic Mentoring — Worked Examples

Use these dialogues as a template for real mentoring sessions. Each example labels the gate, the mentor move (probe vs hint), and the resulting progression. These are not scripts — adapt probes to the student's exact code and level.

## How to Read These Examples

- **Student lines** show the learner's raw thinking.
- **Mentor lines** are tagged as `Diagnostic`, `Probe`, or `Hint`.
- **Gate markers (`→ Gate met`)** show when the condition for advancing is achieved.
- Watch for where scaffolding lowers and where it must rise again because the learner regressed.

## Example 1: Debugging Async Code (JavaScript)

Student: "My function returns undefined even though I call an API."

- Diagnostic probe: "Walk me through the order of execution. When does `fetchUser` run vs when do you read `user.name`?"
- Student: "Oh... I read it right after calling the function."
- Mentor: "What does `fetchUser` actually return at that moment?" (Guided Exploration probe)
- Student: "A Promise."
- Mentor: "So where do you need to be to read the resolved value?"
- Student: "Inside `.then()` or after `await`."
→ Gate met: action/clear next step. Student proceeds to fix.
→ Consolidation: "Explain why moving the read fixed it."
→ Extension: "What if two async calls depend on each other's results — what pattern avoids the pyramid?"

## Example 2: Algorithm Design (Two Sum)

Student: "I can solve it with nested loops but it's slow."

- Diagnostic: "What's the cost of nested loops in big-O terms? What are you actually looking for each iteration?"
- Student: "O(n²). I'm looking for the complement."
- Mentor: "If you could know the complement in O(1) time, what data structure helps?" (hint)
- Student: "A hash map? Store number → index."
- Mentor: "Try writing that." (Gate: clear next step)
→ After success, Consolidation: "Why is the hash-map version O(n) instead of O(n²)?"
→ Extension: "What if the array is sorted already? Could you solve it with less space?"

## Example 3: System Design (Rate Limiter)

Student: "How would you design a rate limiter for an API?"

- Diagnostic: "What axis matters most: per-user, per-IP, or per-endpoint? And what happens when the limit is exceeded?"
- Student: "Per-user. Over-limit requests should be rejected."
- Mentor: "What window model fits best — fixed, sliding log, or token bucket? Defend your choice." (probe)
- Student weighs trade-offs, picks token bucket.
→ Gate met: student takes a position. Guided Exploration continues trade-off probes.
→ Consolidation: "Restate why token bucket handles bursts better than fixed window."
→ Fade scaffolding after this third concept win; next response uses fewer direct hints.

## Example 4: When to Swap to Pseudocode

Student debugging a recursive tree flatten. Stuck for 14 minutes, frustration high.

- Diagnostic: repeated probing reveals student is looping through children incorrectly.
- Multiple Guided Exploration probes and one hint fail to unlock.
- Mentor (exception): writes ≤5-line pseudocode:
  ```
  function flatten(node):
    if node is leaf: return [node.value]
    return [node.value] + flatten(node.left) + flatten(node.right)
  ```
- Mentor: "Map this pseudocode to your actual data structure. Which part mismatches?"
- Student fixes base case, resumes Socratic mode.
→ No credit taken; pseudocode is temporary bridge, not solution.

## Example 5: Fading Scaffolding After Three Wins

Session sequence:
1. Student masters closure with high scaffolding.
2. Student masters memoization with medium scaffolding.
3. Student masters event loop with medium scaffolding.

After the third win, Mentor lowers `scaffolding_intensity` from medium → low for the next concept (promises). Responses now default to probes and assume the student can self-verify, unless the Diagnostic gate reveals anxiety or a new gap.

## Common Pitfalls to Avoid

1. **Turning the examples into a script.** Real students diverge; listen and return to the Diagnostic gate when confusion changes.
2. **Skipping Consolidation after the student says "I got it."** Ask "Explain it back in your own words" before Extension.
3. **Forcing a fade too early.** The 3-concept threshold is a minimum, not a maximum. If the student is still anxious, keep scaffolding high.
4. **Confirming a partial answer just to be encouraging.** Re-state the claim and ask for evidence before you agree.
