# Compose Tool 🐳

**Docker Compose 配置转换工具**

一键转换 Docker Run 命令和 Docker Compose 配置，实现"一容器一目录"的标准化管理。

![License](https://img.shields.io/github/license/BeacherZ/compose-tool?style=flat-square)
![Docker](https://img.shields.io/badge/docker-ready-blue?style=flat-square&logo=docker)
![GitHub Stars](https://img.shields.io/github/stars/BeacherZ/compose-tool?style=flat-square)

---

## 🏗️ 核心哲学：图纸与材料同屋存放

### 问题

装了几个 Docker 项目后，各种映射卷零零散散躺在宿主机的各个目录里，极其混乱：

```
/root/data/          ← 有些项目装这里
/home/user/docker/   ← 有些装这里
/var/lib/myapp/      ← 有些装这里
/tmp/test/           ← 还有些随手放的
```

### 解决方案

本工具的目标是把所有 Docker 项目的"图纸"（compose.yaml 配置文件）和"材料"（映射的数据目录）统一存放在一起：

```
/opt/docker/                        ← 统一大目录
├── vaultwarden/                    ← 每个容器一个子目录
│   ├── compose.yaml                ← 图纸（配置文件）
│   └── vw-data/                    ← 材料（容器数据）
├── portainer/
│   ├── compose.yaml
│   └── portainer-data/
├── compose-tool/                   ← 本项目自身也遵循此规范
│   └── compose.yaml                ← 本项目无数据卷，只有配置文件
└── nextcloud/
    ├── compose.yaml
    └── data/
```

### 好处

- **备份极简**：备份整个 `/opt/docker` 目录即可备份所有项目的配置和数据
- **迁移无痛**：打包 → 上传到新服务器 → 解压 → 一键启动，完整恢复
- **管理清晰**：进入任意子目录执行 `docker compose up -d` 即可启动对应项目

> 本工具默认路径为 `/opt/docker/{container_name}`，首次访问时可在设置中修改为你自己的路径。

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
  --name compose-tool \
  --restart unless-stopped \
  -p 8765:80 \
  ghcr.io/beacherz/compose-tool:latest
```

访问：`http://服务器IP:8765`

> 💡 本工具是纯静态网页，无数据持久化需求，无需挂载卷。

---

### 方式二：Docker Compose（推荐，符合本工具理念）

```bash
mkdir -p /opt/docker/compose-tool && cd /opt/docker/compose-tool && \
cat > compose.yaml << 'EOF'
services:
  compose-tool:
    image: ghcr.io/beacherz/compose-tool:latest
    container_name: compose-tool
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

访问：`http://服务器IP:8765`

**常用管理命令**

```bash
cd /opt/docker/compose-tool      # 进入项目目录
docker compose logs -f            # 查看运行日志
docker compose pull               # 拉取最新镜像
docker compose up -d              # 重新部署（更新后执行）
docker compose down               # 停止并删除容器
```

---

## 🎯 使用流程

**第 1 步：首次访问自动弹出设置窗口**

配置你的默认卷映射路径，推荐填写：

```
/opt/docker/{container_name}
```

`{container_name}` 会自动替换为实际容器名，保存后永久生效，下次访问无需重新配置。

**第 2 步：粘贴 Docker Run 命令或 Compose 配置**

直接从官方文档或 GitHub 复制命令粘贴进去即可。

**第 3 步：点击"转换配置"**

工具自动完成：
- 清理所有 Shell 变量（`$(pwd)`、`$HOME`、`~/` 等）
- 路径转换为统一绝对路径
- 保留系统级挂载不修改
- 添加标准配置（端口引号、重启策略等）

**第 4 步：复制并部署**

```bash
mkdir -p /opt/docker/容器名 && cd /opt/docker/容器名 && \
vim compose.yaml && docker compose up -d
```

> 💡 执行 `vim compose.yaml` 后，按 `i` 进入编辑模式，粘贴转换结果，按 `Esc` 退出编辑模式，输入 `:wq` 保存并退出。

---

## 📖 转换示例

### 示例 1：Docker Run → Compose

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
      - "/opt/docker/vaultwarden/vw-data:/data"
    environment:
      - "DOMAIN=https://vw.example.com"
    restart: unless-stopped
```

---

### 示例 2：官方 Compose → 标准化路径

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
    container_name: vaultwarden
    ports:
      - "8000:80"
    volumes:
      - "/opt/docker/vaultwarden/vw-data:/data"
    restart: unless-stopped
```

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
      - "/opt/docker/portainer/portainer-data:/data"
    restart: unless-stopped
```

---

## 💾 备份与迁移

### 备份原理

按照本工具的理念，所有项目的配置文件和数据都在 `/opt/docker/` 目录下，备份只需打包这个目录即可。

---

### 备份单个项目

以下命令将 `vaultwarden` 项目打包为压缩包，保存在当前用户的家目录（`/root/`）：

```bash
tar -czf /root/vaultwarden-backup.tar.gz /opt/docker/vaultwarden
```

**执行后压缩包位置**：`/root/vaultwarden-backup.tar.gz`

---

### 备份所有项目

```bash
tar -czf /root/docker-all-backup.tar.gz /opt/docker
```

**执行后压缩包位置**：`/root/docker-all-backup.tar.gz`

---

### 下载压缩包到本地电脑

**方法一：使用 scp 命令（在本地电脑终端执行）**

```bash
# 下载单个项目备份
scp root@你的服务器IP:/root/vaultwarden-backup.tar.gz ~/Downloads/

# 下载全部项目备份
scp root@你的服务器IP:/root/docker-all-backup.tar.gz ~/Downloads/
```

**方法二：使用 FTP 工具（推荐新手）**

1. 下载 [FileZilla](https://filezilla-project.org/) 或 [WinSCP](https://winscp.net/)
2. 连接到服务器（填写 IP、用户名 root、密码）
3. 进入右侧 `/root/` 目录
4. 找到 `.tar.gz` 压缩包
5. 右键 → 下载到本地电脑

---

### 迁移到新服务器

**第 1 步：在新服务器安装 Docker**

```bash
curl -fsSL https://get.docker.com | sh
```

**第 2 步：上传压缩包到新服务器**

**方法一：使用 scp 命令（在本地电脑终端执行）**

```bash
# 从本地电脑上传到新服务器的 /root/ 目录
scp ~/Downloads/docker-all-backup.tar.gz root@新服务器IP:/root/
```

**方法二：使用 FTP 工具**

1. 用 FileZilla 或 WinSCP 连接新服务器
2. 将本地电脑的压缩包拖拽到新服务器的 `/root/` 目录

**第 3 步：在新服务器上解压**

```bash
# 解压到根目录，会自动还原 /opt/docker/ 目录结构
tar -xzf /root/docker-all-backup.tar.gz -C /
```

**解压后自动恢复目录结构**：

```
/opt/docker/
├── vaultwarden/
│   ├── compose.yaml
│   └── vw-data/
├── portainer/
│   ├── compose.yaml
│   └── portainer-data/
├── compose-tool/
│   └── compose.yaml
└── ...
```

**第 4 步：一键启动所有容器**

```bash
for dir in /opt/docker/*/; do
  echo "正在启动: $dir"
  (cd "$dir" && docker compose up -d)
done
```

**执行后会看到类似输出**：

```
正在启动: /opt/docker/vaultwarden/
[+] Running 1/1
 ✔ Container vaultwarden  Started

正在启动: /opt/docker/portainer/
[+] Running 1/1
 ✔ Container portainer  Started

正在启动: /opt/docker/compose-tool/
[+] Running 1/1
 ✔ Container compose-tool  Started
```

---

### 单独恢复某个项目

如果只需要恢复其中一个项目：

```bash
# 解压到根目录（会还原到 /opt/docker/vaultwarden/）
tar -xzf /root/vaultwarden-backup.tar.gz -C /

# 进入目录启动
cd /opt/docker/vaultwarden && docker compose up -d
```

---

## 🛡️ 系统路径白名单（自动保留不转换）

| 分类 | 路径示例 |
|---|---|
| **Docker** | `/var/run/docker.sock`、`/var/lib/docker`、`/usr/bin/docker` |
| **内核/设备** | `/proc`、`/sys`、`/dev`、`/boot`、`/lib/modules` |
| **系统配置** | `/etc/localtime`、`/etc/hosts`、`/etc/resolv.conf`、`/etc/timezone` |
| **SSL 证书** | `/etc/ssl`、`/etc/pki`、`/etc/ca-certificates` |
| **用户/组** | `/etc/passwd`、`/etc/group`、`/etc/shadow`、`/etc/gshadow` |

完整白名单包含 45+ 路径，覆盖所有常见系统级挂载。

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

```bash
# Docker Run 方式
docker run -d -p 你的端口:80 ghcr.io/beacherz/compose-tool:latest

# Docker Compose 方式：编辑 compose.yaml 修改 ports 部分
ports:
  - "你的端口:80"
```

### 修改默认路径

首次访问后可随时点击右上角 ⚙️ **设置** 按钮修改，设置保存在浏览器本地。

### 更新到最新版本

```bash
cd /opt/docker/compose-tool && docker compose pull && docker compose up -d
```

---

## 📜 开源协议

本项目采用 **MIT License** 协议开源。

---

## 🌟 Star History

如果这个项目帮助到了你，请点个 **Star ⭐️** 支持作者持续优化！

[![Star History Chart](https://api.star-history.com/svg?repos=BeacherZ/compose-tool&type=Date)](https://star-history.com/#BeacherZ/compose-tool&Date)

---

## 📧 问题反馈

- **Issues**：[提交问题](https://github.com/BeacherZ/compose-tool/issues)
- **Discussions**：[参与讨论](https://github.com/BeacherZ/compose-tool/discussions)

---

<p align="center">
  <sub>Made with ❤️ for Docker enthusiasts</sub>
</p>
