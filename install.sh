#!/usr/bin/env bash
# n8n-autopilot installer for macOS and Linux
set -e

REPO_URL="https://github.com/natiixnt/n8n-autopilot"
SKILLS_DIR=""
MCP_PATH=""

echo "=== n8n-autopilot installer ==="
echo ""

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Darwin) PLATFORM="macOS" ;;
    Linux)  PLATFORM="Linux" ;;
    MINGW*|MSYS*|CYGWIN*)
        echo "Windows detected -- use install.ps1 instead:"
        echo "  irm https://raw.githubusercontent.com/natiixnt/n8n-autopilot/main/install.ps1 | iex"
        exit 1
        ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

echo "Platform: $PLATFORM"

# Set paths
SKILLS_DIR="$HOME/.claude/skills"
MCP_PATH="$HOME/.claude/.mcp.json"

# Step 1: Check prerequisites
echo ""
echo "[1/5] Checking prerequisites..."

if ! command -v node &> /dev/null; then
    echo "ERROR: Node.js not found."
    echo "  macOS:  brew install node"
    echo "  Linux:  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "ERROR: Node.js 18+ required (you have $(node -v))"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "ERROR: git not found."
    echo "  macOS:  xcode-select --install"
    echo "  Linux:  sudo apt-get install git"
    exit 1
fi

echo "  Node.js $(node -v) -- OK"
echo "  git -- OK"

# Step 2: Install n8n-mcp
echo ""
echo "[2/5] Installing n8n-mcp server..."
npm install -g n8n-mcp 2>/dev/null || sudo npm install -g n8n-mcp
echo "  n8n-mcp -- OK"

# Step 3: Install n8n-skills (base skills from czlonkowski)
echo ""
echo "[3/5] Installing n8n-skills (7 base skills)..."
mkdir -p "$SKILLS_DIR"

TEMP_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/czlonkowski/n8n-skills.git "$TEMP_DIR" 2>/dev/null
cp -r "$TEMP_DIR/skills/"* "$SKILLS_DIR/"
rm -rf "$TEMP_DIR"
echo "  7 base skills installed -- OK"

# Step 4: Install n8n-autopilot
echo ""
echo "[4/5] Installing n8n-autopilot skill..."

# If running from cloned repo, copy from local
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -d "$SCRIPT_DIR/skills/n8n-autopilot" ]; then
    cp -r "$SCRIPT_DIR/skills/n8n-autopilot" "$SKILLS_DIR/"
    echo "  n8n-autopilot installed from local -- OK"
else
    # Otherwise download from GitHub
    TEMP_DIR=$(mktemp -d)
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null
    cp -r "$TEMP_DIR/skills/n8n-autopilot" "$SKILLS_DIR/"
    rm -rf "$TEMP_DIR"
    echo "  n8n-autopilot downloaded and installed -- OK"
fi

# Step 5: MCP config
echo ""
echo "[5/5] Configuring MCP server..."

if [ -f "$MCP_PATH" ]; then
    # Check if n8n-mcp already configured
    if grep -q "n8n-mcp" "$MCP_PATH" 2>/dev/null; then
        echo "  n8n-mcp already configured in $MCP_PATH -- OK"
    else
        echo "  .mcp.json exists but n8n-mcp not configured."
        echo "  Add n8n-mcp manually. See README.md for config example."
    fi
else
    echo ""
    echo "  Enter your n8n instance URL (e.g. https://your-name.app.n8n.cloud):"
    read -r N8N_URL
    echo "  Enter your n8n API key (from n8n Settings -> API):"
    read -r N8N_KEY

    mkdir -p "$(dirname "$MCP_PATH")"
    cat > "$MCP_PATH" << MCPEOF
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true",
        "N8N_API_URL": "$N8N_URL",
        "N8N_API_KEY": "$N8N_KEY"
      }
    }
  }
}
MCPEOF
    echo "  .mcp.json created -- OK"

    # Save env vars for credential auto-assignment
    SHELL_RC=""
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        SHELL_RC="$HOME/.bash_profile"
    fi

    if [ -n "$SHELL_RC" ] && ! grep -q "N8N_API_URL" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# n8n API (used by n8n-autopilot for credential auto-assignment)" >> "$SHELL_RC"
        echo "export N8N_API_URL=\"$N8N_URL\"" >> "$SHELL_RC"
        echo "export N8N_API_KEY=\"$N8N_KEY\"" >> "$SHELL_RC"
        echo "  Environment variables added to $SHELL_RC"
    fi
fi

# Done
echo ""
echo "==========================================="
echo "  n8n-autopilot installed successfully!"
echo "==========================================="
echo ""
echo "Installed:"
echo "  n8n-mcp server"
echo "  7 base n8n-skills"
echo "  n8n-autopilot skill"
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code"
echo "  2. Describe what you want to automate:"
echo ""
echo '     "Zbuduj workflow: kiedy ktos wypelni formularz,'
echo '      zapisz dane do Google Sheets i powiadom na Slacku"'
echo ""
echo "  Claude handles the rest: design, build, test, deliver."
echo ""
