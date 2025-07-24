#!/bin/bash

# Claude Code Bell Plugin Uninstall Script
# This script safely removes the plugin and cleans up Claude Code hooks

set -e

echo "🔕 Uninstalling Claude Code Bell Plugin..."

# Configuration
PLUGIN_DIR="$HOME/.claude-code-bell"
CLAUDE_SETTINGS_FILE="$HOME/.claude/settings.json"
CLAUDE_BACKUP_FILE="$HOME/.claude/settings.json.backup.$(date +%Y%m%d_%H%M%S)"

# Function to check if file exists
file_exists() {
    [ -f "$1" ]
}

# Function to backup settings file
backup_settings() {
    if file_exists "$CLAUDE_SETTINGS_FILE"; then
        echo "💾 Backing up settings.json to $CLAUDE_BACKUP_FILE"
        cp "$CLAUDE_SETTINGS_FILE" "$CLAUDE_BACKUP_FILE"
    fi
}

# Function to remove bell-related hooks
cleanup_hooks() {
    if file_exists "$CLAUDE_SETTINGS_FILE"; then
        echo "🧹 Cleaning up Claude Code hooks..."
        
        # Backup original settings
        cp "$CLAUDE_SETTINGS_FILE" "$CLAUDE_SETTINGS_FILE.backup"
        
        # Use Node.js to safely remove hooks (if available)
        if command -v node >/dev/null 2>&1; then
            node -e "
            const fs = require('fs');
            const path = require('path');
            
            try {
                const settings = JSON.parse(fs.readFileSync('$CLAUDE_SETTINGS_FILE', 'utf8'));
                let modified = false;
                
                if (settings.hooks) {
                    // Remove bell plugin hooks
                    const events = ['Stop', 'Notification', 'PostToolUse'];
                    events.forEach(event => {
                        if (settings.hooks[event]) {
                            const originalLength = settings.hooks[event].length;
                            settings.hooks[event] = settings.hooks[event].filter(hook => 
                                !hook.command || !hook.command.includes('.claude-code-bell')
                            );
                            if (settings.hooks[event].length !== originalLength) {
                                modified = true;
                            }
                            
                            // Remove empty arrays
                            if (settings.hooks[event].length === 0) {
                                delete settings.hooks[event];
                                modified = true;
                            }
                        }
                    });
                    
                    // Remove empty hooks object
                    if (Object.keys(settings.hooks).length === 0) {
                        delete settings.hooks;
                        modified = true;
                    }
                }
                
                if (modified) {
                    fs.writeFileSync('$CLAUDE_SETTINGS_FILE', JSON.stringify(settings, null, 2));
                    console.log('✅ Claude Code hooks cleaned');
                } else {
                    console.log('ℹ️  No bell plugin hooks found to remove');
                }
                
                fs.unlinkSync('$CLAUDE_SETTINGS_FILE.backup');
            } catch (error) {
                console.error('Error cleaning hooks:', error.message);
                fs.renameSync('$CLAUDE_SETTINGS_FILE.backup', '$CLAUDE_SETTINGS_FILE');
            }
            "
        else
            # Fallback: use sed to remove hooks (less precise)
            if grep -q 'claude-code-bell\|play-notification\.js' "$CLAUDE_SETTINGS_FILE"; then
                sed -i.backup '/claude-code-bell\|play-notification\.js/d' "$CLAUDE_SETTINGS_FILE"
                echo "✅ Claude Code hooks cleaned (using sed)"
            else
                echo "ℹ️  No bell plugin hooks found to remove"
            fi
        fi
    else
        echo "ℹ️  Claude Code settings.json not found - nothing to clean"
    fi
}

# Function to remove plugin files
remove_plugin() {
    if [ -d "$PLUGIN_DIR" ]; then
        echo "🗑️  Removing plugin files from $PLUGIN_DIR..."
        rm -rf "$PLUGIN_DIR"
        echo "✅ Plugin files removed"
    else
        echo "ℹ️  Plugin directory not found - already removed?"
    fi
}

# Function to show post-uninstall instructions
show_instructions() {
    echo ""
    echo "🎉 Claude Code Bell Plugin successfully uninstalled!"
    echo ""
    
    if file_exists "$CLAUDE_BACKUP_FILE"; then
        echo "💾 Backup saved: $CLAUDE_BACKUP_FILE"
        echo "   You can restore your previous settings with:"
        echo "   cp \"$CLAUDE_BACKUP_FILE\" \"$CLAUDE_SETTINGS_FILE\""
    fi
    
    echo ""
    echo "🔄 Next steps:"
    echo "1. Restart Claude Code to apply changes"
    echo "2. Run '/hooks' in Claude Code to verify configuration"
    echo ""
    echo "📋 To reinstall later, run: bash install.sh"
    echo ""
}

# Function to check if Claude Code is running
check_claude_running() {
    if pgrep -f "claude" > /dev/null; then
        echo "⚠️  WARNING: Claude Code appears to be running"
        echo "   Please restart Claude Code after uninstall to apply changes"
    fi
}

# Main uninstall process
main() {
    echo "=================================="
    echo " Claude Code Bell Plugin Uninstall"
    echo "=================================="
    echo ""
    
    # Confirm uninstall
    read -p "Are you sure you want to uninstall Claude Code Bell Plugin? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Uninstall cancelled"
        exit 0
    fi
    
    # Check if Claude is running
    check_claude_running
    
    # Perform uninstall
    backup_settings
    cleanup_hooks
    remove_plugin
    
    # Show completion message
    show_instructions
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --force     Skip confirmation prompt"
        echo "  --help      Show this help message"
        echo ""
        exit 0
        ;;
    --force|-f)
        echo "Force mode enabled - skipping confirmation"
        backup_settings
        cleanup_hooks
        remove_plugin
        show_instructions
        exit 0
        ;;
    *)
        main
        ;;
esac