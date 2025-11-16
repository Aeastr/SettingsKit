import SwiftUI

// MARK: - Example Settings Container

struct AppSettings: SettingsContainer {
    var settingsBody: some SettingsContent {
        GeneralSettings()
        AppearanceSettings()
        AdvancedSettings()
    }
}

// MARK: - Top-Level Groups

struct GeneralSettings: SettingsGroup {
    @State private var appName = "My App"
    @State private var enableNotifications = true

    var title: String { "General" }
    var icon: String? { "gearshape" }
    var tags: [String] { ["settings", "general"] }

    var settingsBody: some SettingsContent {
        SettingsItem("App Name", icon: "app") {
            TextField("App Name", text: $appName)
        }

        SettingsItem("Enable Notifications", icon: "bell", tags: ["alerts"]) {
            Toggle("Enable Notifications", isOn: $enableNotifications)
        }

        // Nested group!
        NotificationSettings()
    }
}

struct AppearanceSettings: SettingsGroup {
    @State private var darkMode = false
    @State private var accentColor = Color.blue

    var title: String { "Appearance" }
    var icon: String? { "paintbrush" }
    var tags: [String] { ["theme", "colors"] }

    var settingsBody: some SettingsContent {
        SettingsItem("Dark Mode", icon: "moon.fill", tags: ["theme"]) {
            Toggle("Dark Mode", isOn: $darkMode)
        }

        SettingsItem("Accent Color", icon: "paintpalette") {
            ColorPicker("Accent Color", selection: $accentColor)
        }
    }
}

struct AdvancedSettings: SettingsGroup {
    @State private var debugMode = false
    @State private var logLevel = "Info"

    var title: String { "Advanced" }
    var icon: String? { "hammer" }
    var tags: [String] { ["developer", "debug"] }

    var settingsBody: some SettingsContent {
        SettingsItem("Debug Mode", icon: "ladybug", tags: ["developer"]) {
            Toggle("Debug Mode", isOn: $debugMode)
        }

        SettingsItem("Log Level", icon: "doc.text") {
            Picker("Log Level", selection: $logLevel) {
                Text("Error").tag("Error")
                Text("Warning").tag("Warning")
                Text("Info").tag("Info")
                Text("Debug").tag("Debug")
            }
        }
    }
}

// MARK: - Nested Group Example

struct NotificationSettings: SettingsGroup {
    @State private var soundEnabled = true
    @State private var badgeEnabled = true

    var title: String { "Notification Settings" }
    var icon: String? { "bell.badge" }

    var settingsBody: some SettingsContent {
        SettingsItem("Sound", icon: "speaker.wave.2") {
            Toggle("Sound", isOn: $soundEnabled)
        }

        SettingsItem("Badge", icon: "circle.badge") {
            Toggle("Badge", isOn: $badgeEnabled)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView(AppSettings())
            .navigationTitle("Settings")
    }
}
