#!/bin/bash

# macOS 专用的轻量化 Cosmos SDK 安装脚本
# 针对磁盘空间不足的情况优化

echo "🍎 macOS 轻量化 Cosmos SDK 环境设置"

# 检查磁盘空间
AVAILABLE_SPACE=$(df -h / | awk 'NR==2{print $4}' | sed 's/Gi//')
echo "📊 可用磁盘空间: ${AVAILABLE_SPACE}GB"

if [ "${AVAILABLE_SPACE%.*}" -lt 5 ]; then
    echo "⚠️  警告：磁盘空间不足5GB，建议清理后再继续"
    echo "💡 请先运行以下命令清理空间："
    echo "   go clean -cache && go clean -modcache"
    echo "   rm -rf ~/Library/Caches/*"
    exit 1
fi

# 设置轻量化的Go环境
echo "⚙️  设置轻量化Go环境..."
export GOCACHE=/tmp/go-cache
export GOMODCACHE=/tmp/go-mod
export GOPROXY=https://goproxy.cn,direct  # 使用国内代理加速

# 创建临时目录
mkdir -p /tmp/go-cache /tmp/go-mod

# 检查Go安装
if ! command -v go &> /dev/null; then
    echo "📦 安装Go (使用Homebrew)..."
    if ! command -v brew &> /dev/null; then
        echo "❌ 请先安装Homebrew: https://brew.sh"
        exit 1
    fi
    brew install go
fi

echo "✅ Go版本: $(go version)"

# 轻量化安装Ignite CLI
echo "📦 安装轻量化Ignite CLI..."
GOOS=darwin GOARCH=amd64 go install github.com/ignite/cli/ignite/cmd/ignite@latest

# 验证安装
if command -v ignite &> /dev/null; then
    echo "✅ Ignite安装成功: $(ignite version --short)"
else
    echo "❌ Ignite安装失败"
    exit 1
fi

echo ""
echo "🎉 轻量化环境设置完成！"
echo ""
echo "💡 推荐使用Docker方式运行以节省空间："
echo "   docker run -it --rm -v \$(pwd):/workspace -w /workspace golang:1.21-alpine sh"
echo ""
echo "📝 创建最小项目："
echo "   mkdir tiny-chain && cd tiny-chain"
echo "   ignite scaffold chain tiny --minimal --address-prefix tiny"
echo ""
echo "⚠️  注意：请确保至少有5GB可用空间再启动链"
