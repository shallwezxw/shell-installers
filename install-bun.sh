#!/usr/bin/env bash
set -e

# 自动获取最新版本
LATEST=$(curl -fsSL https://api.github.com/repos/oven-sh/bun/releases/latest \
  | grep '"tag_name":' | head -n1 | sed -E 's/.*"([^"]+)".*/\1/')
echo "Detected latest bun version: $LATEST"

INSTALL_DIR="${HOME}/.bun"

# 架构和平台检测
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then ARCH="x64"; elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then ARCH="arm64"; else echo "Unsupported arch"; exit 1; fi

OS=$(uname)
if [[ "$OS" == "Linux" ]]; then OS="linux"; elif [[ "$OS" == "Darwin" ]]; then OS="darwin"; else echo "Unsupported OS"; exit 1; fi

FILE="bun-${OS}-${ARCH}.zip"
#URL="https://ghproxy.com/https://github.com/oven-sh/bun/releases/download/${LATEST}/${FILE}"
URL="https://github.com/oven-sh/bun/releases/download/${LATEST}/${FILE}"
echo "Downloading from: $URL"
mkdir -p "$INSTALL_DIR" && cd "$INSTALL_DIR"

curl -L "$URL" -o bun.zip
unzip -o bun.zip
rm bun.zip

# PATH 配置
PROFILE_RC="$HOME/.bashrc"
[[ -n "$ZSH_VERSION" ]] && PROFILE_RC="$HOME/.zshrc"

if ! grep -q 'export PATH="$HOME/.bun/bin:$PATH"' "$PROFILE_RC" 2>/dev/null; then
  echo 'export PATH="$HOME/.bun/bin:$PATH"' >> "$PROFILE_RC"
  echo "➡️ Added to $PROFILE_RC"
fi

echo "✅ Bun $LATEST installed to $INSTALL_DIR"
echo "➡️ Run: source \"$PROFILE_RC\""
