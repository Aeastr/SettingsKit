import SwiftUI
import SettingsKit

struct DemoSettings: SettingsContainer {
    @Environment(SettingsState.self) var settings

    var settingsBody: some SettingsContent {
        @Bindable var state = settings
        SettingsGroup("Debug", .inline) {
            Text("Toggle: \(state.testToggle ? "ON" : "OFF")")
            Text("Slider: \(Int(state.testSlider * 100))%")
            Text("Text: \(state.testText)")
            Text("Picker: \(state.testPicker)")
            Text("Stepper: \(state.testStepper)")
            Text("Counter: \(state.testCounter)")
            SettingsGroup("Input Testing", systemImage: "wrench.and.screwdriver") {
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
            }
        }
        
            SettingsGroup("Profile", systemImage: "person.crop.circle.fill") {
                VStack(alignment: .leading) {
                    Text("Aether")
                        .font(.headline)
                    Text("Apple Account, iCloud+, and more")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Quick Settings Sections (inline presentation)
            SettingsGroup("Connections", .inline) {
                SettingsGroup("Airplane Mode", systemImage: "airplane") {
                    Toggle("Enabled", isOn: $state.airplaneModeEnabled)
                }

                SettingsGroup("Wi-Fi", systemImage: "wifi") {
                    Text("My Network").foregroundStyle(.secondary)
                }

                SettingsGroup("Bluetooth", systemImage: "wave.3.right") {
                    Toggle("Enabled", isOn: $state.bluetoothEnabled)
                }

                SettingsGroup("Cellular", systemImage: "antenna.radiowaves.left.and.right") {
                    Text("5G").foregroundStyle(.secondary)
                }

                SettingsGroup("Personal Hotspot", systemImage: "personalhotspot") {
                    Toggle("Enabled", isOn: $state.personalHotspotEnabled)
                }
            }

            SettingsGroup("Battery", .inline) {
                SettingsGroup("Battery", systemImage: "battery.100") {
                    Text("94%").foregroundStyle(.secondary)
                }

                SettingsGroup("VPN", systemImage: "network") {
                    Toggle("Enabled", isOn: $state.vpnQuickEnabled)
                }
            }

            // Main Settings
            SettingsGroup("Main", .inline) {
                SettingsGroup("General", systemImage: "gearshape") {
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
                }

                SettingsGroup("Accessibility", systemImage: "figure.arms.open") {
                    Text("Configure").foregroundStyle(.secondary)
                }

                SettingsGroup("Action Button", systemImage: "button.programmable") {
                    Text("Shortcuts").foregroundStyle(.secondary)
                }

                SettingsGroup("Apple Intelligence & Siri", systemImage: "apple.logo") {
                    Toggle("Enabled", isOn: $state.appleIntelligenceEnabled)
                }

                SettingsGroup("Camera", systemImage: "camera.fill") {
                    Text("Configure").foregroundStyle(.secondary)
                }

                SettingsGroup("Control Center", systemImage: "switch.2") {
                    Text("Customize").foregroundStyle(.secondary)
                }

                SettingsGroup("Display & Brightness", systemImage: "sun.max.fill") {
                    Toggle("Auto", isOn: $state.autoBrightness)
                }

                SettingsGroup("Home Screen & App Library", systemImage: "square.grid.2x2") {
                    Text("Standard").foregroundStyle(.secondary)
                }
            }

            SettingsGroup("Display & Interface", .inline) {
                SettingsGroup("Search", systemImage: "magnifyingglass") {
                    Toggle("Enabled", isOn: $state.siriSuggestions)
                }

                SettingsGroup("StandBy", systemImage: "platter.2.filled.iphone") {
                    Toggle("Auto", isOn: $state.autoStandby)
                }

                SettingsGroup("Wallpaper", systemImage: "photo.on.rectangle") {
                    Text("Dynamic").foregroundStyle(.secondary)
                }
            }

            SettingsGroup("Notifications & Focus", .inline) {
                SettingsGroup("Notifications", systemImage: "bell.badge.fill") {
                    Text("3 apps").foregroundStyle(.secondary)
                }

                SettingsGroup("Sounds & Haptics", systemImage: "speaker.wave.3.fill") {
                    Text("Reflection").foregroundStyle(.secondary)
                }

                SettingsGroup("Focus", systemImage: "moon.fill") {
                    Text("None").foregroundStyle(.secondary)
                }

                SettingsGroup("Screen Time", systemImage: "hourglass") {
                    Text("See Report").foregroundStyle(.secondary)
                }
            }

            SettingsGroup("Safety & Privacy", .inline) {
                SettingsGroup("Emergency SOS", systemImage: "sos") {
                    Text("Configure").foregroundStyle(.secondary)
                }

                SettingsGroup("Privacy & Security", systemImage: "hand.raised.fill") {
                    Text("Review").foregroundStyle(.secondary)
                }
            }

            SettingsGroup("Cloud & Services", .inline) {
                SettingsGroup("Game Center", systemImage: "gamecontroller.fill") {
                    Text("Aether").foregroundStyle(.secondary)
                }

                SettingsGroup("iCloud", systemImage: "icloud.fill") {
                    Text("50 GB").foregroundStyle(.secondary)
                }

                SettingsGroup("Wallet & Apple Pay", systemImage: "wallet.pass.fill") {
                    Text("2 cards").foregroundStyle(.secondary)
                }
            }

            SettingsGroup("Applications", .inline) {
                SettingsGroup("Apps", systemImage: "square.grid.3x3.fill") {
                    Text("120 apps").foregroundStyle(.secondary)
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
    }
}
