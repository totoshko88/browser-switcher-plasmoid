# Changelog

All notable changes to Browser Switcher will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-01-17

### Added
- Configuration panel with customizable settings
- "Launch Browser" button in popup footer
- Flatpak/Snap browser type labels
- Translation template (.pot file) for i18n support
- Retry logic for transient switching failures
- Notifications for external browser changes and errors
- GitHub Actions CI/CD for automated releases

### Changed
- Updated to modern QML optional chaining syntax

### Fixed
- Configuration page (was empty placeholder)
- Context menu actions using correct PlasmaCore.Action type

## [1.1.0] - 2025-01-15

### Added
- Keyboard navigation (arrow keys, Enter, Esc)
- Browser list caching for faster startup
- "Configure Default Applications" button and context menu
- System tray support (`X-Plasma-NotificationArea`)
- Command execution timeout (10s) with error recovery
- Visual feedback for just-selected browser

### Changed
- Reduced refresh interval from 60s to 5 minutes

### Fixed
- Icon transition animation

## [1.0.0] - 2025-01-10

### Added
- Initial release
- One-click browser switching
- Auto-detection of installed browsers
- Native KDE Plasma 6 integration
- Support for system, Flatpak, and Snap browsers
