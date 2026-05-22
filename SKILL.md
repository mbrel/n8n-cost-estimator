---
name: n8n-cost-estimator
description: >
  Estimates the monthly running cost of any n8n workflow. The user shares their workflow
  as a published URL, a JSON export, or a plain description — Claude extracts the details
  and returns a full cost breakdown.

  Trigger phrases: "estimate my n8n workflow cost", "how much will my n8n workflow cost",
  "n8n cost", "workflow cost estimator", "cost of my automation", "/n8n-cost"
user-invocable: true
---

# n8n Workflow Cost Estimator

You are helping the user estimate the monthly running cost of an n8n workflow.
The cost calculation is handled by a remote service — your job is to collect the workflow
details, call the service, and present the result clearly.

The estimator endpoint is: `https://mbrel.app.n8n.cloud/webhook/estimate-workflow-cost`

---

## Step 1 — Get the workflow to analyse

Ask the user to share the workflow they want to estimate:

> "Share the workflow you want to cost. You can:
>
> 1. **Paste the published URL** — the editor URL from your n8n instance (must be active/published)
> 2. **Paste the JSON** — export it from n8n via the menu (⋮ → Download)
> 3. **Describe it** — tell me what it does and which services it uses (Gmail, Slack, OpenAI, etc.)
>
> Any of these works."

### If the user pastes a published URL

Attempt to fetch the URL. Extract from the response:
- `workflow_description`: from the workflow name and node names/types
- `services`: every third-party service found in node types or credentials

If the URL requires authentication or returns an error, ask them to export the JSON or describe it instead.

### If the user pastes JSON

Parse it to extract:
- `workflow_description`: from the workflow name and node names/types
- `services`: every third-party service found in node types or credentials
  (e.g. `n8n-nodes-base.gmail` → Gmail, `@n8n/n8n-nodes-langchain.lmChatAnthropic` → Anthropic)

Do not ask follow-up questions about services if the JSON makes them clear.

### If the user describes the workflow

Accept the description as-is and extract the services mentioned. If the description is
vague, ask one clarifying question:
> "Which external services does it connect to? For example: email, messaging apps, databases, AI APIs."

---

## Step 2 — Execution frequency

Ask how often the workflow runs.

> "How often does this workflow run?"

Accept natural language and map to one of these valid values:
- `"once"` — one-off / manual
- `"hourly"` — every hour
- `"daily"` — once a day
- `"weekly"` — once a week
- `"monthly"` — once a month

If the user says something ambiguous like "every 15 minutes" or "twice a day", pick the
closest value and confirm: "I'll treat that as hourly — does that sound right?"

If the frequency is already in the workflow JSON (e.g. a Schedule trigger node), extract
it automatically and confirm rather than asking from scratch.

---

## Step 3 — Scale

Ask how much the workflow processes each time it runs.

> "What's the scale? How much does it process each time it runs — for example: 3,000 emails, 50 Notion rows, 1 Slack message."

Capture as an integer (`volume`). If the user is unsure, suggest they use a typical or average number. If the workflow just does one thing per run (e.g. sends a single notification), default to 1 and confirm.

---

## Step 4 — Call the estimator

Make a POST request to `https://mbrel.app.n8n.cloud/webhook/estimate-workflow-cost` with:

```json
{
  "description": "<description of the workflow including services, frequency, and volume>",
  "services": ["<service1>", "<service2>"],
  "frequency": "<once|hourly|daily|weekly|monthly>",
  "volume": <number>
}
```

Put everything relevant into `description` — the agent reads it as its main prompt.

While waiting, show: "Calculating costs..."

---

## Step 5 — Present the result

### If the response is successful

Present a clean cost breakdown:

```
── Cost breakdown ─────────────────────────────

  n8n platform
  [plan name or tier]                  $X.XX / mo

  External services
  [Service name]                       $X.XX / mo
  [Service name]                       $X.XX / mo

  ──────────────────────────────────────────────
  Total estimate                       $X.XX / mo

  Based on: [frequency] · [items_per_execution] items/run
```

Follow with any notes or assumptions from the response (free tier limits, usage-based
pricing caveats, services with unknown pricing).

### If the response is empty or unexpected

> "The estimator returned an unexpected response. Here's what came back:"
> [raw response]
>
> "Try again in a moment, or check that the workflow you shared is correct."

### If the request fails (network error, timeout, 4xx/5xx)

> "I couldn't reach the estimator service. This might be a temporary issue — try again in a moment."
