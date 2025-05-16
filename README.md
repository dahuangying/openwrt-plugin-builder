
# 🚀 OpenWrt 插件自动构建源

本项目由 [@dahuangying](https://github.com/dahuangying) 维护，自动构建并提供以下插件的 `.ipk` 安装包：

- ✅ PassWall
- ✅ PassWall2
- ✅ SSR-Plus
- ✅ OpenClash

支持平台：

- **x86_64**（适配所有常见 x86 软路由）
- **aarch64_cortex-a53**（适配 R2S、R4S、R5、AX6、AX3600、AX9000 等）

---

## 📦 插件平台下载目录

| 架构平台 | 下载链接 |
|----------|-----------|
| **x86_64** | [点击进入](https://dahuangying.github.io/openwrt-plugin-builder/packages/x86_64/) |
| **aarch64_cortex-a53** | [点击进入](https://dahuangying.github.io/openwrt-plugin-builder/packages/aarch64_cortex-a53/) |

---

## 🛠️ 一键配置 OPKG 插件源（建议手动复制命令）

### 如果你是 `x86_64` 设备：

```bash
echo "src/gz custom_plugins https://dahuangying.github.io/openwrt-plugin-builder/packages/x86_64/" >> /etc/opkg/customfeeds.conf
opkg update
```

### 如果你是 `aarch64_cortex-a53` 设备：

```bash
echo "src/gz custom_plugins https://dahuangying.github.io/openwrt-plugin-builder/packages/aarch64_cortex-a53/" >> /etc/opkg/customfeeds.conf
opkg update
```

---

## 插件一键安装和升级

添加源并执行 `opkg update` 后，即可通过如下命令安装或升级插件：

安装插件：
```bash
opkg install passwall
opkg install passwall2
opkg install ssr-plus
opkg install openclash
```

升级插件：
```bash
opkg upgrade passwall
opkg upgrade passwall2
opkg upgrade ssr-plus
opkg upgrade openclash
```
