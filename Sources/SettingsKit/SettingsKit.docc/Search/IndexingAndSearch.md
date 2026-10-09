# Indexing and Search

Make settings discoverable while preserving live, interactive SwiftUI controls in search results.

## Index individual views

SettingsKit cannot infer the label text embedded in an arbitrary SwiftUI view. Use an `indexed` modifier to explicitly provide a title, tags, or both:

```swift
Toggle("Dark Mode", isOn: $darkMode)
    .indexed("Dark Mode", tags: ["theme", "appearance"])

Slider(value: $brightness)
    .indexed(tags: ["Brightness", "display"])
```

Use ``SettingsTagSet`` and ``Tags`` to share keywords across controls. The full `indexed` modifier family is available on SwiftUI views.

## Exclude a group or control

Apply `.unindexed()` to any `SettingsContent` to exclude it and its descendants
from search while preserving navigation, live controls, identity and styling:

```swift
SettingsGroup("Sync Issues") {
    Text("A reported failure").indexed("Error Details")
}
.unindexed()
```

Apply the modifier after `.indexed(...)`, `.settingsID(...)` or `.settingsTags(...)`.
It works with inline sections, navigation groups and `CustomSettingsGroup`.
Descendant indexing cannot override an excluded ancestor. Root and page-scoped
search both respect the exclusion. Navigation metadata and destination builders
remain registered, so excluded destinations are still reachable normally.

Custom search implementations must skip nodes whose `isIncludedInSearch` is false,
including their subtrees. This differs from `isSearchable`, which also describes
whether a node can be an individual result. Update `settingsIndexRevision` if
exclusion changes dynamically, as with other changes to the index structure.

## Understand the index

``SettingsContent/makeNodes(in:)`` produces metadata-only ``SettingsNode`` values. Groups describe hierarchy and presentation, while item nodes describe indexed controls. Views remain in a host-scoped registry so a result can render the original bound control without storing SwiftUI values in the metadata tree.

``SettingsSearchResult`` describes each match. ``SettingsSearchResults`` is the built-in interactive result renderer used by ``SettingsHost``.

When an indexed control matches inside a navigation group, the default renderer
shows the live matching control and a link to its containing destination in one
list section. Each search result gets a separate section, keeping unrelated
settings in distinct cards. A group match without matching controls still shows
its destination link. Custom
presentations can resolve ``SettingsSearchResult/matchedItems`` with
``SettingsPresentationContext/indexedView(for:)`` and arrange results differently.

- ``SettingsSearch`` decides which metadata matches and how it is ranked.
- ``SettingsSearchResults`` renders matching controls and destination links.
- An app-owned shell can group `matchedItems` in its own categories, labels,
  cards, or sections.

See <doc:CustomPresentation> for examples of each result presentation.

## Customize matching

``DefaultSettingsSearch`` normalizes titles and tags, then prioritizes exact, prefix, substring, and tag matches. Supply a custom ``SettingsSearch`` with `settingsSearch(_:)` when an app needs different scoring or filtering:

```swift
AppSettings()
    .settingsSearch(MySettingsSearch())
```

Custom implementations receive the full node hierarchy and return ordered ``SettingsSearchResult`` values.

## Repeated titles and mixed sections

Search includes indexed controls even when their section also contains navigation groups. Root searches traverse descendants; page searches use the same algorithm over that page’s children.

Node identities are scoped to their ancestor path. Two pages can each contain a Status section and a State row without sharing registry entries. For same-named siblings, supply a stable model identity with `.settingsID("model-key")` on the group.

Index construction is synchronous and does not install SwiftUI state or environment wrappers. Pass observable data explicitly to composed settings content. Keep local confirmation state in the rendered indexed control, or supply bindings from an installed owner. Indexing should never trigger a load or a destructive action.

The group case of ``SettingsNode`` includes a trailing `searchable` value that defaults to `true`. Include that associated value when pattern matching the case. See <doc:MigratingToVersion3> when updating an older custom index implementation.

## Search placement on iPhone and iPad

Destination pages in both built-in styles use `.searchable`.
On iOS 26 and later, `.searchToolbarBehavior(.minimize)` requests a compact native
search control and `DefaultToolbarItem(kind: .search, placement: .topBarTrailing)`
requests its top-toolbar position. Tapping it expands native search. Search still
uses the current page’s children and respects `.unindexed()`. The root sidebar
retains its existing search placement. The field’s expansion and available width
remain system-managed. On older iOS versions, destination search uses the platform’s standard search-field presentation.

For introductory rows and destination-title behavior, see <doc:IntroductionAndTitles>.
