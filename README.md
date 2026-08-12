# Compose Craft 🎨

**精心打造你的 Docker Compose 配置**

一键转换 Docker Run 命令和 Docker Compose 配置，实现"一容器一目录"的标准化管理。

![License](https://img.shields.io/github/license/BeacherZ/compose-craft?style=flat-square)
![Docker](https://img.shields.io/badge/docker-ready-blue?style=flat-square&logo=docker)
![GitHub Stars](https://img.shields.io/github/stars/BeacherZ/compose-craft?style=flat-square)

---

## ✨ 核心特性

| 特性 | 说明 |
|---|---|
| 🔐 **100% 隐私安全** | 纯前端实现，所有数据仅在浏览器本地处理，绝不上传 |
| 🎯 **自动路径规范化** | 自动清理 `$(pwd)`、`${HOME}`、`$PWD` 等所有 Shell 变量 |
| 🛡️ **系统路径白名单** | 45+ 系统级挂载（如 `/var/run/docker.sock`）自动识别保留 |
| 💾 **永久保存设置** | 首次访问配置路径后永久记住，无需重复设置 |
| 🔄 **双模式支持** | 同时支持 Docker Run 命令和 Docker Compose YAML 配置转换 |
| 📱 **响应式设计** | 完美适配桌面端和移动端 |

---

## 🚀 快速部署

### 方式一：Docker Run

```bash
docker run -d \
  --name compose-craft \
  --restart unless-stopped \
  -p 8765:80 \
  ghcr.io/beacherz/compose-craft:latest
```

访问：`http://服务器IP:8765`

> 💡 **说明**：本工具是纯静态网页，无数据持久化需求，无需挂载卷。

---

### 方式二：Docker Compose（推荐）

**第 1 步：创建项目目录**

```bash
mkdir -p /home/dpanel/compose/compose-craft
cd /home/dpanel/compose/compose-craft
```

**第 2 步：创建 compose.yaml**

```bash
cat > compose.yaml << 'EOF'
services:
  compose-craft:
    image: ghcr.io/beacherz/compose-craft:latest
    container_name: compose-craft
    restart: unless-stopped
    ports:
      - "8765:80"
    environment:
      - TZ=Asia/Shanghai
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
EOF
```

**第 3 步：启动服务**

```bash
docker compose up -d
```

> ✅ **符合"图纸与材料同屋"理念**：配置文件存放在 `/home/dpanel/compose/compose-craft/compose.yaml`，虽然本项目无数据卷需求，但目录结构统一，方便管理。

**常用命令**

```bash
docker compose logs -f    # 查看日志
docker compose pull       # 更新镜像
docker compose up -d      # 重新部署
docker compose down       # 停止服务
```

---

## 🎯 使用流程

### 第 1 步：首次访问自动引导

打开网页后会自动弹出设置窗口，配置你的默认卷映射路径，例如：

```
/home/dpanel/compose/{container_name}
```

`{container_name}` 会自动替换为实际容器名，保存后永久生效。

### 第 2 步：粘贴命令或配置

支持两种输入方式：

**① Docker Run 命令**

```bash
docker run -d --name vaultwarden \
  -p 8000:80 \
  -v $(pwd)/vw-data:/data \
  -e DOMAIN=https://vw.example.com \
  vaultwarden/server:latest
```

**② Docker Compose YAML**

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    volumes:
      - ./vw-data:/data
    ports:
      - 8000:80
```

### 第 3 步：一键转换

点击"转换配置"按钮，工具会自动：

- ✅ 清理所有 Shell 变量（`$(pwd)`、`$HOME`、`~/`等）
- ✅ 统一路径格式为绝对路径
- ✅ 识别并保留系统级挂载（如 `/var/run/docker.sock`）
- ✅ 添加标准化配置（端口引号、重启策略等）

### 第 4 步：复制并部署

点击右侧"复制"按钮，然后：

```bash
# 创建项目目录
mkdir -p /home/dpanel/compose/vaultwarden
cd /home/dpanel/compose/vaultwarden

# 保存配置
vim compose.yaml  # 粘贴转换结果

# 启动服务
docker compose up -d
```

---

## 📖 转换示例

### 示例 1：Docker Run → Compose（自动清理 Shell 变量）

**输入**

```bash
docker run -d --name vaultwarden \
  -p 8000:80 \
  -v $(pwd)/vw-data:/data \
  -e DOMAIN=https://vw.example.com \
  vaultwarden/server:latest
```

**输出**

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    ports:
      - "8000:80"
    volumes:
      - "/home/dpanel/compose/vaultwarden/vw-data:/data"
    environment:
      - "DOMAIN=https://vw.example.com"
    restart: unless-stopped
```

**改动说明**：
- `$(pwd)` 被清理，使用自定义绝对路径
- 端口自动加引号
- 自动添加 `restart: unless-stopped`

---

### 示例 2：官方 Compose → 标准化路径

**输入（官方示例）**

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    volumes:
      - ./vw-data:/data
    ports:
      - 8000:80
```

**输出（标准化）**

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    ports:
      - "8000:80"
    volumes:
      - "/home/dpanel/compose/vaultwarden/vw-data:/data"
    restart: unless-stopped
```

**改动说明**：
- `./vw-data` 转换为绝对路径
- 自动添加 `container_name`
- 自动添加 `restart: unless-stopped`

---

### 示例 3：系统路径自动保留

**输入**

```bash
docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/portainer-data:/data \
  --name portainer \
  portainer/portainer-ce
```

**输出**

```yaml
services:
  portainer:
    image: portainer/portainer-ce
    container_name: portainer
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "/home/dpanel/compose/portainer/portainer-data:/data"
    restart: unless-stopped
```

**改动说明**：
- `/var/run/docker.sock` 识别为系统路径，保持原样
- `~/portainer-data` 被清理并转换为绝对路径

---

## 💾 备份与迁移

### 备份 Compose Craft 本身

```bash
# 虽然本项目无数据卷，但可以备份配置文件方便恢复
tar -czf compose-craft-backup.tar.gz /home/dpanel/compose/compose-craft
```

### 备份单个项目

```bash
tar -czf vaultwarden-backup.tar.gz /home/dpanel/compose/vaultwarden
```

### 备份所有项目

```bash
tar -czf docker-all-backup.tar.gz /home/dpanel/compose
```

### 迁移到新服务器

```bash
# 1. 安装 Docker
curl -fsSL https://get.docker.com | sh

# 2. 上传并解压备份
tar -xzf docker-all-backup.tar.gz -C /

# 3. 批量启动所有容器
for dir in /home/dpanel/compose/*/; do
  (cd "$dir" && docker compose up -d)
done
```

---

## 🛡️ 系统路径白名单（自动保留不转换）

以下路径会自动识别并保留，不做转换：

| 分类 | 路径示例 |
|---|---|
| **Docker** | `/var/run/docker.sock`、`/var/lib/docker`、`/usr/bin/docker` |
| **内核/设备** | `/proc`、`/sys`、`/dev`、`/boot`、`/lib/modules` |
| **系统配置** | `/etc/localtime`、`/etc/hosts`、`/etc/resolv.conf`、`/etc/timezone` |
| **SSL 证书** | `/etc/ssl`、`/etc/pki`、`/etc/ca-certificates` |
| **用户/组** | `/etc/passwd`、`/etc/group`、`/etc/shadow`、`/etc/gshadow` |

**完整白名单包含 45+ 路径**，覆盖所有常见系统级挂载。

---

## 📋 支持的 Docker Run 参数

| 参数 | 支持 | 说明 |
|---|:---:|---|
| `--name` | ✅ | 容器名称 |
| `-p / --publish` | ✅ | 端口映射 |
| `-v / --volume` | ✅ | 卷映射（核心功能） |
| `-e / --env` | ✅ | 环境变量 |
| `--restart` | ✅ | 重启策略 |
| `--hostname` | ✅ | 主机名 |
| `--network` | ✅ | 网络配置 |
| `--privileged` | ✅ | 特权模式 |
| `-l / --label` | ✅ | 标签 |
| `--log-driver` | ✅ | 日志驱动 |
| `--log-opt` | ✅ | 日志选项 |
| `--workdir` | ✅ | 工作目录 |
| `-d / --detach` | ✅ | 后台运行（自动忽略） |
| `-it` | ✅ | 交互模式（自动忽略） |
| `--rm` | ✅ | 退出即删除（自动忽略） |

---

## 🔧 高级配置

### 自定义端口

默认端口是 `8765`，修改方法：

```bash
# Docker Run
docker run -d -p 你的端口:80 ghcr.io/beacherz/compose-craft:latest

# Docker Compose
# 编辑 compose.yaml，修改 ports 部分：
ports:
  - "你的端口:80"
```

### 修改默认路径

首次访问设置后，可随时点击右上角 ⚙️ **设置** 按钮修改。

设置保存在浏览器本地（localStorage），迁移到新浏览器需要重新设置。

### 更新到最新版本

```bash
cd /home/dpanel/compose/compose-craft
docker compose pull
docker compose up -d
```

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

```bash
# 1. Fork 本仓库
# 2. 创建特性分支
git checkout -b feature/amazing-feature

# 3. 提交更改
git commit -m 'Add amazing feature'

# 4. 推送到分支
git push origin feature/amazing-feature

# 5. 提交 Pull Request
```

---

## 📜 开源协议

本项目采用 **MIT License** 协议开源。

---

## 🌟 Star History

如果这个项目帮助到了你，请点个 **Star ⭐️** 支持作者持续优化！

[![Star History Chart](https://api.star-history.com/svg?repos=BeacherZ/compose-craft&type=Date)](https://star-history.com/#BeacherZ/compose-craft&Date)

---

## 📧 问题反馈

- **Issues**：[提交问题](https://github.com/BeacherZ/compose-craft/issues)
- **Discussions**：[参与讨论](https://github.com/BeacherZ/compose-craft/discussions)

---

<p align="center">
  <sub>Made with ❤️ for Docker enthusiasts</sub>
</p>
```
