# Understanding SettingsKit

Learn what SettingsKit provides, which responsibilities stay with your app, and how a settings hierarchy remains ordinary SwiftUI while gaining navigation and search metadata.

## Start with the central model

SettingsKit does not replace SwiftUI controls or own your settings values. Your app creates toggles, pickers, sliders, text fields, buttons, and custom views with the same bindings, observable models, environment values, tasks, and actions used anywhere else in SwiftUI. SettingsKit adds semantic structure around those views so it can understand which controls belong together, which groups are destinations, and which values should be discoverable through search.

A ``SettingsContainer`` declares that structure through ``SettingsContainer/settingsBody``. ``SettingsGroup`` and ``CustomSettingsGroup`` establish meaningful boundaries, while the `indexed` modifier family adds explicit search metadata to individual views. The result is both a direct SwiftUI hierarchy and a metadata-only ``SettingsNode`` tree.

## Know what the library provides

### Declaration components

- ``SettingsContainer`` defines the root of a settings hierarchy and supplies the built-in presentation as its default SwiftUI body.
- ``SettingsContent`` marks views that contribute settings structure or indexing metadata.
- ``SettingsContentBuilder`` composes groups, conditional content, loops, extracted settings content, and ordinary SwiftUI views in declaration order.
- ``SettingsGroup`` creates navigation or inline structure and can contain controls or nested groups.
- ``CustomSettingsGroup`` creates a searchable navigation destination whose internal view remains opaque to the index.

### Indexing and search

- ``SettingsNode`` represents groups and indexed items without retaining SwiftUI views.
- The `indexed` modifier family associates an ordinary SwiftUI view with a search title and tags.
- ``SettingsTagSet`` and ``Tags`` make keyword collections reusable.
- ``DefaultSettingsSearch`` traverses and ranks node metadata, while ``SettingsSearch`` is the extension point for a different matching policy.
- ``SettingsSearchResult`` represents navigation matches and collections of matching controls.
- ``SettingsSearchResults`` provides the standard interactive result UI.

### Presentation

- ``SettingsView`` combines a settings runtime with the active ``SettingsStyle`` to provide a complete built-in container, navigation model, search placement, and group presentation.
- ``SidebarSettingsStyle`` and ``SingleColumnSettingsStyle`` are complete container styles with navigation and search placement.
- ``SettingsHost`` exposes the runtime through ``SettingsPresentationContext`` without creating visible navigation, search, toolbar, tab, or layout containers.
- ``SettingsGroupStyle`` changes the appearance and interaction of groups independently of the app's surrounding shell.

## Divide responsibilities deliberately

| Concern | Owner |
| --- | --- |
| Settings values, persistence, validation, actions, and business rules | Your app |
| SwiftUI bindings, observable models, environment dependencies, focus, and control behavior | Your app and SwiftUI |
| Group hierarchy, navigation/inline metadata, search titles, tags, and indexed identity | SettingsKit declarations in your views |
| Metadata traversal, result ranking, host-local view registration, search query, and navigation path | ``SettingsHost`` |
| Built-in navigation containers, list layout, search placement, and group rendering | ``SettingsView`` with a ``SettingsStyle`` |
| Custom navigation containers, tabs, toolbar, backgrounds, scrolling, and window chrome | Your view when using ``SettingsHost`` |
| Group-level layout inside a custom shell | A ``SettingsGroupStyle`` selected by your view |

This boundary allows the same settings declaration to participate in the built-in interface, a custom app-owned shell, or multiple independent settings presentations without moving state into SettingsKit.

## Understand how your views participate

### Ordinary SwiftUI views

An ordinary view inside a group renders normally and keeps all of its SwiftUI behavior. It does not produce an item node because SettingsKit cannot safely infer semantic label text from an arbitrary view.

```swift
SettingsGroup("Playback") {
    Toggle("Autoplay", isOn: $autoplay)
}
```

The toggle appears in the group, but only the group title participates in search.

### Indexed SwiftUI views

An `indexed` modifier wraps the view as ``SettingsContent`` while retaining the original view for rendering. During indexing, the wrapper creates an item node and registers a builder for the live view in the current host.

```swift
Toggle("Autoplay", isOn: $autoplay)
    .indexed("Autoplay", tags: ["video", "playback"])
```

The search renderer can now show the actual toggle rather than a static copy of its label. The original binding still points to your app's state, so interaction from the normal hierarchy or from search updates the same value.

### Extracted settings content

A reusable type conforming to ``SettingsContent`` can combine groups and controls without creating a separate runtime boundary. Its default node-building behavior forwards the active ``SettingsContentScope`` through its body, so nested indexed views register with the same host.

``SettingsContainer/settingsBody`` and ``SettingsGroup`` content closures apply ``SettingsContentBuilder`` automatically. A custom ``SettingsContent`` type's `body` instead inherits SwiftUI's `ViewBuilder`. When that body has multiple top-level settings expressions, annotate it with `@SettingsContentBuilder`; otherwise SwiftUI produces a `TupleView`, which does not conform to ``SettingsContent``. The annotation is optional when the body has one top-level expression.

```swift
struct PlaybackSettings: SettingsContent {
    @Binding var autoplay: Bool
    @Binding var normalizeVolume: Bool

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Playback") {
            Toggle("Autoplay", isOn: $autoplay)
                .indexed("Autoplay")
        }

        SettingsGroup("Audio") {
            Toggle("Normalize Volume", isOn: $normalizeVolume)
        }
    }
}
```

### Custom destinations

``CustomSettingsGroup`` is appropriate for a dashboard, chart, editor, or other destination that should be navigable and searchable as one unit. Its title and tags produce a group node, and its destination view is registered for navigation. Internal controls remain ordinary SwiftUI and are not individually indexed unless the custom destination defines its own settings hierarchy.

## Follow the runtime flow

1. SwiftUI evaluates ``SettingsContainer/settingsBody`` and produces a hierarchy of settings components and ordinary views.
2. ``SettingsHost`` asks that hierarchy for nodes using a host-local ``SettingsContentScope``.
3. Groups and indexed controls emit metadata and register closures that recreate their live SwiftUI content inside that host.
4. The normal presentation renders ``SettingsPresentationContext/rootContent`` directly from the original hierarchy, preserving SwiftUI observation and identity.
5. When ``SettingsPresentationContext/searchText`` is nonempty, the selected ``SettingsSearch`` searches the metadata tree and produces ``SettingsPresentationContext/searchResults``.
6. ``SettingsPresentationContext/searchContent`` resolves matching controls and destinations from the host-local registry. ``SettingsPresentationContext/content`` automatically chooses root or search content for the current query.
7. Navigation uses ``SettingsGroupConfiguration`` values containing resolved group content, allowing either a built-in style or an app-owned `NavigationStack` to present the same destination.

Each ``SettingsHost`` owns its own registry, query, result collection, and navigation path. Two settings windows, tabs, or embedded presentations can therefore use the same declaration without sharing presentation runtime state.

## Choose an integration boundary

Use the default body of ``SettingsContainer`` when the complete built-in experience is appropriate. Apply `settingsStyle(_:)` to select or create the container, navigation, search placement, and group presentation as one system. Settings items remain ordinary SwiftUI views and inherit standard SwiftUI environment styles from that presentation.

Use ``SettingsHost`` when the settings experience belongs inside your app's existing layout. The host gives you bindings and content, and your closure decides where those pieces live:

```swift
SettingsHost(container: AppSettings()) { context in
    NavigationStack(path: context.navigationPath) {
        ScrollView {
            context.content
                .settingsGroupStyle(CardGroupStyle())
        }
        .navigationTitle(context.title)
        .searchable(text: context.searchText)
        .toolbar { SettingsToolbar() }
        .navigationDestination(for: SettingsGroupConfiguration.self) { group in
            ScrollView { group.content }
                .navigationTitle(group.title)
        }
    }
}
```

Use the individual context values when `context.content` is too high-level. For example, a shell can place ``SettingsPresentationContext/rootContent`` in one tab, render ``SettingsPresentationContext/searchResults`` in a custom overlay, resolve an item with ``SettingsPresentationContext/indexedView(for:)``, or resolve a destination with ``SettingsPresentationContext/groupConfiguration(for:)``.

For implementation details about metadata, registration, rendering paths, identity, and navigation configurations, see <doc:SettingsKitArchitecture>.
