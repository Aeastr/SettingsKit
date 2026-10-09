# Introductory Rows and Navigation Titles

Keep a destination’s introductory content visible while coordinating its navigation title with scrolling.

## Mark an introductory row

Apply `settingsIntroduction()` to the app-owned row that introduces a destination. Declare one marked row per page directly in settings content or an inline group:

```swift
import SettingsKit
import SwiftUI

struct AccountSettings: SettingsContainer {
    @State private var syncEnabled = true

    var settingsBody: some SettingsContent {
        SettingsGroup("iCloud") {
            SettingsGroup("", .inline) {
                Text("Keep your settings available across your devices.")
                    .settingsIntroduction()
            }
            Toggle("Use iCloud", isOn: $syncEnabled)
                .indexed("Use iCloud")
        }
    }
}
```

The app owns the introductory row’s layout and copy. The marker preserves existing search metadata and does not index plain content. See <doc:IndexingAndSearch> to make a control searchable or exclude a subtree.

## Understand title behavior

On iOS 18 and later, built-in destination pages hide their visual title while the marked row is visible. When less than 1% of the row remains visible, the title fades and moves upward six points over 0.22 seconds. Reduce Motion uses a short fade. The semantic navigation title stays set.

Pages without a marker keep their normal inline title. Older iOS versions and other platforms retain normal title behavior. Custom styles own their title presentation; the automatic animation applies to built-in iOS destinations.

Each nested navigation page has independent introduction visibility. If the hierarchy changes so a page gains or loses its introduction, update `settingsIndexRevision` along with other structural changes. See <doc:SettingsKitArchitecture> for index lifecycle details.

## Preserve introduction metadata

Keep introduction-bearing content typed during registration. To exclude its rows from search, use `MyPage().unindexed()` rather than `AnyView(MyPage())`; the typed modifier preserves introduction metadata for the initial title state. Runtime visibility reports can recognize introductions inside opaque views after they render.

Built-in iOS destinations use inline toolbar titles and a persistent title item. The introductory row controls that title’s visibility; it does not change the semantic destination name or take ownership of the surrounding toolbar. See <doc:CustomPresentation> when your app needs complete navigation and toolbar control.
