import SwiftUI
import SettingsKit
import ShortcutsGallery

@main
struct SettingsKitDemoApp: App {
    @State private var settings = SettingsState()
//    @State private var stressTest = StressTestSettings()

    var body: some Scene {
        WindowGroup {
            ExampleShortcutsGallery()
                .environment(settings)
//            StressTestSettingsContainer(settings: stressTest)
        }
    }
}
