# Example Evaluation: `python-basics` Skill

> **Load when user asks "show me what a good evaluation looks like"** or for first-time evaluators wanting a worked example. This is a complete evaluation report of a fictional mediocre skill, demonstrating realistic evidence quoting, score-justification phrasing, and grade reasoning. ~180 lines.

## Skill Under Evaluation

**Fictional skill** `python-basics` — created for demonstration only, not a real skill.

**Frontmatter:**
```yaml
---
name: python-basics
description: A helpful skill for Python programming. Covers basics, functions, and standard library.
---
```

**Body summary (~180 lines):**
- "What is Python?" — 15 lines: "Python is an interpreted, high-level, general-purpose programming language..."
- "Writing Your First Function" — 20-line tutorial: `def greet(name): return f'Hello, {name}'`
- "Common Standard Library Modules" — 40 lines listing `os`, `sys`, `json`, `datetime` with one-line usage each
- "Best Practices" — 25 lines: "write clean code", "handle errors", "use meaningful names"
- "When to Use This Skill" — 10 lines placed **in the body**, not the description
- One paragraph on `__slots__` memory optimization (the only near-expert content)
- No `references/` directory, no anti-patterns, no decision trees, no error-handling guidance

---

# Skill Evaluation Report: python-basics

## Summary
- **Total Score**: 52/120 (43%)
- **Grade**: F
- **Pattern**: None recognizable (chaotic structure)
- **Knowledge Ratio**: E:A:R = 5:15:80
- **Verdict**: Nearly pure redundancy — this Skill compresses what the model already knows and adds almost no expert knowledge.

## Dimension Scores

| Dimension | Score | Max | Notes |
|-----------|-------|-----|-------|
| D1: Knowledge Delta | 3 | 20 | ~80% redundant; teaches Python basics |
| D2: Mindset + Procedures | 4 | 15 | Only generic procedures; no thinking frameworks |
| D3: Anti-Pattern Quality | 0 | 15 | No NEVER list anywhere in the body |
| D4: Specification Compliance | 6 | 15 | Valid frontmatter but description is vague |
| D5: Progressive Disclosure | 8 | 15 | Self-contained (<200 lines) but nothing to layer |
| D6: Freedom Calibration | 8 | 15 | Mismatched — fragile file I/O gets vague guidance |
| D7: Pattern Recognition | 2 | 10 | No recognizable pattern; reads like a textbook |
| D8: Practical Usability | 5 | 15 | No decision trees, no error handling, no edge cases |

## Critical Issues

1. **The Skill is a tutorial, not a Skill.** The entire body explains concepts the model already knows ("What is Python?", "Writing Your First Function"). This is the "Tutorial" failure pattern — the author assumed a Skill should "teach" the model rather than inject expert-only knowledge.
2. **Description is useless for activation.** `"A helpful skill for Python programming. Covers basics, functions, and standard library."` answers none of the three required questions meaningfully. "Helpful" and "basics" are not trigger keywords. The Agent has no reason to activate this over its built-in Python knowledge — this is the "Invisible Skill" pattern.
3. **Zero anti-patterns.** No NEVER list anywhere. Python has decades of accumulated "don't do this" wisdom (mutable default arguments, bare `except:`, `==` vs `is`, float comparison) — none captured.
4. **"When to Use" is in the body, not the description.** 10 lines wasted telling the Agent when to use the Skill, but the Agent only reads the description before deciding to load. This information is invisible at the moment it matters — the "Wrong Location" pattern.

## Top 3 Improvements

1. **Delete ~80% of the body and replace with expert knowledge.** Remove "What is Python?", the function tutorial, and the stdlib overview. Replace with: decision trees for `pathlib` vs `os.path`, trade-offs between `dataclasses` and `attrs`, edge cases in `datetime` timezone handling, async gotchas — things the model does NOT reliably know.
2. **Rewrite the description with WHAT + WHEN + KEYWORDS.** Example: `"Python expert decisions for non-obvious choices: pathlib vs os.path, dataclasses vs attrs, datetime timezone traps, async gotchas. Use when user needs Python guidance beyond standard syntax — library selection, performance trade-offs, or debugging subtle bugs."`
3. **Add a specific NEVER list with reasons.** Example: `NEVER use mutable default arguments (def f(x=[])) — the list is shared across calls. NEVER use bare except; — it swallows KeyboardInterrupt. NEVER compare floats with == — use math.isclose().`

## Detailed Analysis

### D1: Knowledge Delta — 3/20

**Evidence (redundant content):**
- Line 12: `"Python is an interpreted, high-level, general-purpose programming language."` — The model knows this. Definition of an industry-standard term.
- Line 34: `"To define a function, use the def keyword: def greet(name): return f'Hello, {name}'"` — step-by-step tutorial for standard syntax. The model generates this without any Skill.
- Line 60: `"The os module provides a portable way of using operating system dependent functionality."` — standard-library documentation the model has memorized.

**Evidence (expert content — the only ~5%):**
- One paragraph on `__slots__` memory optimization. This is the only section approaching expert knowledge, but it's undeveloped (no trade-offs, no "when to use" guidance).

**Why 3/20:** Every instant ≤5 red flag is hit: "What is [basic concept]" sections, step-by-step tutorials, explaining common libraries, generic best practices, definitions of industry-standard terms. The E:A:R ratio of 5:15:80 places this firmly in "Bad Skill" territory (<40% Expert, high Redundant).

### D2: Mindset + Appropriate Procedures — 4/15

**Evidence:**
- The only procedures are generic: `"Step 1: Open your .py file. Step 2: Write the function. Step 3: Save and run."` — The model already knows how to open, edit, and save files.
- No thinking frameworks. No "Before writing a function, ask yourself..." prompts. No domain-specific workflows the model wouldn't know.

**Why 4/15:** Only generic procedures the model already knows. No transfer of expert thinking patterns. A Python expert's actual thinking — "Is this a hot path? Should I reach for numpy? Is mutation safe here? Does this need a dataclass or a plain dict?" — is entirely absent.

### D3: Anti-Pattern Quality — 0/15

**Evidence:** Searched the entire body for "NEVER", "don't", "avoid", "anti-pattern". Zero matches.

**Why 0/15:** No anti-patterns mentioned at all. Python is a language where the anti-patterns ARE the expert knowledge (mutable defaults, late-binding closures, `is` vs `==`, `except Exception` ordering, GIL implications). Omitting all of them means the Skill captures none of what makes a Python expert an expert. Would an expert read this and say "yes, I learned this the hard way"? No — there's nothing here to learn.

### D4: Specification Compliance — 6/15

**Evidence:**
- Frontmatter is valid YAML. `name: python-basics` is lowercase, alphanumeric+hyphens, under 64 chars. ✓
- Description: `"A helpful skill for Python programming. Covers basics, functions, and standard library."`

**Description analysis:**
- WHAT: vague ("Python programming", "basics") — what specifically?
- WHEN: missing entirely — no trigger scenarios
- KEYWORDS: missing — no "debugging", no "performance", no "library selection", no specific terms

**Why 6/15:** Valid frontmatter but description is vague and incomplete. This is the "Invisible Skill" failure pattern — even great content (if it existed) would never get activated because the description gives the Agent no reason to load it.

### D5: Progressive Disclosure — 8/15

**Evidence:**
- SKILL.md is ~180 lines (within the <500 ideal).
- No `references/` directory.
- No loading triggers (none needed — single file).

**Why 8/15:** Self-contained and concise, which is acceptable for a simple Skill. But the content is wrong regardless of layering — being short doesn't help when 80% of what's there shouldn't be there. No progressive-disclosure design is evident because there's nothing worth layering.

### D6: Freedom Calibration — 8/15

**Evidence:**
- The Skill gives vague guidance ("use meaningful names", "handle errors") across operations whose fragility varies widely.
- No distinction between creative tasks (high freedom appropriate) and fragile operations (low freedom needed).
- The file-I/O section offers only `"read and write files carefully"` — exactly where low-freedom exact steps matter most (encoding, context managers, path handling, atomic writes).

**Why 8/15:** Partially appropriate. The mismatch is most visible in file I/O, where vague guidance for a fragile operation (encoding bugs, unclosed handles, path injection) is precisely wrong.

### D7: Pattern Recognition — 2/10

**Evidence:** The structure ("What is X" → tutorial → reference → best practices) matches no official pattern. It resembles a textbook chapter, not a Skill. The closest official pattern would be "Tool" (~300 lines, decision trees, low freedom) — but this Skill has no decision trees and is far too short and vague to qualify.

**Why 2/10:** No recognizable pattern, chaotic structure. The author treated the Skill as a mini-textbook rather than a knowledge-injection artifact.

### D8: Practical Usability — 5/15

**Evidence:**
- No decision trees. When the Agent must choose between `requests` and `httpx`, or `multiprocessing` and `threading`, there's no guidance.
- Code examples are trivially correct but useless (they demonstrate syntax the model already knows).
- No error handling. No fallbacks. No edge cases.
- The Agent cannot act on this Skill in any way it couldn't already act without it.

**Why 5/15:** The Skill provides no actionable guidance beyond what the model generates by default. It adds zero practical capability — loading it changes nothing about the Agent's behavior.

---

## Grade Reasoning

**52/120 = 43% → Grade F.**

The F grade (<60%) is warranted because the Skill needs **fundamental redesign**, not incremental improvement. The core problem — D1 Knowledge Delta at 3/20 — is not fixable by editing; it requires deleting ~80% of the content and replacing it with genuine expert knowledge. By the Core Formula (`Good Skill = Expert-only Knowledge − What the model already knows`), a Skill that compresses what the model already knows is a negative-value artifact: it costs tokens and returns nothing.

The single most diagnostic finding is the E:A:R ratio of 5:15:80. Until that inverts to >70% Expert, no other improvement matters. Fixing the description (D4) or adding progressive disclosure (D5) without addressing D1 would be polishing a tutorial — the "Tutorial" and "Invisible Skill" patterns compound: even if the description were fixed to trigger reliably, loading would only deliver redundancy.

Recommended rebuild order: (1) identify the 5% Expert content and build outward from it, (2) write the description only after the expert content exists, (3) add anti-patterns last — they emerge naturally once you're writing about what goes wrong in practice.
