import SwiftUI
import SettingsKit

struct DeveloperSettingsGroup: SettingsContent {
    @Bindable var state: SettingsState

    var body: some SettingsContent {
        SettingsGroup("Developer", .inline) {
            SettingsGroup("Advanced", systemImage: "hammer") {
                Toggle("Debug Mode", isOn: $state.debugMode)

                // Conditionally show these options only when debug mode is enabled
                if state.debugMode {
                    Toggle("Verbose Logging", isOn: $state.verboseLogging)
                    Toggle("Show Hidden Features", isOn: $state.showHiddenFeatures)

                    SettingsGroup("Developer Tools", systemImage: "wrench.and.screwdriver") {
                        Toggle("Network Debugging", isOn: $state.networkDebugging)
                    }
                }
            }

            SettingsGroup("Appearance", systemImage: "paintbrush") {
                Toggle("Dark Mode", isOn: $state.darkMode)
            }
        }
    }
}
