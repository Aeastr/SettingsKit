//
//  SettingsKitDemoWatchApp.swift
//  SettingsKitDemoWatch Watch App
//
//  Created by Aether on 11/17/25.
//

import SwiftUI
import SettingsKit

@main
struct SettingsKitDemoWatch_Watch_AppApp: App {
    @State private var settings = SettingsState()

    var body: some Scene {
        WindowGroup {
            DemoSettings()
                .environment(settings)
        }
    }
}
