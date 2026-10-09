# Migrating to Version 3

Update a 2.x integration for SettingsKit's new presentation, styling, and metadata APIs.

## Update the dependency

Version 3 is a major release because several public APIs have changed. Swift tools 6.2 and the package's minimum deployment targets remain unchanged: iOS 17, macOS 14, tvOS 17, watchOS 10, and visionOS 1.

```swift
.package(url: "https://github.com/aeastr/SettingsKit.git", from: "3.0.0")
```

Existing declarations using `SettingsContainer`, ordinary SwiftUI controls, `.indexed(...)`, and groups with optional `systemImage` metadata remain the starting point. Review the changes below if you use custom icons, styles, node construction, or custom indexing.

## Move group decoration into styles

`SettingsGroup` now has one generic parameter, `Content`. The `Icon` parameter and the `icon:` view-builder initializer have been removed, along with the `SettingsIcon` view.

For a group represented by an SF Symbol, use semantic image metadata:

```swift
SettingsGroup("Connectivity", systemImage: "wifi") {
    Toggle("Wi-Fi", isOn: $wifiEnabled)
        .indexed("Wi-Fi")
}
```

Colored backgrounds, custom image views, typography, and row layout now belong to an app-owned `SettingsGroupStyle` or `SettingsStyle`. A group style can use `configuration.title`, `configuration.systemImage`, and `configuration.content` to build its row and destination. See <doc:StylingSettings> for a complete example. This requires moving existing icon decoration into the style; the old `icon:` closure has no direct replacement on `SettingsGroup`.

`CustomSettingsGroup` also removes its `systemImage:` argument. It still accepts a title, tags, and arbitrary destination content:

```swift
CustomSettingsGroup("Developer Tools", tags: ["debug", "diagnostics"]) {
    DeveloperToolsView()
}
```

For an SF Symbol on a custom destination, use an ordinary group containing the unindexed destination view when that matches your intended layout, or supply the row decoration in your custom group style. A plain SwiftUI destination view does not recursively contribute search metadata.

## Update custom styles

`SettingsStyle` now owns container and group presentation only. Remove `ItemBody`, `ItemConfiguration`, and `makeItem(configuration:)` from custom style implementations. `SettingsItemConfiguration` has been removed. Apply ordinary SwiftUI control styles and view modifiers to individual controls instead.

Update group configuration access:

| Version 2 | Version 3 |
| --- | --- |
| `configuration.iconName` | `configuration.systemImage` |
| `configuration.iconView` | Render decoration in your style |
| Private configuration identity | Public `configuration.id` |
| Container navigation path only | Navigation path plus `configuration.selectedGroup` |

Use `.settingsStyle(...)` to replace a full built-in presentation. Use `.settingsGroupStyle(...)` when only group appearance should change.

For app-owned navigation, tabs, search fields, or toolbars, use `SettingsHost` and its `SettingsPresentationContext`. Resolve destination and indexed-control views through `context.groupConfiguration(for:)` and `context.indexedView(for:)` so they use that host's registry. See <doc:CustomPresentation>.

## Update metadata and custom search

`SettingsNode` is still metadata-only, but its enum cases have changed:

```swift
case group(
    id: UUID,
    title: String,
    systemImage: String? = nil,
    tags: [String],
    presentation: SettingsGroupPresentation,
    children: [SettingsNode],
    searchable: Bool = true
)

case item(id: UUID, title: String, tags: [String], searchable: Bool)
```

Rename group construction's `icon:` argument to `systemImage:`. Remove the item case's `icon:` argument. Replace `node.icon` with `node.systemImage` where you need a group's SF Symbol. Update enum pattern matches to account for the new associated values.

Custom search implementations must skip a node and its descendants when `isIncludedInSearch` is false. `isSearchable` also depends on presentation, so it is not a substitute for this subtree exclusion check. Apply `.unindexed()` to exclude a group or indexed control without removing navigation or live content.

Navigation search results can now contain `matchedItems` alongside their destination link. Custom renderers should resolve those controls through the presentation context. Result identity is now derived from `group.id` rather than a fresh UUID for each search.

## Forward the indexing scope and invalidate structural changes

Built-in hosts use a separate registry for each presentation. Composed custom `SettingsContent` normally uses the default `makeNodes(in:)` implementation. If your conformance constructs metadata manually or forwards to child content, implement the scoped entry point too and pass its scope to child `makeNodes(in:)` calls. An implementation of only `makeNodes()` is not used by the built-in host's scoped indexing path.

`SettingsHost` builds metadata in a task at initial presentation and when `settingsIndexRevision` changes. Increment that revision when titles, tags, hierarchy, exclusions, or introduction markers change. Bound control values remain live and do not require an index rebuild.

Use `.settingsID("model-key")` to distinguish same-named sibling groups, and `.indexed("Title", tags: [], id: "model-key")` for repeated indexed controls. Choose stable, unique keys within a parent. Generated node UUIDs use Swift's process-local hashing; do not persist them as identifiers across launches.

In a custom `SettingsContent` whose body contains multiple top-level settings expressions, annotate that body with `@SettingsContentBuilder`. Avoid erasing settings content to `AnyView` before indexing when its hierarchy or introduction metadata must be retained.

## Check presentation differences

The single-column style now uses `Form`. The macOS sidebar uses a central selection and detail stack with styled cards and rows. Revisit custom layout assumptions, nested navigation, and navigation round trips after upgrading.

Both built-in styles accept search placement (`.root`, `.destinations`, `.all`, or `.none`); destination-scoped search is implemented for iOS. Defaults use `.all`. On iOS 18 and later, `.settingsIntroduction()` lets a destination reveal its visual title as the introduction scrolls out of view. Other platforms retain their normal title behavior.

SettingsKit keeps bindings connected to the application's model; the application remains responsible for storing values across launches.
