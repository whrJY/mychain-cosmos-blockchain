#!/bin/bash

# MyChain Cosmos SDK 自动安装脚本 (使用curl版本)
# 自动检测系统架构并安装正确的Go和Ignite CLI版本

set -e

echo "🚀 开始安装 MyChain Cosmos SDK 开发环境..."

# 检测操作系统和架构
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    arm64)
        ARCH="arm64"
        ;;
    *)
        echo "❌ 不支持的架构: $ARCH"
        exit 1
        ;;
esac

echo "📋 检测到系统: $OS-$ARCH"

# 设置Go版本
GO_VERSION="1.21.6"
GO_ARCHIVE="go${GO_VERSION}.${OS}-${ARCH}.tar.gz"
GO_URL="https://golang.org/dl/${GO_ARCHIVE}"

# 清理现有Go安装
echo "🧹 清理现有Go安装..."
sudo rm -rf /usr/local/go

# 下载并安装Go
echo "⬇️  下载Go ${GO_VERSION}..."
curl -L --progress-bar "$GO_URL" -o "/tmp/${GO_ARCHIVE}"

echo "📦 安装Go..."
sudo tar -C /usr/local -xzf "/tmp/${GO_ARCHIVE}"
rm "/tmp/${GO_ARCHIVE}"

# 配置环境变量
echo "⚙️  配置环境变量..."
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.profile"
fi

# 备份现有配置
if [ -f "$SHELL_RC" ]; then
    cp "$SHELL_RC" "$SHELL_RC.backup"
fi

# 添加Go环境变量（如果不存在）
if ! grep -q "/usr/local/go/bin" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Go configuration" >> "$SHELL_RC"
    echo "export PATH=\$PATH:/usr/local/go/bin" >> "$SHELL_RC"
    echo "export GOPATH=\$HOME/go" >> "$SHELL_RC"
    echo "export GOBIN=\$GOPATH/bin" >> "$SHELL_RC"
    echo "export PATH=\$PATH:\$GOBIN" >> "$SHELL_RC"
fi

# 使环境变量生效
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# 创建GOPATH目录
mkdir -p "$GOPATH/bin"

# 验证Go安装
echo "✅ 验证Go安装..."
go version

# 安装Ignite CLI
echo "📦 安装Ignite CLI..."

# 方法1: 尝试使用go install
echo "尝试使用go install安装Ignite..."
if go install github.com/ignite/cli/ignite/cmd/ignite@latest; then
    echo "✅ Ignite CLI安装成功 (via go install)"
else
    echo "⚠️  go install失败，尝试手动下载..."
    
    # 方法2: 手动下载二进制文件
    IGNITE_VERSION="0.27.2"
    IGNITE_ARCHIVE="ignite_${IGNITE_VERSION}_${OS}_${ARCH}.tar.gz"
    IGNITE_URL="https://github.com/ignite/cli/releases/download/v${IGNITE_VERSION}/${IGNITE_ARCHIVE}"
    
    echo "下载Ignite CLI ${IGNITE_VERSION}..."
    curl -L --progress-bar "$IGNITE_URL" -o "/tmp/${IGNITE_ARCHIVE}"
    
    # 解压到临时目录
    mkdir -p /tmp/ignite
    tar -xzf "/tmp/${IGNITE_ARCHIVE}" -C /tmp/ignite
    
    # 移动到PATH目录
    sudo mv /tmp/ignite/ignite /usr/local/bin/
    sudo chmod +x /usr/local/bin/ignite
    
    # 清理
    rm -rf /tmp/ignite "/tmp/${IGNITE_ARCHIVE}"
    
    echo "✅ Ignite CLI手动安装成功"
fi

# 验证Ignite安装
echo "✅ 验证Ignite安装..."
ignite version

echo ""
echo "🎉 安装完成！"
echo ""
echo "📝 请运行以下命令来重新加载环境变量："
echo "   source $SHELL_RC"
echo ""
echo "🚀 现在您可以开始创建区块链："
echo "   ignite scaffold chain mychain --address-prefix mychain"
echo "   cd mychain"
echo "   ignite chain serve"
echo ""
echo "📚 查看完整文档："
echo "   https://github.com/whrJY/mychain-cosmos-blockchain"
