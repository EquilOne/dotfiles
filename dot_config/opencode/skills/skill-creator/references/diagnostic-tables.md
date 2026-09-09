# Diagnostic Tables

> **Load when iteration fails or the user reports problems.** These tables help diagnose why a skill isn't working. Do NOT load on every invocation — only when the user reports issues or asks for troubleshooting.

## When Iteration Fails

The skill will not be right on the first draft. When the user reports problems, diagnose before fixing:

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Skill fires when it shouldn't | Description is too broad, no negative triggers | Tighten KEYWORDS; add "Use ONLY when..." to description |
| Skill doesn't fire when it should | Description missing WHEN or specific phrases | Add 3+ concrete user phrases; remove generic verbs |
| Skill fires but output is wrong | Body has generic advice, not domain-specific knowledge | Rewrite body with concrete procedures only the model would not know |
| User keeps correcting the same thing | Skill is over-constrained or under-constrained | Find the constraint that is wrong — loosen rigid MUSTs, tighten vague advice |
| Description is fine but skill feels redundant | Skill duplicates content already in AGENTS.md or another skill | Cut the duplication; point to the canonical source |

Do not auto-loop. Each fix needs user confirmation before applying.

## Handle Edge Cases

Use this decision tree when the request is unclear or the iteration hits friction:

| Situation | First Move | If That Fails |
|-----------|-----------|---------------|
| Request is ambiguous | Ask one clarifying question about WHAT the skill should enable. | Propose 2-3 candidate scopes and let the user pick. Default to the smallest viable scope rather than guessing wide. |
| Skill exists but is bad | Read it first. Identify what's wrong (description? structure? triggers?). Propose specific fixes. | If the user disagrees with the diagnosis, ask which symptom they want fixed first. Do not rewrite from scratch unless the structure is fundamentally broken. |
| User wants a one-off | Push back. The bar is: "you'd use this 3+ times across different prompts." | If under that, suggest chat-only or a slash command instead. If the user insists, make it anyway but mark it `experimental` in frontmatter metadata. |
| Forking a skill | Copy the directory, rename in frontmatter, update triggers to match the new scope, keep the parent's good parts. | If the parent changes later, note the divergence so the user can rebase manually. |
| User rejects iteration changes | Ask which specific change they reject and why. Update only that part — do not revert everything. | If the user rejects 2+ iterations on the same section, that section needs a different approach, not more polish. |
| Skill passes validation but never triggers | Description is the problem. Apply the three-question framework — usually WHEN or KEYWORDS are missing. | Add 2-3 more trigger phrases the user might say. Bias toward over-triggering. |
