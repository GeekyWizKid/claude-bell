# Claude Code 提示音插件

为 Claude Code 设计的轻量级音频通知插件，在任务完成、遇到错误或需要用户输入时提供音频反馈。

## ✨ 功能特性

- 🔔 **任务完成提醒** - 长时间运行的任务完成时提供音频反馈
- ❌ **错误通知** - 操作失败时立即提供音频警报
- 🔔 **用户提示通知** - Claude 需要用户输入时提供音频提示
- 🎵 **跨平台支持** - 支持 macOS、Linux 和 Windows
- ⚙️ **完全可配置** - 可自定义音效、音量和触发事件
- 🔗 **原生集成** - 基于 Claude Code 官方 hooks 系统构建

## 🚀 快速开始

### 通过 npm 安装（推荐）

```bash
npm install -g claude-code-bell-plugin
```

安装程序会自动配置 Claude Code hooks 并设置插件。如果 Claude Code 正在运行，只需重启即可。

### 手动安装

1. **克隆或下载** 本仓库
2. **运行安装程序**：
   ```bash
   cd claude-bell
   bash install.sh
   ```

3. **自动配置**（如果已安装 Claude Code）：
   - 安装程序会自动配置 Claude Code hooks
   - 重启 Claude Code 以应用更改

4. **手动配置**（如需要）：
   - 在 Claude Code 中运行：`/hooks`
   - 添加这些 hooks 到 `~/.claude/settings.json`：
   ```json
   {
     "hooks": {
       "Stop": [
         {
           "command": "node $HOME/.claude-code-bell/play-notification.js completion",
           "description": "任务完成时播放提示音"
         }
       ],
       "Notification": [
         {
           "command": "node $HOME/.claude-code-bell/play-notification.js notification",
           "description": "用户提示时播放提示音"
         }
       ],
       "PostToolUse": [
         {
           "command": "node $HOME/.claude-code-bell/play-notification.js toolComplete",
           "description": "工具执行完成后播放提示音（可选）"
         }
       ]
     }
   }
   ```

### 测试

安装后立即测试插件：

```bash
# 测试完成音效
node ~/.claude-code-bell/play-notification.js completion

# 测试错误音效
node ~/.claude-code-bell/play-notification.js error

# 测试通知音效
node ~/.claude-code-bell/play-notification.js notification
```

## ⚙️ 配置

### 基础配置

运行交互式配置工具：
```bash
node ~/.claude-code-bell/configure.js
```

### 手动配置

编辑 `~/.claude-code-bell/config.json`：

```json
{
  "enabled": true,
  "volume": 0.7,
  "sounds": {
    "completion": "completion.wav",
    "notification": "notification.wav",
    "error": "error.wav",
    "toolComplete": "tool-complete.wav"
  },
  "events": {
    "Stop": true,
    "Notification": true,
    "PostToolUse": false,
    "PreToolUse": false
  }
}
```

### 自定义音效

用你自己的音效文件替换 `~/.claude-code-bell/sounds/` 中的 WAV 文件：
- `completion.wav` - 任务完成
- `error.wav` - 操作失败
- `notification.wav` - 用户提示
- `tool-complete.wav` - 工具执行完成

## 🛠️ 开发

### 项目结构

```
claude-bell/
├── README.md                 # 英文说明
├── README_CN.md              # 中文说明
├── install.sh               # 安装脚本
├── uninstall.sh             # 卸载脚本
├── config.json              # 默认配置
└── src/                     # 源代码
    ├── config-manager.js
    ├── notification-player.js
    ├── play-notification.js
    └── sounds/               # 音频文件
        ├── completion.wav
        ├── error.wav
        ├── notification.wav
        └── tool-complete.wav
    ├── config-manager.js
    ├── notification-player.js
    └── play-notification.js
```

### 手动安装

1. **复制文件**：
   ```bash
   mkdir -p ~/.claude-code-bell/sounds
   cp src/*.js ~/.claude-code-bell/
   cp src/sounds/*.wav ~/.claude-code-bell/sounds/
   cp config.json ~/.claude-code-bell/
   chmod +x ~/.claude-code-bell/*.js
   ```

2. **配置 hooks** 如快速开始所示

## 🧹 卸载

### 自动卸载
```bash
bash uninstall.sh
```

### 手动卸载
```bash
# 删除插件目录
rm -rf ~/.claude-code-bell

# 从 Claude Code hooks 中移除
# 编辑 ~/.claude-code/settings.json 并从 hooks 部分删除提示音插件相关条目
```

## 🔧 故障排除

### 没有声音
- 检查系统音量
- 验证 config.json 中 `enabled: true`
- 使用手动命令测试
- 确保已授予音频权限

### 插件不工作
- 验证 Claude Code hooks 已配置
- 检查 Node.js 是否安装：`which node`
- 运行测试命令验证功能
- 配置更改后重启 Claude Code

### 路径问题
- 确保 hooks.toml 中的路径正确
- 检查文件权限：`ls -la ~/.claude-code-bell/`
- 验证 Node.js 可执行文件路径

## 📋 系统要求

- Node.js 16+（用于音频播放）
- 支持 hooks 的 Claude Code
- 音频系统（扬声器/耳机）

## 🤝 贡献

1. Fork 仓库
2. 创建功能分支
3. 进行更改
4. 充分测试
5. 提交拉取请求

## 📄 许可证

MIT 许可证 - 详见 LICENSE 文件

## 🌐 国际化

英文文档请参见 [README.md](README.md)