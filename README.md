# KDE Plasma Browser Switcher

<p align="center">
  <img src="package/contents/icon.png" alt="Browser Switcher Logo" width="128" height="128">
</p>

<p align="center">
  <strong>One-click default browser switching from the KDE Plasma panel</strong>
</p>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#features">Features</a> •
  <a href="#requirements">Requirements</a> •
  <a href="#development">Development</a> •
  <a href="#support">Support</a>
</p>

---

## Features

| Feature | Description |
|---------|-------------|
| 🚀 Simple & Fast | One-click browser switching |
| 🎯 Zero Configuration | Works out of the box |
| 🪶 Lightweight | No external dependencies |
| 🔄 Auto-Detection | Finds all installed browsers automatically |
| 🎨 Native Integration | Matches KDE Plasma design |
| ⚡ Non-Blocking | Async operations for smooth performance |

### Use Case

Perfect for users who work with different browser profiles for different tasks — for example, separate work and personal SSO authentication.

<p align="center">
  <img src="screenshots/up_dark.png" alt="Dark Theme" width="280">
  &nbsp;&nbsp;
  <img src="screenshots/up_white.png" alt="Light Theme" width="280">
</p>

---

## Installation

### From KDE Store (Recommended)

**https://www.pling.com/p/2342330/**

Or via Plasma UI:
1. Right-click desktop → **"Add Widgets..."**
2. Click **"Get New Widgets..."** → **"Download New Plasma Widgets..."**
3. Search for **"Browser Switcher"**

### Manual Installation

1. Download the latest release from [Releases](https://github.com/totoshko88/browser-switcher-plasmoid/releases)

2. Install and enable:
   ```bash
   kpackagetool6 -t Plasma/Applet -i browser-switcher-*.plasmoid
   ```

3. Add widget to panel or desktop

### Uninstallation

```bash
kpackagetool6 -t Plasma/Applet -r org.kde.plasma.browserswitcher
```

---

## Requirements

- KDE Plasma 6.0 or later
- Wayland or X11
- `xdg-settings` (usually pre-installed via `xdg-utils`)

---

## How It Works

**Browser Detection:** Scans XDG directories for `.desktop` files with `WebBrowser` category:
- `/usr/share/applications/`
- `~/.local/share/applications/`
- Flatpak and Snap application directories

**Default Browser Management:** Uses `xdg-settings` for cross-desktop compatibility.

---

## Development

### Local Testing

```bash
# Test in a window
plasmawindowed org.kde.plasma.browserswitcher

# Or use plasmoidviewer
plasmoidviewer -a org.kde.plasma.browserswitcher
```

### Building Release

```bash
cd package
zip -r ../browser-switcher.plasmoid . -x "*.git*"
```

### Contributing

Contributions welcome! Please ensure:
- Code follows KDE QML style guidelines
- Test on both Wayland and X11
- Test with Plasma 6.0+

---

## Support

If you find this extension useful, consider supporting development:

[![Ko-Fi](https://img.shields.io/badge/Ko--Fi-Support-ff5e5b?logo=ko-fi)](https://ko-fi.com/totoshko88)
[![PayPal](https://img.shields.io/badge/PayPal-Donate-00457C?logo=paypal)](https://www.paypal.com/qrcodes/p2pqrc/JJLUXRZSQ5V3A)
[![Monobank](https://img.shields.io/badge/Monobank-UAH-black)](https://send.monobank.ua/jar/2UgaGcQ3JC)


---

## License

GPL-3.0 — Made with ❤️ in Ukraine 🇺🇦
