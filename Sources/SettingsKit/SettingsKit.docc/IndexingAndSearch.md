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

The group case of `SettingsNode` now has a trailing `searchable` value, defaulting
to `true`. Existing group construction remains valid; code that destructures the
group case must include this additional associated value.

## Search placement on iPhone and iPad

Destination pages in both built-in styles use `.searchable`.
On iOS 26 and later, `.searchToolbarBehavior(.minimize)` requests a compact native
search control and `DefaultToolbarItem(kind: .search, placement: .topBarTrailing)`
requests its top-toolbar position. Tapping it expands native search. Search still
uses the current page’s children and respects `.unindexed()`. The root sidebar
retains its existing search placement. The field’s expansion and available width
remain system-managed. Source and SDK availability review only; no build, test or
device layout verification was run for this placement change.


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

Source review only: regression coverage was added but not run. Builds, tests,
scroll animation, lazy Form behavior, navigation return, search interaction,
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
item placement. Source review only; corrected on-device rendering is unverified.


### Compact destination search

The owner still observed search outside the top toolbar after the explicit item
was added. The iOS 26+ path now omits `SearchFieldPlacement.toolbar`: Apple's
[placement documentation](https://developer.apple.com/documentation/swiftui/searchfieldplacement/toolbar)
describes its iPhone behavior as a field below the navigation bar.
`DefaultToolbarItem(kind: .search, placement: .topBarTrailing)` owns the placement,
with `.searchToolbarBehavior(.minimize)` following `.searchable` to request the
compact native control. Activation expands native search. The pre-iOS-26 fallback
and root sidebar search remain unchanged. This is a source correction based on
the API contract; the updated device behavior has not been verified. No builds
or tests were run.
