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


## Requirements

- Swift 6.0+
- iOS 17+ / macOS 14+ / watchOS 10+ / tvOS 17+ / visionOS 1+
- Xcode 16.0+


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

SettingsKit uses a hybrid architecture that combines **metadata-only nodes** for indexing and search with a **view registry system** for dynamic rendering. This design enables powerful search capabilities while maintaining live, reactive SwiftUI views with proper state observation.

### The Hybrid Architecture

SettingsKit separates concerns between **what** settings exist (metadata) and **how** they render (views):

1. **Metadata Layer (Nodes)** - Lightweight tree structure for indexing and search
2. **View Layer (Registry)** - Dynamic view builders registered by ID
3. **Rendering Layer** - Direct SwiftUI view hierarchy with proper state observation

### The Indexing System

When you define settings using `SettingsGroup` and views with `.indexed()`, SettingsKit builds an internal **node tree** that represents your entire settings hierarchy:

1. **Declarative Definition** - You write settings using SwiftUI-style syntax
2. **Node Tree Building** - Each element converts to a `SettingsNode` containing only metadata
3. **View Registration** - Each item registers its view builder in the global registry
4. **Lazy Indexing** - The tree is built on-demand during rendering or searching
5. **Search & Navigation** - The indexed tree powers both features

#### The Node Tree (Metadata-Only)

Groups and indexed views become nodes in an indexed tree. Nodes store only metadata—no views or content:

```
SettingsNode Tree:
├─ Group: "General" (navigation)
│  ├─ IndexedView: "Notifications" → ID: abc123
│  └─ IndexedView: "Dark Mode" → ID: def456
├─ Group: "Appearance" (navigation)
│  └─ IndexedView: "Font Size" → ID: ghi789
├─ CustomGroup: "Developer Tools" (navigation) → ID: xyz789
│  └─ (no children - custom content not indexed)
└─ Group: "Privacy & Security" (navigation)
   └─ (no indexed views - group searchable by title only)
```

Each node stores:
- **UUID** - Stable identifier (hash-based, not random) for navigation and registry lookup
- **Title & Icon** - Display information for search results
- **Tags** - Additional keywords for search discoverability
- **Presentation Mode** - Navigation link or inline section (for groups)
- **Children** - Nested groups and items (for groups; empty for custom groups)
- **No Content** - Views are NOT stored in nodes

#### The View Registry

The `SettingsNodeViewRegistry` is a global singleton that maps node IDs to view builder closures:

```swift
// When .indexed() wraps a view:
SettingsNodeViewRegistry.shared.register(id: viewID) {
    AnyView(Toggle("Enable", isOn: $settings.notificationsEnabled))
}

// When CustomSettingsGroup.makeNodes() is called:
SettingsNodeViewRegistry.shared.register(id: customGroupID) {
    AnyView(YourCompletelyCustomView())
}

// Later, in search results:
if let view = SettingsNodeViewRegistry.shared.view(for: viewID) {
    view  // Renders the actual Toggle with live state binding
}
```

#### How Search Works

The default search implementation uses intelligent scoring:

1. **Normalization** - Removes spaces, special characters, converts to lowercase
2. **Tree Traversal** - Recursively searches all nodes by title and tags
3. **Scoring** - Ranks matches by relevance:
   - Exact match: 1000 points
   - Starts with: 500 points
   - Contains: 300 points
   - Tag match: 100 points
4. **Result Grouping** - Groups matched items by their parent group
5. **View Lookup** - Retrieves actual view builders from registry for matched items

#### Rendering Modes

SettingsKit uses **two different rendering approaches** depending on context:

**Normal Rendering (Direct Hierarchy)**:
- Views render directly from the SwiftUI view hierarchy
- Full state observation through SwiftUI's dependency tracking
- Controls update reactively as state changes
- No registry lookup needed

**Search Results Rendering (Registry Lookup)**:
- Matched items retrieve their view builders from the registry
- Views are instantiated fresh for each search
- State bindings remain live and reactive
- Allows showing actual controls in search results

#### Navigation Architecture

SettingsKit provides two navigation styles that work with the same indexed tree:

**Sidebar Style (NavigationSplitView)**:
- Split-view layout with sidebar and detail pane
- Top-level groups appear in the sidebar
- Uses destination-based NavigationLink on macOS for proper control updates
- Detail pane has its own NavigationStack for nested groups
- On iOS: uses selection-based navigation (no control update issues)

**Single Column Style (NavigationStack)**:
- Push navigation for all groups
- Linear navigation hierarchy
- Inline groups render as section headers
- Search results push onto the navigation stack

#### Stable IDs

Node UUIDs are generated using **hash-based stable IDs** rather than random UUIDs:

```swift
var hasher = Hasher()
hasher.combine(title)
hasher.combine(icon)
let hashValue = hasher.finalize()
// Convert hash to UUID bytes...
```

This ensures the same setting always gets the same ID across multiple `makeNodes()` calls.

### Why This Design?

This hybrid architecture solves multiple challenges simultaneously:

- **Reactive Controls** - Direct view hierarchy preserves SwiftUI state observation
- **Powerful Search** - Metadata nodes enable fast, comprehensive search
- **Interactive Search Results** - Registry allows rendering actual controls in search
- **Performance** - Lazy indexing builds the tree only when needed
- **Dynamic Content** - Supports conditional settings (if/else, ForEach)
- **Platform Adaptive** - Navigation adapts to macOS vs iOS patterns
- **Extensibility** - Custom search and styles work with the same tree
- **Type Safety** - SwiftUI result builders validate at compile time

### Platform Differences

**iOS**:
- Uses `NavigationStack` for push navigation in single-column style
- Uses `NavigationSplitView` with selection-based navigation in sidebar style
- Supports search with `.searchable()`
- Inline groups render as section headers

**macOS**:
- Uses `NavigationSplitView` for sidebar navigation in sidebar style
- Destination-based navigation links for proper control state updates
- Detail pane has its own `NavigationStack` for deeper navigation
- Search results show actual interactive controls via view registry


## Contributing

Contributions welcome. Please feel free to submit a Pull Request.


## License

MIT. See [LICENSE](LICENSE) for details.
