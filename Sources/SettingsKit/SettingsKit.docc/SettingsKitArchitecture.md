# Architecture

Understand how SettingsKit combines metadata indexing with live SwiftUI views.

## Separate metadata from rendering

SettingsKit builds a tree of ``SettingsNode`` values from a ``SettingsContainer``. Nodes contain titles, tags, presentation modes, and child relationships. They do not retain SwiftUI views.

During the same traversal, the active ``SettingsContentScope`` registers view builders for groups and indexed controls. ``SettingsHost`` creates a separate registry for each host, preventing one presentation from resolving another presentation's views. Direct calls to ``SettingsContent/makeNodes()`` use a shared registration scope, while ``SettingsContent/makeNodes(in:)`` carries a specific host's scope through nested content.

## Render through two paths

Normal settings presentation renders the direct SwiftUI hierarchy. This keeps SwiftUI dependency tracking and control state intact.
The host builds search metadata when it first appears, then keeps that tree and its destination registry until `SettingsContainer.settingsIndexRevision` changes. Rendered controls remain live in a separate child view. Change the revision when titles, tags, or the settings structure changes; progress, counters, and status text do not need to rebuild the index. Dynamic values should live in their own row views, and transient values such as activity logs should generally not be indexed as search terms.

Search presentation traverses metadata, then resolves matching live controls from the host's registry. This allows search results to remain interactive while the index stays lightweight and hashable.

Both paths defer view-body evaluation to SwiftUI. Groups pass their ``SettingsContent`` value into the hierarchy instead of reading `body` directly, and registry-backed destinations resolve their content after SwiftUI mounts the destination. This distinction is especially important for the long-lived sidebar and detail columns used on macOS. See <doc:MacOSNavigationState> for the failure mode and fixes.

## Own presentation at the appropriate layer

``SettingsView`` combines the runtime with a ``SettingsStyle`` for the built-in experience. ``SettingsHost`` stops at ``SettingsPresentationContext`` so an app can own navigation, toolbars, tabs, and layout. ``SettingsGroupStyle`` provides a narrower extension point that changes only group appearance and interaction.

## Navigate with configurations

``SettingsGroupConfiguration`` carries a group's identity, label information, presentation mode, child metadata, and resolved content. Built-in styles use it as a `NavigationStack` value, and custom shells can do the same.

Node identifiers are derived from group or item metadata and remain consistent across repeated index construction during a process. They connect metadata to the registry and provide SwiftUI identity. Applications should still avoid defining duplicate groups or indexed items with identical identifying metadata in the same hierarchy.

## Search in ordered passes

``DefaultSettingsSearch`` recursively walks the node tree, normalizes titles and tags, scores matches by relevance, and preserves declaration order when scores are equal. Results retain their closest navigation parent so the built-in renderer can group related controls.

## Related debugging notes

- <doc:MacOSNavigationState>
