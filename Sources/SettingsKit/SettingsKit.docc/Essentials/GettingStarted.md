# Getting Started

Use ``SettingsHost`` as the entry point for new integrations. Declare settings in ``SettingsContainer/settingsBody`` and implement an explicit `body` that owns the screen.

```swift
import SettingsKit
import SwiftUI

struct AppSettings: SettingsContainer {
    @State private var notificationsEnabled = true
    @State private var displayName = "Guest"

    var body: some View {
        SettingsHost(container: self) { context in
            NavigationStack(path: context.navigationPath) {
                Form { context.content }
                    .navigationTitle(context.title)
                    .searchable(text: context.searchText)
                    .navigationDestination(for: SettingsGroupConfiguration.self) { group in
                        Form { group.content }.navigationTitle(group.title)
                    }
            }
        }
    }

    var settingsBody: some SettingsContent {
        SettingsGroup("General") {
            Toggle("Notifications", isOn: $notificationsEnabled)
                .indexed("Notifications", tags: ["alerts"])
            TextField("Display Name", text: $displayName)
                .indexed("Display Name")
        }
    }
}

struct SettingsScreen: View {
    var body: some View {
        AppSettings()
    }
}
```

`SettingsContainer` declares the hierarchy; its explicit body uses `SettingsHost` to supply runtime values to app-owned SwiftUI. Group titles are searchable; individual controls opt in with `.indexed(...)`. Search results display the live controls bound to the same values.

The example uses local view state. Your app owns settings models, persistence, validation, actions, and errors from those actions. Use your normal observable model, bindings, or persistent storage when values must survive the view’s lifetime. SettingsKit does not save them automatically.

See <doc:CustomPresentation> for app-owned navigation, toolbar placement and search rendering. The implicit container body and complete styled presentation APIs are deprecated and retained for compatibility.
