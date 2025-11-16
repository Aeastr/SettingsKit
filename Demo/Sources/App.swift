import SwiftUI
import SettingsKit

// MARK: - Custom Styles

struct CustomContainerStyle: SettingsContainerStyle {
    func makeBody(configuration: Configuration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            ScrollView {
                configuration.content
            }
            .navigationTitle(configuration.title)
            .background(Color.blue.opacity(0.05))
        }
    }
}

struct CustomGroupStyle: SettingsGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            configuration.label
                .font(.headline)
                .foregroundColor(.purple)
            configuration.content
                .padding(.leading, 8)
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CustomItemStyle: SettingsItemStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundColor(.green)
            Spacer()
            configuration.content
        }
        .padding(12)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - State

// Observable state class that can be shared by reference
class SettingsState: ObservableObject {
    @Published var airplaneModeEnabled = false
    @Published var bluetoothEnabled = true
    @Published var personalHotspotEnabled = false
    @Published var vpnQuickEnabled = false
    @Published var appleIntelligenceEnabled = true
    @Published var autoBrightness = true
    @Published var siriSuggestions = true
    @Published var autoStandby = true
    @Published var debugMode = false
    @Published var verboseLogging = false
    @Published var showHiddenFeatures = false
    @Published var networkDebugging = false
    @Published var airDropEnabled = true
    @Published var pipEnabled = true
    @Published var autoFillPasswords = true
    @Published var use24Hour = false
    @Published var autoCorrect = true
    @Published var vpnManagementEnabled = false
    @Published var darkMode = false
    @Published var autoJoinWiFi = true
}

@main
struct SettingsKitDemoApp: App {
    @StateObject private var state = SettingsState()

    var body: some Scene {
        WindowGroup {
            SettingsView(DemoSettings(state: state))
                .settingsContainerStyle(.sidebar)  // Custom container style demo
                .settingsItemStyle(CustomItemStyle())  // Custom item style demo - applies to all items
        }
    }
}

struct DemoSettings: SettingsContainer {
    @ObservedObject var state: SettingsState

    var settingsBody: some SettingsContent {
        SettingsGroup("Profile", systemImage: "person.crop.circle.fill") {
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

        // Quick Settings Sections
        SettingsGroup("Connections") {
            SettingsGroup("Airplane Mode", systemImage: "airplane") {
                SettingsItem("Toggle") { Toggle("Enabled", isOn: $state.airplaneModeEnabled) }
            }

            SettingsGroup("Wi-Fi", systemImage: "wifi") {
                SettingsItem("Network", searchable: false) { Text("Tabley 5").foregroundStyle(.secondary) }
            }

            SettingsGroup("Bluetooth", systemImage: "wave.3.right") {
                SettingsItem("Toggle") { Toggle("Enabled", isOn: $state.bluetoothEnabled) }
            }

            SettingsGroup("Cellular", systemImage: "antenna.radiowaves.left.and.right") {
                SettingsItem("Data", searchable: false) { Text("5G").foregroundStyle(.secondary) }
            }

            SettingsGroup("Personal Hotspot", systemImage: "personalhotspot") {
                SettingsItem("Toggle") { Toggle("Enabled", isOn: $state.personalHotspotEnabled) }
            }
        }
        .settingsGroupStyle(.inline)

        SettingsGroup("Battery") {
            SettingsGroup("Battery", systemImage: "battery.100") {
                SettingsItem("Level", searchable: false) { Text("94%").foregroundStyle(.secondary) }
            }

            SettingsGroup("VPN", systemImage: "network") {
                SettingsItem("Toggle") { Toggle("Enabled", isOn: $state.vpnQuickEnabled) }
            }
        }
        .settingsGroupStyle(.inline)

        // Main Settings
        SettingsGroup("Main") {
            SettingsGroup("General", systemImage: "gearshape") {
                SettingsGroup("Device Information") {
                    SettingsGroup("About", systemImage: "info.circle") {
                        SettingsItem("Device Name") {
                            Text("iPhone")
                        }
                    }

                    SettingsGroup("Software Update", systemImage: "gear.badge") {
                        SettingsItem("Status") {
                            Text("Up to date")
                        }
                    }

                    SettingsGroup("iPhone Storage", systemImage: "internaldrive") {
                        SettingsItem("Used") {
                            Text("64 GB")
                        }
                    }
                }
                .settingsGroupStyle(.inline)

                SettingsGroup("Connectivity", footer: "Manage how your device connects and shares content with other devices.") {
                    SettingsGroup("AirDrop", systemImage: "airplayaudio") {
                        SettingsItem("Receiving", icon: "person.crop.circle") {
                            Toggle("Receiving", isOn: $state.airDropEnabled)
                        }
                    }

                    SettingsGroup("AirPlay & Continuity", systemImage: "tv.and.hifispeaker.fill") {
                        SettingsItem("Status") {
                            Text("Enabled")
                        }
                    }

                    SettingsGroup("Picture in Picture", systemImage: "rectangle.on.rectangle") {
                        SettingsItem("Automatically Start", icon: "play.rectangle") {
                            Toggle("Auto Start", isOn: $state.pipEnabled)
                        }
                    }

                    // Deeper nested navigation group
                    SettingsGroup("Network", systemImage: "network") {
                        SettingsGroup("Wi-Fi Settings", systemImage: "wifi") {
                            SettingsItem("Auto-Join") {
                                Toggle("Auto-Join", isOn: $state.autoJoinWiFi)
                            }
                        }

                        SettingsGroup("VPN Configuration", systemImage: "lock.shield") {
                            SettingsItem("VPN Type") {
                                Text("IKEv2")
                            }
                        }

                        SettingsGroup("Advanced", systemImage: "gearshape.2") {
                            SettingsItem("DNS") {
                                Text("Automatic")
                            }

                            SettingsItem("Proxy") {
                                Text("Off")
                            }
                        }
                    }
                }
                .settingsGroupStyle(.inline)

                SettingsGroup("System") {
                    SettingsGroup("CarPlay", systemImage: "car") {
                        SettingsItem("Status") {
                            Text("Not Connected")
                        }
                    }
                }
                .settingsGroupStyle(.inline)

                SettingsGroup("Settings & Privacy") {
                    SettingsGroup("AutoFill & Passwords", systemImage: "key.fill") {
                        SettingsItem("AutoFill Passwords", icon: "key") {
                            Toggle("AutoFill", isOn: $state.autoFillPasswords)
                        }
                    }

                    SettingsGroup("Date & Time", systemImage: "clock") {
                        SettingsItem("24-Hour Time", icon: "clock") {
                            Toggle("24-Hour", isOn: $state.use24Hour)
                        }
                    }

                    SettingsGroup("Keyboard", systemImage: "keyboard") {
                        SettingsItem("Auto-Correction", icon: "text.cursor") {
                            Toggle("Auto-Correction", isOn: $state.autoCorrect)
                        }
                        SettingsItem("Auto-Correction", icon: "text.cursor") {
                            Toggle("Auto-Correction", isOn: $state.autoCorrect)
                        }
                    }

                    SettingsGroup("Language & Region", systemImage: "globe") {
                        SettingsItem("Language") {
                            Text("English")
                        }
                    }

                    SettingsGroup("VPN & Device Management", systemImage: "network") {
                        SettingsItem("VPN Status", icon: "lock.shield") {
                            Toggle("VPN", isOn: $state.vpnManagementEnabled)
                        }
                    }
                }
                .settingsGroupStyle(.inline)
            }

            SettingsGroup("Accessibility", systemImage: "figure.arms.open") {
                SettingsItem("Options", searchable: false) { Text("Configure").foregroundStyle(.secondary) }
            }

            SettingsGroup("Action Button", systemImage: "button.programmable") {
                SettingsItem("Action", searchable: false) { Text("Shortcuts").foregroundStyle(.secondary) }
            }

            SettingsGroup("Apple Intelligence & Siri", systemImage: "apple.logo") {
                SettingsItem("Toggle") { Toggle("Enabled", isOn: $state.appleIntelligenceEnabled) }
            }

            SettingsGroup("Camera", systemImage: "camera.fill") {
                SettingsItem("Settings", searchable: false) { Text("Configure").foregroundStyle(.secondary) }
            }

            SettingsGroup("Control Center", systemImage: "switch.2") {
                SettingsItem("Controls", searchable: false) { Text("Customize").foregroundStyle(.secondary) }
            }

            SettingsGroup("Display & Brightness", systemImage: "sun.max.fill") {
                SettingsItem("Auto-Brightness") { Toggle("Auto", isOn: $state.autoBrightness) }
            }

            SettingsGroup("Home Screen & App Library", systemImage: "square.grid.2x2") {
                SettingsItem("Layout", searchable: false) { Text("Standard").foregroundStyle(.secondary) }
            }
        }
        .settingsGroupStyle(.inline)

        SettingsGroup("Display & Interface") {
            SettingsGroup("Search", systemImage: "magnifyingglass") {
                SettingsItem("Siri Suggestions") { Toggle("Enabled", isOn: $state.siriSuggestions) }
            }

            SettingsGroup("StandBy", systemImage: "platter.2.filled.iphone") {
                SettingsItem("Automatic") { Toggle("Auto", isOn: $state.autoStandby) }
            }

            SettingsGroup("Wallpaper", systemImage: "photo.on.rectangle") {
                SettingsItem("Current", searchable: false) { Text("Dynamic").foregroundStyle(.secondary) }
            }
        }
        .settingsGroupStyle(.inline)

        SettingsGroup("Notifications & Focus") {
            SettingsGroup("Notifications", systemImage: "bell.badge.fill") {
                SettingsItem("Scheduled", searchable: false) { Text("3 apps").foregroundStyle(.secondary) }
            }

            SettingsGroup("Sounds & Haptics", systemImage: "speaker.wave.3.fill") {
                SettingsItem("Ringtone", searchable: false) { Text("Reflection").foregroundStyle(.secondary) }
            }

            SettingsGroup("Focus", systemImage: "moon.fill") {
                SettingsItem("Active", searchable: false) { Text("None").foregroundStyle(.secondary) }
            }

            SettingsGroup("Screen Time", systemImage: "hourglass") {
                SettingsItem("Usage", searchable: false) { Text("See Report").foregroundStyle(.secondary) }
            }
        }
        .settingsGroupStyle(.inline)

        SettingsGroup("Safety & Privacy") {
            SettingsGroup("Emergency SOS", systemImage: "sos") {
                SettingsItem("Settings", searchable: false) { Text("Configure").foregroundStyle(.secondary) }
            }

            SettingsGroup("Privacy & Security", systemImage: "hand.raised.fill") {
                SettingsItem("Permissions", searchable: false) { Text("Review").foregroundStyle(.secondary) }
            }
        }
        .settingsGroupStyle(.inline)

        SettingsGroup("Cloud & Services") {
            SettingsGroup("Game Center", systemImage: "gamecontroller.fill") {
                SettingsItem("Profile", searchable: false) { Text("Aether").foregroundStyle(.secondary) }
            }

            SettingsGroup("iCloud", systemImage: "icloud.fill") {
                SettingsItem("Storage", searchable: false) { Text("50 GB").foregroundStyle(.secondary) }
            }

            SettingsGroup("Wallet & Apple Pay", systemImage: "wallet.pass.fill") {
                SettingsItem("Cards", searchable: false) { Text("2 cards").foregroundStyle(.secondary) }
            }
        }
        .settingsGroupStyle(.inline)

        SettingsGroup("Applications") {
            SettingsGroup("Apps", systemImage: "square.grid.3x3.fill") {
                SettingsItem("Installed", searchable: false) { Text("120 apps").foregroundStyle(.secondary) }
            }
        }
        .settingsGroupStyle(.inline)

        SettingsGroup("Developer") {
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
            .settingsGroupStyle(CustomGroupStyle())  // Custom group style demo
        }
        .settingsGroupStyle(.inline)
    }
}
