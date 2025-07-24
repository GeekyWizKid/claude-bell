# Claude Code Bell Plugin

A lightweight audio notification plugin for Claude Code that provides audio feedback when tasks complete, encounter errors, or require user input.

## ✨ Features

- 🔔 **Task Completion Alerts** - audio feedback when long-running tasks finish
- ❌ **Error Notifications** - immediate audio alerts when operations fail
- 🔔 **User Prompt Notifications** - audio cues when Claude needs user input
- 🎵 **Cross-Platform Support** - works on macOS, Linux, and Windows
- ⚙️ **Fully Configurable** - customize sounds, volume, and trigger events
- 🔗 **Native Integration** - built on Claude Code's official hooks system

## 🚀 Quick Start

### Installation via npm (Recommended)

```bash
npm install -g claude-code-bell-plugin
```

The installer will automatically configure Claude Code hooks and set up the plugin. Just restart Claude Code if it's currently running.

### Manual Installation

1. **Clone or download** this repository
2. **Run the installer**:
   ```bash
   cd claude-bell
   bash install.sh
   ```

3. **Auto-configuration** (if Claude Code is installed):
   - The installer will automatically configure Claude Code hooks
   - Restart Claude Code to apply changes

4. **Manual configuration** (if needed):
   - In Claude Code, run: `/hooks`
   - Add these hooks to `~/.claude/settings.json`:
   ```json
   {
     "hooks": {
       "Stop": [
         {
           "command": "node $HOME/.claude-code-bell/play-notification.js completion",
           "description": "Play completion sound when task finishes"
         }
       ],
       "Notification": [
         {
           "command": "node $HOME/.claude-code-bell/play-notification.js notification",
           "description": "Play notification sound for user prompts"
         }
       ],
       "PostToolUse": [
         {
           "command": "node $HOME/.claude-code-bell/play-notification.js toolComplete",
           "description": "Play sound after tool execution (optional)"
         }
       ]
     }
   }
   ```

### Testing

Test the plugin immediately after installation:

```bash
# Test completion sound
node ~/.claude-code-bell/play-notification.js completion

# Test error sound
node ~/.claude-code-bell/play-notification.js error

# Test notification sound
node ~/.claude-code-bell/play-notification.js notification
```

## ⚙️ Configuration

### Basic Configuration

Run the interactive configuration tool:
```bash
node ~/.claude-code-bell/configure.js
```

### Manual Configuration

Edit `~/.claude-code-bell/config.json`:

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

### Custom Sounds

Replace the WAV files in `~/.claude-code-bell/sounds/` with your own sounds:
- `completion.wav` - task completion
- `error.wav` - operation failure
- `notification.wav` - user prompt
- `tool-complete.wav` - tool execution completion

## 🛠️ Development

### Project Structure

```
claude-bell/
├── README.md                 # This file
├── README_CN.md              # Chinese README
├── install.sh               # Installation script
├── uninstall.sh             # Uninstallation script
├── config.json              # Default configuration
└── src/                     # Source code
    ├── config-manager.js
    ├── notification-player.js
    ├── play-notification.js
    └── sounds/               # Audio files
        ├── completion.wav
        ├── error.wav
        ├── notification.wav
        └── tool-complete.wav
    ├── config-manager.js
    ├── notification-player.js
    └── play-notification.js
```

### Manual Installation

1. **Copy files**:
   ```bash
   mkdir -p ~/.claude-code-bell/sounds
   cp src/*.js ~/.claude-code-bell/
   cp src/sounds/*.wav ~/.claude-code-bell/sounds/
   cp config.json ~/.claude-code-bell/
   chmod +x ~/.claude-code-bell/*.js
   ```

2. **Configure hooks** as shown in Quick Start

## 🧹 Uninstallation

### Automatic Removal
```bash
bash uninstall.sh
```

### Manual Removal
```bash
# Remove plugin directory
rm -rf ~/.claude-code-bell

# Remove from Claude Code hooks
# Edit ~/.claude-code/settings.json and remove bell plugin entries from the hooks section
```

## 🔧 Troubleshooting

### No Sound
- Check system volume
- Verify `enabled: true` in config.json
- Test with manual commands
- Ensure audio permissions are granted

### Plugin Not Working
- Verify Claude Code hooks are configured
- Check if Node.js is installed: `which node`
- Run test commands to verify functionality
- Restart Claude Code after configuration changes

### Path Issues
- Ensure paths are correct in hooks.toml
- Check file permissions: `ls -la ~/.claude-code-bell/`
- Verify Node.js executable path

## 📋 Requirements

- Node.js 16+ (for audio playback)
- Claude Code with hooks support
- Audio system (speakers/headphones)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.

## 🌐 International

For Chinese documentation, see [README_CN.md](README_CN.md)