#!/bin/bash

# Claude Code Bell Plugin Installation Script
# This script installs the notification plugin for Claude Code and configures hooks

set -e

echo "🛎️  Installing Claude Code Bell Plugin..."

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If running from global npm bin, get the package directory
if [[ "$SCRIPT_DIR" == *".nvm"* ]] || [[ "$SCRIPT_DIR" == *"npm"* ]]; then
    # Find the actual package directory
    SCRIPT_DIR="$(npm root -g)/claude-code-bell-plugin"
fi
PLUGIN_NAME="claude-code-bell"
PLUGIN_DIR="$HOME/.claude-code-bell"

# Create plugin directory
echo "📁 Creating plugin directory: $PLUGIN_DIR"
mkdir -p "$PLUGIN_DIR/sounds"

# Copy files
echo "📋 Copying plugin files..."
cp "$SCRIPT_DIR/src/"*.js "$PLUGIN_DIR/"
cp "$SCRIPT_DIR/src/sounds/"*.mp3 "$PLUGIN_DIR/sounds/" 2>/dev/null || true
cp "$SCRIPT_DIR/src/sounds/"*.wav "$PLUGIN_DIR/sounds/" 2>/dev/null || true
cp "$SCRIPT_DIR/config.json" "$PLUGIN_DIR/"

# Make scripts executable
echo "🔧 Setting permissions..."
chmod +x "$PLUGIN_DIR"/*.js

# Check if Claude Code hooks directory exists
CLAUDE_HOOKS_DIR="$HOME/.claude-code"
CLAUDE_HOOKS_FILE="$CLAUDE_HOOKS_DIR/hooks.toml"

# Auto-configure Claude Code hooks if directory exists
if [ -d "$CLAUDE_HOOKS_DIR" ]; then
    echo "🔗 Configuring Claude Code hooks..."
    
    # Check if hooks.toml exists, create if not
    if [ ! -f "$CLAUDE_HOOKS_FILE" ]; then
        echo "Creating hooks.toml..."
        touch "$CLAUDE_HOOKS_FILE"
    fi
    
    # Check if bell plugin hooks already exist
    if grep -q "claude-code-bell" "$CLAUDE_HOOKS_FILE"; then
        echo "⚠️  Claude Code Bell hooks already configured. Skipping..."
    else
        echo "Adding hooks to $CLAUDE_HOOKS_FILE..."
        cat >> "$CLAUDE_HOOKS_FILE" << EOF

# Claude Code Bell Plugin - Audio notifications
[[hooks]]
event = "Stop"
command = "node $HOME/.claude-code-bell/play-notification.js completion"
description = "Play completion sound when task finishes"

[[hooks]]
event = "Notification"
command = "node $HOME/.claude-code-bell/play-notification.js notification"
description = "Play notification sound for user prompts"

[[hooks]]
event = "PostToolUse"
command = "node $HOME/.claude-code-bell/play-notification.js toolComplete"
description = "Play sound after tool execution (optional)"
EOF
        echo "✅ Hooks configured successfully!"
    fi
else
    echo "⚠️  Claude Code directory not found at $CLAUDE_HOOKS_DIR"
    echo "   Manual configuration required - see instructions below"
fi

# Create configuration CLI
echo "⚙️  Creating configuration CLI..."
cat > "$PLUGIN_DIR/configure.js" << 'EOF'
const ConfigManager = require('./config-manager');
const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const configManager = new ConfigManager();

function askQuestion(question) {
    return new Promise(resolve => {
        rl.question(question, resolve);
    });
}

async function configure() {
    console.log('🛎️  Claude Code Bell Plugin Configuration');
    console.log('=====================================\n');
    
    const currentConfig = configManager.getConfig();
    
    console.log('Current configuration:');
    console.log(JSON.stringify(currentConfig, null, 2));
    console.log('');
    
    const enabled = await askQuestion('Enable notifications? (y/n) [y]: ');
    const volume = await askQuestion('Set volume (0.0-1.0) [0.5]: ');
    
    const newConfig = {
        enabled: enabled.toLowerCase() !== 'n',
        volume: parseFloat(volume) || 0.5
    };
    
    configManager.updateConfig(newConfig);
    
    console.log('\n✅ Configuration updated!');
    console.log('Restart Claude Code for changes to take effect.');
    
    rl.close();
}

if (require.main === module) {
    configure();
}

module.exports = { configure };
EOF

# Link main scripts for easy access
ln -sf "$PLUGIN_DIR/play-notification.js" "$PLUGIN_DIR/bell-completion"
ln -sf "$PLUGIN_DIR/play-notification.js" "$PLUGIN_DIR/bell-notification"
ln -sf "$PLUGIN_DIR/play-notification.js" "$PLUGIN_DIR/bell-error"

# Test installation
echo "🧪 Testing installation..."
if node "$PLUGIN_DIR/play-notification.js" completion; then
    echo "✅ Plugin installation successful!"
else
    echo "❌ Installation test failed"
    exit 1
fi

echo ""
echo "🎉 Claude Code Bell Plugin installed successfully!"
echo ""

if [ -d "$CLAUDE_HOOKS_DIR" ]; then
    echo "✅ Claude Code hooks have been automatically configured!"
    echo "   You can verify by running '/hooks' in Claude Code"
    echo "   Or restart Claude Code if it's currently running"
else
    echo "📋 Manual configuration required:"
    echo "1. In Claude Code, run '/hooks' to open hooks configuration"
    echo "2. Add the following hooks:"
    echo ""
    echo "   Event: Stop"
    echo "   Command: node $HOME/.claude-code-bell/play-notification.js completion"
    echo ""
    echo "   Event: Notification"
    echo "   Command: node $HOME/.claude-code-bell/play-notification.js notification"
fi

echo ""
echo "🔧 Optional configuration: node $PLUGIN_DIR/configure.js"
echo "🔕 To disable: set enabled: false in $PLUGIN_DIR/config.json"