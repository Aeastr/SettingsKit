import SwiftUI
import SettingsKit

struct DeviceSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Device", .inline) {
            SettingsGroup("General") {
                GeneralSettings(state: state)
            }
            .settingsTags(["about", "software update", "storage", "keyboard", "language", "reset"])

            SettingsGroup("Accessibility") {
                AccessibilitySettings(state: state)
            }
            .settingsTags(["VoiceOver", "vision", "hearing", "motor", "captions"])

            SettingsGroup("Action Button") {
                SettingsGroup("Assigned Action", .inline) {
                    Picker("Action", selection: $state.actionButtonAction) {
                        Text("Silent Mode").tag("Silent Mode")
                        Text("Focus").tag("Focus")
                        Text("Camera").tag("Camera")
                        Text("Flashlight").tag("Flashlight")
                        Text("Voice Memo").tag("Voice Memo")
                        Text("Recognize Music").tag("Recognize Music")
                        Text("Translate").tag("Translate")
                        Text("Magnifier").tag("Magnifier")
                        Text("Controls").tag("Controls")
                        Text("Shortcut").tag("Shortcut")
                        Text("Accessibility").tag("Accessibility")
                    }
                    .indexed("Action Button Action", tags: ["shortcut", "hardware button"])
                }
                SettingsGroup("Gesture", .inline) {
                    SettingsNote("Press and hold the Action button to activate (state.actionButtonAction). A short press confirms the currently assigned action.")
                }
            }

            SettingsGroup("Apple Intelligence & Siri") {
                IntelligenceAndSiriSettings(state: state)
            }
            .settingsTags(["Siri", "Apple Intelligence", "assistant", "voice"])

            SettingsGroup("Camera") {
                CameraSettings(state: state)
            }
            .settingsTags(["photo", "video", "formats", "resolution", "QR"])

            SettingsGroup("Control Center") {
                SettingsGroup("Access", .inline) {
                    Toggle(isOn: $state.accessWithinApps) {
                        Text("Access Within Apps")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                        .indexed("Access Control Center Within Apps", tags: ["controls", "swipe"])
                }
                SettingsGroup("Included Controls", .inline) {
                    SettingsValueRow(title: "Connectivity", value: "4 Controls")
                    SettingsValueRow(title: "Now Playing", value: "Included")
                    SettingsValueRow(title: "Home", value: "Included")
                    SettingsValueRow(title: "Brightness", value: "Included")
                    SettingsValueRow(title: "Volume", value: "Included")
                    SettingsValueRow(title: "Flashlight", value: "Included")
                    SettingsValueRow(title: "Camera", value: "Included")
                    SettingsValueRow(title: "Calculator", value: "Included")
                    SettingsNote("Open Control Center, touch and hold the background, then tap Add a Control to rearrange or add controls.")
                }
                Button("Reset Control Center") {
                    state.resetControlCenter.toggle()
                }
            }

            SettingsGroup("Display & Brightness") {
                DisplaySettings(state: state)
            }
            .settingsTags(["dark mode", "brightness", "Night Shift", "Auto-Lock", "text size"])

            SettingsGroup("Home Screen & App Library") {
                SettingsGroup("Newly Downloaded Apps", .inline) {
                    Picker("Add Apps To", selection: $state.newlyDownloadedApps) {
                        Text("Add to Home Screen").tag("Add to Home Screen")
                        Text("App Library Only").tag("App Library Only")
                    }
                    .pickerStyle(.inline)
                }
                SettingsGroup("Notification Badges", .inline) {
                    Toggle(isOn: $state.notificationBadgesInLibrary) {
                        Text("Show in App Library")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
                SettingsGroup("Search", .inline) {
                    Toggle(isOn: $state.showOnHomeScreen) {
                        Text("Show on Home Screen")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.showInAppLibrary) {
                        Text("Show App in Search")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
            }
        }
    }
}

private struct GeneralSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Device Information", .inline) {
            SettingsGroup("About") {
                AboutSettings()
            }
            SettingsGroup("Software Update") {
                SoftwareUpdateSettings(state: state)
            }
            SettingsGroup("Coverage") {
                SettingsGroup("AppleCare & Warranty", .inline) {
                    SettingsValueRow(title: "This iPhone", value: "Limited Warranty")
                    SettingsValueRow(title: "Coverage Expires", value: "September 19, 2026")
                    SettingsValueRow(title: "Hardware Coverage", value: "Covered")
                    SettingsValueRow(title: "Chat & Phone Support", value: "Covered")
                }
            }
            SettingsGroup("iPhone Storage") {
                IPhoneStorageSettings(state: state)
            }
        }

        SettingsGroup("Connectivity & Continuity", .inline) {
            SettingsGroup("AirDrop") {
                Picker("Receiving Off", selection: $state.airDropReceiving) {
                    Text("Receiving Off").tag("Receiving Off")
                    Text("Contacts Only").tag("Contacts Only")
                    Text("Everyone for 10 Minutes").tag("Everyone for 10 Minutes")
                }
                Toggle(isOn: $state.bringDevicesTogether) {
                    Text("Bringing Devices Together")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsNote("Hold the top of this iPhone near another iPhone to share contacts or start an AirDrop transfer.")
            }
            SettingsGroup("AirPlay & Continuity") {
                Picker("Automatically AirPlay", selection: $state.airPlayAutomatically) {
                    Text("Never").tag("Never")
                    Text("Ask").tag("Ask")
                    Text("Automatic").tag("Automatic")
                }
                Toggle(isOn: $state.transferToHomePod) {
                    Text("Transfer to HomePod")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.handoffEnabled) {
                    Text("Handoff")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.continuityCamera) {
                    Text("Continuity Camera")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "AirPlay Receiver", value: "Off")
            }
            SettingsGroup("Picture in Picture") {
                Toggle(isOn: $state.pipAutoStart) {
                    Text("Start PiP Automatically")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.pipEnabled) {
                    Text("Picture in Picture")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
            SettingsGroup("CarPlay") {
                SettingsGroup("My Cars", .inline) {
                    SettingsGroup("Sample Car") {
                        Toggle(isOn: $state.accessWithinApps) {
                            Text("Allow CarPlay While Locked")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                            .toggleStyle(.switch)
                            .smallControlSizeOnMacOS()
                        SettingsValueRow(title: "Wallpaper", value: "Blue")
                        SettingsValueRow(title: "Customize", value: "12 Apps")
                    }
                    Button("Available Cars…") {}
                }
            }
        }

        SettingsGroup("Input & Region", .inline) {
            SettingsGroup("AutoFill & Passwords") {
                Toggle(isOn: $state.autoFillPasswords) {
                    Text("AutoFill Passwords and Passkeys")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.autoFillPasskeys) {
                    Text("AutoFill Passkeys")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.deleteAfterUse) {
                    Text("Delete After Use")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsGroup("AutoFill From", .inline) {
                    SettingsValueRow(title: "Passwords", value: "Enabled")
                    SettingsValueRow(title: "1Password", value: "Enabled")
                }
                SettingsValueRow(title: "Set Up Verification Codes Using", value: "Passwords")
            }
            SettingsGroup("Date & Time") {
                Toggle(isOn: $state.use24Hour) {
                    Text("24-Hour Time")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.setAutomatically) {
                    Text("Set Automatically")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Time Zone", value: state.timeZone)
                SettingsValueRow(title: "Date", value: "July 15, 2026")
                SettingsValueRow(title: "Time", value: "9:41 AM")
            }
            SettingsGroup("Keyboard") {
                KeyboardSettings(state: state)
            }
            SettingsGroup("Language & Region") {
                Picker("iPhone Language", selection: $state.language) {
                    Text("English (US)").tag("English (US)")
                    Text("English (UK)").tag("English (UK)")
                    Text("Spanish").tag("Spanish")
                    Text("French").tag("French")
                    Text("Japanese").tag("Japanese")
                }
                Picker("Region", selection: $state.region) {
                    Text("United States").tag("United States")
                    Text("Canada").tag("Canada")
                    Text("United Kingdom").tag("United Kingdom")
                    Text("Japan").tag("Japan")
                }
                SettingsValueRow(title: "Preferred Languages", value: "English")
                Picker("Calendar", selection: $state.calendar) {
                    Text("Gregorian").tag("Gregorian")
                    Text("Japanese").tag("Japanese")
                    Text("Buddhist").tag("Buddhist")
                }
                Picker("Temperature System", selection: $state.temperatureUnit) {
                    Text("System Setting").tag("System")
                    Text("Celsius").tag("Celsius")
                    Text("Fahrenheit").tag("Fahrenheit")
                }
                Picker("Measurement System", selection: $state.measurementSystem) {
                    Text("US").tag("US")
                    Text("Metric").tag("Metric")
                    Text("UK").tag("UK")
                }
                SettingsValueRow(title: "First Day of Week", value: "Sunday")
                SettingsValueRow(title: "Number Format", value: "1,234,567.89")
                SettingsValueRow(title: "Live Text", value: "On")
            }
            SettingsGroup("Dictionary") {
                SettingsGroup("Downloaded Dictionaries", .inline) {
                    SettingsValueRow(title: "Apple Dictionary", value: "English")
                    SettingsValueRow(title: "New Oxford American Dictionary", value: "English")
                    SettingsValueRow(title: "Oxford American Writer’s Thesaurus", value: "English")
                }
            }
            SettingsGroup("Fonts") {
                ContentUnavailableView("No Fonts Installed", systemImage: "textformat", description: Text("Fonts installed from the App Store appear here."))
            }
        }

        SettingsGroup("Management", .inline) {
            SettingsGroup("VPN & Device Management") {
                SettingsValueRow(title: "VPN", value: state.vpnQuickEnabled ? "Connected" : "Not Connected")
                SettingsValueRow(title: "Configuration Profiles", value: "None")
                SettingsValueRow(title: "Developer App", value: "SettingsKit Demo")
            }
            SettingsGroup("Legal & Regulatory") {
                SettingsValueRow(title: "Legal Notices", value: "Apple Inc.")
                SettingsValueRow(title: "License", value: "iOS Software License")
                SettingsValueRow(title: "RF Exposure", value: "View")
                SettingsValueRow(title: "Regulatory", value: "FCC · CE · UKCA")
            }
            SettingsGroup("Transfer or Reset iPhone") {
                SettingsGroup("Prepare for New iPhone", .inline) {
                    SettingsNote("Make sure everything is ready to transfer to a new iPhone, even if you do not currently have enough iCloud storage.")
                    Button("Get Started") {}
                }
                SettingsGroup("Reset", .inline) {
                    Button("Reset All Settings") {}
                    Button("Reset Network Settings") {}
                    Button("Reset Keyboard Dictionary") {}
                    Button("Reset Home Screen Layout") {}
                    Button("Reset Location & Privacy") {}
                }
                Button("Erase All Content and Settings", role: .destructive) {}
            }
        }
    }
}

private struct AboutSettings: SettingsContent {
    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Identity", .inline) {
            SettingsNote("Every identifier and personal value shown in this example is fictional sample data.")
            SettingsValueRow(title: "Name", value: "Sample iPhone")
            SettingsValueRow(title: "iOS Version", value: "27.0 (27A-SAMPLE)")
            SettingsValueRow(title: "Model Name", value: "Sample iPhone Pro")
            SettingsValueRow(title: "Model Number", value: "FAKE1LL/A")
            SettingsValueRow(title: "Serial Number", value: "SAMPLE-SERIAL-001")
            SettingsValueRow(title: "Coverage", value: "Limited Warranty")
        }
        SettingsGroup("Content", .inline) {
            SettingsValueRow(title: "Songs", value: "1,284")
            SettingsValueRow(title: "Videos", value: "42")
            SettingsValueRow(title: "Photos", value: "18,736")
            SettingsValueRow(title: "Applications", value: "120")
            SettingsValueRow(title: "Capacity", value: "256 GB")
            SettingsValueRow(title: "Available", value: "154.7 GB")
        }
        SettingsGroup("Network Identifiers", .inline) {
            SettingsValueRow(title: "Wi-Fi Address", value: "02:00:00:00:00:01 · Sample")
            SettingsValueRow(title: "Bluetooth", value: "02:00:00:00:00:02 · Sample")
            SettingsValueRow(title: "Modem Firmware", value: "SAMPLE.1")
            SettingsValueRow(title: "SEID", value: "SAMPLE-SEID-0001")
            SettingsValueRow(title: "EID", value: "SAMPLE-EID-0001")
            SettingsValueRow(title: "IMEI", value: "00 000000 000001 0 · Sample")
            SettingsValueRow(title: "IMEI2", value: "00 000000 000002 0 · Sample")
            SettingsValueRow(title: "ICCID", value: "SAMPLE-ICCID-0001")
            SettingsValueRow(title: "MEID", value: "SAMPLE-MEID-0001")
        }
        SettingsGroup("Carrier", .inline) {
            SettingsValueRow(title: "Carrier", value: "Example Wireless 60.0")
            SettingsValueRow(title: "Carrier Lock", value: "No SIM restrictions")
            SettingsValueRow(title: "Digital SIM", value: "Primary")
        }
        SettingsGroup("Certificates", .inline) {
            SettingsValueRow(title: "Certificate Trust Settings", value: "System Defaults")
            SettingsValueRow(title: "Trust Store Version", value: "2025051500")
            SettingsValueRow(title: "Trust Asset Version", value: "22")
        }
    }
}

private struct SoftwareUpdateSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("iOS 27.0", .inline) {
            SettingsValueRow(title: "Status", value: "iOS is up to date")
            SettingsValueRow(title: "Version", value: "27.0")
            SettingsValueRow(title: "Build", value: "27A-SAMPLE")
            SettingsNote("iOS 27.0 includes improvements, security updates, and bug fixes for your iPhone. The build identifier shown here is fictional.")
            Button("Learn More…") {}
        }
        SettingsGroup("Automatic Updates") {
            Toggle(isOn: $state.automaticSoftwareUpdates) {
                Text("Automatic Updates")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.downloadIOSUpdates) {
                Text("Download iOS Updates")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.installIOSUpdates) {
                Text("Install iOS Updates")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.securityResponsesEnabled) {
                Text("Security Responses & System Files")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("Beta Updates") {
            Toggle(isOn: $state.betaSoftwareUpdates) {
                Text("Beta Updates")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Apple Account", value: "sample.user@example.com")
        }
    }
}

private struct IPhoneStorageSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Storage", .inline) {
            ProgressView(value: 101.3, total: 256)
            SettingsValueRow(title: "Used", value: "101.3 GB of 256 GB")
            StorageUsageRow(title: "Apps", detail: "38.4 GB", color: .blue)
            StorageUsageRow(title: "Photos", detail: "22.7 GB", color: .orange)
            StorageUsageRow(title: "iOS", detail: "18.1 GB", color: .gray)
            StorageUsageRow(title: "Messages", detail: "8.9 GB", color: .green)
            StorageUsageRow(title: "System Data", detail: "7.2 GB", color: .purple)
        }
        SettingsGroup("Recommendations", .inline) {
            Toggle(isOn: $state.offloadUnusedApps) {
                Text("Offload Unused Apps")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Review Downloaded Videos", value: "2.6 GB")
            SettingsValueRow(title: "Auto Delete Old Conversations", value: "4.1 GB")
        }
        SettingsGroup("Apps", .inline) {
            SettingsValueRow(title: "Photos", value: "22.7 GB")
            SettingsValueRow(title: "Music", value: "9.8 GB")
            SettingsValueRow(title: "Messages", value: "8.9 GB")
            SettingsValueRow(title: "Podcasts", value: "4.3 GB")
            SettingsValueRow(title: "Maps", value: "3.7 GB")
            SettingsValueRow(title: "Safari", value: "2.9 GB")
            SettingsValueRow(title: "Files", value: "2.2 GB")
            SettingsValueRow(title: "Mail", value: "1.6 GB")
        }
    }
}

private struct KeyboardSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Keyboards", .inline) {
            SettingsGroup("Keyboards") {
                SettingsValueRow(title: "English (US)", value: "QWERTY")
                SettingsValueRow(title: "Emoji", value: "Emoji")
                Button("Add New Keyboard…") {}
            }
            SettingsGroup("Text Replacement") {
                SettingsValueRow(title: "On my way!", value: "omw")
                SettingsValueRow(title: "Be right back", value: "brb")
                Button("Add Text Replacement") {}
            }
            SettingsValueRow(title: "One-Handed Keyboard", value: "Off")
            SettingsValueRow(title: "Hardware Keyboard", value: "Not Connected")
        }
        SettingsGroup("All Keyboards", .inline) {
            Toggle(isOn: $state.autoCapitalization) {
                Text("Auto-Capitalization")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.autoCorrect) {
                Text("Auto-Correction")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.checkSpelling) {
                Text("Check Spelling")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.capsLock) {
                Text("Enable Caps Lock")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.predictiveText) {
                Text("Predictive Text")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.inlinePredictions) {
                Text("Show Predictions Inline")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.smartPunctuation) {
                Text("Smart Punctuation")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.characterPreview) {
                Text("Character Preview")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.smartPunctuation) {
                Text("“.” Shortcut")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("English", .inline) {
            Toggle(isOn: $state.slideToType) {
                Text("Slide to Type")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.deleteAfterUse) {
                Text("Delete Slide-to-Type by Word")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("Dictation", .inline) {
            Toggle(isOn: $state.dictation) {
                Text("Enable Dictation")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Dictation Languages", value: "English (US)")
            Toggle(isOn: $state.autoPunctuation) {
                Text("Auto-Punctuation")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
    }
}
