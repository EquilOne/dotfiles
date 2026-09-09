# Self-Heal Diagnostic Tables

Load this file during Phase 2 (Diagnose) to map symptoms to root causes and fixes.

## Symptom -> Root Cause -> Fix

| Symptom                                                | Root Cause                                                   | Fix                                                                                | Evidence Needed                                                      |
| ------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Skill never fires                                      | Description lacks WHEN/KEYWORDS triggers                     | Add user phrases to description field                                              | Read description, compare to user's actual phrasing in conversation  |
| Skill fires but output is wrong or irrelevant          | Skill content too generic, wrong pattern chosen              | Rewrite body with domain-specific procedures; check pattern table                  | Compare skill output to what user expected                           |
| Agent keeps doing the wrong thing despite instructions | AGENTS.md constraint is missing, vague, or misplaced         | Add explicit constraint at relevant section; move constraint higher                | Read AGENTS.md, identify where the behavior should have been stopped |
| Same error repeated across sessions                    | Missing anti-pattern in skill or AGENTS.md                   | Add anti-pattern entry describing the exact failure mode                           | Identify the recurring pattern, check if it's explicitly forbidden   |
| Config file causes validation error                    | JSON syntax error, missing field, model name typo            | Fix syntax, add field, correct model name against OpenRouter catalog               | Validate against `https://opencode.ai/config.json`                     |
| Agent routing wrong - wrong subagent responds          | `opencode.json` / `reference.md` mismatch                      | Align agent names and model assignments between both files                         | Compare routing tables; find discrepancy                             |
| Skills missing - skill not found on disk               | File deleted, renamed, or never created; path typo in config | Restore from git, rename, or create missing file                                   | Glob the path; confirm it doesn't exist                              |
| Skill loads but does nothing meaningful                | Skill body is generic advice model already knows             | Run skill-judge Knowledge Delta test; replace generic advice with domain knowledge | Read skill body; tag paragraphs [E] [A] [R]; compute ratio           |
| User keeps re-explaining the same workflow             | No skill exists for the workflow                             | Create skill via skill-creator                                                     | Identify workflow; check no existing skill covers it                 |
| Agent responds with uncertainty ("I don't know if...") | Instructions too vague, missing decision trees               | Add branching decision rules or explicit edge case handling                        | Read the agent/skill that should cover the scenario                 |

## Severity Classification

| Severity | Criteria                                                      | Response                |
| -------- | ------------------------------------------------------------- | ----------------------- |
| Critical | Config won't load, agent can't respond, skill breaks all uses | Fix before other work   |
| High     | Skill fires but wrong, agent does opposite of intent          | Fix in this session     |
| Medium   | Skill doesn't fire, description outdated, minor config drift  | Propose fix, can defer  |
| Low      | Cosmetic, unused parameter, minor inconsistency               | Mention but don't block |