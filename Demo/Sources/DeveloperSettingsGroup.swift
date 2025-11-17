import SwiftUI
import SettingsKit

struct DeveloperSettingsGroup: SettingsContent {
    @Bindable var state: SettingsState

    var body: some SettingsContent {
        SettingsGroup("Developer", .inline) {
            SettingsGroup("Advanced", systemImage: "hammer") {
                SettingsItem("Debug Mode", icon: "ladybug") {
                    Toggle("Debug Mode", isOn: $state.debugMode)
                }

                // Conditionally show these options only when debug mode is enabled
                if state.debugMode {
                    SettingsItem("Verbose Logging", icon: "doc.text.fill") {
                        Toggle("Verbose Logging", isOn: $state.verboseLogging)
                    }

                    SettingsItem("Show Hidden Features", icon: "eye") {
                        Toggle("Show Hidden Features", isOn: $state.showHiddenFeatures)
                    }

                    SettingsGroup("Developer Tools", systemImage: "wrench.and.screwdriver") {
                        SettingsItem("Network Debugging", icon: "network") {
                            Toggle("Network Debugging", isOn: $state.networkDebugging)
                        }
                    }
                }
            }

            SettingsGroup("Appearance", systemImage: "paintbrush") {
                SettingsItem("Dark Mode", icon: "moon.fill") {
                    Toggle("Dark Mode", isOn: $state.darkMode)
                }
            }
        }
    }
}
