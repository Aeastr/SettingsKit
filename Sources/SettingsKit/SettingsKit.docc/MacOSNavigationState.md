# macOS Navigation and Live State

Understand why a control could show an old value after macOS sidebar navigation, why search behaved differently, and how SettingsKit now keeps both routes connected to live state.

## The symptoms

The bug had two visible forms:

| Route | Symptom |
| --- | --- |
| Normal sidebar | Change a toggle in Wi-Fi, open Bluetooth, and return to Wi-Fi. The switch could show its original value again. |
| Search | A group opened from a search result could contain controls that did not update reliably. |

The normal-sidebar behavior looked like failed persistence, but it was not a model or storage failure. Instrumenting the demo established this exact sequence:

1. `Ask to Join Networks` began as `true`.
2. Pressing its switch set `SettingsState.askToJoinNetworks` to `false`.
3. Navigating to Bluetooth and back did not set the property to `true` again.
4. The returned macOS switch nevertheless displayed the old on state.

The model contained `false`; the remounted detail interface displayed `true`. This distinction matters because saving the value again, adding another state store, or changing disk persistence would not solve the problem.

## Cause 1: macOS sidebar rows owned their destinations

The old macOS sidebar used a destination closure in every row:

```swift
NavigationLink {
    NavigationStack {
        MacOSSidebarDetail(configuration: configuration)
    }
} label: {
    configuration.label
}
```

This gave each sidebar link its own prepared destination and navigation stack. `NavigationSplitView` and AppKit could retain those destinations independently of the visible detail column. When a user left Wi-Fi and later selected it again, macOS could restore the previously prepared control hierarchy.

The switch did write through its `Binding`. While it remained visible, its AppKit control also reflected the click. The problem appeared when the destination was revisited: the retained control state came from the destination's earlier presentation rather than from a newly installed detail hierarchy.

This is why the behavior looked inconsistent. Refreshing the hierarchy through search could expose the current model value, while returning through the original sidebar link could expose the retained control again.

### The normal-navigation fix

The decisive clue was that search now worked while ordinary navigation still failed. Search destinations were already resolving their content from the live registry after mounting. Ordinary ``SettingsGroup`` configurations were still carrying `AnyView(content)` captured while the sidebar hierarchy was built.

Navigation groups now use the same `RegisteredSettingsNodeContent` resolver as search. Inline groups still render their content directly because they are already mounted at their point of use. This makes the working search route and the normal route resolve controls in the same way.

The macOS sidebar now follows the same broad architecture as the iOS sidebar. Rows contain values rather than destination views:

```swift
NavigationLink(value: configuration) {
    configuration.label
}
```

The `List` owns one selection, and the split view owns one detail `NavigationStack`. That detail renders the selected configuration:

```swift
NavigationStack(path: configuration.navigationPath) {
    if let selectedGroup {
        MacOSSidebarDetail(configuration: selectedGroup)
            .id(detailGeneration)
    }
}
```

When the selected group changes, SettingsKit increments `detailGeneration`. The new identity tells SwiftUI to install a new detail hierarchy instead of asking AppKit to reuse controls from the previous destination. The new controls read their values from the existing bindings, so they display the model's current values.

Changing the top-level selection also clears the nested navigation path. A path belonging to Wi-Fi should not remain active after the user selects Bluetooth.

Nested macOS rows use `NavigationLink(value:)` as well. One central navigation stack therefore owns both top-level selection and deeper routes.

## Cause 2: search resolved destination content before presentation

Search begins with metadata. A ``SettingsNode`` stores identifiers, titles, tags, presentation modes, and relationships; it does not store a SwiftUI view. A host-local registry maps each node identifier to a builder for its live content.

The old search path asked the registry for a group view while creating the search result link. That was too early: the result still belonged to the sidebar, not to the active detail destination. macOS could retain the resulting `AnyView` with the link and later present that prepared value.

Search configurations now store a small resolver view containing only the node identifier and registry. The registry lookup happens from the resolver's `body`, after SwiftUI mounts the destination:

```swift
private struct RegisteredSettingsNodeContent: View {
    let id: UUID
    let registry: SettingsNodeViewRegistry

    var body: some View {
        registry.view(for: id)
    }
}
```

Search navigation links are also value-based on macOS. Search and ordinary sidebar navigation therefore enter the same central detail stack instead of creating two kinds of macOS destination lifecycle.

## Supporting lifecycle fixes

Two smaller problems made the navigation behavior easier to trigger and harder to reason about.

### Mount settings content instead of calling `body`

``SettingsGroup`` previously erased `content.body`:

```swift
AnyView(content.body)
```

A view's `body` is SwiftUI's job to evaluate after installing that view in a hierarchy. Calling it directly can bypass the lifecycle in which SwiftUI connects environment values, observation, state, and identity.

SettingsKit now erases the settings content value itself:

```swift
AnyView(content)
```

The registry builders follow the same rule. SwiftUI decides when to evaluate the content.

### Build one settings hierarchy per host update

``SettingsHost`` previously evaluated `container.settingsBody` once for indexing and again for normal rendering. Even when both results referenced the same app model, this created separate control graphs for search and the ordinary page.

The host now evaluates `settingsBody` once and uses that value for metadata, registry builders, and root presentation. This is not what reset the model—the instrumented value proved the model never reset—but it removes an unnecessary difference between the two routes and guarantees that search and normal presentation begin with the same controls and bindings.

## Why iOS did not show the same bug

The old implementations were not structurally identical.

On iOS and iPadOS, sidebar rows already used value-based navigation. The `NavigationSplitView` updated a selected ``SettingsGroupConfiguration``, and one detail `NavigationStack` rendered that selection. A sidebar row did not own a separate prepared destination.

On macOS, every row used a destination-based link containing its own detail stack. That route crossed from SwiftUI navigation into long-lived AppKit sidebar and switch controls. Retaining destination state is normally useful, but here it allowed a control's earlier presentation state to outlive the detail visit that changed its binding.

The fix does not depend on assuming that macOS always caches and iOS always recreates views. It removes the architectural difference: both platforms now express sidebar navigation as values and let the split view's detail column own presentation.

## Why `TabbedCardsSettingsDemo` behaved correctly

The tabbed cards example provided an important comparison because it uses the same `SettingsState` model.

Visited tabs remain mounted in a `ZStack`. Inactive tabs become transparent and stop accepting input, but their control hierarchies are not removed. Moving between tabs therefore does not ask the platform to restore a discarded destination control.

The example also owns its navigation stacks centrally and uses value-based routes. Its search page resolves matching controls inline through ``SettingsPresentationContext/indexedView(for:)`` instead of putting prepared destinations inside sidebar rows.

Finally, `TabbedSettingsContainer` stores its `@Bindable` wrapper. Each tab host still has independent search and navigation state, but every control writes to the same `SettingsState` reference.

These differences explain why Tabbed Cards worked: it avoided the destination lifecycle that exposed the macOS sidebar bug. It also confirmed that `SettingsState` and its bindings were capable of preserving the values.

## What SettingsKit does and does not persist

SettingsKit preserves the normal SwiftUI bindings supplied by an application. It does not own the values behind those bindings and does not save them to disk.

For the demo, "persistence" in this discussion means that a value remains in the shared in-memory `SettingsState` while navigating. Long-term storage across application launches remains the application's responsibility through `UserDefaults`, a database, files, or another persistence system.

## Regression coverage

Automated tests now verify that:

- creating a search group configuration does not resolve its registered view immediately;
- one ``SettingsHost`` body evaluation builds `settingsBody` only once;
- search metadata continues to preserve navigation and matched-control behavior.

The important macOS interaction test is a round trip, not only the first presentation:

1. Open Wi-Fi.
2. Change both `Enable Wi-Fi` and `Ask to Join Networks`.
3. Open Bluetooth.
4. Return to Wi-Fi and verify both displayed values.
5. Repeat through search and after clearing the search query.

For the broader metadata and rendering model, see <doc:SettingsKitArchitecture>. For search behavior and custom result rendering, see <doc:IndexingAndSearch>.
