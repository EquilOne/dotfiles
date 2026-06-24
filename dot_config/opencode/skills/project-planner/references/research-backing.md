# Research Backing: Project Planner Skill

This reference file contains the research grounding for the project-planner skill. Load it when:
- The user asks about the research behind the skill's design
- A plan produced by the skill failed in execution and you need diagnostic support
- The user wants to understand why a specific rule or pattern exists

## Plan-and-Execute Pattern

The skill uses a Plan-and-Execute architecture: a "planner" phase (the skill workflow) produces a structured plan, and then an "executor" phase follows it. This mirrors the Saga Pattern described in the Agent Patterns Catalog:

> "Decouples strategy from tactics. A strong 'planner' model generates an upfront sequence, and a cheaper 'executor' model executes it step-by-step. It ensures predictable costs and limits hallucination by only replanning upon failure."

Sources: [Agent Patterns Catalog](https://github.com/agentpatternscatalog/patterns/blob/main/patterns/plan-and-execute.md), [LangChain Blog](https://www.langchain.com/blog/planning-agents)

## Read-Only Plan Mode

Phase 1 (Enter Plan Mode) restricts the agent to read-only exploration. This is based on Addy Osmani's "good spec" approach for AI coding:

> "Restrict the agent to a read-only exploration phase where it analyzes code and drafts a specification. Do not allow tool execution until the user manually approves the plan."

And Anthropic's Building Effective Agents guide:

> "Hardcoding strict constraints at the tool interface — such as forcing absolute filepaths instead of relative ones — eliminates entire classes of trivial execution errors during the planning process."

Source: [Addy Osmani - Good Spec](https://addyosmani.com/blog/good-spec/), [Anthropic - Building Effective Agents](https://www.anthropic.com/research/building-effective-agents)

## DAG Structure Over Flat Lists

The skill outputs plans as DAGs (Directed Acyclic Graphs) with milestone dependencies. This is supported by multiple sources:

- LangChain's planning guide recommends DAG outputs so "execution units can run non-dependent steps in parallel"
- The Agent Patterns Catalog describes plans as DAGs where "outputs feed as variables into downstream steps"

## Zero-Duration Milestones

Milestones in the skill are "checkpoints representing moments in time" rather than task collections. This follows Asana's project management research: grouping tasks into milestones "keeps the LLM aligned on high-level state changes, preventing it from getting bogged down in execution minutiae."

Source: [Asana - Project Milestones](https://asana.com/resources/project-milestones)

## Anti-Pattern Research Sources

Each anti-pattern in the SKILL.md is grounded in research:

| Anti-pattern | Research Source |
|---|---|
| Circular dependencies | Tian Pan (2026): "Planners hallucinate circular dependencies in natural language... resulting in zero-progress busy waits" |
| Flat task lists without dependencies | LangChain DAG research: agents execute sequentially when DE could run in parallel |
| Over-committing on vague scope | Plan viability degrades sharply beyond 2-step horizons without explicit constraints |
| Skipping verification gates | Decision-complete checkpoints research: "explicitly bake in AI validation steps ensures downstream executor doesn't need to make architectural decisions" |
| Asking for every detail | Global constraint instructions research: "reserve planning space for parallel downstream sub-tasks prevents local over-commitment" |
| Exceeding 7 milestones without phases | Depth degradation research: "plan viability degrades sharply beyond 2-step horizons" — holding more than 7 ungrouped items causes context overflow |

Source for depth degradation: [arXiv 2605.10601](https://arxiv.org/html/2305.10601v2)

## ReAct vs. Plan-and-Execute

The project-planner skill deliberately uses Plan-and-Execute rather than ReAct (Reason + Act). This is a deliberate choice based on research:

> "There is an active architectural conflict between ReAct (which prioritizes fresh context/adaptation) and Plan-and-Execute (which prioritizes predictable cost/global strategy). The industry consensus is that neither is universally superior; they must be routed contextually or composed."

For project planning specifically, Plan-and-Execute wins because:
1. Planning requires global context (all dependencies, all scope) — ReAct's per-step reasoning cannot see the full picture
2. Plans need user approval before execution — ReAct's interleaved actions make approval impossible
3. Plan output must be stored and referenced — ReAct has no persistent plan artifact

Source: [Building Agentic AI - ReAct vs Plan-and-Execute](https://buildingagenticai.com/blog/react-vs-plan-and-execute/)

## Localized In-Context Learning (L-ICL)

The skill's Phase 5 (Add Verification Checkpoints) and the checkpoint-by-milestone structure draw from L-ICL research:

> "Injecting minimal, targeted corrections for specific constraint violations drastically outperforms feeding the model full successful trajectories."

By verifying each milestone individually (localized feedback) rather than waiting until the end, the skill applies this principle.

Source: [arXiv 2602.00276](https://arxiv.org/html/2602.00276v1)

## Scope Creep and Constraint Instructions

The skill's constraint-gathering phase (Phase 2) is grounded in global constraint instruction research:

> "Explicitly prompting the LLM to reserve planning space and resources (like budgets) for parallel downstream sub-tasks prevents local over-commitment."

Source: [arXiv 2506.02683](https://arxiv.org/html/2506.02683v1)
