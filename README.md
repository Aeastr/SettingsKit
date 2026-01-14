<div align="center">
  <img width="128" height="128" src="/Resources/icon/icon.png" alt="SettingsKit Icon">
  <h1><b>SettingsKit</b></h1>
  <p>
    A declarative SwiftUI framework for building settings interfaces with navigation, search, and customizable styling.
  </p>
</div>

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.0+-F05138?logo=swift&logoColor=white" alt="Swift 6.0+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/iOS-17+-000000?logo=apple" alt="iOS 17+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/macOS-14+-000000?logo=apple" alt="macOS 14+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/tvOS-17+-000000?logo=apple" alt="tvOS 17+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/watchOS-10+-000000?logo=apple" alt="watchOS 10+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/visionOS-1+-000000?logo=apple" alt="visionOS 1+"></a>
</p>

<div align="center">
  <img width="600" alt="Preview" src="https://github.com/user-attachments/assets/7d937cbd-182d-4715-b030-fd172a9cdc08" />
</div>


## Overview

- **Declarative API** - Build settings hierarchies with intuitive SwiftUI-style syntax
- **Built-in Search** - Automatic search functionality with intelligent filtering and scoring
- **Multiple Styles** - Choose from sidebar, grouped, card, or default presentation styles
- **Customizable** - Extend with custom styles and search implementations
- **Platform Adaptive** - Works seamlessly on iOS and macOS with appropriate navigation patterns


## Installation

```swift
dependencies: [
    .package(url: "https://github.com/aeastr/SettingsKit.git", from: "1.0.0")
]
```

```swift
import SettingsKit
```


## Usage

### Quick Start

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
}

struct MySettings: SettingsContainer {
    @Environment(AppSettings.self) var appSettings

    var settingsBody: some SettingsContent {
        @Bindable var settings = appSettings

        // Plain icon (no colored background)
        SettingsGroup("General", systemImage: "gear") {
            Toggle("Notifications", isOn: $settings.notificationsEnabled)
            Toggle("Dark Mode", isOn: $settings.darkMode)
        }

        // iOS Settings-style colored icons
        SettingsGroup("Appearance") {
            Slider(value: $settings.fontSize, in: 10...24, step: 1) {
                Text("Font Size: \(Int(settings.fontSize))pt")
            }
        } icon: {
            SettingsIcon("paintbrush", color: .blue)
        }

        SettingsGroup("Privacy & Security") {
            Slider(value: $settings.autoLockDelay, in: 60...3600, step: 60) {
                Text("Auto Lock: \(Int(settings.autoLockDelay/60)) min")
            }
        } icon: {
            SettingsIcon("lock.shield", color: .blue)
        }
    }
}
```

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

### iOS Settings-Style Icons

For colored icon backgrounds like the iOS Settings app, use the `icon:` ViewBuilder with `SettingsIcon`:

```swift
SettingsGroup("Airplane Mode") {
    Toggle("Enabled", isOn: $airplaneMode)
} icon: {
    SettingsIcon("airplane", color: .orange)
}

SettingsGroup("Wi-Fi") {
    Text("My Network")
} icon: {
    SettingsIcon("wifi", color: .blue)
}

SettingsGroup("Battery") {
    Text("94%")
} icon: {
    SettingsIcon("battery.100", color: .green)
}
```

The `icon:` ViewBuilder accepts any SwiftUI view, so you can create fully custom icons:

```swift
SettingsGroup("Custom") {
    // content
} icon: {
    Circle()
        .fill(.purple.gradient)
        .frame(width: 29, height: 29)
        .overlay {
            Image(systemName: "star.fill")
                .foregroundStyle(.white)
        }
}
```

### Custom Settings Groups

For completely custom UI that doesn't fit the standard settings structure, use `CustomSettingsGroup`:

```swift
CustomSettingsGroup("Advanced Tools", systemImage: "hammer") {
    VStack(spacing: 20) {
        Text("Your Custom UI")
            .font(.largeTitle)

        Button("Custom Action") {
            performAction()
        }
    }
    .padding()
}
```

Custom groups are indexed and searchable (by title, icon, and tags), but their content is rendered as-is without indexing individual elements.

### Using SwiftUI Views Directly

Inside groups, use standard SwiftUI controls directly:

```swift
SettingsGroup("Sound", systemImage: "speaker.wave.2") {
    Slider(value: $volume, in: 0...100)
    Toggle("Haptic Feedback", isOn: $haptics)
    Picker("Output", selection: $audioOutput) {
        Text("Speaker").tag(0)
        Text("Headphones").tag(1)
    }
}
```

### Making Views Searchable with `.indexed()`

By default, individual views are **not** indexed for search—only `SettingsGroup` titles are searchable. To make a view appear in search results, use the `.indexed()` modifier:

```swift
SettingsGroup("Display", systemImage: "sun.max") {
    Toggle("Dark Mode", isOn: $darkMode)
        .indexed("Dark Mode", tags: ["theme", "appearance"])

    Slider(value: $brightness, in: 0...1)
        .indexed("Brightness")
}
```

#### `.indexed()` API

```swift
// Title only
Toggle("Dark Mode", isOn: $dark)
    .indexed("Dark Mode")

// Title + additional search tags
Toggle("Dark Mode", isOn: $dark)
    .indexed("Dark Mode", tags: ["theme", "night", "appearance"])

// Tags only (useful when title would be redundant)
Toggle("Dark Mode", isOn: $dark)
    .indexed(tags: ["Dark Mode", "theme", "appearance"])
```

#### Reusable Tag Sets

Define tag sets to keep tagging consistent across your app:

```swift
struct ThemeTags: SettingsTagSet {
    var tags: [String] { ["theme", "appearance", "display", "colors"] }
}

struct AccessibilityTags: SettingsTagSet {
    var tags: [String] { ["accessibility", "a11y", "vision", "motor"] }
}

// Use them
Toggle("Dark Mode", isOn: $dark)
    .indexed("Dark Mode", tagSet: ThemeTags())

// Combine multiple tag sets
Toggle("High Contrast", isOn: $highContrast)
    .indexed("High Contrast", tagSets: ThemeTags(), AccessibilityTags())
```

### Nested Navigation

Groups can contain other groups for deep hierarchies:

```swift
SettingsGroup("General", systemImage: "gear") {
    SettingsGroup("About", systemImage: "info.circle") {
        Text("Version: 1.0.0")
        Text("Build: 42")
    }

    SettingsGroup("Language", systemImage: "globe") {
        Picker("Language", selection: $language) {
            Text("English").tag("en")
            Text("Spanish").tag("es")
        }
    }
}
```

### Extracted Settings Groups

Extract complex groups into separate structures:

```swift
struct DeveloperSettings: SettingsContent {
    @Bindable var settings: AppSettings

    var body: some SettingsContent {
        SettingsGroup("Developer", systemImage: "hammer") {
            Toggle("Debug Mode", isOn: $settings.debugMode)

            if settings.debugMode {
                Toggle("Verbose Logging", isOn: $settings.verboseLogging)
            }
        }
    }
}

// Use it in your main settings
var settingsBody: some SettingsContent {
    DeveloperSettings(settings: settings)
}
```

### Conditional Content

Show or hide settings based on state:

```swift
SettingsGroup("Advanced", systemImage: "gearshape.2") {
    Toggle("Enable Advanced Features", isOn: $showAdvanced)

    if showAdvanced {
        Toggle("Advanced Option 1", isOn: $option1)
        Toggle("Advanced Option 2", isOn: $option2)
    }
}
```


## Customization

### Built-in Styles

**Sidebar Style (Default)** - Split-view navigation:

```swift
MySettings(settings: settings)
    .settingsStyle(.sidebar)
```

**Single Column Style** - Clean, single-column list:

```swift
MySettings(settings: settings)
    .settingsStyle(.single)
```

### Custom Styles

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

### Search

Search is automatic and works out of the box. `SettingsGroup` titles are always searchable. Use `.indexed()` on individual views to make them searchable too.

#### Adding Tags to Groups

```swift
SettingsGroup("Notifications", systemImage: "bell")
    .settingsTags(["alerts", "sounds", "badges", "push"])
```

#### Custom Search

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


## How It Works

SettingsKit uses a hybrid architecture that separates **what** settings exist from **how** they render:

### Metadata Layer

When you define settings, SettingsKit builds a lightweight node tree containing only metadata—titles, icons, tags, and hierarchy. This tree powers search and navigation without storing any view content.

### View Registry

Each `.indexed()` view and `CustomSettingsGroup` registers its view builder in a global registry, mapped by stable IDs. This allows search results to render actual interactive controls (toggles, sliders, etc.) rather than static labels.

### Rendering

Normal navigation renders views directly from SwiftUI's view hierarchy, preserving full state observation and reactivity. Search results retrieve view builders from the registry, instantiating fresh views with live state bindings.

### Search

The built-in search normalizes queries, traverses the node tree, and scores matches by relevance (exact matches rank highest, then prefix matches, then contains, then tag matches). Results are grouped by their parent settings group.

For implementation details on the node tree structure, view registry, stable ID generation, and platform-specific navigation patterns, see [Architecture](docs/Architecture.md).


## Contributing

Contributions welcome. Please feel free to submit a Pull Request.


## License

MIT. See [LICENSE](LICENSE) for details.
