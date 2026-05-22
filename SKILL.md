---
name: n8n-cost-estimator
description: >
  Estimates the monthly running cost of an n8n workflow by asking the user about their
  workflow, the external services it uses, and how often it runs — then calling their
  personal n8n webhook to get a full cost breakdown.

  Trigger phrases: "estimate my n8n workflow cost", "how much will my n8n workflow cost",
  "n8n cost", "workflow cost estimator", "cost of my automation", "/n8n-cost"
---

# n8n Workflow Cost Estimator

You are helping the user estimate the monthly running cost of an n8n workflow.
The actual calculation is handled by an n8n webhook the user has set up. Your job is
to collect the right information conversationally, call the webhook, and present the
result clearly.

---

## Step 1 — Get or recall the webhook URL

Check memory for a saved key `n8n_cost_estimator_webhook_url`.

- **If found:** confirm it with the user before proceeding.
  > "I have your webhook URL saved as `{url}`. Shall I use that, or do you want to update it?"
- **If not found:** ask the user for it.
  > "To get started, I need your n8n webhook URL. You can find it in your n8n workflow's Webhook trigger node — it looks like `https://your-instance.app.n8n.cloud/webhook/...`"

Once you have a confirmed URL, save it to memory under the key `n8n_cost_estimator_webhook_url`.

---

## Step 2 — Describe the workflow

Ask the user to describe what their workflow does and which external services it connects to.

> "Tell me about your workflow — what does it do, and which external services does it use?
> For example: Gmail, Slack, Notion, WhatsApp Business, OpenAI, a weather API, a database, etc."

Capture:
- A short description of what the workflow does (`workflow_description`)
- A list of external services mentioned (`services`)

Do not suggest services — let the user describe their own workflow freely.

---

## Step 3 — Execution frequency

Ask how often the workflow runs.

> "How often does this workflow run?"

Accept natural language and map it to one of these valid values:
- `"once"` — one-off / manual
- `"hourly"` — every hour
- `"daily"` — once a day
- `"weekly"` — once a week
- `"monthly"` — once a month

If the user says something like "every 15 minutes" or "twice a day", pick the closest valid
value and confirm: "I'll treat that as hourly — does that sound right?"

---

## Step 4 — Items per execution

Ask how many items the workflow processes each time it runs.

> "How many items does it process per execution? For example: emails, messages, rows, records, API responses."

Capture this as an integer (`items_per_execution`). If the user is unsure, suggest they
use a typical or average number.

---

## Step 5 — Call the webhook

Make a POST request to the webhook URL with this JSON body:

```json
{
  "workflow_description": "<what the user described>",
  "services": ["<service1>", "<service2>"],
  "frequency": "<once|hourly|daily|weekly|monthly>",
  "items_per_execution": <number>
}
```

While waiting, show: "Calculating costs..."

---

## Step 6 — Present the result

### If the webhook responds successfully

Parse and display the response as a clean cost breakdown. The response will contain cost
data — present it in this structure:

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

Follow the breakdown with any notes or assumptions the webhook returned (e.g. free tier
limits, usage-based pricing caveats, services with unknown pricing).

### If the webhook returns an error or unexpected data

> "The webhook returned an unexpected response. Here's what came back:"
> [raw response]
>
> "You may want to check that your n8n workflow is active and the webhook URL is correct."

### If the webhook call fails (network error, timeout, 4xx/5xx)

> "I couldn't reach your webhook. This could mean:
> - The workflow is not active in n8n (check the toggle in the top-right of the workflow editor)
> - The webhook URL has changed
> - There's a temporary connectivity issue
>
> Your saved URL is: `{url}`
> Would you like to update it, or try again?"

---

## Memory

- Save the webhook URL under `n8n_cost_estimator_webhook_url` after first successful use.
- Do not save workflow descriptions, services, or cost results — those are per-run data.
