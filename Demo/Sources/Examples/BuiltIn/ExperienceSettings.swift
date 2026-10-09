import SwiftUI
import SettingsKit

struct ExperienceSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Personalization & Wellbeing", .inline) {
            SettingsGroup("Search") {
                SettingsGroup("Before Searching", .inline) {
                    Toggle(isOn: $state.siriSuggestions) {
                        Text("Show Suggestions")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.siriSuggestions) {
                        Text("Show Recents")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
                SettingsGroup("Content from Apple", .inline) {
                    Toggle(isOn: $state.siriSuggestions) {
                        Text("Show in Look Up")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.siriSuggestions) {
                        Text("Show in Spotlight")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
                SettingsGroup("Suggestions from Apple", .inline) {
                    Toggle(isOn: $state.siriSuggestions) {
                        Text("Allow Notifications")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.showInAppLibrary) {
                        Text("Show in App Library")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.siriSuggestions) {
                        Text("Show When Sharing")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.siriSuggestions) {
                        Text("Show When Listening")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
                SettingsGroup("Apps", .inline) {
                    SettingsValueRow(title: "Contacts", value: "Show App in Search")
                    SettingsValueRow(title: "Files", value: "Show Content in Search")
                    SettingsValueRow(title: "Mail", value: "Learn from this App")
                    SettingsValueRow(title: "Maps", value: "Suggest App")
                    SettingsValueRow(title: "Messages", value: "Show Content in Search")
                    SettingsValueRow(title: "Photos", value: "Show Content in Search")
                    SettingsValueRow(title: "Safari", value: "Show App in Search")
                }
            }
            .settingsTags(["Spotlight", "Siri suggestions", "lookup", "app search"])

            SettingsGroup("StandBy") {
                SettingsGroup("StandBy", .inline) {
                    Toggle(isOn: $state.autoStandby) {
                        Text("StandBy")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                        .indexed("StandBy", tags: ["charging", "landscape", "nightstand"])
                    Picker("Turn Display Off", selection: $state.standbyDisplay) {
                        Text("Automatically").tag("Automatically")
                        Text("After 20 Seconds").tag("After 20 Seconds")
                        Text("Never").tag("Never")
                    }
                }
                SettingsGroup("Night Mode", .inline) {
                    Toggle(isOn: $state.standbyNightMode) {
                        Text("Night Mode")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.standbyMotionToWake) {
                        Text("Motion to Wake")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
                SettingsGroup("Notifications", .inline) {
                    Toggle(isOn: $state.showNotifications) {
                        Text("Show Notifications")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.screenSharingNotifications) {
                        Text("Show Preview on Tap Only")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
            }

            SettingsGroup("Wallpaper") {
                SettingsGroup("Current Pair", .inline) {
                    SettingsValueRow(title: "Lock Screen", value: "Astronomy · Earth")
                    SettingsValueRow(title: "Home Screen", value: "Blurred Blue")
                    SettingsValueRow(title: "Focus", value: "None")
                    Button("Customize") {}
                }
                SettingsGroup("Featured", .inline) {
                    SettingsValueRow(title: "Weather & Astronomy", value: "5 Wallpapers")
                    SettingsValueRow(title: "Emoji", value: "6 Patterns")
                    SettingsValueRow(title: "Collections", value: "8 Wallpapers")
                    SettingsValueRow(title: "Color", value: "12 Colors")
                }
                Button("Add New Wallpaper") {}
            }
            .settingsTags(["Lock Screen", "Home Screen", "background", "photo"])

            SettingsGroup("Notifications") {
                SettingsGroup("Display As", .inline) {
                    Picker("Notification Display", selection: $state.notificationDisplay) {
                        Text("Count").tag("Count")
                        Text("Stack").tag("Stack")
                        Text("List").tag("List")
                    }
                    .pickerStyle(.inline)
                }
                SettingsGroup("Notification Center", .inline) {
                    Toggle(isOn: $state.scheduledSummary) {
                        Text("Scheduled Summary")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Picker("Show Previews", selection: $state.showPreviews) {
                        Text("Always").tag("Always")
                        Text("When Unlocked").tag("When Unlocked")
                        Text("Never").tag("Never")
                    }
                    Toggle(isOn: $state.screenSharingNotifications) {
                        Text("Screen Sharing")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.siriNotificationSuggestions) {
                        Text("Siri Suggestions")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
                SettingsGroup("Government Alerts", .inline) {
                    SettingsValueRow(title: "AMBER Alerts", value: "On")
                    SettingsValueRow(title: "Emergency Alerts", value: "On")
                    SettingsValueRow(title: "Public Safety Alerts", value: "On")
                    SettingsValueRow(title: "Test Alerts", value: "Off")
                }
                SettingsGroup("Notification Style", .inline) {
                    AppNotificationRow(name: "Calendar", summary: "Banners, Sounds, Badges")
                    AppNotificationRow(name: "FaceTime", summary: "Banners, Sounds, Badges")
                    AppNotificationRow(name: "Find My", summary: "Banners, Sounds")
                    AppNotificationRow(name: "Mail", summary: "Badges")
                    AppNotificationRow(name: "Messages", summary: "Banners, Sounds, Badges")
                    AppNotificationRow(name: "Music", summary: "Banners")
                    AppNotificationRow(name: "Photos", summary: "Banners, Badges")
                    AppNotificationRow(name: "Reminders", summary: "Banners, Sounds, Badges")
                    AppNotificationRow(name: "Settings", summary: "Banners")
                    AppNotificationRow(name: "Wallet", summary: "Banners, Sounds, Badges")
                }
            }
            .settingsTags(["alerts", "banners", "badges", "previews", "summary"])

            SettingsGroup("Sounds & Haptics") {
                SettingsGroup("Ringtone and Alerts", .inline) {
                    Slider(value: $state.ringerVolume, in: 0...1) {
                        Text("Ringer and Alerts")
                    } minimumValueLabel: {
                        Image(systemName: "speaker")
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.3.fill")
                    }
                    Toggle(isOn: $state.changeWithButtons) {
                        Text("Change with Buttons")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Picker("Haptics", selection: $state.siriResponses) {
                        Text("Always Play").tag("Automatic")
                        Text("Play in Silent Mode").tag("Silent")
                        Text("Never Play").tag("Never")
                    }
                }
                SettingsGroup("Sounds and Haptic Patterns", .inline) {
                    Picker("Ringtone", selection: $state.ringtone) {
                        Text("Reflection").tag("Reflection")
                        Text("Radial").tag("Radial")
                        Text("Journey").tag("Journey")
                    }
                    Picker("Text Tone", selection: $state.textTone) {
                        Text("Note").tag("Note")
                        Text("Chord").tag("Chord")
                        Text("Rebound").tag("Rebound")
                    }
                    SettingsValueRow(title: "New Voicemail", value: "Tri-tone")
                    SettingsValueRow(title: "New Mail", value: "None")
                    SettingsValueRow(title: "Sent Mail", value: "Swoosh")
                    SettingsValueRow(title: "Calendar Alerts", value: "Chord")
                    SettingsValueRow(title: "Reminder Alerts", value: "Chord")
                    SettingsValueRow(title: "Default Alerts", value: "Rebound")
                }
                SettingsGroup("Keyboard Feedback") {
                    Toggle(isOn: $state.keyboardFeedbackSound) {
                        Text("Sound")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.keyboardFeedbackHaptics) {
                        Text("Haptic")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
                SettingsGroup("Headphone Safety") {
                    Toggle(isOn: $state.headphoneSafety) {
                        Text("Headphone Notifications")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.reduceLoudAudio) {
                        Text("Reduce Loud Audio")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    SettingsValueRow(title: "Last 6 Months", value: "0 Notifications")
                }
                Toggle(isOn: $state.systemHaptics) {
                    Text("Lock Sound")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.systemHaptics) {
                    Text("System Haptics")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }

            SettingsGroup("Focus") {
                SettingsGroup("Focus Modes", .inline) {
                    SettingsGroup("Do Not Disturb") {
                        Toggle(isOn: $state.doNotDisturb) {
                            Text("Do Not Disturb")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                            .toggleStyle(.switch)
                            .smallControlSizeOnMacOS()
                        SettingsValueRow(title: "Allow Notifications", value: "Favorites, Repeated Calls")
                        SettingsValueRow(title: "Schedule", value: "10:00 PM–7:00 AM")
                        SettingsValueRow(title: "Focus Filters", value: "None")
                    }
                    SettingsGroup("Personal") {
                        SettingsValueRow(title: "People", value: "3 Allowed")
                        SettingsValueRow(title: "Apps", value: "4 Allowed")
                        SettingsValueRow(title: "Schedule", value: "Smart Activation")
                        SettingsValueRow(title: "Home Screen", value: "Personal Page")
                    }
                    SettingsGroup("Sleep") {
                        SettingsValueRow(title: "Schedule", value: "10:30 PM–6:30 AM")
                        SettingsValueRow(title: "Sleep Screen", value: "On")
                        SettingsValueRow(title: "Wind Down", value: "30 Minutes")
                    }
                    SettingsGroup("Work") {
                        SettingsValueRow(title: "People", value: "Coworkers")
                        SettingsValueRow(title: "Apps", value: "Mail, Calendar, Slack")
                        SettingsValueRow(title: "Schedule", value: "Weekdays, 9–5")
                    }
                    Button("Add Focus") {}
                }
                SettingsGroup("Focus Status", .inline) {
                    Toggle(isOn: $state.shareFocusStatus) {
                        Text("Share Focus Status")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    SettingsValueRow(title: "Share From", value: "Do Not Disturb, Personal, Sleep, Work")
                }
                Toggle(isOn: $state.focusAcrossDevices) {
                    Text("Share Across Devices")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }

            SettingsGroup("Screen Time") {
                SettingsGroup("Activity", .inline) {
                    SettingsValueRow(title: "Screen Time", value: "4h 18m Daily Average")
                    SettingsValueRow(title: "Most Used", value: "Social · 1h 12m")
                    SettingsValueRow(title: "Pickups", value: "86")
                    SettingsValueRow(title: "Notifications", value: "142")
                    Button("See All App & Website Activity") {}
                }
                SettingsGroup("Limit Usage", .inline) {
                    Toggle(isOn: $state.downtimeEnabled) {
                        Text("Downtime")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    SettingsValueRow(title: "App Limits", value: state.appLimitsEnabled ? "2 Limits" : "Off")
                    SettingsValueRow(title: "Always Allowed", value: "Phone, Messages, Maps")
                    SettingsValueRow(title: "Screen Distance", value: "On")
                }
                SettingsGroup("Communication", .inline) {
                    SettingsValueRow(title: "Communication Limits", value: "Contacts Only")
                    Toggle(isOn: $state.communicationSafety) {
                        Text("Communication Safety")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
                SettingsGroup("Restrictions", .inline) {
                    Toggle(isOn: $state.contentPrivacyRestrictions) {
                        Text("Content & Privacy Restrictions")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    SettingsValueRow(title: "Lock Screen Time Settings", value: "Passcode Set")
                }
                Toggle(isOn: $state.screenTimeEnabled) {
                    Text("Share Across Devices")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Button("Turn Off App & Website Activity", role: .destructive) {
                    state.screenTimeEnabled = false
                }
            }

            SettingsGroup("Battery") {
                SettingsGroup("Current Charge", .inline) {
                    SettingsValueRow(title: "Battery", value: "94%")
                    SettingsValueRow(title: "Last Charged", value: "100% at 7:12 AM")
                    Toggle(isOn: $state.lowPowerMode) {
                        Text("Low Power Mode")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.batteryPercentage) {
                        Text("Battery Percentage")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
                SettingsGroup("Battery Usage", .inline) {
                    SettingsValueRow(title: "Last 24 Hours", value: "Screen Active 4h 18m")
                    SettingsValueRow(title: "Last 10 Days", value: "Average 82% per day")
                    SettingsValueRow(title: "Home & Lock Screen", value: "18%")
                    SettingsValueRow(title: "Safari", value: "14%")
                    SettingsValueRow(title: "Messages", value: "11%")
                    SettingsValueRow(title: "Music", value: "9%")
                    SettingsValueRow(title: "Background Activity", value: "6%")
                }
                SettingsGroup("Charging") {
                    Picker("Charging Limit", selection: $state.chargingLimit) {
                        Text("80%").tag("80%")
                        Text("85%").tag("85%")
                        Text("90%").tag("90%")
                        Text("95%").tag("95%")
                        Text("100%").tag("100%")
                    }
                    Toggle(isOn: $state.optimizedCharging) {
                        Text("Optimized Battery Charging")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.cleanEnergyCharging) {
                        Text("Clean Energy Charging")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
                SettingsGroup("Battery Health") {
                    SettingsValueRow(title: "Maximum Capacity", value: "98%")
                    SettingsValueRow(title: "Cycle Count", value: "142")
                    SettingsValueRow(title: "Manufacture Date", value: "July 2025")
                    SettingsValueRow(title: "First Use", value: "September 2025")
                    SettingsValueRow(title: "Peak Performance Capability", value: "Normal")
                }
            }
            .settingsTags(["charge", "health", "capacity", "low power", "usage"])
        }
    }
}

private struct AppNotificationRow: View {
    let name: String
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
            Text(summary)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
