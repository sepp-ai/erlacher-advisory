#!/bin/bash

# Maintenance Mode Toggle Script
# Usage: ./scripts/maintenance-mode.sh [on|off]

set -e

MAINTENANCE_FILE="maintenance.html"
INDEX_FILE="index.html"
BACKUP_FILE="index.html.backup"

function enable_maintenance() {
    echo "🔄 Enabling maintenance mode..."
    
    # Create backup of current index.html if it doesn't exist
    if [ ! -f "$BACKUP_FILE" ]; then
        cp "$INDEX_FILE" "$BACKUP_FILE"
        echo "✅ Created backup of current index.html"
    fi
    
    # Replace index.html with maintenance page
    cp "$MAINTENANCE_FILE" "$INDEX_FILE"
    echo "✅ Maintenance mode enabled"
    echo "📧 Contact email: roman@erlacher-advisory.com"
}

function disable_maintenance() {
    echo "🔄 Disabling maintenance mode..."
    
    if [ -f "$BACKUP_FILE" ]; then
        # Restore original index.html
        cp "$BACKUP_FILE" "$INDEX_FILE"
        echo "✅ Normal mode restored from backup"
    else
        echo "❌ No backup found. Please restore index.html manually."
        exit 1
    fi
}

function show_status() {
    if [ -f "$BACKUP_FILE" ]; then
        echo "📊 Status: Maintenance mode is available (backup exists)"
    else
        echo "📊 Status: Normal mode (no backup found)"
    fi
    
    if grep -q "Website in Wartung" "$INDEX_FILE" 2>/dev/null; then
        echo "🔧 Current state: MAINTENANCE MODE"
    else
        echo "🌐 Current state: NORMAL MODE"
    fi
}

# Main script logic
case "${1:-status}" in
    "on"|"enable")
        enable_maintenance
        ;;
    "off"|"disable")
        disable_maintenance
        ;;
    "status")
        show_status
        ;;
    *)
        echo "Usage: $0 [on|off|status]"
        echo ""
        echo "Commands:"
        echo "  on, enable   - Enable maintenance mode"
        echo "  off, disable - Disable maintenance mode"
        echo "  status       - Show current status (default)"
        echo ""
        show_status
        ;;
esac 