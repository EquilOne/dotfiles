# OpenCode Agent Stack

Native configuration and Markdown agent files are the source of truth. This document is a concise routing reference.

## Primary agents

| Agent | Model | Role |
| --- | --- | --- |
| `fixer` | DeepSeek V4 Flash 0731 | Default router-only entry point |
| `chat` | DeepSeek V4 Flash 0731 | Direct read-only conversation and research |
| `conductor` | GPT 5.6 Luna, max | Explicit multi-phase coordinator |
| `build` | GPT 5.6 Luna, xhigh | Optional high-agency/vibe coding for disposable software |

## Planning and implementation

| Agent | Model | Role |
| --- | --- | --- |
| `plan` | GPT 5.6 Luna, high | Read-only, non-delegating planning subagent |
| `coder` | GPT 5.6 Luna, high | Focused code implementation |
| `generate-test` | GPT 5.6 Luna | Test generation and execution |
| `docs` | DeepSeek V4 Flash 0731 | Documentation and configuration text |

## Analysis and operations

| Agent | Model | Role |
| --- | --- | --- |
| `review` | GPT 5.6 Terra, high | Read-only code/config review |
| `research` | GPT 5.6 Luna | Research orchestration through `search` |
| `search` | Gemini 2.5 Flash Lite | Web search and retrieval |
| `commit` | Gemini 2.5 Flash Lite | Staged-diff commit-message generation |
| `media-viewer` | Gemini 2.5 Flash Lite | Attached media analysis |
| `spaced-repetition` | DeepSeek V4 Flash 0731 | Learning guides and spaced-repetition suggestions |

## Routing rules

- Use `fixer` by default for repository work; it routes but does not edit or run shell commands.
- Use `conductor` for serious multi-phase coordination, dependencies, parallel workstreams, or risk-bearing initiatives.
- Use `build` only when explicitly choosing rapid, disposable-software/vibe-coding behavior.
- Primary agents invoke `plan` when a repository plan is requested; `plan` is not a primary entry point.
- `research` delegates web retrieval to `search`; `search` does not delegate.
- External-directory access is approval-gated for agents that can modify or inspect workspace-adjacent paths.