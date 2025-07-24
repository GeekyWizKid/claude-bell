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
        
        # First, backup the original
        cp "$CLAUDE_HOOKS_FILE" "$CLAUDE_HOOKS_FILE.backup"
        
        # Use a simpler approach: grep out lines that contain bell plugin references
        # and their associated hooks blocks
        
        # First, find line numbers of hooks blocks that contain bell references
        local bell_lines=$(grep -n 'claude-code-bell\|play-notification\.js\|\.claude-code-bell' "$CLAUDE_HOOKS_FILE" | cut -d: -f1)
        
        if [ -n "$bell_lines" ]; then
            echo "🧹 Removing bell plugin hooks..."
            
            # Create a new file without the problematic hooks
            local current_line=1
            local skip_start=0
            local skip_end=0
            
            # Process file line by line
            while IFS= read -r line; do
                if [[ "$line" =~ ^\[\[hooks\]\] ]]; then
                    # Start of a new hooks block
                    local block_end=$(tail -n +$current_line "$CLAUDE_HOOKS_FILE" | grep -n '^\[\[' | tail -n +2 | head -n1 | cut -d: -f1)
                    if [ -z "$block_end" ]; then
                        block_end=$(wc -l < "$CLAUDE_HOOKS_FILE")
                        block_end=$((block_end - current_line + 1))
                    else
                        block_end=$((block_end + current_line - 1))
                    fi
                    
                    # Check if this block contains bell references
                    local block_start=$current_line
                    local block_content=$(sed -n "${block_start},${block_end}p" "$CLAUDE_HOOKS_FILE")
                    if echo "$block_content" | grep -q 'claude-code-bell\|play-notification\.js\|\.claude-code-bell'; then
                        # Skip this block
                        skip_start=$block_start
                        skip_end=$block_end
                        current_line=$((block_end + 1))
                        continue
                    fi
                fi
                
                if [ $current_line -lt $skip_start ] || [ $current_line -gt $skip_end ]; then
                    echo "$line"
                fi
                
                current_line=$((current_line + 1))
            done < "$CLAUDE_HOOKS_FILE" > "$CLAUDE_HOOKS_FILE.clean"
            
            # Clean up empty lines and check if file has content
            grep -v '^[[:space:]]*$' "$CLAUDE_HOOKS_FILE.clean" > "$CLAUDE_HOOKS_FILE.final" 2>/dev/null
            
            if [ -s "$CLAUDE_HOOKS_FILE.final" ]; then
                mv "$CLAUDE_HOOKS_FILE.final" "$CLAUDE_HOOKS_FILE"
                rm -f "$CLAUDE_HOOKS_FILE.backup" "$CLAUDE_HOOKS_FILE.clean"
                echo "✅ Claude Code hooks cleaned"
            else
                rm -f "$CLAUDE_HOOKS_FILE.final" "$CLAUDE_HOOKS_FILE.clean" "$CLAUDE_HOOKS_FILE"
                echo "🗑️  hooks.toml removed (no content left)"
            fi
        else
            # No bell plugin references found, keep the file as-is
            rm -f "$CLAUDE_HOOKS_FILE.backup" "$CLAUDE_HOOKS_FILE.clean"
            echo "ℹ️  No bell plugin hooks found to remove"
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