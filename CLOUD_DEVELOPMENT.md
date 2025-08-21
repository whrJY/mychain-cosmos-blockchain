# 🌤️ 云端 Cosmos SDK 开发指南

由于本地macOS内存限制（只有1.26GB可用），推荐使用云端开发环境。

## 1. GitHub Codespaces（推荐）

### 快速开始：
1. 访问：https://github.com/whrJY/mychain-cosmos-blockchain
2. 点击绿色的 "Code" 按钮
3. 选择 "Codespaces" 标签
4. 点击 "Create codespace on main"

### 在Codespace中运行：
```bash
# 安装依赖
curl https://get.ignite.com/cli! | bash

# 创建区块链
ignite scaffold chain mychain --address-prefix mychain
cd mychain

# 启动（云端有足够资源）
ignite chain serve
```

## 2. Gitpod

### 一键启动：
点击链接：[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/whrJY/mychain-cosmos-blockchain)

### 或手动：
1. 访问：https://gitpod.io
2. 输入仓库URL：`https://github.com/whrJY/mychain-cosmos-blockchain`
3. 点击 "Continue"

## 3. 本地低内存模式

如果必须在本地运行，使用这个脚本：

```bash
#!/bin/bash
# 低内存模式启动脚本

echo "🔧 配置低内存模式..."

# 释放内存
sudo purge

# 设置严格限制
export GOMEMLIMIT=150MiB
export GOMAXPROCS=1
export CGO_ENABLED=0
export GOCACHE=/tmp/gocache
export GOMODCACHE=/tmp/gomod

# 创建临时目录
mkdir -p /tmp/gocache /tmp/gomod

# 最小化项目
ignite scaffold chain mini --minimal --address-prefix mini
cd mini

# 分步构建
echo "📦 分步构建..."
go mod tidy
go mod download
go build -ldflags="-s -w" ./cmd/minid

# 手动启动
echo "🚀 启动节点..."
./minid init mynode --chain-id mini
./minid keys add alice --keyring-backend test
./minid add-genesis-account alice 1000000stake --keyring-backend test
./minid gentx alice 100000stake --chain-id mini --keyring-backend test
./minid collect-gentxs
./minid start
```

## 4. 使用预构建Docker镜像

```bash
# 拉取官方轻量镜像
docker pull cosmossdk/cosmos:latest

# 运行开发环境
docker run -it --rm \
  -p 26657:26657 \
  -p 1317:1317 \
  --memory=512m \
  --cpus=0.5 \
  cosmossdk/cosmos:latest
```

## 建议选择

### 🥇 首选：GitHub Codespaces
- ✅ 免费额度：每月60小时
- ✅ 完整的开发环境
- ✅ 4核心 + 8GB内存
- ✅ 支持VS Code

### 🥈 次选：Gitpod
- ✅ 免费额度：每月50小时
- ✅ 快速启动
- ✅ 良好的性能

### 🥉 备选：本地Docker
- ⚠️ 需要至少2GB内存
- ⚠️ 可能仍然遇到内存问题

### ❌ 不推荐：本地直接运行
- ❌ 您的可用内存不足
- ❌ 频繁被系统杀死

## 总结

考虑到您的硬件限制，**强烈建议使用GitHub Codespaces**，这样可以：
1. 获得完整的开发体验
2. 避免本地资源限制
3. 随时随地开发
4. 与GitHub完美集成

立即开始：https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=1041805796
