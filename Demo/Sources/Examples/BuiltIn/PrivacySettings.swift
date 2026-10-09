import SwiftUI
import SettingsKit

struct WellbeingAndPrivacySettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Safety & Privacy", .inline) {
            SettingsGroup("Face ID & Passcode") {
                SettingsGroup("Use Face ID For", .inline) {
                    Toggle(isOn: $state.autoFillPasswords) {
                        Text("iPhone Unlock")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.autoFillPasswords) {
                        Text("iTunes & App Store")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.doubleClickSideButton) {
                        Text("Wallet & Apple Pay")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.autoFillPasswords) {
                        Text("Password AutoFill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    SettingsValueRow(title: "Other Apps", value: "14 Apps")
                }
                SettingsGroup("Attention", .inline) {
                    SettingsValueRow(title: "Require Attention for Face ID", value: "On")
                    SettingsValueRow(title: "Attention-Aware Features", value: "On")
                    SettingsValueRow(title: "Haptic on Successful Authentication", value: "On")
                }
                SettingsGroup("Allow Access When Locked", .inline) {
                    SettingsValueRow(title: "Today View and Search", value: "On")
                    SettingsValueRow(title: "Notification Center", value: "On")
                    SettingsValueRow(title: "Control Center", value: "On")
                    SettingsValueRow(title: "Lock Screen Widgets", value: "On")
                    SettingsValueRow(title: "Live Activities", value: "On")
                    SettingsValueRow(title: "Reply with Message", value: "On")
                    SettingsValueRow(title: "Home Control", value: "On")
                    SettingsValueRow(title: "Wallet", value: "On")
                    SettingsValueRow(title: "Return Missed Calls", value: "Off")
                    SettingsValueRow(title: "Accessories", value: "Off")
                }
                SettingsGroup("Security", .inline) {
                    SettingsValueRow(title: "Stolen Device Protection", value: "Away from Familiar Locations")
                    SettingsValueRow(title: "Require Passcode", value: "Immediately")
                    SettingsValueRow(title: "Voice Dial", value: "On")
                    SettingsValueRow(title: "Previous Passcode", value: "Expire Now")
                    Button("Change Passcode") {}
                    Button("Reset Face ID") {}
                    Button("Set Up an Alternate Appearance") {}
                }
                Toggle(isOn: $state.deleteAfterUse) {
                    Text("Erase Data After 10 Failed Attempts")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
            .settingsTags(["unlock", "passcode", "biometrics", "stolen device protection"])

            SettingsGroup("Emergency SOS") {
                SettingsGroup("Call Emergency Services", .inline) {
                    Toggle(isOn: $state.emergencyCallHold) {
                        Text("Call with Hold and Release")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.emergencyCallFivePresses) {
                        Text("Call with 5 Button Presses")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.callAfterSevereCrash) {
                        Text("Call After Severe Crash")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    SettingsValueRow(title: "Countdown Sound", value: "On")
                }
                SettingsGroup("Emergency Contacts", .inline) {
                    SettingsValueRow(title: "Sample Contact One", value: "Partner")
                    SettingsValueRow(title: "Sample Contact Two", value: "Friend")
                    Button("Edit Emergency Contacts in Health") {}
                }
                SettingsGroup("Emergency SOS via Satellite", .inline) {
                    SettingsValueRow(title: "Availability", value: "Available")
                    SettingsValueRow(title: "Satellite Connection Demo", value: "Ready")
                    Button("Try Demo") {
                        state.emergencySatelliteDemo.toggle()
                    }
                }
                SettingsGroup("Government Alerts", .inline) {
                    SettingsValueRow(title: "Emergency Alerts", value: "On")
                    SettingsValueRow(title: "Always Play Sound", value: "On")
                }
            }
            .settingsTags(["emergency", "crash detection", "satellite", "contacts"])

            SettingsGroup("Privacy & Security") {
                PrivacyAndSecuritySettings(state: state)
            }
            .settingsTags(["location", "tracking", "permissions", "camera", "microphone", "analytics"])
        }
    }
}

private struct PrivacyAndSecuritySettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Location", .inline) {
            SettingsGroup("Location Services") {
                Toggle(isOn: $state.locationServices) {
                    Text("Location Services")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "App Store", value: "While Using")
                SettingsValueRow(title: "Camera", value: "While Using")
                SettingsValueRow(title: "Find My", value: "Always")
                SettingsValueRow(title: "Maps", value: "While Using")
                SettingsValueRow(title: "Photos", value: "While Using")
                SettingsValueRow(title: "Safari Websites", value: "Ask Next Time")
                SettingsGroup("System Services") {
                    SettingsValueRow(title: "Cell Network Search", value: "On")
                    SettingsValueRow(title: "Emergency Calls & SOS", value: "On")
                    SettingsValueRow(title: "Find My iPhone", value: "On")
                    SettingsValueRow(title: "HomeKit", value: "On")
                    SettingsValueRow(title: "Location-Based Alerts", value: "On")
                    SettingsValueRow(title: "Motion Calibration & Distance", value: "On")
                    SettingsValueRow(title: "Networking & Wireless", value: "On")
                    SettingsValueRow(title: "Setting Time Zone", value: "On")
                    SettingsValueRow(title: "Share My Location", value: "On")
                    SettingsValueRow(title: "Significant Locations", value: "42 Records")
                    SettingsValueRow(title: "iPhone Analytics", value: "Off")
                    SettingsValueRow(title: "Routing & Traffic", value: "On")
                    SettingsValueRow(title: "Improve Maps", value: "On")
                    SettingsValueRow(title: "Status Bar Icon", value: "On")
                }
            }
            SettingsGroup("Tracking") {
                Toggle(isOn: $state.appTrackingRequests) {
                    Text("Allow Apps to Request to Track")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Apps That Requested", value: "3")
                SettingsValueRow(title: "News", value: "Off")
                SettingsValueRow(title: "Shopping", value: "Off")
                SettingsValueRow(title: "Weather", value: "Off")
            }
        }

        SettingsGroup("App Access", .inline) {
            SettingsGroup("Contacts") {
                Picker("Default Access", selection: $state.contactsAccess) {
                    Text("None").tag("None")
                    Text("Limited").tag("Limited")
                    Text("Full Access").tag("Full Access")
                }
                SettingsValueRow(title: "Mail", value: "Full Access")
                SettingsValueRow(title: "Messages", value: "Full Access")
                SettingsValueRow(title: "Social", value: "Limited Access")
            }
            SettingsGroup("Calendars") {
                SettingsValueRow(title: "Calendar", value: "Full Access")
                SettingsValueRow(title: "Mail", value: "Add Events Only")
                SettingsValueRow(title: "Reminders", value: "Full Access")
            }
            SettingsGroup("Photos Access") {
                Picker("Example Social App", selection: $state.photosAccess) {
                    Text("None").tag("None")
                    Text("Selected Photos").tag("Selected Photos")
                    Text("Full Access").tag("Full Access")
                }
                SettingsValueRow(title: "Camera", value: "Add Photos Only")
                SettingsValueRow(title: "Messages", value: "Full Access")
                SettingsValueRow(title: "Files", value: "Selected Photos")
            }
            SettingsGroup("Bluetooth Access") {
                Toggle(isOn: $state.bluetoothAppAccess) {
                    Text("Allow App Bluetooth Access")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Home", value: "On")
                SettingsValueRow(title: "Health", value: "On")
                SettingsValueRow(title: "Music", value: "On")
            }
            SettingsGroup("Local Network") {
                Toggle(isOn: $state.localNetworkAccess) {
                    Text("Allow Local Network Access")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Home", value: "On")
                SettingsValueRow(title: "Music", value: "On")
                SettingsValueRow(title: "Remote", value: "On")
            }
            SettingsGroup("Microphone") {
                Toggle(isOn: $state.microphoneAccess) {
                    Text("Allow Microphone Access")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Camera", value: "On")
                SettingsValueRow(title: "FaceTime", value: "On")
                SettingsValueRow(title: "Messages", value: "On")
                SettingsValueRow(title: "Voice Memos", value: "On")
            }
            SettingsGroup("Camera Access") {
                Toggle(isOn: $state.cameraAccess) {
                    Text("Allow Camera Access")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "FaceTime", value: "On")
                SettingsValueRow(title: "Messages", value: "On")
                SettingsValueRow(title: "Safari", value: "Ask")
            }
            SettingsValueRow(title: "Reminders", value: "4 Apps")
            SettingsValueRow(title: "Speech Recognition", value: "2 Apps")
            SettingsValueRow(title: "Health", value: "6 Apps")
            SettingsValueRow(title: "HomeKit", value: "3 Apps")
            SettingsValueRow(title: "Media & Apple Music", value: "5 Apps")
            SettingsValueRow(title: "Files and Folders", value: "8 Apps")
            SettingsValueRow(title: "Focus", value: "2 Apps")
        }

        SettingsGroup("Safety", .inline) {
            SettingsGroup("Safety Check") {
                SettingsNote("Quickly review people, apps, and devices with access to your information. Emergency Reset immediately stops all sharing.")
                SettingsValueRow(title: "Manage Sharing & Access", value: "Review")
                SettingsValueRow(title: "Emergency Reset", value: "Available")
                Toggle(isOn: $state.safetyCheckComplete) {
                    Text("Review Complete")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
            SettingsGroup("Sensitive Content Warning") {
                SettingsValueRow(title: "Sensitive Content Warning", value: "On")
                SettingsValueRow(title: "Safety Resources", value: "Available")
                SettingsValueRow(title: "Improve Sensitive Content Warning", value: "Off")
            }
            SettingsGroup("Lockdown Mode") {
                Toggle(isOn: $state.lockdownMode) {
                    Text("Lockdown Mode")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsNote("Lockdown Mode is an extreme, optional protection designed for the very few individuals who may be targeted by highly sophisticated cyberattacks.")
            }
        }

        SettingsGroup("Transparency & Analytics", .inline) {
            SettingsGroup("App Privacy Report") {
                SettingsValueRow(title: "Data & Sensor Access", value: "7 Days")
                SettingsValueRow(title: "App Network Activity", value: "42 Domains")
                SettingsValueRow(title: "Website Network Activity", value: "18 Domains")
                SettingsValueRow(title: "Most Contacted Domains", value: "View Report")
            }
            SettingsGroup("Analytics & Improvements") {
                Toggle(isOn: $state.analyticsSharing) {
                    Text("Share iPhone Analytics")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.analyticsSharing) {
                    Text("Share iCloud Analytics")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.analyticsSharing) {
                    Text("Improve Safety")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.analyticsSharing) {
                    Text("Improve Siri & Dictation")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Analytics Data", value: "128 Logs")
            }
            SettingsGroup("Apple Advertising") {
                Toggle(isOn: $state.personalizedAds) {
                    Text("Personalized Ads")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Ad Targeting Information", value: "View")
            }
        }
    }
}
