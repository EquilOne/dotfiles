---
name: self-heal
description: "Diagnose and fix problems with skills, agent instructions, and config files. Never auto-fixes — always presents findings and asks for approval before making changes. Use when the agent keeps making the same mistake, the user says 'this didn't work', a skill should fire but doesn't, config files fail validation, agent instructions produce wrong results, or the user explicitly asks to self-heal. Fire on: 'self-heal', 'heal', 'this config is broken', 'review my skills', 'check my agent config', 'this skill is useless', 'you keep making the same mistake', 'something is off with the setup', repeated corrections, config validation errors, or skill description mismatches."
---

# Self-Heal

Diagnose and fix problems with skills, agent instructions, and config files. Never auto-fixes — always presents findings and asks for approval before making changes.

**Must ask user before running this skill.** Do not self-trigger. Activate only when the user explicitly requests it or their behavior signals a systemic issue.

## Thinking Framework

Before diagnosing, internalize this diagnostic mindset:

> **You are a doctor for agent config. The patient (skills, AGENTS.md, opencode.json) can't tell you what's wrong. You must gather symptoms, test hypotheses, propose treatments, and let the patient (user) decide whether to proceed.**

The five phases mirror medical diagnosis:
1. **Detect** — What symptoms exist? (don't treat yet)
2. **Diagnose** — What's the root cause? (don't prescribe yet)
3. **Propose** — What's the treatment plan? (don't operate yet)
4. **Apply** — Perform the approved treatment (only what's approved)
5. **Verify** — Did the treatment work? (if not, re-enter at Phase 1)

## Trigger Signals

Fire when the user says or implies:

- "This didn't work" / "That's wrong" / "Not what I wanted"
- "Why did you do that?" / "I told you not to do that"
- "This skill is useless" / "You keep making the same mistake"
- "This config is broken" / "Something is off with the setup"
- "Can you review my skills?" / "Check my agent config"
- "Run self-heal" / "Self-heal" / "Heal" (explicit invocation)

Also fire when:
- User corrects the same behavior 2+ times in a session
- Agent expresses uncertainty about its own instructions
- Config file validation fails (malformed JSON, missing fields)
- A skill description clearly doesn't match what the user is asking for

## Workflow

### Phase 0: Should You Heal? — Pre-check

Before investing in detection, check whether self-healing is appropriate:

| Situation                                       | Action                            |
| ----------------------------------------------- | --------------------------------- |
| Single mistake, no repetition                   | Correct in chat, don't heal       |
| User is experimenting / exploring               | Let them explore, don't intervene |
| User just installed new config                  | Wait 2-3 sessions for patterns    |
| Issue is in the user's application code         | Tell user: out of scope           |
| Model hallucinated — no config or skill at fault | Identify as model issue, not heal |
| Multiple failures or repeated pattern           | Proceed to Phase 1                |

If the situation is not appropriate, tell the user why and stop. Do not proceed to Phase 1.

### Phase 1: Detect — Gather Evidence

Run these checks in parallel. **Do NOT skip checks** — the user may not know what's wrong but will know when the fix is wrong.

1. **Skill description audit** — Read all SKILL.md files in `~/.config/opencode/skills/` and `~/.agents/skills/`. Check each description against current conversation context. Does the user's request match any skill's trigger? If a skill should have fired but didn't, flag it.

2. **Missing file check** — Verify every file referenced in `opencode.json` (plugins, agent configs, MCP configs), `reference.md` (all agent entries), and any SKILL.md that loads reference files actually exists on disk. Flag broken references.

3. **Repeated correction check** — Scan conversation history for patterns where the user said "no", "not that", "wrong", "I already told you" about the same topic 2+ times. Flag the topic.

4. **Config validation** — Check `opencode.json` and `tui.json` against schema (https://opencode.ai/config.json). Check for missing required fields, invalid model names, agent routing mismatches between `opencode.json` and `reference.md`.

5. **Skill quality check** — If a skill is underperforming, run skill-judge evaluation on it. Only run on skills the user has complained about or that should have fired but didn't.

6. **Git history check** — If git-tracked, check recent commits for changes to skills, configs, or agent files. Flag recent changes that correlate with the user's complaint.

### Phase 2: Diagnose — Find Root Cause

**MANDATORY — READ ENTIRE FILE**: Before diagnosing, you MUST load and read `references/diagnostic-tables.md` (~37 lines) completely. It contains symptom/cause/fix lookup tables.

**Do NOT load** `references/diagnostic-tables.md` at any other phase — it is only needed during Phase 2.

For each finding from Phase 1, trace to root cause. Present findings as:

```
| #   | Issue         | Source            | Root Cause                       | Severity |
| --- | ------------- | ----------------- | -------------------------------- | -------- |
| 1   | X never fires | skills/X/SKILL.md | Description has no WHEN triggers | High     |
```

When multiple findings exist, prioritize by severity:
- **Critical** (config won't load, agent can't respond) — fix first
- **High** (skill fires wrong, agent does opposite of intent) — fix this session
- **Medium** (skill doesn't fire, description outdated) — propose, can defer
- **Low** (cosmetic, unused parameter) — mention but don't block

### Phase 3: Propose — Present Fixes

For each diagnosed issue, propose a specific fix. Be precise — say "change line 12 of X.md from `A` to `B`", not "update the description".

Each proposal must include:
- **File** — exact path
- **What to change** — line numbers or section
- **Current content** — quote the relevant lines
- **Proposed content** — what it should be instead
- **Rationale** — why this fix addresses the root cause

Group proposals by type: **Changes** (edits), **Rollbacks** (git revert), **New files** (creations).

**Ask the user**: "Which proposals should I apply? (list numbers, 'all', or 'none')."

If the user says "none" or proposes an alternative approach:
- **"None"** — Summarize findings and ask: "What would you like to do differently? I can adjust the proposals."
- **Alternative approach** — Update the proposals to match the user's approach, then re-present for approval.
- **"Let me handle it"** — Acknowledge and stop. The user will fix it themselves.

### Phase 4: Apply — Execute Approved Changes

Apply only what the user explicitly approved. For each:

1. **Edits** — Write the exact change proposed.
2. **Rollbacks** — `git revert <commit>` or restore from backup.
3. **New files** — Create with content proposed.

After each change, validate:
- JSON files: validate against schema
- SKILL.md: verify description still present
- AGENTS.md: verify key section unchanged

### Phase 5: Verify — Confirm Fix

1. **Re-check** — Re-run relevant Phase 1 checks. Does the issue still exist?
2. **Summary** — Tell the user what changed, what didn't, what to test next.
3. **Follow-up** — "Try your original request now. If it still doesn't work, run self-heal again."

## Anti-Patterns

- NEVER auto-fix without approval — you are diagnosing, not operating. Every change needs the user's explicit yes. **Why**: The user's config reflects their intent. An auto-fix that changes the wrong thing erodes trust more than the original bug.
- NEVER fix everything at once — batch by symptom, not convenience. **Why**: Multiple changes at once hides which fix worked. If the user says "that's still broken" after 5 changes, you can't tell which one mattered.
- NEVER diagnose without evidence — if you can't point to a specific line or conversation, you haven't found the cause. **Why**: Guessing the root cause wastes the user's time and produces irrelevant proposals. The diagnostic table exists to give you specific mappings.
- NEVER change a skill description without checking the skill body — fixing the trigger on a broken skill makes things worse. **Why**: A skill that fires but does the wrong thing is more damaging than a skill that never fires — it actively produces bad output.
- NEVER suggest rollback without checking git log first — a rollback may revert intentional changes. **Why**: Recent commits may contain deliberate improvements. Blind rollback discards the user's work. Always check the commit message and diff.
- NEVER rewrite a skill from scratch — fix the specific failure point. **Why**: The user wrote the skill for a reason. Whole-skill rewrites discard the user's calibration of what works for their specific workflow. Targeted edits preserve intent.
- NEVER report a finding without a proposed fix — every finding must pair with an actionable proposal. **Why**: "This is broken" with no path forward is noise. The user is paying attention to see what you recommend. An orphan finding wastes the slot.
- NEVER claim healing is complete — self-healing is iterative. **Why**: The first pass may not catch everything. Ending with "test and let me know if it's better or if there's more to fix" sets proper expectations and invites the next iteration.

## Out of Scope

- Fixing user's application code — this heals agent config, not the user's project
- Auto-tuning model parameters — this skill doesn't change provider/price settings
- Creating new skills from scratch — use skill-creator for that
- Evaluating skills without proposing fixes — use skill-judge for pure evaluation
- Debugging plugin code — plugins are third-party, this skill only edits config