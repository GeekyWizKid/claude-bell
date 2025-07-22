#!/bin/bash

# Claude Code Bell Plugin Uninstall Script
# This script safely removes the plugin and cleans up Claude Code hooks

set -e

echo "🔕 Uninstalling Claude Code Bell Plugin..."

# Configuration
PLUGIN_DIR="$HOME/.claude-code-bell"
CLAUDE_HOOKS_FILE="$HOME/.claude-code/hooks.toml"
BACKUP_FILE="$HOME/.claude-code/hooks.toml.backup.$(date +%Y%m%d_%H%M%S)"

# Function to check if file exists
file_exists() {
    [ -f "$1" ]
}

# Function to backup hooks file
backup_hooks() {
    if file_exists "$CLAUDE_HOOKS_FILE"; then
        echo "💾 Backing up hooks.toml to $BACKUP_FILE"
        cp "$CLAUDE_HOOKS_FILE" "$BACKUP_FILE"
    fi
}

# Function to remove bell-related hooks
cleanup_hooks() {
    if file_exists "$CLAUDE_HOOKS_FILE"; then
        echo "🧹 Cleaning up Claude Code hooks..."
        
        # Create temporary file without bell plugin hooks
        grep -v "claude-code-bell\|play-notification.js" "$CLAUDE_HOOKS_FILE" > "$CLAUDE_HOOKS_FILE.tmp" 2>/dev/null || true
        
        # Only replace if we successfully created the temp file
        if [ -s "$CLAUDE_HOOKS_FILE.tmp" ]; then
            mv "$CLAUDE_HOOKS_FILE.tmp" "$CLAUDE_HOOKS_FILE"
            echo "✅ Claude Code hooks cleaned"
        else
            # If temp file is empty, just remove all bell-related content
            sed '/.*claude-code-bell.*\|.*play-notification.js.*/d' "$CLAUDE_HOOKS_FILE" > "$CLAUDE_HOOKS_FILE.tmp" 2>/dev/null || true
            if [ -s "$CLAUDE_HOOKS_FILE.tmp" ]; then
                mv "$CLAUDE_HOOKS_FILE.tmp" "$CLAUDE_HOOKS_FILE"
                echo "✅ Claude Code hooks cleaned"
            else
                rm -f "$CLAUDE_HOOKS_FILE.tmp"
                echo "⚠️  hooks.toml appears to only contain bell plugin hooks"
                read -p "Remove entire hooks.toml file? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -f "$CLAUDE_HOOKS_FILE"
                    echo "🗑️  hooks.toml removed"
                fi
            fi
        fi
    else
        echo "ℹ️  Claude Code hooks.toml not found - nothing to clean"
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
    
    if file_exists "$BACKUP_FILE"; then
        echo "💾 Backup saved: $BACKUP_FILE"
        echo "   You can restore your previous hooks with:"
        echo "   cp \"$BACKUP_FILE\" \"$CLAUDE_HOOKS_FILE\""
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
    backup_hooks
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
        backup_hooks
        cleanup_hooks
        remove_plugin
        show_instructions
        exit 0
        ;;
    *)
        main
        ;;
esac