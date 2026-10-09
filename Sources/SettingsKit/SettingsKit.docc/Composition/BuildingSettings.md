# Building Settings

Compose navigation groups, inline sections, and custom destinations from SwiftUI views.

## Organize controls into groups

``SettingsGroup`` is the primary component. Its default ``SettingsGroupPresentation/navigation`` presentation creates a destination; ``SettingsGroupPresentation/inline`` presents the content as a section in the current destination.

```swift
SettingsGroup("General") {
    SettingsGroup("About") {
        Text("Version 1.0")
    }

    SettingsGroup("Quick Options", .inline, footer: "Applied immediately.") {
        Toggle("Haptics", isOn: $haptics)
            .indexed("Haptics")
    }
}
```

Call ``SettingsGroup/settingsTags(_:)`` when alternate terms should match the group itself.

## Open a page programmatically

Pass a fresh ``SettingsNavigationRequest`` to `SettingsView` when an app route should open a settings page. List the unique, localized group titles from the root destination to the requested page. Inline sections are traversed automatically. The request selects the first destination in a split view and pushes any remaining pages on its detail stack.

```swift
SettingsView(
    container: settings,
    navigationRequest: request,
    onNavigationResult: { request, succeeded in
        // Consume the one-shot request and show recovery if it failed.
    }
)
```

SettingsKit reports failure when a title is missing or ambiguous. Keep app URL parsing and tab selection in the app router; SettingsKit resolves only its own group hierarchy.

## Keep presentation in styles

``SettingsGroup`` carries semantic hierarchy rather than decoration. It has no icon or visual accessory API. Use ``SettingsStyle`` or ``SettingsGroupStyle`` to present group titles and content. Ordinary SwiftUI views and modifiers remain available inside the content closure.

## Build a custom destination

Use ``CustomSettingsGroup`` when a destination does not fit the standard settings hierarchy. The group title and tags are indexed, but the view's internal controls are not traversed.

```swift
CustomSettingsGroup(
    "Storage",
    tags: ["disk", "cache"]
) {
    StorageDashboard()
}
```

For custom reusable content that still participates in the hierarchy, create a type conforming to ``SettingsContent``.
