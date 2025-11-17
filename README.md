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

<img width="1280" height="640" alt="githubsocialpreview" src="https://github.com/user-attachments/assets/7d937cbd-182d-4715-b030-fd172a9cdc08" />

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

## How It Works

SettingsKit uses a two-stage architecture to transform your declarative settings into a searchable, navigable interface.

### The Indexing System

When you define settings using `SettingsGroup` and `SettingsItem`, SettingsKit builds an internal **node tree** that represents your entire settings hierarchy. This happens automatically and efficiently:

1. **Declarative Definition** - You write settings using SwiftUI-style syntax
2. **Node Tree Building** - Each element converts to a `SettingsNode` (group or item)
3. **Lazy Indexing** - The tree is built on-demand during rendering or searching
4. **Search & Navigation** - The indexed tree powers both features

#### The Node Tree

Every setting becomes a node in an indexed tree:

```
SettingsNode Tree:
├─ Group: "General" (navigation)
│  ├─ Item: "Notifications"
│  └─ Item: "Dark Mode"
├─ Group: "Appearance" (navigation)
│  └─ Item: "Font Size"
└─ Group: "Privacy & Security" (navigation)
   └─ Item: "Auto Lock Delay"
```

Each node stores:
- **UUID** - Unique identifier for navigation and identity
- **Title & Icon** - Display information
- **Tags** - Additional keywords for search
- **Presentation Mode** - Navigation link or inline section
- **Children** - Nested groups and items (for groups)

#### How Search Works

The default search implementation uses intelligent scoring:

1. **Normalization** - Removes spaces, special characters, converts to lowercase
2. **Scoring** - Ranks matches by relevance:
   - Exact match: 1000 points
   - Starts with: 500 points
   - Contains: 300 points
   - Tag match: 100 points
3. **Tree Traversal** - Recursively searches all nodes
4. **Result Grouping** - Groups matched items by their parent group

This means searching "notif" finds "Notifications", and tags like `["alerts", "sounds"]` make items discoverable through alternative keywords.

#### Navigation Architecture

SettingsKit provides two navigation styles that work with the same indexed tree:

**Sidebar Style (NavigationSplitView)**:
- Split-view layout with sidebar and detail pane
- Top-level groups appear in the sidebar
- Selection-based navigation
- On macOS: detail pane has its own NavigationStack for nested groups
- On iOS: uses NavigationSplitView's built-in navigation

**Single Column Style (NavigationStack)**:
- Push navigation for all groups
- Linear navigation hierarchy
- Inline groups render as section headers
- Search results push onto the navigation stack

The node tree's awareness of **navigation vs. inline presentation** ensures groups render correctly in both styles.

### Why This Design?

- **Performance** - Lazy indexing builds the tree only when needed
- **Dynamic Content** - Supports conditional settings (if/else, ForEach)
- **Powerful Search** - Entire hierarchy is searchable with one index
- **Extensibility** - Custom search and styles work with the same tree
- **Type Safety** - SwiftUI result builders validate at compile time

## Platform Differences

### iOS
- Uses `NavigationStack` for navigation
- Supports search with `.searchable()`
- Inline groups render as section headers

### macOS
- Uses `NavigationSplitView` for sidebar navigation
- Selection-based navigation for sidebar items
- Detail pane has its own `NavigationStack` for deeper navigation

## Known Issues

### macOS Control Update Issue (Sidebar Style)

When using the **Sidebar Style** on macOS, there is a known issue where interactive controls (Toggle, Slider, TextField, Picker, etc.) in the detail view don't visually update when interacted with, even though the underlying state changes correctly.

**Symptoms:**
- Controls appear frozen/unresponsive visually
- The actual state behind the controls does update (verified by observing state values elsewhere)
- The sidebar renders updates properly
- Issue only affects macOS; iOS/iPadOS work correctly

**Current Workaround:**
The Sidebar Style uses different navigation approaches on macOS vs iOS to work around this issue:
- **macOS**: Destination-based navigation (creates fresh view hierarchies)
- **iOS**: Selection-based navigation (no issues observed)

**Suspected Causes (Unconfirmed):**
1. **AnyView type erasure** - Content is wrapped in `AnyView` for type erasure in the node system
2. **Node-based rendering** - Rendering from cached node content rather than directly from view hierarchy
3. **macOS NavigationSplitView caching** - macOS may aggressively cache detail column content

**Ongoing Investigation:**
The `refactor/nodes-metadata-only` branch explores an architectural change that removes `AnyView` content from nodes entirely, making them metadata-only for indexing/search while rendering directly from the view hierarchy. This may resolve the root cause but requires significant refactoring.

See `Sources/SettingsKit/Styles/SidebarSettingsStyle.swift` for detailed implementation comments.

**Alternative:**
If you encounter issues with the Sidebar Style on macOS, consider using the Single Column Style (`.settingsStyle(.single)`) which doesn't exhibit this problem.

## Requirements

- iOS 17.0+ / macOS 14.0+ / watchOS 10.0+ / tvOS 17.0+ / visionOS 1.0+
- Swift 6.0+
- Xcode 16.0+

## License

SettingsKit is available under the MIT license. See the LICENSE file for more info.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

