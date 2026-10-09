import SwiftUI
import SettingsKit

@main
struct SettingsKitDemoApp: App {
    @State private var settings = SettingsState()

    var body: some Scene {
        WindowGroup {
            Group{
                DemoSettings()
                    .settingsStyle(.sidebar)
            }
                .environment(settings)
        }
    }
}
