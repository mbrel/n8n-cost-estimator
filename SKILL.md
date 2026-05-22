---
name: n8n-cost-estimator
description: >
  Estimates the monthly running cost of an n8n workflow. The user can share their workflow
  as a URL, a JSON export, or a plain description — Claude extracts the relevant details
  and calls a personal n8n webhook to get a full cost breakdown.

  Trigger phrases: "estimate my n8n workflow cost", "how much will my n8n workflow cost",
  "n8n cost", "workflow cost estimator", "cost of my automation", "/n8n-cost"
---

# n8n Workflow Cost Estimator

You are helping the user estimate the monthly running cost of an n8n workflow.
The actual calculation is handled by an n8n webhook the user has set up. Your job is
to collect the right information, call the webhook, and present the result clearly.

---

## Step 1 — Get or recall the webhook URL

Check memory for a saved key `n8n_cost_estimator_webhook_url`.

- **If found:** confirm with the user before proceeding.
  > "I have your estimator webhook saved as `{url}`. Shall I use that, or do you want to update it?"
- **If not found:** ask for it.
  > "First, I need your cost estimator webhook URL — the one from your n8n cost estimator workflow. It looks like `https://your-instance.app.n8n.cloud/webhook/...`"

Once confirmed, save it under `n8n_cost_estimator_webhook_url`.

---

## Step 2 — Get the workflow to analyse

Ask the user to share the workflow they want to cost. Offer three options clearly:

> "Now, share the workflow you want to estimate. You can:
>
> 1. **Paste the JSON** — export it from n8n via the menu (⋮ → Download) and paste it here
> 2. **Paste a workflow URL** — the editor URL from your n8n instance
> 3. **Describe it** — tell me what it does and which services it uses (Gmail, Slack, OpenAI, etc.)
>
> Any of these works."

### If the user pastes JSON

Parse the JSON to extract:
- `workflow_description`: derive from the workflow name and node names/types
- `services`: list every third-party service found in node types or credentials
  (e.g. `n8n-nodes-base.gmail` → Gmail, `@n8n/n8n-nodes-langchain.lmChatAnthropic` → Anthropic, etc.)

Do not ask follow-up questions about services if the JSON makes them clear.

### If the user pastes a URL

Attempt to fetch the URL. If it requires authentication or returns an error, ask them to
export the JSON instead or describe the workflow.

### If the user describes the workflow

Accept the description as-is. Extract the services they mention. If the description is
vague, ask one clarifying question:
> "Which external services does it connect to? For example: email, messaging apps, databases, AI APIs."

---

## Step 3 — Execution frequency

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

If the frequency is already specified in the workflow JSON (e.g. a Schedule trigger node),
extract it automatically and confirm rather than asking from scratch.

---

## Step 4 — Items per execution

Ask how many items the workflow processes each time it runs.

> "How many items does it process per execution? For example: emails, messages, rows, records."

Capture as an integer (`items_per_execution`). If the user is unsure, suggest they use
a typical or average number.

---

## Step 5 — Call the webhook

Make a POST request to the webhook URL with this JSON body:

```json
{
  "workflow_description": "<description or derived from JSON/URL>",
  "services": ["<service1>", "<service2>"],
  "frequency": "<once|hourly|daily|weekly|monthly>",
  "items_per_execution": <number>
}
```

While waiting, show: "Calculating costs..."

---

## Step 6 — Present the result

### If the webhook responds successfully

Parse and display the response as a clean cost breakdown:

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
> "You may want to check that your estimator workflow is active and the webhook URL is correct."

### If the webhook call fails (network error, timeout, 4xx/5xx)

> "I couldn't reach your webhook. This could mean:
> - The estimator workflow is not active in n8n
> - The webhook URL has changed
> - There's a temporary connectivity issue
>
> Your saved URL is: `{url}`
> Would you like to update it, or try again?"

---

## Memory

- Save the webhook URL under `n8n_cost_estimator_webhook_url` after first confirmed use.
- Do not save workflow descriptions, services, or cost results — those are per-run data.
