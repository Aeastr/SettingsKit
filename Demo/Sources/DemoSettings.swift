import SwiftUI
import SettingsKit
import SettingsKitPortable

struct DemoSettings: SettingsContainer {
    @Environment(SettingsState.self) var settings

    var settingsBody: some SettingsContent {
        @Bindable var state = settings

        SettingsGroup("Profile") {
            VStack(alignment: .leading) {
                Text("Aether")
                    .font(.headline)
                Text("Apple Account, iCloud+, and more")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            SettingsIcon("person.crop.circle.fill", color: .gray)
        }

        // Quick Settings Sections (inline presentation)
        SettingsGroup("Connections", .inline) {
            SettingsGroup("Airplane Mode") {
                Toggle("Enabled", isOn: $state.airplaneModeEnabled)
            } icon: {
                SettingsIcon("airplane", color: .orange)
            }

            SettingsGroup("Wi-Fi") {
                Text("My Network").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("wifi", color: .blue)
            }

            SettingsGroup("Bluetooth") {
                Toggle("Enabled", isOn: $state.bluetoothEnabled)
            } icon: {
                SettingsIcon("wave.3.right", color: .blue)
            }

            SettingsGroup("Cellular") {
                Text("5G").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("antenna.radiowaves.left.and.right", color: .green)
            }

            SettingsGroup("Personal Hotspot") {
                Toggle("Enabled", isOn: $state.personalHotspotEnabled)
            } icon: {
                SettingsIcon("personalhotspot", color: .green)
            }
        }

        SettingsGroup("Battery", .inline) {
            SettingsGroup("Battery") {
                Text("94%").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("battery.100", color: .green)
            }

            SettingsGroup("VPN") {
                Toggle("Enabled", isOn: $state.vpnQuickEnabled)
            } icon: {
                SettingsIcon("network", color: .blue)
            }
        }

        // Main Settings
        SettingsGroup("Main", .inline) {
            SettingsGroup("General") {
                SettingsGroup("Device Information", .inline) {
                    SettingsGroup("About", systemImage: "info.circle") {
                        Text("iPhone")
                    }

                    SettingsGroup("Software Update", systemImage: "gear.badge") {
                        Text("Up to date")
                    }

                    SettingsGroup("iPhone Storage", systemImage: "internaldrive") {
                        Text("64 GB")
                    }
                }

                SettingsGroup("Connectivity", .inline, footer: "Manage how your device connects and shares content with other devices.") {
                    SettingsGroup("AirDrop", systemImage: "airplayaudio") {
                        Toggle("Receiving", isOn: $state.airDropEnabled)
                    }

                    SettingsGroup("AirPlay & Continuity", systemImage: "tv.and.hifispeaker.fill") {
                        Text("Enabled")
                    }

                    SettingsGroup("Picture in Picture", systemImage: "rectangle.on.rectangle") {
                        Toggle("Auto Start", isOn: $state.pipEnabled)
                    }

                    // Deeper nested navigation group
                    SettingsGroup("Network", systemImage: "network") {
                        SettingsGroup("Wi-Fi Settings", systemImage: "wifi") {
                            Toggle("Auto-Join", isOn: $state.autoJoinWiFi)
                        }

                        SettingsGroup("VPN Configuration", systemImage: "lock.shield") {
                            Text("IKEv2")
                        }

                        SettingsGroup("Advanced", systemImage: "gearshape.2") {
                            Text("DNS: Automatic")
                            Text("Proxy: Off")
                        }
                    }
                }

                SettingsGroup("System", .inline) {
                    SettingsGroup("CarPlay", systemImage: "car") {
                        Text("Not Connected")
                    }
                }

                SettingsGroup("Settings & Privacy", .inline) {
                    SettingsGroup("AutoFill & Passwords", systemImage: "key.fill") {
                        Toggle("AutoFill", isOn: $state.autoFillPasswords)
                    }

                    SettingsGroup("Date & Time", systemImage: "clock") {
                        Toggle("24-Hour", isOn: $state.use24Hour)
                    }

                    SettingsGroup("Keyboard", systemImage: "keyboard") {
                        Toggle("Auto-Correction", isOn: $state.autoCorrect)
                    }

                    SettingsGroup("Language & Region", systemImage: "globe") {
                        Text("English")
                    }

                    SettingsGroup("VPN & Device Management", systemImage: "network") {
                        Toggle("VPN", isOn: $state.vpnManagementEnabled)
                    }
                }
            } icon: {
                SettingsIcon("gearshape", color: .gray)
            }

            SettingsGroup("Accessibility") {
                Text("Configure").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("figure.arms.open", color: .blue)
            }

            SettingsGroup("Action Button") {
                Text("Shortcuts").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("button.programmable", color: .blue)
            }

            SettingsGroup("Apple Intelligence & Siri") {
                Toggle("Enabled", isOn: $state.appleIntelligenceEnabled)
            } icon: {
                SettingsIcon("apple.logo", color: .purple)
            }

            SettingsGroup("Camera") {
                Text("Configure").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("camera.fill", color: .gray)
            }

            SettingsGroup("Control Center") {
                Text("Customize").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("switch.2", color: .gray)
            }

            SettingsGroup("Display & Brightness") {
                Toggle("Auto", isOn: $state.autoBrightness)
            } icon: {
                SettingsIcon("sun.max.fill", color: .blue)
            }

            SettingsGroup("Home Screen & App Library") {
                Text("Standard").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("square.grid.2x2", color: .blue)
            }
        }

        SettingsGroup("Display & Interface", .inline) {
            SettingsGroup("Search") {
                Toggle("Enabled", isOn: $state.siriSuggestions)
            } icon: {
                SettingsIcon("magnifyingglass", color: .gray)
            }

            SettingsGroup("StandBy") {
                Toggle("Auto", isOn: $state.autoStandby)
            } icon: {
                SettingsIcon("platter.2.filled.iphone", color: .black)
            }

            SettingsGroup("Wallpaper") {
                Text("Dynamic").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("photo.on.rectangle", color: .cyan)
            }
        }

        SettingsGroup("Notifications & Focus", .inline) {
            SettingsGroup("Notifications") {
                Text("3 apps").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("bell.badge.fill", color: .red)
            }

            SettingsGroup("Sounds & Haptics") {
                Text("Reflection").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("speaker.wave.3.fill", color: .pink)
            }

            SettingsGroup("Focus") {
                Text("None").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("moon.fill", color: .purple)
            }

            SettingsGroup("Screen Time") {
                Text("See Report").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("hourglass", color: .purple)
            }
        }

        SettingsGroup("Safety & Privacy", .inline) {
            SettingsGroup("Emergency SOS") {
                Text("Configure").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("sos", color: .red)
            }

            SettingsGroup("Privacy & Security") {
                Text("Review").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("hand.raised.fill", color: .blue)
            }
        }

        SettingsGroup("Cloud & Services", .inline) {
            SettingsGroup("Game Center") {
                Text("Aether").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("gamecontroller.fill", color: .pink)
            }

            SettingsGroup("iCloud") {
                Text("50 GB").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("icloud.fill", color: .blue)
            }

            SettingsGroup("Wallet & Apple Pay") {
                Text("2 cards").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("wallet.pass.fill", color: .black)
            }
        }

        SettingsGroup("Applications", .inline) {
            SettingsGroup("Apps") {
                Text("120 apps").foregroundStyle(.secondary)
            } icon: {
                SettingsIcon("square.grid.3x3.fill", color: .blue)
            }

            CustomSettingsGroup("Custom UI Demo", systemImage: "paintbrush.pointed") {
                VStack(spacing: 20) {
                    Text("Completely Custom View")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("This is a CustomSettingsGroup - you can put ANY SwiftUI view here!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding()

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Group is indexed & searchable")
                        }

                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Content is NOT indexed")
                        }

                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Perfect for custom UI")
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)

                    Spacer()

                    Button("Tap Me!") {
                        print("Custom button tapped!")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }

        DeveloperSettingsGroup(state: state)

        SettingsGroup("Data & Transfer", .inline) {
            SettingsGroup("Settings Transfer") {
                SettingsExportDemo()
            } icon: {
                SettingsIcon("arrow.up.arrow.down.circle.fill", color: .blue)
            }
        }

        SettingsGroup("Debug", .inline) {
            SettingsGroup("Input Testing") {
                Toggle("Test Toggle", isOn: $state.testToggle)

                VStack(alignment: .leading) {
                    Text("Slider Value: \(Int(state.testSlider * 100))%")
                    Slider(value: $state.testSlider, in: 0...1)
                }

                TextField("Enter text", text: $state.testText)

                Picker("Selection", selection: $state.testPicker) {
                    Text("Option 1").tag(0)
                    Text("Option 2").tag(1)
                    Text("Option 3").tag(2)
                }

                Stepper("Count: \(state.testStepper)", value: $state.testStepper, in: 0...10)

                Button("Increment Counter: \(state.testCounter)") {
                    state.testCounter += 1
                }
            } icon: {
                SettingsIcon("wrench.and.screwdriver", color: .gray)
            }
        }
    }
}
