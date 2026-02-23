# Paster

A modern, lightweight clipboard manager for macOS built with SwiftUI.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Clipboard History** — Automatically saves everything you copy (text, images, links, files, code)
- **Instant Search** — Quickly find any item in your clipboard history
- **Smart Detection** — Automatically detects content type (URLs, code snippets, plain text)
- **Syntax Highlighting** — Code snippets are displayed with proper syntax highlighting
- **Image Preview** — View copied images directly in the app
- **Link Preview** — See URL previews for copied links
- **Pin Items** — Keep important clips always accessible
- **Categories** — Organize clips with custom categories
- **Floating Panel** — Access your clipboard history with `Cmd+Shift+V`
- **Menu Bar App** — Lives quietly in your menu bar
- **Auto Cleanup** — Optionally remove old clips after a configurable period
- **Launch at Login** — Start automatically when you log in

## Screenshots

<!-- Add screenshots here -->

## Installation

### Requirements

- macOS 14.0 (Sonoma) or later

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/elmiliano41/Paster.git
   cd Paster
   ```

2. Open in Xcode:
   ```bash
   open Paster.xcodeproj
   ```

3. Build and run (`Cmd+R`)

## Usage

### Quick Access

Press `Cmd+Shift+V` to open the floating panel from anywhere.

### Menu Bar

Click the clipboard icon in the menu bar to access quick options.

### Managing Clips

- **Double-click** — Copy item back to clipboard
- **Right-click** — Access context menu (copy, pin, delete)
- **Pin** — Keep important items at the top

### Settings

Access settings from the menu bar icon → Settings, or use `Cmd+,`

- **Max History Items** — Configure how many items to keep (50-5000)
- **Auto Cleanup** — Automatically delete items older than 7/14/30/60/90 days
- **Launch at Login** — Start Paster when you log in
- **Custom Hotkey** — Change the keyboard shortcut

## Architecture

```
Paster/
├── PasterApp.swift          # App entry point
├── AppDelegate.swift        # App lifecycle, floating panel management
├── Models/
│   ├── ClipItem.swift       # Clipboard item model
│   ├── ClipItemType.swift   # Content type enum
│   └── Category.swift       # Category model
├── Services/
│   ├── DataStore.swift      # Persistence layer (JSON)
│   ├── ClipboardMonitor.swift # System clipboard monitoring
│   ├── HotKeyManager.swift  # Global hotkey handling
│   ├── PasteService.swift   # Copy/paste operations
│   └── SyntaxDetector.swift # Code language detection
├── Views/
│   ├── FloatingPanel/       # Main floating panel UI
│   ├── MenuBar/             # Menu bar views
│   ├── Settings/            # Settings views
│   ├── Previews/            # Content preview views
│   └── Components/          # Reusable UI components
└── Utils/
    ├── Constants.swift      # App constants
    └── Extensions.swift     # Swift extensions
```

## Tech Stack

- **SwiftUI** — Modern declarative UI framework
- **Observation** — Swift's native observation framework (iOS 17+)
- **AppKit** — NSPasteboard monitoring, NSPanel for floating window
- **ServiceManagement** — Launch at login functionality

## Privacy

Paster stores all clipboard data locally on your Mac in `~/Library/Application Support/Paster/`. No data is ever sent to external servers.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License — see [LICENSE](LICENSE) for details.

## Author

Made with SwiftUI by [elmiliano41](https://github.com/elmiliano41)
