# SettingsKit - Architecture

How SettingsKit combines metadata indexing with reactive SwiftUI views.

## Overview

SettingsKit uses a hybrid architecture that combines **metadata-only nodes** for indexing and search with a **view registry system** for dynamic rendering. This design enables powerful search capabilities while maintaining live, reactive SwiftUI views with proper state observation.

```
┌─────────────────────────────────────────────────────────┐
│                    SettingsKit                          │
├─────────────────────────────────────────────────────────┤
│  Metadata Layer    │  View Layer     │  Rendering       │
│  (Node Tree)       │  (Registry)     │  (SwiftUI)       │
│                    │                 │                  │
│  - Titles          │  - View builders│  - Direct        │
│  - Icons           │  - ID mapping   │    hierarchy     │
│  - Tags            │                 │  - State         │
│  - Structure       │                 │    observation   │
└─────────────────────────────────────────────────────────┘
```

## The Node Tree

When you define settings using `SettingsGroup` and views with `.indexed()`, SettingsKit builds an internal node tree representing your settings hierarchy.

Groups and indexed views become nodes. Nodes store only metadata—no views:

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

| Property | Purpose |
|----------|---------|
| UUID | Stable identifier (hash-based) for navigation and registry lookup |
| Title | Display text for search results |
| Icon | SF Symbol name |
| Tags | Additional keywords for search |
| Presentation Mode | Navigation link or inline section |
| Children | Nested groups and items |

Nodes do **not** store view content.

## The View Registry

The `SettingsNodeViewRegistry` maps node IDs to view builder closures:

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

This allows search results to render **actual interactive controls** rather than static labels.

## Search

The default search implementation uses intelligent scoring:

1. **Normalization** - Removes spaces, special characters, converts to lowercase
2. **Tree Traversal** - Recursively searches all nodes by title and tags
3. **Scoring** - Ranks matches by relevance:

| Match Type | Score |
|------------|-------|
| Exact match | 1000 |
| Starts with | 500 |
| Contains | 300 |
| Tag match | 100 |

4. **Result Grouping** - Groups matched items by their parent group
5. **View Lookup** - Retrieves actual view builders from registry

## Rendering Modes

SettingsKit uses two rendering approaches:

**Normal Rendering (Direct Hierarchy)**
- Views render directly from the SwiftUI view hierarchy
- Full state observation through SwiftUI's dependency tracking
- Controls update reactively as state changes
- No registry lookup needed

**Search Results Rendering (Registry Lookup)**
- Matched items retrieve view builders from the registry
- Views instantiated fresh for each search
- State bindings remain live and reactive
- Allows showing actual controls in search results

## Navigation

Two navigation styles work with the same indexed tree:

### Sidebar Style (NavigationSplitView)

- Split-view layout with sidebar and detail pane
- Top-level groups appear in the sidebar
- macOS: destination-based NavigationLink for proper control updates
- iOS: selection-based navigation
- Detail pane has its own NavigationStack for nested groups

### Single Column Style (NavigationStack)

- Push navigation for all groups
- Linear navigation hierarchy
- Inline groups render as section headers
- Search results push onto the navigation stack

## Stable IDs

Node UUIDs use hash-based generation rather than random UUIDs:

```swift
var hasher = Hasher()
hasher.combine(title)
hasher.combine(icon)
let hashValue = hasher.finalize()
// Convert hash to UUID bytes...
```

This ensures the same setting always gets the same ID across multiple `makeNodes()` calls, which is critical for:

- Matching search results to views in the registry
- Maintaining navigation state
- View identity and animation stability

## Platform Differences

| Feature | iOS | macOS |
|---------|-----|-------|
| Single column | NavigationStack | NavigationStack |
| Sidebar | NavigationSplitView (selection-based) | NavigationSplitView (destination-based) |
| Search | `.searchable()` | `.searchable()` |
| Inline groups | Section headers | Section headers |
| Control updates | Works with selection | Requires destination-based links |

## Why This Design?

The hybrid architecture solves multiple challenges:

- **Reactive Controls** - Direct view hierarchy preserves SwiftUI state observation
- **Powerful Search** - Metadata nodes enable fast, comprehensive search
- **Interactive Search Results** - Registry allows rendering actual controls in search
- **Performance** - Lazy indexing builds the tree only when needed
- **Dynamic Content** - Supports conditional settings (if/else, ForEach)
- **Platform Adaptive** - Navigation adapts to macOS vs iOS patterns
- **Extensibility** - Custom search and styles work with the same tree
- **Type Safety** - SwiftUI result builders validate at compile time

## Notes

The hybrid view registry architecture emerged from solving a critical macOS bug where `NavigationSplitView` with selection-based navigation caused interactive controls to stop updating visually. The solution separates metadata (nodes) from views (registry), using direct view hierarchies for normal rendering and registry lookups for search results.
