# n8n Workflow Cost Estimator

A Claude Code skill that estimates the monthly running cost of any n8n workflow.

## How it works

The skill is the conversational front-end. The actual cost calculation runs inside an n8n
workflow that you host in your own n8n instance with your own credentials.

```
User → Claude Code skill → your n8n webhook → Claude AI Agent (your API key) → cost breakdown
```

Each user runs their own instance, so you pay only your own API costs.

## Setup

### 1. Import the n8n workflow

Import `workflow.json` into your n8n instance:

1. Open n8n
2. Go to **Workflows → Import from file**
3. Select `workflow.json`
4. You'll see a credentials prompt — add your Anthropic API key
5. Activate the workflow (toggle in the top-right)

**Credentials required:**
- Anthropic API key (for the Claude AI Agent node inside the workflow)

No other credentials are needed. The workflow does not connect to any external billing APIs — the Claude agent reasons about pricing from its training knowledge.

### 2. Install the Claude Code skill

Copy `SKILL.md` into your Claude Code skills directory:

```bash
cp SKILL.md ~/.claude/skills/n8n-cost-estimator.md
```

Or place it in your project's `.claude/skills/` folder if you want it scoped to a project.

### 3. Run it

In Claude Code, type:

```
/n8n-cost-estimator
```

Or trigger it naturally:

> "estimate my n8n workflow cost"
> "how much will my automation cost to run?"

On first run, the skill will ask for your webhook URL (found in the Webhook trigger node
in n8n). It saves the URL so you only need to enter it once.

## What the skill collects

| Field | Description |
|---|---|
| `workflow_description` | What the workflow does |
| `services` | External services used (Gmail, Slack, OpenAI, etc.) |
| `frequency` | How often it runs: `once`, `hourly`, `daily`, `weekly`, `monthly` |
| `items_per_execution` | How many items it processes per run |

## Webhook payload

The skill sends a POST request to your webhook with:

```json
{
  "workflow_description": "Summarise unread emails and post to Slack",
  "services": ["Gmail", "Slack", "OpenAI"],
  "frequency": "daily",
  "items_per_execution": 20
}
```

## Output

The skill presents a clean cost breakdown:

```
── Cost breakdown ─────────────────────────────

  n8n platform
  Starter plan                         $20.00 / mo

  External services
  Gmail (Google Workspace)              $0.00 / mo
  Slack (free tier)                     $0.00 / mo
  OpenAI GPT-4o                         $1.80 / mo

  ──────────────────────────────────────────────
  Total estimate                       $21.80 / mo

  Based on: daily · 20 items/run
```

## Notes

- Pricing estimates are based on the Claude agent's knowledge and may not reflect the
  latest pricing. Always verify against official pricing pages before making decisions.
- Free tier limits are noted where applicable.
- Usage-based services (OpenAI, Anthropic, etc.) are estimated based on typical token usage
  for the described workflow.
