<p align="center">
  <h1 align="center">n8n-autopilot</h1>
  <p align="center">
    <strong>AI-powered autonomous workflow builder for n8n</strong>
  </p>
  <p align="center">
    Describe a task in plain language. Get a production-ready n8n workflow.<br>
    Designed, built, validated, tested, and delivered - fully autonomous.
  </p>
  <p align="center">
    <a href="https://natiixnt.github.io/n8n-autopilot/"><strong>Website</strong></a> &nbsp;&middot;&nbsp;
    <a href="#quick-start"><strong>Quick Start</strong></a> &nbsp;&middot;&nbsp;
    <a href="#how-it-works"><strong>How It Works</strong></a> &nbsp;&middot;&nbsp;
    <a href="https://github.com/natiixnt/n8n-autopilot/issues"><strong>Issues</strong></a>
  </p>
  <p align="center">
    <a href="https://github.com/natiixnt/n8n-autopilot/blob/main/LICENSE"><img src="https://img.shields.io/github/license/natiixnt/n8n-autopilot?style=flat-square&color=f97316" alt="MIT License"></a>
    <a href="https://github.com/natiixnt/n8n-autopilot/stargazers"><img src="https://img.shields.io/github/stars/natiixnt/n8n-autopilot?style=flat-square&color=f97316" alt="Stars"></a>
    <a href="https://github.com/natiixnt/n8n-autopilot/issues"><img src="https://img.shields.io/github/issues/natiixnt/n8n-autopilot?style=flat-square" alt="Issues"></a>
    <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue?style=flat-square" alt="Platform">
    <img src="https://img.shields.io/badge/n8n-Cloud%20%7C%20Self--Hosted%20%7C%20Desktop-green?style=flat-square" alt="n8n Support">
  </p>
</p>

<br>

## What is n8n-autopilot?

A [Claude Code](https://claude.ai/code) skill that turns plain-language descriptions into fully working n8n workflows. No manual node dragging, no configuration, no debugging.

**You say:**
> "When a customer submits a feedback form, analyze sentiment with AI, save everything to Google Sheets, and alert the team on Slack if the feedback is negative"

**Autopilot does:**
1. Parses your requirements (trigger, processing, output, error handling)
2. Searches 2,653+ workflow templates for matching solutions
3. Picks optimal nodes from 525+ available integrations
4. Builds the workflow iteratively in your n8n instance
5. Auto-assigns credentials from your stored n8n credentials
6. Validates, auto-fixes errors, re-validates until clean
7. Tests with realistic data, checks execution results
8. Activates and delivers a report with webhook URLs + status

**Zero technical decisions on your part.**

<br>

## Quick Start

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/natiixnt/n8n-autopilot/main/install.sh | bash
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/natiixnt/n8n-autopilot/main/install.ps1 | iex
```

### What the installer does
1. Installs [n8n-mcp](https://github.com/czlonkowski/n8n-mcp) server (`npm install -g n8n-mcp`)
2. Installs 7 base [n8n-skills](https://github.com/czlonkowski/n8n-skills)
3. Installs the autopilot skill
4. Configures MCP connection to your n8n instance
5. Done - restart Claude Code and start describing workflows

**Requirements:** Node.js 18+, Claude Code, n8n instance with API access

<br>

## How It Works

### 5-Phase Autonomous Pipeline

```
Brief: "Monitor our APIs every 5 minutes, alert on Slack when something goes down"
  |
  v
Phase 1: UNDERSTAND
  Trigger: Schedule (every 5 min)
  Processing: HTTP health checks, status comparison
  Output: Slack alert on state change
  |
  v
Phase 2: DESIGN
  Pattern: Scheduled Task
  Nodes: Schedule -> Code -> HTTP Request -> IF -> Slack
  Template match: 45% - building from scratch
  |
  v
Phase 3: BUILD + CREDENTIALS
  n8n_create_workflow -> iterative n8n_update_partial_workflow
  Auto-assign: Slack (Prod), HTTP credentials
  |
  v
Phase 4: VALIDATE & FIX
  n8n_validate_workflow -> n8n_autofix_workflow -> re-validate
  2 cycles -> clean
  |
  v
Phase 5: TEST & DELIVER
  n8n_test_workflow -> check n8n_executions -> activate
  "Workflow #3291 is live"
```

### Smart Credential Auto-Assignment

Autopilot reads your existing n8n credentials via API and matches them automatically:

| Scenario | Behavior |
|----------|----------|
| One credential of needed type | Assigned automatically |
| Multiple, one named "prod"/"main"/"live" | Production one picked |
| Multiple, brief says "test workflow" | Dev/test one picked |
| Multiple, truly ambiguous | One bundled question for all |
| None found | Reported in delivery - "configure in n8n UI" |

### Autonomous Decision-Making

You don't pick the architecture. Autopilot decides:

| Your words | Autopilot decides |
|-----------|-------------------|
| "when someone fills a form" | Webhook trigger, POST method |
| "every morning at 9" | Schedule trigger, cron |
| "classify", "analyze sentiment" | AI node (OpenAI/Anthropic) |
| "if amount > 1000" | IF node, rule-based |
| "save the data" | Google Sheets or Postgres |
| "notify the team" | Slack or Email |
| "summarize", "generate" | AI text generation |
| doesn't mention error handling | Adds it anyway (retry + alert) |

<br>

## Supported Platforms

**Operating Systems:**
- macOS (Intel + Apple Silicon)
- Linux (Ubuntu, Debian, CentOS, Fedora, Arch)
- Windows 10/11

**n8n Deployments:**
- n8n Cloud
- Self-hosted (Docker, bare metal, Kubernetes)
- n8n Desktop

**Claude Code Environments:**
- CLI
- VS Code extension
- Desktop app
- Web (claude.ai)

<br>

## 525+ Integrations

Every integration n8n supports works with autopilot. Some popular ones:

**Communication:** Slack, Gmail, Telegram, Discord, Twilio, Microsoft Teams, WhatsApp
**Data:** Google Sheets, Airtable, Notion, PostgreSQL, MySQL, MongoDB, Redis, Supabase
**AI/ML:** OpenAI, Anthropic, Google AI, Pinecone, Qdrant, Hugging Face
**CRM:** HubSpot, Salesforce, Pipedrive, Zoho
**Project Management:** Jira, Asana, Trello, Linear, ClickUp, Monday.com
**E-commerce:** Stripe, Shopify, WooCommerce, PayPal
**DevOps:** GitHub, GitLab, AWS, Google Cloud, Docker, Kubernetes
**Storage:** Google Drive, Dropbox, AWS S3, OneDrive
**And 450+ more** - if n8n has a node for it, autopilot can use it.

<br>

## Use Cases

```
"Collect leads from our landing page form, qualify them with AI, push hot leads to HubSpot, notify sales on Slack"

"Generate a weekly sales report from our API, summarize with AI, email to the team every Monday"

"When a customer sends a support email, draft an AI response, create a Jira ticket, notify the team"

"Sync contacts between Google Sheets and HubSpot every 15 minutes"

"Monitor competitor websites for changes, summarize what changed, send a daily Slack digest"

"Process uploaded CSV files: validate data, import to Postgres, send confirmation email"

"Auto-respond to Slack messages in #support channel using AI with access to our docs"
```

Works in any language - English, Polish, German, Spanish, etc.

<br>

## Project Structure

```
n8n-autopilot/
  skills/n8n-autopilot/
    SKILL.md              # Core skill - 5-phase autonomous pipeline
    SOLUTION_DESIGN.md    # Decision trees, 8 scenario-to-architecture mappings
    EXAMPLES.md           # 6 real-world briefs with full solutions
  docs/
    index.html            # Landing page (GitHub Pages)
  install.sh              # macOS/Linux installer
  install.ps1             # Windows installer
  .claude-plugin/
    plugin.json           # Claude Code plugin metadata
```

<br>

## Built On

- **[n8n-mcp](https://github.com/czlonkowski/n8n-mcp)** - MCP server providing n8n API tools (create, validate, test, execute workflows)
- **[n8n-skills](https://github.com/czlonkowski/n8n-skills)** - 7 expert skills teaching Claude how to use n8n-mcp effectively
- **n8n-autopilot** - Autonomous orchestration layer that ties everything together

Created by Romuald Czlonkowski ([n8n-mcp](https://github.com/czlonkowski/n8n-mcp), [n8n-skills](https://github.com/czlonkowski/n8n-skills)) and extended with autopilot by [natiixnt](https://github.com/natiixnt).

<br>

## Contributing

Issues and PRs welcome. If you have a use case that doesn't work well, [open an issue](https://github.com/natiixnt/n8n-autopilot/issues) with your brief and what went wrong.

## License

[MIT](LICENSE)
