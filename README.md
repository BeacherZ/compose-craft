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
  ghcr.io/BeacherZ/compose-craft:latest
```

访问：`http://服务器IP:8765`

### 方式二：Docker Compose

```bash
cat > docker-compose.yml << 'EOF'
services:
  compose-craft:
    image: ghcr.io/BeacherZ/compose-craft:latest
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
docker compose up -d
```

常用命令：

```bash
docker compose logs -f    # 查看日志
docker compose pull       # 更新镜像
docker compose down       # 停止服务
```

---

## 🎯 使用流程

**第1 步：首次访问自动引导**

打开网页后自动弹出设置窗口，配置你的默认卷映射路径，例如 `/home/dpanel/compose/{container_name}`，保存后永久生效。

**第 2 步：粘贴命令或配置**

支持直接粘贴 Docker Run 命令或官方 Docker Compose YAML。

**第 3 步：一键转换**

点击"转换配置"按钮，自动完成路径规范化、Shell 变量清理、系统路径保留。

**第 4 步：复制并部署**

```bash
mkdir -p /home/dpanel/compose/容器名
cd /home/dpanel/compose/容器名
vim compose.yaml
docker compose up -d
```

---

## 📖 转换示例

### 示例 1：Docker Run 命令 → Compose

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

### 示例 2：官方 Compose →标准化路径

**输入**

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    volumes:
      - ./vw-data:/data
    ports:
      - 8000:80
```

**输出**

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    volumes:
      - "/home/dpanel/compose/vaultwarden/vw-data:/data"
    ports:
      - "8000:80"restart: unless-stopped
```

### 示例 3：系统路径自动保留

**输入**

```bash
docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/data:/data \
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
      - "/home/dpanel/compose/portainer/data:/data"
    restart: unless-stopped
```

---

## 💾 备份与迁移

```bash
# 备份单个项目
tar -czf vaultwarden-backup.tar.gz /home/dpanel/compose/vaultwarden

# 备份所有项目
tar -czf docker-all-backup.tar.gz /home/dpanel/compose

# 迁移到新服务器
curl -fsSL https://get.docker.com | sh
tar -xzf docker-all-backup.tar.gz -C /
for dir in /home/dpanel/compose/*/; do
  (cd "$dir" && docker compose up -d)
done
```

---

## 🛡️ 系统路径白名单（自动保留不转换）

| 分类 | 路径示例 |
|---|---|
| Docker | `/var/run/docker.sock`、`/var/lib/docker`、`/usr/bin/docker` |
| 内核/设备 | `/proc`、`/sys`、`/dev`、`/boot`、`/lib/modules` |
| 系统配置 | `/etc/localtime`、`/etc/hosts`、`/etc/resolv.conf` |
| SSL 证书 | `/etc/ssl`、`/etc/pki`、`/etc/ca-certificates` |
| 用户/组 | `/etc/passwd`、`/etc/group`、`/etc/shadow` |

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
| `--workdir` | ✅ | 工作目录 |
| `-d / --detach` | ✅ | 后台运行（自动忽略） |
| `-it` | ✅ | 交互模式（自动忽略） |

---

## 📜 开源协议

本项目采用 **MIT License**协议开源。

---

⭐ 如果这个项目帮助到了你，请点个 **Star** 支持作者持续优化！
