#!/bin/bash
# HackShell Startup Script

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/config.conf"

# Load configuration if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Default values
    THEME="hacker"
fi

# Launch the theme
THEME_FILE="$SCRIPT_DIR/themes/$THEME.bashrc"
if [ -f "$THEME_FILE" ]; then
    # We use exec to replace the current shell with a new one using the theme
    # This ensures the theme variables and prompt are active in the interactive session
    exec bash --rcfile "$THEME_FILE"
else
    echo "Theme file not found: $THEME_FILE"
    echo "Falling back to default shell"
    exec bash
fi
