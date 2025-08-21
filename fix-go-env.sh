#!/bin/bash

# macOS Go 环境修复脚本
# 解决新终端窗口中Go环境变量缺失问题

echo "🔧 修复 macOS Go 环境变量..."

# 检测shell类型
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
    echo "检测到 zsh shell"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bash_profile"
    echo "检测到 bash shell"
else
    SHELL_RC="$HOME/.profile"
    echo "使用通用 profile"
fi

echo "配置文件: $SHELL_RC"

# 检查Go是否已安装
if command -v go >/dev/null 2>&1; then
    echo "✅ Go 已安装: $(go version)"
    GO_ROOT=$(go env GOROOT)
    GO_PATH=$(go env GOPATH)
else
    echo "❌ Go 未找到，尝试检查常见安装位置..."
    
    # 检查常见Go安装位置
    if [ -f "/usr/local/go/bin/go" ]; then
        echo "✅ 找到Go在 /usr/local/go/"
        GO_ROOT="/usr/local/go"
        GO_PATH="$HOME/go"
    elif [ -f "/opt/homebrew/bin/go" ]; then
        echo "✅ 找到Go在 /opt/homebrew/ (Apple Silicon)"
        GO_ROOT="/opt/homebrew"
        GO_PATH="$HOME/go"
    elif command -v brew >/dev/null 2>&1; then
        echo "📦 使用 Homebrew 安装 Go..."
        brew install go
        GO_ROOT=$(brew --prefix go)
        GO_PATH="$HOME/go"
    else
        echo "❌ 未找到Go，请手动安装"
        echo "运行: brew install go"
        exit 1
    fi
fi

# 备份现有配置
if [ -f "$SHELL_RC" ]; then
    cp "$SHELL_RC" "${SHELL_RC}.backup.$(date +%Y%m%d)"
    echo "📋 已备份现有配置到 ${SHELL_RC}.backup.$(date +%Y%m%d)"
fi

# 移除旧的Go配置（如果存在）
if [ -f "$SHELL_RC" ]; then
    grep -v "# Go configuration" "$SHELL_RC" > "${SHELL_RC}.tmp" || true
    grep -v "export.*go" "${SHELL_RC}.tmp" > "$SHELL_RC" || true
    rm -f "${SHELL_RC}.tmp"
fi

# 添加新的Go配置
cat >> "$SHELL_RC" << EOF

# Go configuration - added by fix script
export GOROOT=$GO_ROOT
export GOPATH=$GO_PATH
export GOBIN=\$GOPATH/bin
export PATH=\$PATH:\$GOROOT/bin:\$GOBIN
EOF

echo "✅ Go 环境变量已添加到 $SHELL_RC"

# 创建Go工作目录
mkdir -p "$GO_PATH/bin" "$GO_PATH/src" "$GO_PATH/pkg"

# 应用配置到当前会话
source "$SHELL_RC"

# 验证配置
echo ""
echo "🧪 验证配置..."
export GOROOT=$GO_ROOT
export GOPATH=$GO_PATH
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOROOT/bin:$GOBIN

if command -v go >/dev/null 2>&1; then
    echo "✅ Go 版本: $(go version)"
    echo "✅ GOROOT: $(go env GOROOT)"
    echo "✅ GOPATH: $(go env GOPATH)"
    
    # 验证Ignite
    if command -v ignite >/dev/null 2>&1; then
        echo "✅ Ignite 版本: $(ignite version --short 2>/dev/null || echo '需要重新安装')"
    else
        echo "📦 重新安装 Ignite CLI..."
        go install github.com/ignite/cli/ignite/cmd/ignite@latest
    fi
    
    echo ""
    echo "🎉 修复完成！"
    echo ""
    echo "📝 请在新终端窗口中运行以下命令测试："
    echo "   go version"
    echo "   ignite version"
    echo ""
    echo "🚀 然后可以继续启动区块链："
    echo "   cd mychain"
    echo "   ignite chain serve --verbose"
    
else
    echo "❌ 修复失败，请手动检查Go安装"
    echo "建议运行: brew install go"
fi

echo ""
echo "⚠️  注意：请关闭当前终端并打开新终端窗口，或运行以下命令："
echo "   source $SHELL_RC"
