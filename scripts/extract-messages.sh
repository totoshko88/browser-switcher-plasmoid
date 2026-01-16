#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Extract translatable strings from QML files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGE_DIR="$PROJECT_DIR/package/contents"
OUTPUT_FILE="$PACKAGE_DIR/locale/template.pot"

echo "Extracting translatable strings..."

# Use xgettext to extract i18n() calls from QML files
xgettext \
    --from-code=UTF-8 \
    --language=JavaScript \
    --keyword=i18n:1 \
    --keyword=i18nc:1c,2 \
    --keyword=i18np:1,2 \
    --keyword=i18ncp:1c,2,3 \
    --package-name="org.kde.plasma.browserswitcher" \
    --package-version="1.2.0" \
    --msgid-bugs-address="https://github.com/totoshko88/browser-switcher-plasmoid/issues" \
    --output="$OUTPUT_FILE" \
    "$PACKAGE_DIR/ui/"*.qml \
    "$PACKAGE_DIR/config/"*.qml \
    2>/dev/null

if [ $? -eq 0 ]; then
    echo "Translation template created: $OUTPUT_FILE"
else
    echo "Note: xgettext not found or failed. Manual template.pot is available."
fi
