# n8n-autopilot installer for Windows (PowerShell)
# Run: irm https://raw.githubusercontent.com/natiixnt/n8n-autopilot/main/install.ps1 | iex
# Or:  .\install.ps1

$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/natiixnt/n8n-autopilot"

Write-Host "=== n8n-autopilot installer ===" -ForegroundColor Cyan
Write-Host ""

$SkillsDir = "$env:USERPROFILE\.claude\skills"
$McpPath = "$env:USERPROFILE\.claude\.mcp.json"

# Step 1: Check prerequisites
Write-Host "[1/5] Checking prerequisites..." -ForegroundColor Yellow

try {
    $nodeVersion = (node -v) -replace 'v', ''
    $major = [int]($nodeVersion.Split('.')[0])
    if ($major -lt 18) {
        Write-Host "ERROR: Node.js 18+ required (you have v$nodeVersion)" -ForegroundColor Red
        Write-Host "  Download from https://nodejs.org/"
        exit 1
    }
    Write-Host "  Node.js v$nodeVersion -- OK"
} catch {
    Write-Host "ERROR: Node.js not found. Download from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

try {
    git --version | Out-Null
    Write-Host "  git -- OK"
} catch {
    Write-Host "ERROR: git not found. Download from https://git-scm.com/" -ForegroundColor Red
    exit 1
}

# Step 2: Install n8n-mcp
Write-Host ""
Write-Host "[2/5] Installing n8n-mcp server..." -ForegroundColor Yellow
npm install -g n8n-mcp
Write-Host "  n8n-mcp -- OK"

# Step 3: Install n8n-skills
Write-Host ""
Write-Host "[3/5] Installing n8n-skills (7 base skills)..." -ForegroundColor Yellow

New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

$TempDir = Join-Path $env:TEMP "n8n-skills-$(Get-Random)"
git clone --depth 1 https://github.com/czlonkowski/n8n-skills.git $TempDir 2>$null
Copy-Item -Recurse -Force "$TempDir\skills\*" $SkillsDir
Remove-Item -Recurse -Force $TempDir
Write-Host "  7 base skills installed -- OK"

# Step 4: Install n8n-autopilot
Write-Host ""
Write-Host "[4/5] Installing n8n-autopilot skill..." -ForegroundColor Yellow

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LocalSkill = Join-Path $ScriptDir "skills\n8n-autopilot"

if (Test-Path $LocalSkill) {
    Copy-Item -Recurse -Force $LocalSkill "$SkillsDir\n8n-autopilot"
    Write-Host "  n8n-autopilot installed from local -- OK"
} else {
    $TempDir = Join-Path $env:TEMP "n8n-autopilot-$(Get-Random)"
    git clone --depth 1 $RepoUrl $TempDir 2>$null
    Copy-Item -Recurse -Force "$TempDir\skills\n8n-autopilot" "$SkillsDir\n8n-autopilot"
    Remove-Item -Recurse -Force $TempDir
    Write-Host "  n8n-autopilot downloaded and installed -- OK"
}

# Step 5: MCP config
Write-Host ""
Write-Host "[5/5] Configuring MCP server..." -ForegroundColor Yellow

if (Test-Path $McpPath) {
    $content = Get-Content $McpPath -Raw
    if ($content -match "n8n-mcp") {
        Write-Host "  n8n-mcp already configured -- OK"
    } else {
        Write-Host "  .mcp.json exists but n8n-mcp not configured."
        Write-Host "  Add n8n-mcp manually. See README.md for config example."
    }
} else {
    Write-Host ""
    $N8nUrl = Read-Host "  Enter your n8n instance URL (e.g. https://your-name.app.n8n.cloud)"
    $N8nKey = Read-Host "  Enter your n8n API key (from n8n Settings -> API)"

    $mcpDir = Split-Path $McpPath
    New-Item -ItemType Directory -Force -Path $mcpDir | Out-Null

    $mcpConfig = @"
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true",
        "N8N_API_URL": "$N8nUrl",
        "N8N_API_KEY": "$N8nKey"
      }
    }
  }
}
"@
    Set-Content -Path $McpPath -Value $mcpConfig -Encoding UTF8
    Write-Host "  .mcp.json created -- OK"

    # Save env vars for credential auto-assignment
    [System.Environment]::SetEnvironmentVariable("N8N_API_URL", $N8nUrl, "User")
    [System.Environment]::SetEnvironmentVariable("N8N_API_KEY", $N8nKey, "User")
    Write-Host "  Environment variables set (user scope) -- OK"
}

# Done
Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host "  n8n-autopilot installed successfully!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Installed:"
Write-Host "  n8n-mcp server"
Write-Host "  7 base n8n-skills"
Write-Host "  n8n-autopilot skill"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Restart Claude Code"
Write-Host '  2. Describe what you want to automate:'
Write-Host ""
Write-Host '     "Build a workflow: when someone fills a form,' -ForegroundColor White
Write-Host '      save data to Google Sheets and notify on Slack"' -ForegroundColor White
Write-Host ""
Write-Host "  Claude handles the rest: design, build, test, deliver."
Write-Host ""
