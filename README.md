# n8n-autopilot

Autonomous n8n workflow builder for Claude Code. Describe what you need in plain language - Claude designs, builds, validates, tests, and delivers a working workflow.

Built on top of [n8n-mcp](https://github.com/czlonkowski/n8n-mcp) and [n8n-skills](https://github.com/czlonkowski/n8n-skills).

## What it does

You describe a task:

> "When someone fills out a contact form, save the data to Google Sheets, qualify the lead with AI, and send a Slack notification"

Claude autonomously:

1. **Understands** - parses your brief into requirements (trigger, processing, output)
2. **Designs** - searches 2,653+ templates and 525+ nodes, picks the best architecture
3. **Builds** - creates the workflow iteratively, node by node
4. **Assigns credentials** - finds matching credentials from your n8n instance automatically
5. **Validates** - runs validation loops, auto-fixes errors
6. **Tests** - executes the workflow with realistic test data
7. **Delivers** - active workflow + report with everything you need to know

Zero technical decisions on your part. Works with any n8n integration.

## Requirements

- [Node.js](https://nodejs.org/) 18+
- [Claude Code](https://claude.ai/code) (CLI, desktop app, or VS Code extension)
- An n8n instance ([Cloud](https://n8n.io/cloud/), self-hosted, or desktop) with API access

## Installation

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/natiixnt/n8n-autopilot/main/install.sh | bash
```

Or clone and run:
```bash
git clone https://github.com/natiixnt/n8n-autopilot.git
cd n8n-autopilot
./install.sh
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/natiixnt/n8n-autopilot/main/install.ps1 | iex
```

Or clone and run:
```powershell
git clone https://github.com/natiixnt/n8n-autopilot.git
cd n8n-autopilot
.\install.ps1
```

### Manual installation

1. Install n8n-mcp:
```bash
npm install -g n8n-mcp
```

2. Install base n8n-skills:
```bash
git clone https://github.com/czlonkowski/n8n-skills.git /tmp/n8n-skills
mkdir -p ~/.claude/skills
cp -r /tmp/n8n-skills/skills/* ~/.claude/skills/
```

3. Install n8n-autopilot:
```bash
git clone https://github.com/natiixnt/n8n-autopilot.git /tmp/n8n-autopilot
cp -r /tmp/n8n-autopilot/skills/n8n-autopilot ~/.claude/skills/
```

4. Configure MCP - create `~/.claude/.mcp.json`:
```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true",
        "N8N_API_URL": "https://your-instance.app.n8n.cloud",
        "N8N_API_KEY": "your-api-key"
      }
    }
  }
}
```

5. Restart Claude Code.

## Usage

Just describe what you need. Works in any language.

```
Build a workflow: when someone submits a form, save to Google Sheets and notify on Slack
```

```
Monitor our services every 5 minutes and alert on Slack when something goes down
```

```
Weekly sales report from our API, summarized by AI, emailed to the team
```

```
Auto-respond to customer emails using AI with access to our knowledge base
```

```
Klient chce: zbieraj leady z formularza i kwalifikuj je z AI
```

Claude takes it from there. No technical decisions needed.

## How it works

### 5-phase autonomous pipeline

```
Phase 1: UNDERSTAND
  Parse brief -> extract: trigger, sources, processing, output
  Infer missing details (don't ask unless truly ambiguous)

Phase 2: DESIGN
  Search templates (2,653+) -> find matching patterns
  Select architecture (webhook / API / database / AI / scheduled)
  Pick best nodes (525+ available)

Phase 3: BUILD
  Create workflow iteratively (node by node)
  Configure expressions, connections, error handling

Phase 3.5: CREDENTIALS
  List credentials from your n8n instance via API
  Auto-match by type (slackApi, openAiApi, etc.)
  Smart resolution when multiple exist (production-first, context-aware)

Phase 4: VALIDATE & FIX
  Run validation -> auto-fix errors -> re-validate
  Usually 2-3 cycles until clean

Phase 5: TEST & DELIVER
  Execute with realistic test data
  Check results, fix if needed
  Activate + deliver report
```

### Credential auto-assignment

When your n8n instance has stored credentials, autopilot matches them automatically:

| Situation | What happens |
|-----------|-------------|
| 1 credential of needed type | Assigned automatically |
| Multiple, one named "prod"/"main" | Production one picked automatically |
| Multiple, brief says "test workflow" | Test/dev one picked automatically |
| Multiple, truly ambiguous | One bundled question for all |
| None found | Reported as "configure manually in n8n UI" |

### Decision-making

Autopilot makes technical decisions for you:

| Your words | Claude decides |
|-----------|---------------|
| "when someone fills a form" | Webhook trigger, POST |
| "every morning" | Schedule trigger, cron 8:00 |
| "classify", "sentiment" | AI node (OpenAI/Anthropic) |
| "if amount > 1000" | IF node (rule-based) |
| "save the data" | Google Sheets (simple) or Postgres (structured) |
| "notify the team" | Slack (real-time) or Email (async) |

## Works with

**n8n deployments:**
- n8n Cloud
- Self-hosted (Docker, bare metal)
- n8n Desktop

**Operating systems:**
- macOS
- Linux (Ubuntu, Debian, CentOS, etc.)
- Windows 10/11

**All 525+ n8n integrations**, including:
Slack, Google Sheets, Gmail, OpenAI, Postgres, MySQL, HubSpot, Notion, Airtable, Telegram, Discord, Stripe, Twilio, Jira, GitHub, HTTP Request, and everything else n8n supports.

## Project structure

```
n8n-autopilot/
  skills/
    n8n-autopilot/
      SKILL.md              # Main skill - 5-phase autonomous pipeline
      SOLUTION_DESIGN.md    # Decision trees, scenario->architecture mappings
      EXAMPLES.md           # Real briefs -> solutions (6 examples)
  install.sh                # macOS/Linux installer
  install.ps1               # Windows installer
  .claude-plugin/
    plugin.json             # Claude Code plugin metadata
  README.md
  LICENSE
```

## Credits

- [n8n-mcp](https://github.com/czlonkowski/n8n-mcp) - MCP server by Romuald Czlonkowski
- [n8n-skills](https://github.com/czlonkowski/n8n-skills) - Base skills by Romuald Czlonkowski
- n8n-autopilot - Autonomous orchestration layer

## License

MIT
