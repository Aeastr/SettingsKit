import SwiftUI
import SettingsKit

@main
struct SettingsKitDemoApp: App {
    var body: some Scene {
        WindowGroup {
            SettingsView(DemoSettings())
        }
    }
}

struct DemoSettings: SettingsContainer {
    var settingsBody: some SettingsContent {
        ProfileSection()
        QuickSettingsSection()
        QuickSettings2()
        MainSettingsSection()
        MainSettings2()
        MainSettings3()
        MainSettings4()
        MainSettings5()
        MainSettings6()
        MainSettings7()
    }
}

// MARK: - Profile Section
struct ProfileSection: SettingsGroup {
    var title: String { "Profile" }
    var icon: String? { "person.crop.circle.fill" }

    var settingsBody: some SettingsContent {
        SettingsItem("Account Info") {
            VStack(alignment: .leading) {
                Text("Aether")
                    .font(.headline)
                Text("Apple Account, iCloud+, and more")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Quick Settings Sections
struct QuickSettingsSection: SettingsGroup {
    var title: String { "Connections" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        AirplaneModeItem()
        WiFiItem()
        BluetoothItem()
        CellularItem()
        PersonalHotspotItem()
    }
}

struct QuickSettings2: SettingsGroup {
    var title: String { "Battery" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        BatteryItem()
        VPNItem()
    }
}

struct MainSettingsSection: SettingsGroup {
    var title: String { "Main" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        GeneralSettings()
        AccessibilityItem()
        ActionButtonItem()
        AppleIntelligenceItem()
        CameraItem()
        ControlCenterItem()
        DisplayBrightnessItem()
        HomeScreenItem()
    }
}

struct MainSettings2: SettingsGroup {
    var title: String { "Display & Interface" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        SearchItem()
        StandByItem()
        WallpaperItem()
    }
}

struct MainSettings3: SettingsGroup {
    var title: String { "Notifications & Focus" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        NotificationsItem()
        SoundsHapticsItem()
        FocusItem()
        ScreenTimeItem()
    }
}

struct MainSettings4: SettingsGroup {
    var title: String { "Safety & Privacy" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        EmergencySOSItem()
        PrivacySecurityItem()
    }
}

struct MainSettings5: SettingsGroup {
    var title: String { "Cloud & Services" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        GameCenterItem()
        iCloudItem()
        WalletApplePayItem()
    }
}

struct MainSettings6: SettingsGroup {
    var title: String { "Applications" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        AppsItem()
    }
}

struct MainSettings7: SettingsGroup {
    var title: String { "Developer" }
    var style: SettingsGroupStyle { .inline }

    var settingsBody: some SettingsContent {
        AdvancedSettings()
    }
}

// MARK: - Quick Settings Items
struct AirplaneModeItem: SettingsGroup {
    @State private var enabled = false
    var title: String { "Airplane Mode" }
    var icon: String? { "airplane" }
    var settingsBody: some SettingsContent {
        SettingsItem("Toggle") { Toggle("Enabled", isOn: $enabled) }
    }
}

struct WiFiItem: SettingsGroup {
    var title: String { "Wi-Fi" }
    var icon: String? { "wifi" }
    var settingsBody: some SettingsContent {
        SettingsItem("Network", searchable: false) { Text("Tabley 5").foregroundStyle(.secondary) }
    }
}

struct BluetoothItem: SettingsGroup {
    @State private var enabled = true
    var title: String { "Bluetooth" }
    var icon: String? { "wave.3.right" }
    var settingsBody: some SettingsContent {
        SettingsItem("Toggle") { Toggle("Enabled", isOn: $enabled) }
    }
}

struct CellularItem: SettingsGroup {
    var title: String { "Cellular" }
    var icon: String? { "antenna.radiowaves.left.and.right" }
    var settingsBody: some SettingsContent {
        SettingsItem("Data", searchable: false) { Text("5G").foregroundStyle(.secondary) }
    }
}

struct PersonalHotspotItem: SettingsGroup {
    @State private var enabled = false
    var title: String { "Personal Hotspot" }
    var icon: String? { "personalhotspot" }
    var settingsBody: some SettingsContent {
        SettingsItem("Toggle") { Toggle("Enabled", isOn: $enabled) }
    }
}

struct BatteryItem: SettingsGroup {
    var title: String { "Battery" }
    var icon: String? { "battery.100" }
    var settingsBody: some SettingsContent {
        SettingsItem("Level", searchable: false) { Text("94%").foregroundStyle(.secondary) }
    }
}

struct VPNItem: SettingsGroup {
    @State private var enabled = false
    var title: String { "VPN" }
    var icon: String? { "network" }
    var settingsBody: some SettingsContent {
        SettingsItem("Toggle") { Toggle("Enabled", isOn: $enabled) }
    }
}

// MARK: - Main Settings Items
struct AccessibilityItem: SettingsGroup {
    var title: String { "Accessibility" }
    var icon: String? { "figure.arms.open" }
    var settingsBody: some SettingsContent {
        SettingsItem("Options", searchable: false) { Text("Configure").foregroundStyle(.secondary) }
    }
}

struct ActionButtonItem: SettingsGroup {
    var title: String { "Action Button" }
    var icon: String? { "button.programmable" }
    var settingsBody: some SettingsContent {
        SettingsItem("Action", searchable: false) { Text("Shortcuts").foregroundStyle(.secondary) }
    }
}

struct AppleIntelligenceItem: SettingsGroup {
    @State private var enabled = true
    var title: String { "Apple Intelligence & Siri" }
    var icon: String? { "apple.logo" }
    var settingsBody: some SettingsContent {
        SettingsItem("Toggle") { Toggle("Enabled", isOn: $enabled) }
    }
}

struct CameraItem: SettingsGroup {
    var title: String { "Camera" }
    var icon: String? { "camera.fill" }
    var settingsBody: some SettingsContent {
        SettingsItem("Settings", searchable: false) { Text("Configure").foregroundStyle(.secondary) }
    }
}

struct ControlCenterItem: SettingsGroup {
    var title: String { "Control Center" }
    var icon: String? { "switch.2" }
    var settingsBody: some SettingsContent {
        SettingsItem("Controls", searchable: false) { Text("Customize").foregroundStyle(.secondary) }
    }
}

struct DisplayBrightnessItem: SettingsGroup {
    @State private var autoBrightness = true
    var title: String { "Display & Brightness" }
    var icon: String? { "sun.max.fill" }
    var settingsBody: some SettingsContent {
        SettingsItem("Auto-Brightness") { Toggle("Auto", isOn: $autoBrightness) }
    }
}

struct HomeScreenItem: SettingsGroup {
    var title: String { "Home Screen & App Library" }
    var icon: String? { "square.grid.2x2" }
    var settingsBody: some SettingsContent {
        SettingsItem("Layout", searchable: false) { Text("Standard").foregroundStyle(.secondary) }
    }
}

struct SearchItem: SettingsGroup {
    @State private var siriSuggestions = true
    var title: String { "Search" }
    var icon: String? { "magnifyingglass" }
    var settingsBody: some SettingsContent {
        SettingsItem("Siri Suggestions") { Toggle("Enabled", isOn: $siriSuggestions) }
    }
}

struct StandByItem: SettingsGroup {
    @State private var autoStandby = true
    var title: String { "StandBy" }
    var icon: String? { "platter.2.filled.iphone" }
    var settingsBody: some SettingsContent {
        SettingsItem("Automatic") { Toggle("Auto", isOn: $autoStandby) }
    }
}

struct WallpaperItem: SettingsGroup {
    var title: String { "Wallpaper" }
    var icon: String? { "photo.on.rectangle" }
    var settingsBody: some SettingsContent {
        SettingsItem("Current", searchable: false) { Text("Dynamic").foregroundStyle(.secondary) }
    }
}

struct NotificationsItem: SettingsGroup {
    var title: String { "Notifications" }
    var icon: String? { "bell.badge.fill" }
    var settingsBody: some SettingsContent {
        SettingsItem("Scheduled", searchable: false) { Text("3 apps").foregroundStyle(.secondary) }
    }
}

struct SoundsHapticsItem: SettingsGroup {
    var title: String { "Sounds & Haptics" }
    var icon: String? { "speaker.wave.3.fill" }
    var settingsBody: some SettingsContent {
        SettingsItem("Ringtone", searchable: false) { Text("Reflection").foregroundStyle(.secondary) }
    }
}

struct FocusItem: SettingsGroup {
    var title: String { "Focus" }
    var icon: String? { "moon.fill" }
    var settingsBody: some SettingsContent {
        SettingsItem("Active", searchable: false) { Text("None").foregroundStyle(.secondary) }
    }
}

struct ScreenTimeItem: SettingsGroup {
    var title: String { "Screen Time" }
    var icon: String? { "hourglass" }
    var settingsBody: some SettingsContent {
        SettingsItem("Usage", searchable: false) { Text("See Report").foregroundStyle(.secondary) }
    }
}

struct EmergencySOSItem: SettingsGroup {
    var title: String { "Emergency SOS" }
    var icon: String? { "sos" }
    var settingsBody: some SettingsContent {
        SettingsItem("Settings", searchable: false) { Text("Configure").foregroundStyle(.secondary) }
    }
}

struct PrivacySecurityItem: SettingsGroup {
    var title: String { "Privacy & Security" }
    var icon: String? { "hand.raised.fill" }
    var settingsBody: some SettingsContent {
        SettingsItem("Permissions", searchable: false) { Text("Review").foregroundStyle(.secondary) }
    }
}

struct GameCenterItem: SettingsGroup {
    var title: String { "Game Center" }
    var icon: String? { "gamecontroller.fill" }
    var settingsBody: some SettingsContent {
        SettingsItem("Profile", searchable: false) { Text("Aether").foregroundStyle(.secondary) }
    }
}

struct iCloudItem: SettingsGroup {
    var title: String { "iCloud" }
    var icon: String? { "icloud.fill" }
    var settingsBody: some SettingsContent {
        SettingsItem("Storage", searchable: false) { Text("50 GB").foregroundStyle(.secondary) }
    }
}

struct WalletApplePayItem: SettingsGroup {
    var title: String { "Wallet & Apple Pay" }
    var icon: String? { "wallet.pass.fill" }
    var settingsBody: some SettingsContent {
        SettingsItem("Cards", searchable: false) { Text("2 cards").foregroundStyle(.secondary) }
    }
}

struct AppsItem: SettingsGroup {
    var title: String { "Apps" }
    var icon: String? { "square.grid.3x3.fill" }
    var settingsBody: some SettingsContent {
        SettingsItem("Installed", searchable: false) { Text("120 apps").foregroundStyle(.secondary) }
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
    var footer: String? { "Manage how your device connects and shares content with other devices." }

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
    @State private var verboseLogging = false
    @State private var showHiddenFeatures = false

    var title: String { "Advanced" }
    var icon: String? { "hammer" }

    var settingsBody: some SettingsContent {
        SettingsItem("Debug Mode", icon: "ladybug") {
            Toggle("Debug Mode", isOn: $debugMode)
        }

        // Conditionally show these options only when debug mode is enabled
        if debugMode {
            SettingsItem("Verbose Logging", icon: "doc.text.fill") {
                Toggle("Verbose Logging", isOn: $verboseLogging)
            }

            SettingsItem("Show Hidden Features", icon: "eye") {
                Toggle("Show Hidden Features", isOn: $showHiddenFeatures)
            }

            DeveloperToolsGroup()
        }
    }
}

// Nested group that only appears when debug mode is on
struct DeveloperToolsGroup: SettingsGroup {
    @State private var networkDebugging = false

    var title: String { "Developer Tools" }
    var icon: String? { "wrench.and.screwdriver" }

    var settingsBody: some SettingsContent {
        SettingsItem("Network Debugging", icon: "network") {
            Toggle("Network Debugging", isOn: $networkDebugging)
        }
    }
}

