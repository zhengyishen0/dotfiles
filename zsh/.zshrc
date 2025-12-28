################################################################################
# Environment Variables
################################################################################
export PATH="$PATH:$HOME/.local/bin"

# Context7 API key
export CONTEXT7_API_KEY='ctx7sk-ab0ddc96-7d9f-4a62-8c0f-0fd3f7d1adcb'

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section


################################################################################
# Claude Code
################################################################################
# claude-tools directory
CLAUDE_TOOLS_DIR="$HOME/Codes/claude-code/claude-tools"

# Process management
alias claude-ps='pgrep -fl "^claude"'
alias claude-kill='pkill -9 "^claude"'

# claude-tools alias - auto-generated
alias claude-tools="$CLAUDE_TOOLS_DIR/run.sh"

# Claude Code CLI
alias cc="COLUMNS=200 claude --dangerously-skip-permissions"
alias claude-fast="COLUMNS=200 claude --dangerously-skip-permissions --model haiku"

# Usage tracking
alias claude-usage="~/.config/opencode/usage.sh"


################################################################################
# Proxy Configuration
################################################################################
# Manual proxy toggle functions (or use: claude-tools proxy enable/disable)
proxy_on() {
  export https_proxy=http://127.0.0.1:33210
  export http_proxy=http://127.0.0.1:33210
  echo "代理已开启"
}

proxy_off() {
  unset https_proxy http_proxy
  echo "代理已关闭"
}

# Claude Code Proxy Auto-Enable
if [ -f "$CLAUDE_TOOLS_DIR/proxy/init.sh" ]; then
    source "$CLAUDE_TOOLS_DIR/proxy/init.sh"
fi
