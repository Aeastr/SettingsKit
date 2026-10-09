import SwiftUI
import SettingsKit

/// A realistic, shared iPhone settings hierarchy used by both built-in styles.
struct DemoSettings: SettingsContainer {
    @Environment(SettingsState.self) private var settings

    var settingsBody: some SettingsContent {
        @Bindable var state = settings

        SettingsGroup("Apple Account") {
            AppleAccountSettings(state: state)
        }
        .settingsTags(["profile", "iCloud", "Apple ID", "account"])

        ConnectivitySettings(state: state)
        DeviceSettings(state: state)
        ExperienceSettings(state: state)
        WellbeingAndPrivacySettings(state: state)
        ServicesAndAppsSettings(state: state)

        CustomSettingsGroup(
            "Custom Destination Demo",
            tags: ["custom UI", "dashboard", "arbitrary view", "CustomSettingsGroup"]
        ) {
            CustomDestinationDemo(state: state)
        }
    }
}
