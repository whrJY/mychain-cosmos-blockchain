#!/bin/bash

# macOS 低内存环境 Cosmos SDK 解决方案
# 使用 Docker 避免本地内存问题

echo "🐳 使用 Docker 方式解决内存问题"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "📦 请先安装 Docker Desktop for Mac:"
    echo "   brew install --cask docker"
    echo "   或者从 https://docs.docker.com/desktop/mac/install/ 下载"
    exit 1
fi

# 检查 Docker 是否运行
if ! docker info >/dev/null 2>&1; then
    echo "🚀 请启动 Docker Desktop"
    open -a Docker
    echo "⏳ 等待 Docker 启动..."
    while ! docker info >/dev/null 2>&1; do
        sleep 2
    done
    echo "✅ Docker 已启动"
fi

# 创建轻量化的 Dockerfile
cat > Dockerfile.cosmos << 'EOF'
FROM golang:1.21-alpine

# 安装必要工具
RUN apk add --no-cache git curl bash make gcc musl-dev

# 设置工作目录
WORKDIR /workspace

# 安装 Ignite CLI
RUN curl https://get.ignite.com/cli! | bash

# 设置环境变量
ENV GOCACHE=/tmp/go-cache
ENV GOMODCACHE=/tmp/go-mod
ENV GOMEMLIMIT=512MiB
ENV GOMAXPROCS=1

# 暴露端口
EXPOSE 26656 26657 1317 9090 4500

# 启动命令
CMD ["/bin/bash"]
EOF

echo "🏗️  构建 Docker 镜像..."
docker build -f Dockerfile.cosmos -t cosmos-dev .

echo "🚀 启动 Cosmos 开发环境..."
docker run -it --rm \
    -p 26657:26657 \
    -p 1317:1317 \
    -p 9090:9090 \
    -p 4500:4500 \
    -v $(pwd):/workspace \
    cosmos-dev

echo ""
echo "📝 在 Docker 容器内运行以下命令："
echo "   ignite scaffold chain mychain --address-prefix mychain"
echo "   cd mychain"
echo "   ignite chain serve"
