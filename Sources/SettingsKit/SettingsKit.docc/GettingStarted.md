# Getting Started

Define a settings container, group related controls, and opt controls into search.

## Create a settings container

Conform a SwiftUI view to ``SettingsContainer`` and implement ``SettingsContainer/settingsBody`` with a ``SettingsContentBuilder`` block. The protocol supplies the built-in ``SettingsView`` as its default body.

The `settingsBody` requirement applies the builder automatically, so implementations do not write the attribute explicitly. Custom ``SettingsContent`` types with multiple top-level expressions do need an explicit `@SettingsContentBuilder`; see <doc:UnderstandingSettingsKit#Extracted-settings-content>.

```swift
import SettingsKit
import SwiftUI

struct AppSettings: SettingsContainer {
    @State private var darkMode = false
    @State private var displayName = "Guest"

    var settingsBody: some SettingsContent {
        SettingsGroup("Appearance") {
            Toggle("Dark Mode", isOn: $darkMode)
                .indexed("Dark Mode", tags: ["theme", "night"])
        }

        SettingsGroup("Profile") {
            TextField("Display Name", text: $displayName)
                .indexed("Display Name")
        }
    }
}
```

Groups are always part of the metadata hierarchy. Ordinary SwiftUI views render normally, but only views marked with an `indexed` modifier become individual search targets. See <doc:IndexingAndSearch> for the complete search model.

## Choose a presentation

The default protocol implementation uses ``SettingsView`` and the sidebar style. Apply `settingsStyle(_:)` to use another full presentation style:

```swift
AppSettings()
    .settingsStyle(.single)
```

When your app already owns its navigation, toolbar, or tabs, use ``SettingsHost`` instead. See <doc:CustomPresentation>.

## Next steps

- Use <doc:BuildingSettings> to learn about groups, styling boundaries, and custom content.
- Use <doc:StylingSettings> to customize group or container presentation.
