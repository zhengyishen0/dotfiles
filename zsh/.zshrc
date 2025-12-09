
# 代理开关
proxy_on() {
  export https_proxy=http://127.0.0.1:33210
  export http_proxy=http://127.0.0.1:33210
  echo "代理已开启"
}

proxy_off() {
  unset https_proxy http_proxy
  echo "代理已关闭"
}


export PATH="$PATH:$HOME/.local/bin"

# Claude Code alias
alias claude-danger="claude --dangerously-skip-permissions"
