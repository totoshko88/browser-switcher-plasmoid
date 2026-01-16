# Browser Switcher for KDE Plasma 6

🚀 Quick default browser switching from the KDE Plasma panel.

![Browser Switcher](screenshots/preview.png)

## Features

| Feature | Description |
|---------|-------------|
| 🚀 Simple & Fast | One-click browser switching |
| 🎯 Zero Configuration | Works out of the box |
| 🪶 Lightweight | No external dependencies |
| 🔄 Auto-Detection | Finds all installed browsers automatically |
| 🎨 Native Integration | Matches KDE Plasma design |
| ⚡ Non-Blocking | Async operations for smooth performance |

## Use Case

Perfect for users who work with different browser profiles for different tasks — for example, separate work and personal SSO authentication.

## Requirements

- KDE Plasma 6.0 or later
- Wayland or X11
- `xdg-settings` (usually pre-installed)

## Installation

### From KDE Store (Recommended)

Coming soon...

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/totoshko88/browser-switcher-kde.git
cd browser-switcher-kde

# Install the plasmoid
./install.sh
```

Or manually:

```bash
# Install to user directory
kpackagetool6 -t Plasma/Applet -i package/

# Or update existing installation
kpackagetool6 -t Plasma/Applet -u package/
```

### Uninstallation

```bash
kpackagetool6 -t Plasma/Applet -r org.kde.plasma.browserswitcher
```

## How It Works

### Browser Detection

Scans XDG directories for `.desktop` files with `WebBrowser` category:
- `/usr/share/applications/`
- `/usr/local/share/applications/`
- `~/.local/share/applications/`
- `/var/lib/snapd/desktop/applications/` (Snap packages)
- `/var/lib/flatpak/exports/share/applications/` (Flatpak system)
- `~/.local/share/flatpak/exports/share/applications/` (Flatpak user)

### Default Browser Management

Uses `xdg-settings` for cross-desktop compatibility:
- `xdg-settings get default-web-browser` - get current default
- `xdg-settings set default-web-browser <browser.desktop>` - set default

## Development

### Testing

```bash
# Test the plasmoid in a window
plasmawindowed org.kde.plasma.browserswitcher

# Or use plasmoidviewer
plasmoidviewer -a org.kde.plasma.browserswitcher
```

### Project Structure

```
browser-switcher-kde/
├── package/
│   ├── metadata.json                 # Plasmoid metadata (Plasma 6)
│   └── contents/
│       ├── icons/
│       │   └── browserswitcher.png   # Widget icon
│       └── ui/
│           ├── main.qml              # Main entry point & logic
│           ├── CompactRepresentation.qml  # Panel icon
│           ├── FullRepresentation.qml     # Popup menu
│           └── BrowserDelegate.qml        # List item delegate
├── install.sh                        # Installation script
├── uninstall.sh                      # Uninstallation script
├── README.md
└── LICENSE
```

## Contributing

Contributions welcome! Please ensure:
- Code follows KDE QML style guidelines
- Test on both Wayland and X11
- Test with Plasma 6.0+

## License

GPL-3.0 — Made with ❤️ in Ukraine 🇺🇦

## Credits

Based on the [GNOME Browser Switcher](https://github.com/totoshko88/browser-switcher) extension.
