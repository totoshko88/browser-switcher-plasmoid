#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Browser Switcher for KDE Plasma - Installation Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/package"
PLASMOID_ID="org.kde.plasma.browserswitcher"

echo "🌐 Browser Switcher for KDE Plasma"
echo "=================================="
echo ""

# Check if kpackagetool6 is available (Plasma 6)
if command -v kpackagetool6 &> /dev/null; then
    KPACKAGETOOL="kpackagetool6"
elif command -v kpackagetool5 &> /dev/null; then
    KPACKAGETOOL="kpackagetool5"
    echo "⚠️  Warning: Using kpackagetool5. This plasmoid is designed for Plasma 6."
else
    echo "❌ Error: kpackagetool not found. Please install plasma-framework."
    exit 1
fi

echo "Using: $KPACKAGETOOL"
echo ""

# Check if already installed
if $KPACKAGETOOL -t Plasma/Applet -l 2>/dev/null | grep -q "$PLASMOID_ID"; then
    echo "📦 Updating existing installation..."
    $KPACKAGETOOL -t Plasma/Applet -u "$PACKAGE_DIR"
else
    echo "📦 Installing plasmoid..."
    $KPACKAGETOOL -t Plasma/Applet -i "$PACKAGE_DIR"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "To add the widget:"
echo "  1. Right-click on your panel or desktop"
echo "  2. Select 'Add Widgets...'"
echo "  3. Search for 'Browser Switcher'"
echo "  4. Drag it to your panel or desktop"
echo ""
echo "To test in a window:"
echo "  plasmawindowed $PLASMOID_ID"
echo ""
