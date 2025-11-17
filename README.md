<div align="center">
  <img width="150" height="150" src="/Resources/icon/icon.png" alt="SettingsKit Icon">
  <h1><b>SettingsKit</b></h1>
  <p>
    A declarative SwiftUI framework for building settings interfaces with navigation, search, and customizable styling.
  </p>
</div>

<p align="center">
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-17%2B-blue.svg" alt="iOS 17+"></a>
  <a href="https://developer.apple.com/macOS/"><img src="https://img.shields.io/badge/macOS-14%2B-blue.svg" alt="macOS 14+"></a>
  <a href="https://developer.apple.com/watchOS/"><img src="https://img.shields.io/badge/watchOS-10%2B-blue.svg" alt="watchOS 10+"></a>
  <a href="https://developer.apple.com/tvOS/"><img src="https://img.shields.io/badge/tvOS-17%2B-blue.svg" alt="tvOS 17+"></a>
  <a href="https://developer.apple.com/visionOS/"><img src="https://img.shields.io/badge/visionOS-1%2B-blue.svg" alt="visionOS 1+"></a>
  <a href="https://swift.org/"><img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT"></a>
</p>

SettingsKit provides a declarative API for building settings interfaces that feel native to iOS and macOS. Define your settings hierarchy with simple, composable building blocks, and get automatic support for navigation, search, and multiple presentation styles out of the box.

<img width="1200" height="675" alt="Example" src="https://github.com/user-attachments/assets/53f3a6e3-9145-4671-a0dc-b182d79ce9e7" />

## Features

- **Declarative API** - Build settings hierarchies with intuitive SwiftUI-style syntax
- **Built-in Search** - Automatic search functionality with intelligent filtering and scoring
- **Multiple Styles** - Choose from sidebar, grouped, card, or default presentation styles
- **Customizable** - Extend with custom styles and search implementations
- **Platform Adaptive** - Works seamlessly on iOS and macOS with appropriate navigation patterns

## Installation

### Swift Package Manager

Add SettingsKit to your project through Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL
```
https://github.com/aeastr/SettingsKit.git
```
4. Select the version you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/aeastr/SettingsKit.git", from: "1.0.0")
]
```

## Quick Start

```swift
import SwiftUI
import SettingsKit

@Observable
class AppSettings {
    var notificationsEnabled = true
    var darkMode = false
    var username = "Guest"
    var fontSize: Double = 14.0
    var soundEnabled = true
    var autoLockDelay: Double = 300
    var hardwareAcceleration = true
    // ... 20+ more settings
}

struct MySettings: SettingsContainer {
    @Environment(AppSettings.self) var appSettings

    var settingsBody: some SettingsContent {
        @Bindable var settings = appSettings

        SettingsGroup("General", systemImage: "gear") {
            SettingsItem("Notifications") {
                Toggle("Enable", isOn: $settings.notificationsEnabled)
            }
            
            SettingsItem("Dark Mode") {
                Toggle("Enable", isOn: $settings.darkMode)
            }
        }
        
        SettingsGroup("Appearance", systemImage: "paintbrush") {
            SettingsItem("Font Size") {
                Slider(value: $settings.fontSize, in: 10...24, step: 1) {
                    Text("Size: \(Int(settings.fontSize))pt")
                }
            }
        }
        
        SettingsGroup("Privacy & Security", systemImage: "lock.shield") {
            SettingsItem("Auto Lock Delay") {
                Slider(value: $settings.autoLockDelay, in: 60...3600, step: 60) {
                    Text("Delay: \(Int(settings.autoLockDelay/60)) minutes")
                }
            }
        }
        
        // ... more groups
    }
}
```

## Core Concepts

### Settings Container

A `SettingsContainer` is the root of your settings hierarchy:

```swift
struct AppSettings: SettingsContainer {
    var settingsBody: some SettingsContent {
        // Your settings groups here
    }
}
```

### Settings Groups

Groups organize related settings and can be presented as navigation links or inline sections:

```swift
// Navigation group (default) - appears as a tappable row
SettingsGroup("Display", systemImage: "sun.max") {
    // Settings items...
}

// Inline group - appears as a section header
SettingsGroup("Quick Settings", .inline) {
    // Settings items...
}
```

### Settings Items

Items are the individual settings within a group:

```swift
SettingsItem("Volume") {
    Slider(value: $volume, in: 0...100)
}

SettingsItem("Auto-Lock", icon: "lock") {
    Picker("", selection: $autoLockTime) {
        Text("30 seconds").tag(30)
        Text("1 minute").tag(60)
    }
}
```

### Nested Navigation

Groups can contain other groups for deep hierarchies:

```swift
SettingsGroup("General", systemImage: "gear") {
    SettingsGroup("About", systemImage: "info.circle") {
        SettingsItem("Version") {
            Text("1.0.0")
        }
    }

    SettingsGroup("Language", systemImage: "globe") {
        SettingsItem("Preferred Language") {
            Text("English")
        }
    }
}
```

## Built-in Styles

### Sidebar Style (Default)

Perfect for apps with split-view navigation (default on all platforms):

```swift
MySettings(settings: settings)
    .settingsStyle(.sidebar)
```

### Single Column Style

Clean, single-column list presentation:

```swift
MySettings(settings: settings)
    .settingsStyle(.single)
```

## Custom Styles

Create your own presentation styles by conforming to `SettingsStyle`:

```swift
struct MyCustomStyle: SettingsStyle {
    func makeContainer(configuration: ContainerConfiguration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    configuration.content
                }
                .padding()
            }
            .navigationTitle(configuration.title)
        }
    }

    func makeGroup(configuration: GroupConfiguration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(.headline)
            configuration.content
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    func makeItem(configuration: ItemConfiguration) -> some View {
        HStack {
            configuration.label
            Spacer()
            configuration.content
        }
    }
}

// Apply your custom style
MySettings(settings: settings)
    .settingsStyle(MyCustomStyle())
```

## Search

Search is automatic and intelligent, filtering by titles and tags:

### Adding Search Tags

Improve search discoverability with tags:

```swift
SettingsGroup("Notifications", systemImage: "bell")
    .settingsTags(["alerts", "sounds", "badges"])
```

### Custom Search

Implement your own search logic:

```swift
struct FuzzySearch: SettingsSearch {
    func search(nodes: [SettingsNode], query: String) -> [SettingsSearchResult] {
        // Your custom search implementation
    }
}

MySettings(settings: settings)
    .settingsSearch(FuzzySearch())
```

## Advanced Features

### Extracted Settings Groups

Extract complex groups into separate structures:

```swift
struct DeveloperSettings: SettingsContent {
    @Bindable var settings: AppSettings

    var body: some SettingsContent {
        SettingsGroup("Developer", systemImage: "hammer") {
            SettingsItem("Debug Mode") {
                Toggle("Enable", isOn: $settings.debugMode)
            }

            if settings.debugMode {
                SettingsItem("Verbose Logging") {
                    Toggle("Enable", isOn: $settings.verboseLogging)
                }
            }
        }
    }
}

// Use it in your main settings
var settingsBody: some SettingsContent {
    // Other groups...

    DeveloperSettings(settings: settings)
}
```

### Conditional Content

Show or hide settings based on state:

```swift
SettingsGroup("Advanced", systemImage: "gearshape.2") {
    SettingsItem("Enable Advanced Features") {
        Toggle("Enable", isOn: $showAdvanced)
    }

    if showAdvanced {
        SettingsItem("Advanced Option 1") { /* ... */ }
        SettingsItem("Advanced Option 2") { /* ... */ }
    }
}
```

### Non-Searchable Items

Mark items as non-searchable when they're not useful in search results:

```swift
SettingsItem("Current Status", searchable: false) {
    Text("Connected")
        .foregroundStyle(.secondary)
}
```

## Platform Differences

### iOS
- Uses `NavigationStack` for navigation
- Supports search with `.searchable()`
- Inline groups render as section headers

### macOS
- Uses `NavigationSplitView` for sidebar navigation
- Selection-based navigation for sidebar items
- Detail pane has its own `NavigationStack` for deeper navigation

## Requirements

- iOS 17.0+ / macOS 14.0+ / watchOS 10.0+ / tvOS 17.0+ / visionOS 1.0+
- Swift 6.0+
- Xcode 16.0+

## License

SettingsKit is available under the MIT license. See the LICENSE file for more info.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

