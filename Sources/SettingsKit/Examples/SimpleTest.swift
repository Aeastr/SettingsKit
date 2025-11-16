import SwiftUI

// Simplest possible test
struct SimpleTestSettings: SettingsContainer {
    var settingsBody: some SettingsContent {
        TestGroup()
    }
}

struct TestGroup: SettingsGroup {
    var title: String { "Test" }

    var settingsBody: some SettingsContent {
        SettingsItem("Item") {
            Text("Hello")
        }
    }
}

#Preview {
    SettingsView(SimpleTestSettings())
}
