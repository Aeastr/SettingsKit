# ``SettingsKit``

Build searchable, styled settings interfaces with a declarative SwiftUI API.

## Overview

SettingsKit turns a ``SettingsContainer`` into a hierarchy of ``SettingsGroup`` values and ordinary SwiftUI controls. Groups provide navigation structure while the `indexed` modifier family opts individual controls into search.

Use ``SettingsView`` for the built-in presentation, or use ``SettingsHost`` to place SettingsKit's index, search results, and navigation state inside an app-owned layout.

```swift
import SettingsKit
import SwiftUI

struct AppSettings: SettingsContainer {
    @State private var notificationsEnabled = true

    var settingsBody: some SettingsContent {
        SettingsGroup("General") {
            Toggle("Notifications", isOn: $notificationsEnabled)
                .indexed("Notifications")
        }
    }
}
```

## Topics

### Essentials

- <doc:MigratingToVersion3>
- <doc:UnderstandingSettingsKit>
- <doc:GettingStarted>
- <doc:BuildingSettings>
- ``SettingsContainer``
- ``SettingsContent``
- ``SettingsGroup``
- ``CustomSettingsGroup``

### Indexing and Search

- <doc:IndexingAndSearch>
- ``SettingsNode``
- ``SettingsSearch``
- ``DefaultSettingsSearch``
- ``SettingsSearchResult``

### Presentation and Styling

- <doc:CustomPresentation>
- <doc:StylingSettings>
- ``SettingsView``
- ``SettingsHost``
- ``SettingsPresentationContext``
- ``SettingsSearchResults``
- ``SettingsGroupStyle``
- ``SettingsStyle``

### Architecture

- <doc:SettingsKitArchitecture>
- <doc:MacOSNavigationState>
