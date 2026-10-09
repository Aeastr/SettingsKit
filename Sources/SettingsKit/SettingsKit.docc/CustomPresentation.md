# Building a Custom Presentation

Use SettingsKit's indexing and search runtime inside navigation and layout owned by your app.

## Host the settings runtime

``SettingsHost`` passes a ``SettingsPresentationContext`` to its content closure. The context exposes the root hierarchy, current search results, bindings, and resolved destination content.

```swift
SettingsHost(container: AppSettings()) { context in
    NavigationStack(path: context.navigationPath) {
        Form {
            context.content
        }
        .navigationTitle(context.title)
        .searchable(text: context.searchText)
        .navigationDestination(for: SettingsGroupConfiguration.self) { group in
            Form { group.content }
                .navigationTitle(group.title)
        }
    }
}
```

``SettingsPresentationContext/content`` automatically switches between ``SettingsPresentationContext/rootContent`` and ``SettingsPresentationContext/searchContent`` as the query changes.

## Render custom search results

Inspect ``SettingsPresentationContext/searchResults`` to create a result layout, then resolve live content with ``SettingsPresentationContext/indexedView(for:)`` or destinations with ``SettingsPresentationContext/groupConfiguration(for:)``.

Each navigation result keeps its matching indexed controls in
``SettingsSearchResult/matchedItems``. This lets a shell choose its behavior: link
to `result.group` for destination-oriented search, or resolve the matched items to
place bound toggles and other controls directly in the results.

Use ``SettingsSearchResults`` directly when the built-in result UI is suitable but the surrounding shell is custom.

### Show destination results and matching controls

The built-in renderer shows a link to the nearest containing destination and
renders its matching indexed controls as live rows below that link:

```swift
SettingsSearchResults(
    query: context.searchText.wrappedValue,
    results: context.searchResults,
    navigationPath: context.navigationPath
)
```

For a custom destination row, inspect ``SettingsSearchResult/isNavigation`` and
resolve ``SettingsSearchResult/group`` with
``SettingsPresentationContext/groupConfiguration(for:)``.

### Show live controls

A custom presentation can instead render the controls that caused the match:

```swift
ForEach(context.searchResults) { result in
    ForEach(result.matchedItems) { item in
        context.indexedView(for: item)
    }
}
```

The resolved view is the original bound SwiftUI control. Changing a toggle in the
search result changes the same state as the control in its destination.

### Apply app-specific grouping

SettingsKit does not decide whether results belong under labels such as “General,”
“Appearance,” or “Automation.” Those categories belong to the app's presentation.
A custom shell can map result groups into its own sections and place a small header
outside the result container:

```swift
ForEach(appSections) { section in
    Section(section.title) {
        ForEach(section.results.flatMap(\.matchedItems)) { item in
            context.indexedView(for: item)
        }
    }
}
```

The tabbed-cards demo uses this approach. Its category mapping is intentionally
local to that example; it is not part of the SettingsKit search or style APIs.

## Keep responsibilities separate

The host owns runtime state: the query, metadata index, view registry, search results, and navigation path. The closure owns visible structure, including navigation containers, toolbars, tabs, split views, and window chrome.
