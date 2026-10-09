import SwiftUI
import SettingsKit

/// Reusable nested content used by the built-in examples.
struct DeveloperSettingsGroup: SettingsContent {
    @Bindable var state: SettingsState

    var body: some SettingsContent {
        SettingsGroup("Developer", .inline) {
            SettingsGroup("Advanced") {
                Toggle(isOn: $state.debugMode) {
                    Text("Debug Mode")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()

                // Conditionally show these options only when debug mode is enabled
                if state.debugMode {
                    Toggle(isOn: $state.verboseLogging) {
                        Text("Verbose Logging")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.showHiddenFeatures) {
                        Text("Show Hidden Features")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()

                    SettingsGroup("Developer Tools") {
                        Toggle(isOn: $state.networkDebugging) {
                            Text("Network Debugging")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                            .toggleStyle(.switch)
                            .smallControlSizeOnMacOS()
                    }
                }
            }

            SettingsGroup("Appearance") {
                Toggle(isOn: $state.darkMode) {
                    Text("Dark Mode")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
        }
    }
}
