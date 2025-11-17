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

SettingsKit uses a hybrid architecture that combines **metadata-only nodes** for indexing and search with a **view registry system** for dynamic rendering. This design enables powerful search capabilities while maintaining live, reactive SwiftUI views with proper state observation.

### The Hybrid Architecture

SettingsKit separates concerns between **what** settings exist (metadata) and **how** they render (views):

1. **Metadata Layer (Nodes)** - Lightweight tree structure for indexing and search
2. **View Layer (Registry)** - Dynamic view builders registered by ID
3. **Rendering Layer** - Direct SwiftUI view hierarchy with proper state observation

This separation solves a critical challenge: making settings fully searchable while keeping interactive controls responsive and reactive.

### The Indexing System

When you define settings using `SettingsGroup` and `SettingsItem`, SettingsKit builds an internal **node tree** that represents your entire settings hierarchy:

1. **Declarative Definition** - You write settings using SwiftUI-style syntax
2. **Node Tree Building** - Each element converts to a `SettingsNode` containing only metadata
3. **View Registration** - Each item registers its view builder in the global registry
4. **Lazy Indexing** - The tree is built on-demand during rendering or searching
5. **Search & Navigation** - The indexed tree powers both features

#### The Node Tree (Metadata-Only)

Every setting becomes a node in an indexed tree. **Crucially, nodes store only metadata—no views or content:**

```
SettingsNode Tree:
├─ Group: "General" (navigation)
│  ├─ Item: "Notifications" → ID: abc123
│  └─ Item: "Dark Mode" → ID: def456
├─ Group: "Appearance" (navigation)
│  └─ Item: "Font Size" → ID: ghi789
└─ Group: "Privacy & Security" (navigation)
   └─ Item: "Auto Lock Delay" → ID: jkl012
```

Each node stores:
- **UUID** - Stable identifier (hash-based, not random) for navigation and registry lookup
- **Title & Icon** - Display information for search results
- **Tags** - Additional keywords for search discoverability
- **Presentation Mode** - Navigation link or inline section (for groups)
- **Children** - Nested groups and items (for groups)
- **⚠️ No Content** - Views are NOT stored in nodes

#### The View Registry

The `SettingsNodeViewRegistry` is a global singleton that maps node IDs to view builder closures:

```swift
// When SettingsItem.makeNodes() is called:
SettingsNodeViewRegistry.shared.register(id: itemID) {
    AnyView(Toggle("Enable", isOn: $settings.notificationsEnabled))
}

// Later, in search results:
if let view = SettingsNodeViewRegistry.shared.view(for: itemID) {
    view  // Renders the actual Toggle with live state binding
}
```

This registry allows search results to render **actual interactive controls** (Toggle, Slider, TextField, etc.) rather than static text labels.

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

When you search for "notif", it finds "Notifications" and renders the actual Toggle control with live state binding—not just a text label.

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

This dual approach ensures optimal performance: normal navigation uses direct view hierarchies (fast), while search results use dynamic registry lookups (flexible).

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

The node tree's awareness of **navigation vs. inline presentation** ensures groups render correctly in both styles.

#### Stable IDs

Node UUIDs are generated using **hash-based stable IDs** rather than random UUIDs:

```swift
var hasher = Hasher()
hasher.combine(title)
hasher.combine(icon)
let hashValue = hasher.finalize()
// Convert hash to UUID bytes...
```

This ensures the same setting always gets the same ID across multiple `makeNodes()` calls, which is critical for:
- Matching search results to actual views in the registry
- Maintaining navigation state
- View identity and animation stability

### Why This Design?

This hybrid architecture solves multiple challenges simultaneously:

- **✅ Reactive Controls** - Direct view hierarchy preserves SwiftUI state observation
- **✅ Powerful Search** - Metadata nodes enable fast, comprehensive search
- **✅ Interactive Search Results** - Registry allows rendering actual controls in search
- **✅ Performance** - Lazy indexing builds the tree only when needed
- **✅ Dynamic Content** - Supports conditional settings (if/else, ForEach)
- **✅ Platform Adaptive** - Navigation adapts to macOS vs iOS patterns
- **✅ Extensibility** - Custom search and styles work with the same tree
- **✅ Type Safety** - SwiftUI result builders validate at compile time

### The Journey: From Problem to Solution

The hybrid view registry architecture wasn't the original design—it emerged from solving a critical macOS bug. Here's how we got here:

#### The Original Problem

Early versions stored view content directly in nodes using `AnyView` type erasure. This worked fine initially, but revealed a **critical macOS-only bug**: when using `NavigationSplitView` with selection-based navigation, interactive controls (Toggle, Slider, TextField, etc.) in the detail pane stopped updating visually. State changed correctly, but the UI appeared frozen.

#### Attempted Solutions

We tried multiple approaches to fix the control update issue:

1. **Force re-rendering with `.id()` modifier** ❌
   - Adding unique IDs to force SwiftUI to rebuild views
   - Didn't work because the problem was deeper in the view hierarchy

2. **Repositioning `navigationDestination`** ❌
   - Moving the navigation destination modifier to different locations
   - No effect on control updates

3. **Extracting separate `DetailContentView`** ❌
   - Thought reducing view nesting might help
   - Same issue persisted

4. **Rendering from nodes instead of cached content** ❌
   - Attempted to rebuild views from node metadata on each render
   - Still had AnyView type erasure breaking state observation

5. **Platform-specific navigation** ✅ (Partial)
   - macOS: Destination-based `NavigationLink` (creates fresh view hierarchies)
   - iOS: Selection-based `NavigationLink` (no issues observed)
   - **Fixed control updates** but created a new problem: views rebuilt on every state change, causing TextField to lose focus on each keystroke

#### The Root Cause

The core issue was **AnyView type erasure combined with macOS NavigationSplitView's aggressive caching**. When content was wrapped in `AnyView` and passed through the node system, SwiftUI's dependency tracking broke down. macOS's NavigationSplitView appeared to cache detail content more aggressively than iOS, making the problem platform-specific.

#### The Breakthrough

The key insight came from asking: **"Can we have a hybrid system where we have nodes that we can grab *their* view for that particular node, and use it in search?"**

This led to the current architecture:

1. **Nodes become metadata-only** - No `AnyView` content stored in nodes
2. **View registry maps IDs to builders** - Global singleton stores `UUID → () -> AnyView`
3. **Normal rendering uses direct hierarchy** - No type erasure, full state observation
4. **Search results use registry lookup** - Can render actual controls dynamically

#### Why It Works

This architecture solves the problem because:

- **No AnyView in normal paths** - Direct view hierarchy preserves SwiftUI's state dependency tracking
- **Platform-specific navigation is isolated** - macOS workaround doesn't affect iOS
- **Search gets actual views** - Registry lookup provides real controls, not just metadata
- **Stable IDs enable matching** - Hash-based UUIDs ensure registry lookups succeed
- **View identity is stable** - No more TextField losing focus from unnecessary rebuilds

The hybrid approach gives us the best of both worlds: searchable metadata trees + reactive SwiftUI views.

## Platform Differences

### iOS
- Uses `NavigationStack` for push navigation in single-column style
- Uses `NavigationSplitView` with selection-based navigation in sidebar style
- Supports search with `.searchable()`
- Inline groups render as section headers

### macOS
- Uses `NavigationSplitView` for sidebar navigation in sidebar style
- Destination-based navigation links for proper control state updates
- Detail pane has its own `NavigationStack` for deeper navigation
- Search results show actual interactive controls via view registry

## Requirements

- iOS 17.0+ / macOS 14.0+ / watchOS 10.0+ / tvOS 17.0+ / visionOS 1.0+
- Swift 6.0+
- Xcode 16.0+

## License

SettingsKit is available under the MIT license. See the LICENSE file for more info.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

