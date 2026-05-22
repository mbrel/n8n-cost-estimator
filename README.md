# n8n Workflow Cost Estimator

A Claude Code skill that estimates the monthly running cost of any n8n workflow.

---

## Install the skill

**Option A — one line, no clone needed:**

```bash
curl -sL https://raw.githubusercontent.com/mbrel/n8n-cost-estimator/main/SKILL.md \
  -o ~/.claude/skills/n8n-cost-estimator.md && echo "✓ Done. Open Claude Code and type: /n8n-cost"
```

**Option B — clone and run setup:**

```bash
git clone https://github.com/mbrel/n8n-cost-estimator.git
cd n8n-cost-estimator
./setup.sh
```

That's it. Open a new Claude Code session and type `/n8n-cost`.

---

## How it works

The skill is the conversational front-end. The actual cost calculation runs inside an n8n
workflow that you host in your own n8n instance.

```
You → Claude Code skill → your n8n webhook → Claude AI Agent (your API key) → cost breakdown
```

Each user runs their own instance, so you pay only your own API costs.

---

## Using the skill

Once installed, open Claude Code and type:

```
/n8n-cost
```

or just:

```
estimate my n8n workflow cost
```

The skill will:
1. Ask for your estimator webhook URL (saved after first use — you only enter it once)
2. Ask you to share the workflow to analyse — you can paste the **JSON export**, a **workflow URL**, or just **describe it**
3. Ask how often it runs and how many items it processes
4. Call your webhook and return a clean cost breakdown

---

## Set up your own estimator webhook

The skill needs an n8n workflow running in your own instance to do the calculation.

### 1. Import the workflow

Import `workflow.json` into your n8n instance:

1. Go to **Workflows → Import from file**
2. Select `workflow.json`
3. Add your Anthropic API key when prompted
4. Activate the workflow (toggle top-right)

**Credentials required:** Anthropic API key only.

### 2. Copy your webhook URL

Open the imported workflow, click the Webhook trigger node, and copy the Production URL.
It looks like: `https://your-instance.app.n8n.cloud/webhook/estimate-workflow-cost`

### 3. Run the skill

Type `/n8n-cost` in Claude Code — it will ask for that URL on first run and save it.

---

## Output example

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

---

## Notes

- Pricing estimates are based on the Claude agent's knowledge and may not reflect the latest pricing. Verify against official pricing pages before making decisions.
- Free tier limits are noted where applicable.
- Usage-based services are estimated based on typical token usage for the described workflow.
