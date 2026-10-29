<!-- Appendix C (appendices.md:467-564), verbatim from the book. Copy it per project and fill the blanks. The prices are the book's; check the current ones on the Claude pricing page before you plan a budget. -->

# Appendix C: Cost Calculator and Budget Guide

## How Pricing Works (Quick Recap)

Claude Code charges are based on token consumption. Tokens are units of text, roughly 4 characters or 0.75 words per token.

Every interaction has two token costs:

1. **Input tokens**: Everything Claude reads to process your request. This includes your prompt, the conversation history, any files Claude reads, and your CLAUDE.md configuration. Cheaper per token.

2. **Output tokens**: Everything Claude generates in response. Code, explanations, file contents, command outputs. More expensive per token, roughly 5x the cost of input tokens.

**Current pricing:**

| Model | Input (per 1M tokens) | Output (per 1M tokens) |
|---|---|---|
| Claude Sonnet 4.6 | $3 | $15 |
| Claude Opus 4.7 | $5 | $25 |
| Claude Haiku 4.5 | $1 | $5 |

**Subscription plans:**

| Plan | Monthly Cost | Best For |
|---|---|---|
| Pro | $20 | Light usage, learning, small projects |
| Max (Standard) | $100 | Daily development, real projects |
| Max (Power) | $200 | Heavy usage, multi-agent, production work |

## Typical Costs by Project Type

These estimates assume Sonnet 4.6 for most tasks, with Opus 4.7 for complex reasoning. Your costs will vary based on how specific your prompts are, how many debugging cycles you hit, and how large your codebase is.

**Learning and exploration**
- Following a tutorial: $0.50 to $2
- Experimenting with a new library: $1 to $5
- Asking Claude to explain code: $0.10 to $0.50 per question

**Small projects (scripts, tools, simple apps)**
- CLI tool (under 500 lines): $2 to $10
- Chrome extension: $5 to $15
- Simple web app (CRUD, no auth): $5 to $20

**Medium projects (full-stack apps, integrations)**
- Full-stack app with auth: $15 to $50
- MCP server integration project: $10 to $30
- API with 10+ endpoints: $20 to $60

**Large projects (SaaS, multi-agent, production deployments)**
- Micro-SaaS with payments: $30 to $100
- Multi-agent pipeline: $20 to $80
- Production deployment with CI/CD: $15 to $40
- Full refactor of existing codebase: $50 to $200+

## Budget Worksheet

Use this worksheet before starting any project. Fill in the estimates, then track actual costs to improve your future estimates.

**Project name:** _______________

**Estimated scope:**
- Number of files to create: ___
- Number of existing files to modify: ___
- Number of integrations (APIs, databases, services): ___
- Estimated complexity (Low / Medium / High): ___

**Cost estimate:**

| Task | Estimated Exchanges | Est. Cost |
|---|---|---|
| Project scaffold | ___ | $___ |
| Core feature build | ___ | $___ |
| Secondary features | ___ | $___ |
| Testing and debugging | ___ | $___ |
| Deployment | ___ | $___ |
| **Buffer (3x the largest single task)** | | $___ |
| **Total estimate** | | **$___** |

**Actual cost tracking:**

| Date | Task | Exchanges | Actual Cost | Notes |
|---|---|---|---|---|
| ___ | ___ | ___ | $___ | ___ |
| ___ | ___ | ___ | $___ | ___ |
| ___ | ___ | ___ | $___ | ___ |

**Post-project review:**
- Total actual cost: $___
- Was it within estimate? Y/N
- Biggest cost driver: _______________
- What would you do differently? _______________

**Tips for staying on budget:**

1. Do the hardest task first. If it blows the budget, you'll know early.
2. Set a daily spending limit and stop when you hit it. Fresh eyes tomorrow will solve problems cheaper than a fatigued session tonight.
3. Track costs per task, not just per project. You'll discover which types of tasks are expensive and plan accordingly.
4. Use Sonnet 4.6 as your default. Reach for Opus 4.7 only on tasks that genuinely need the extra reasoning, not for everything. The per-token gap is smaller than it used to be, so this is about focus, not dramatic savings.
5. Kill sessions early when you see looping behavior. A new session with a better prompt is always cheaper than a loop.
