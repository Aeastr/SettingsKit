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

- **Declarative Structure** - Organize ordinary SwiftUI controls into navigation groups, inline sections, and custom destinations
- **Interactive Search** - Index selected controls and render their live bindings directly in ranked search results
- **Composable Presentation** - Use the built-in settings interface or place the SettingsKit runtime inside your own navigation, tabs, toolbars, and layout
- **Focused Styling** - Style complete presentations with `SettingsStyle` or only group content with `SettingsGroupStyle`
- **Platform Adaptive** - Support iOS, macOS, tvOS, watchOS, and visionOS from one settings declaration


## Installation

```swift
dependencies: [
    .package(url: "https://github.com/aeastr/SettingsKit.git", from: "3.0.0")
]
```

```swift
import SettingsKit
```

Upgrading from 2.x? Read the [3.0 migration guide](Sources/SettingsKit/SettingsKit.docc/MigratingToVersion3.md) and [release notes](docs/releases/3.0.0.md) before updating. Version 3 changes public styling, icon, and metadata APIs.


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

        SettingsGroup("General") {
            Toggle("Notifications", isOn: $settings.notificationsEnabled)
                .indexed("Notifications")
            Toggle("Dark Mode", isOn: $settings.darkMode)
                .indexed("Dark Mode", tags: ["theme", "appearance"])
        }

        SettingsGroup("Appearance") {
            Slider(value: $settings.fontSize, in: 10...24, step: 1) {
                Text("Font Size: \(Int(settings.fontSize))pt")
            }
            .indexed("Font Size", tags: ["text", "display"])
        }

        SettingsGroup("Privacy & Security") {
            Slider(value: $settings.autoLockDelay, in: 60...3600, step: 60) {
                Text("Auto Lock: \(Int(settings.autoLockDelay/60)) min")
            }
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
SettingsGroup("Display") {
    // Settings items...
}

// Inline group - appears as a section header
SettingsGroup("Quick Settings", .inline) {
    // Settings items...
}
```

### Styling Boundaries

`SettingsGroup` contains semantic structure: a title, presentation mode, footer, tags, and content. It does not carry icon or decoration metadata. Use `SettingsStyle` or `SettingsGroupStyle` to decide how group titles and content are presented. Inside a group, ordinary SwiftUI views and modifiers remain available when a particular control needs custom UI.

### Custom Settings Groups

For completely custom UI that doesn't fit the standard settings structure, use `CustomSettingsGroup`:

```swift
CustomSettingsGroup("Advanced Tools") {
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

Custom groups are indexed and searchable by title and tags, but their content is rendered as-is without indexing individual elements.

### Using SwiftUI Views Directly

Inside groups, use standard SwiftUI controls directly:

```swift
SettingsGroup("Sound") {
    Slider(value: $volume, in: 0...100)
    Toggle("Haptic Feedback", isOn: $haptics)
    Picker("Output", selection: $audioOutput) {
        Text("Speaker").tag(0)
        Text("Headphones").tag(1)
    }
}
```

### Excluding Content with `.unindexed()`

Keep a settings group visible and navigable while excluding it and all of its descendants from search:

```swift
SettingsGroup("Recent Activity", systemImage: "clock") {
    ActivitySettings()
}
.unindexed()
```

The modifier also works on `CustomSettingsGroup` and on individual controls after
`.indexed(...)`. It preserves group styles, identities, bindings and live
navigation. Apply it after identity and tag modifiers. Exclusion overrides all
indexed children, including in page-scoped search. Ordinary SwiftUI views remain
unindexed by default. Custom search implementations should skip nodes where
`isIncludedInSearch` is false; the metadata is retained for navigation.

### Making Views Searchable with `.indexed()`

By default, individual views are **not** indexed for search—`SettingsGroup` titles are searchable unless excluded with `.unindexed()`. To make a view appear in search results, use the `.indexed()` modifier:

```swift
SettingsGroup("Display") {
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
SettingsGroup("General") {
    SettingsGroup("About") {
        Text("Version: 1.0.0")
        Text("Build: 42")
    }

    SettingsGroup("Language") {
        Picker("Language", selection: $language) {
            Text("English").tag("en")
            Text("Spanish").tag("es")
        }
    }
}
```

### Extracted Settings Groups

Extract complex groups into separate structures:

`SettingsContainer.settingsBody` and `SettingsGroup` closures receive `SettingsContentBuilder` automatically. A custom type's `body` inherits SwiftUI's `ViewBuilder`, so add `@SettingsContentBuilder` when the body contains more than one top-level settings expression. A body with one outer `SettingsGroup` does not need the explicit annotation.

```swift
struct DeveloperSettings: SettingsContent {
    @Bindable var settings: AppSettings

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Developer") {
            Toggle("Debug Mode", isOn: $settings.debugMode)

            if settings.debugMode {
                Toggle("Verbose Logging", isOn: $settings.verboseLogging)
            }
        }

        SettingsGroup("Diagnostics") {
            Button("Export Logs") { }
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
SettingsGroup("Advanced") {
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

Both built-in styles can choose where search is presented:

```swift
MySettings(settings: settings)
    .settingsStyle(.sidebar(search: .root))

MySettings(settings: settings)
    .settingsStyle(.single(search: .destinations))
```

Use `.root` for only the top-level search field, `.destinations` for hierarchy-scoped destination search, `.all` for both, or `.none` to hide built-in search UI. Plain `.sidebar` and `.single` default to `.all`.

### Full Presentation Styles

Use `SettingsStyle` when one reusable style should own the settings container, navigation, search placement, destinations, and group presentation:

```swift
struct CardPresentationStyle: SettingsStyle {
    func makeContainer(configuration: ContainerConfiguration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    configuration.content
                }
                .padding()
            }
            .navigationTitle(configuration.title)
            .navigationDestination(for: SettingsGroupConfiguration.self) { group in
                ScrollView { group.content }
                    .navigationTitle(group.title)
            }
        }
        .tint(.indigo)
        .controlSize(.large)
    }

    @ViewBuilder
    func makeGroup(configuration: GroupConfiguration) -> some View {
        switch configuration.presentation {
        case .navigation:
            NavigationLink(value: configuration) {
                configuration.label
            }
        case .inline:
            VStack(alignment: .leading) {
                configuration.label
                configuration.content
            }
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: 20))
        }
    }
}

MySettings(settings: settings)
    .settingsStyle(CardPresentationStyle())
```

Settings items remain the SwiftUI views declared by the app. A full style customizes their shared appearance through ordinary environment modifiers such as `tint`, `controlSize`, `toggleStyle`, and `buttonStyle`, while specialized rows can keep their own local styling.

### Fully Composable Layouts

Use `SettingsHost` when your app should own the visible settings presentation. The host keeps SettingsKit's index, custom search implementation, live interactive search results, and navigation path, but it does not create any navigation or layout containers:

```swift
SettingsHost(container: MySettings(settings: settings)) { context in
    NavigationStack(path: context.navigationPath) {
        ScrollView {
            LazyVStack(spacing: 16) {
                context.content
            }
            .padding()
        }
        .searchable(text: context.searchText)
        .toolbar {
            Button("Reset", action: resetSettings)
        }
        .navigationDestination(for: SettingsGroupConfiguration.self) { group in
            ScrollView { group.content }
                .navigationTitle(group.title)
        }
    }
}
```

The context also exposes `rootContent`, `searchContent`, `nodes`, and `searchResults` when a design needs to position those pieces independently. Fully custom result renderers can resolve live content with `groupConfiguration(for:)` and `indexedView(for:)`.

### Group-Only Styles

`SettingsGroupStyle` changes groups without taking ownership of the surrounding navigation, search UI, toolbar, or window chrome:

```swift
struct CardGroupStyle: SettingsGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            configuration.label
                .font(.headline)
            configuration.content
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

SettingsHost(container: MySettings(settings: settings)) { context in
    ScrollView {
        context.content
            .settingsGroupStyle(CardGroupStyle())
    }
}
```

The demo includes separate tabs for a full `SettingsStyle` presentation and a card-and-tab shell using `SettingsHost` with `SettingsGroupStyle`.

Use `SettingsStyle` when a reusable style should define the complete built-in container, navigation, and groups. Use `SettingsGroupStyle` when the surrounding interface belongs to your app.

### Search

Search is automatic and works out of the box. `SettingsGroup` titles are searchable by default. Use `.unindexed()` to exclude a group and its descendants. Use `.indexed()` on individual views to make them searchable too.

#### Adding Tags to Groups

```swift
SettingsGroup("Notifications")
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


## How SettingsKit Fits Around Your Views

SettingsKit adds structure, indexing, search, and presentation tools around ordinary SwiftUI views. It does not own your settings values or replace SwiftUI controls. Your app remains responsible for models, persistence, validation, actions, bindings, and environment dependencies; the toggle, picker, slider, field, button, or custom view inside a `SettingsGroup` behaves like the same view anywhere else in your app.

### What SettingsKit Provides

| Layer | Provided types and behavior |
| --- | --- |
| Declaration | `SettingsContainer`, `SettingsContentBuilder`, `SettingsGroup`, and `CustomSettingsGroup` describe the hierarchy around your views. |
| Indexing | `.indexed()` adds explicit search metadata to an individual SwiftUI view. `SettingsNode` stores titles, tags, presentation modes, and child relationships without storing views. |
| Search | `DefaultSettingsSearch` traverses and ranks metadata. `SettingsSearch` lets an app provide a different matching policy, and `SettingsSearchResults` renders the standard interactive result UI. |
| Runtime | `SettingsHost` owns a search query, navigation path, metadata tree, search results, and a host-local registry that resolves node identities back to live views. |
| Presentation | `SettingsView` provides the complete built-in interface. `SettingsPresentationContext` exposes the same runtime to an app-owned shell. `SettingsStyle` customizes the complete built-in presentation, while `SettingsGroupStyle` customizes groups independently. |

### How a SwiftUI View Becomes Searchable

An ordinary view inside a group renders normally but does not create an item in the search index. SettingsKit cannot safely infer the semantic label embedded in an arbitrary SwiftUI value, so indexing is explicit:

```swift
Toggle("Dark Mode", isOn: $darkMode)
    .indexed("Dark Mode", tags: ["theme", "appearance"])
```

The modifier keeps the original toggle for normal rendering, emits an item node during indexing, and registers a builder for that live view inside the current `SettingsHost`. Search results can therefore display the actual toggle with the same binding to your model instead of a static label or duplicated control state.

`CustomSettingsGroup` works at destination granularity: its title and tags are searchable and its full custom view is available for navigation, but SettingsKit does not inspect or individually index the controls inside that destination.

### Runtime and Rendering Flow

1. SwiftUI evaluates `settingsBody`, including groups, conditionals, loops, extracted `SettingsContent`, and ordinary views.
2. `SettingsHost` traverses that hierarchy to build metadata-only `SettingsNode` values and register live group and indexed-control builders in a registry owned by that host.
3. Normal presentation renders the direct SwiftUI hierarchy, preserving observation, environment propagation, bindings, and control identity.
4. When `searchText` is nonempty, the active `SettingsSearch` searches node metadata and produces ordered `SettingsSearchResult` values.
5. Search presentation resolves the matching live controls and destinations from the host's registry. `context.content` automatically switches between `rootContent` and `searchContent` for the current query.
6. Navigation passes `SettingsGroupConfiguration` values containing resolved destination content into either a built-in style or your own `NavigationStack`.

Every `SettingsHost` has independent search, navigation, and view-registration state, so the same settings declaration can appear in multiple windows, tabs, or embedded layouts without those presentation runtimes leaking into one another.

`SettingsHost` builds the search index once when it appears. Live values update in the rendered controls without reindexing. If a container changes its searchable titles, tags, or group structure, implement `settingsIndexRevision` and change that integer with the structure. Keep transient values such as progress and activity-log entries out of `.indexed(...)` tags; index the stable destination and control names instead.

### Choose Who Owns the Visible Interface

Use a `SettingsContainer` directly when the built-in settings interface is the right fit. Its default body creates `SettingsView`, and the active `SettingsStyle` supplies the container, navigation, search placement, and group presentation. Individual settings remain ordinary SwiftUI views.

Use `SettingsHost` when your app should own visible structure. The context supplies `searchText` and `navigationPath` bindings; `rootContent`, `searchContent`, and automatically selected `content`; the node tree and result collection; and resolvers for destination content and indexed controls. Your view decides where to put navigation containers, search fields, tabs, toolbars, backgrounds, scrolling, and window chrome.

For the complete system model, integration patterns, and implementation details, open the [SettingsKit DocC catalog](Sources/SettingsKit/SettingsKit.docc/SettingsKit.md), starting with [Understanding SettingsKit](Sources/SettingsKit/SettingsKit.docc/UnderstandingSettingsKit.md) and [Architecture](Sources/SettingsKit/SettingsKit.docc/SettingsKitArchitecture.md).


## Contributing

Contributions welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for branch naming, pull requests, validation, and releases.


## License

MIT. See [LICENSE](LICENSE) for details.


## Introductory rows and navigation titles

Mark an app-owned introductory row inside a settings destination:

```swift
SettingsGroup("iCloud") {
    SettingsGroup("", .inline) {
        MyIntroductionView()
            .settingsIntroduction()
    }
    Toggle("Use iCloud", isOn: $syncEnabled).indexed("Use iCloud")
}
```

On iOS 18 and later, both built-in destination styles keep the visual title hidden
while the marked row is visible. When less than 1% remains visible, the title
fades and moves upward six points over 0.22 seconds. Reduce Motion uses a short
fade only. The semantic navigation title stays set. With no marker, the normal
inline title remains visible. Older iOS and other platforms retain normal titles.

The app owns the row's layout and copy; SettingsKit owns detection and animation.
Declare one marked row per page directly in SettingsContent or an inline group.
The marker preserves existing search metadata and does not index plain content.
Nested navigation pages have independent introductions. Changing whether a page
has an intro requires the same index revision update as other structural changes.
Custom settings styles can keep their own title behavior; the automatic animation
applies to the built-in iOS destination pages.

For version 3.0.0, all 26 package tests and macOS/iOS demo builds passed.
Scroll animation, lazy Form behavior, navigation return, search interaction,
Dynamic Type and VoiceOver remain unverified on device.


### Destination toolbar ownership

Every built-in iOS destination sets `.toolbarTitleDisplayMode(.inline)` and owns
one persistent `ToolbarItem(placement: .title)`. This overrides the sidebar root’s
separate title mode. Intro visibility controls the custom title’s opacity/offset;
without an intro it remains visible. `.navigationTitle` retains the semantic name.

Keep intro-bearing content typed during registration. To exclude its rows from
search, use `MyPage().unindexed()` rather than `AnyView(MyPage())`; the former
preserves introduction metadata for the initial title state. Runtime visibility
reports also recognize intros hidden inside opaque views after they render.

The earlier placement-only implementation did not establish the requested device
behavior: the owner observed duplicate/large titles and misplaced search. This
correction explicitly sets toolbar display mode, the title slot and the search
item placement. The iOS demo build passes; on-device rendering is unverified.


### Compact destination search

The owner still observed search outside the top toolbar after the explicit item
was added. The iOS 26+ path now omits `SearchFieldPlacement.toolbar`: Apple's
[placement documentation](https://developer.apple.com/documentation/swiftui/searchfieldplacement/toolbar)
describes its iPhone behavior as a field below the navigation bar.
`DefaultToolbarItem(kind: .search, placement: .topBarTrailing)` owns the placement,
with `.searchToolbarBehavior(.minimize)` following `.searchable` to request the
compact native control. Activation expands native search. The pre-iOS-26 fallback
and root sidebar search remain unchanged. This is a source correction based on
the API contract. The iOS demo build passes; updated device behavior remains
unverified.
