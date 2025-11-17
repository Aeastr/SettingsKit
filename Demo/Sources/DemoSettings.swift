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
                SettingsItem("Toggle Test") {
                    Toggle("Test Toggle", isOn: $state.testToggle)
                }

                SettingsItem("Slider Test") {
                    VStack(alignment: .leading) {
                        Text("Slider Value: \(Int(state.testSlider * 100))%")
                        Slider(value: $state.testSlider, in: 0...1)
                    }
                }

                SettingsItem("TextField Test") {
                    TextField("Enter text", text: $state.testText)
                }

                SettingsItem("Picker Test") {
                    Picker("Selection", selection: $state.testPicker) {
                        Text("Option 1").tag(0)
                        Text("Option 2").tag(1)
                        Text("Option 3").tag(2)
                    }
                }

                SettingsItem("Stepper Test") {
                    Stepper("Count: \(state.testStepper)", value: $state.testStepper, in: 0...10)
                }

                SettingsItem("Button Test") {
                    Button("Increment Counter: \(state.testCounter)") {
                        state.testCounter += 1
                    }
                }
            }
        }
        
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

            // Quick Settings Sections (inline presentation)
            SettingsGroup("Connections", .inline) {
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

            SettingsGroup("Battery", .inline) {
                SettingsGroup("Battery", systemImage: "battery.100") {
                    SettingsItem("Level", searchable: false) { Text("94%").foregroundStyle(.secondary) }
                }

                SettingsGroup("VPN", systemImage: "network") {
                    SettingsItem("Toggle") { Toggle("Enabled", isOn: $state.vpnQuickEnabled) }
                }
            }

            // Main Settings
            SettingsGroup("Main", .inline) {
                SettingsGroup("General", systemImage: "gearshape") {
                    SettingsGroup("Device Information", .inline) {
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

                    SettingsGroup("Connectivity", .inline, footer: "Manage how your device connects and shares content with other devices.") {
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
                            Text("")
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

                    SettingsGroup("System", .inline) {
                        SettingsGroup("CarPlay", systemImage: "car") {
                            SettingsItem("Status") {
                                Text("Not Connected")
                            }
                        }
                    }

                    SettingsGroup("Settings & Privacy", .inline) {
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

            SettingsGroup("Display & Interface", .inline) {
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

            SettingsGroup("Notifications & Focus", .inline) {
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

            SettingsGroup("Safety & Privacy", .inline) {
                SettingsGroup("Emergency SOS", systemImage: "sos") {
                    SettingsItem("Settings", searchable: false) { Text("Configure").foregroundStyle(.secondary) }
                }

                SettingsGroup("Privacy & Security", systemImage: "hand.raised.fill") {
                    SettingsItem("Permissions", searchable: false) { Text("Review").foregroundStyle(.secondary) }
                }
            }

            SettingsGroup("Cloud & Services", .inline) {
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

            SettingsGroup("Applications", .inline) {
                SettingsGroup("Apps", systemImage: "square.grid.3x3.fill") {
                    SettingsItem("Installed", searchable: false) { Text("120 apps").foregroundStyle(.secondary) }
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
