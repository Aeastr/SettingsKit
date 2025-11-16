import SwiftUI
import SettingsKit

@main
struct SettingsKitDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SettingsView(DemoSettings())
                    .navigationTitle("Settings")
            }
        }
    }
}

struct DemoSettings: SettingsContainer {
    var body: some SettingsContent {
        GeneralSettings()
        AppearanceSettings()
        AdvancedSettings()
    }
}

struct GeneralSettings: SettingsGroup {
    var title: String { "General" }
    var icon: String? { "gearshape" }

    var settingsBody: some SettingsContent {
        DeviceInfoSection()
        ConnectivitySection()
        SystemSection()
        ManagementSection()
    }
}

// Inline sections for visual grouping
struct DeviceInfoSection: SettingsGroup {
    var title: String { "Device Information" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        AboutSettings()
        SoftwareUpdateSettings()
        StorageSettings()
    }
}

struct ConnectivitySection: SettingsGroup {
    var title: String { "Connectivity" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        AirDropSettings()
        AirPlaySettings()
        PictureInPictureSettings()
    }
}

struct SystemSection: SettingsGroup {
    var title: String { "System" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        CarPlaySettings()
    }
}

struct ManagementSection: SettingsGroup {
    var title: String { "Settings & Privacy" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        AutoFillSettings()
        DateTimeSettings()
        KeyboardSettings()
        LanguageSettings()
        VPNSettings()
    }
}

// Nested settings groups
struct AboutSettings: SettingsGroup {
    var title: String { "About" }
    var icon: String? { "info.circle" }

    var settingsBody: some SettingsContent {
        SettingsItem("Device Name") {
            Text("iPhone")
        }
    }
}

struct SoftwareUpdateSettings: SettingsGroup {
    var title: String { "Software Update" }
    var icon: String? { "gear.badge" }

    var settingsBody: some SettingsContent {
        SettingsItem("Status") {
            Text("Up to date")
        }
    }
}

struct StorageSettings: SettingsGroup {
    var title: String { "iPhone Storage" }
    var icon: String? { "internaldrive" }

    var settingsBody: some SettingsContent {
        SettingsItem("Used") {
            Text("64 GB")
        }
    }
}

struct AirDropSettings: SettingsGroup {
    @State private var airDropEnabled = true

    var title: String { "AirDrop" }
    var icon: String? { "airplayaudio" }

    var settingsBody: some SettingsContent {
        SettingsItem("Receiving", icon: "person.crop.circle") {
            Toggle("Receiving", isOn: $airDropEnabled)
        }
    }
}

struct AirPlaySettings: SettingsGroup {
    var title: String { "AirPlay & Continuity" }
    var icon: String? { "tv.and.hifispeaker.fill" }

    var settingsBody: some SettingsContent {
        SettingsItem("Status") {
            Text("Enabled")
        }
    }
}

struct PictureInPictureSettings: SettingsGroup {
    @State private var pipEnabled = true

    var title: String { "Picture in Picture" }
    var icon: String? { "rectangle.on.rectangle" }

    var settingsBody: some SettingsContent {
        SettingsItem("Automatically Start", icon: "play.rectangle") {
            Toggle("Auto Start", isOn: $pipEnabled)
        }
    }
}

struct CarPlaySettings: SettingsGroup {
    var title: String { "CarPlay" }
    var icon: String? { "car" }

    var settingsBody: some SettingsContent {
        SettingsItem("Status") {
            Text("Not Connected")
        }
    }
}

struct AutoFillSettings: SettingsGroup {
    @State private var autoFillPasswords = true

    var title: String { "AutoFill & Passwords" }
    var icon: String? { "key.fill" }

    var settingsBody: some SettingsContent {
        SettingsItem("AutoFill Passwords", icon: "key") {
            Toggle("AutoFill", isOn: $autoFillPasswords)
        }
    }
}

struct DateTimeSettings: SettingsGroup {
    @State private var use24Hour = false

    var title: String { "Date & Time" }
    var icon: String? { "clock" }

    var settingsBody: some SettingsContent {
        SettingsItem("24-Hour Time", icon: "clock") {
            Toggle("24-Hour", isOn: $use24Hour)
        }
    }
}

struct KeyboardSettings: SettingsGroup {
    @State private var autoCorrect = true

    var title: String { "Keyboard" }
    var icon: String? { "keyboard" }

    var settingsBody: some SettingsContent {
        SettingsItem("Auto-Correction", icon: "text.cursor") {
            Toggle("Auto-Correction", isOn: $autoCorrect)
        }
    }
}

struct LanguageSettings: SettingsGroup {
    var title: String { "Language & Region" }
    var icon: String? { "globe" }

    var settingsBody: some SettingsContent {
        SettingsItem("Language") {
            Text("English")
        }
    }
}

struct VPNSettings: SettingsGroup {
    @State private var vpnEnabled = false

    var title: String { "VPN & Device Management" }
    var icon: String? { "network" }

    var settingsBody: some SettingsContent {
        SettingsItem("VPN Status", icon: "lock.shield") {
            Toggle("VPN", isOn: $vpnEnabled)
        }
    }
}

struct AppearanceSettings: SettingsGroup {
    @State private var darkMode = false

    var title: String { "Appearance" }
    var icon: String? { "paintbrush" }

    var settingsBody: some SettingsContent {
        SettingsItem("Dark Mode", icon: "moon.fill") {
            Toggle("Dark Mode", isOn: $darkMode)
        }
    }
}

struct AdvancedSettings: SettingsGroup {
    @State private var debugMode = false

    var title: String { "Advanced" }
    var icon: String? { "hammer" }

    var settingsBody: some SettingsContent {
        SettingsItem("Debug Mode", icon: "ladybug") {
            Toggle("Debug Mode", isOn: $debugMode)
        }
    }
}

