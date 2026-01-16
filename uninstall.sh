#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Browser Switcher for KDE Plasma - Uninstallation Script

set -e

PLASMOID_ID="org.kde.plasma.browserswitcher"

echo "🌐 Browser Switcher for KDE Plasma - Uninstall"
echo "=============================================="
echo ""

# Check if kpackagetool6 is available (Plasma 6)
if command -v kpackagetool6 &> /dev/null; then
    KPACKAGETOOL="kpackagetool6"
elif command -v kpackagetool5 &> /dev/null; then
    KPACKAGETOOL="kpackagetool5"
else
    echo "❌ Error: kpackagetool not found."
    exit 1
fi

echo "Using: $KPACKAGETOOL"
echo ""

# Check if installed
if $KPACKAGETOOL -t Plasma/Applet -l 2>/dev/null | grep -q "$PLASMOID_ID"; then
    echo "📦 Removing plasmoid..."
    $KPACKAGETOOL -t Plasma/Applet -r "$PLASMOID_ID"
    echo ""
    echo "✅ Uninstallation complete!"
else
    echo "ℹ️  Plasmoid is not installed."
fi
