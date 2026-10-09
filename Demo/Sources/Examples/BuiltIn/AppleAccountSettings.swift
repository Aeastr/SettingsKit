import SwiftUI
import SettingsKit

struct AppleAccountSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Profile", .inline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(state.profileDisplayName)
                    .font(.title2.bold())
                Text(state.profileEmail)
                    .foregroundStyle(.secondary)
                Text("Apple Account, iCloud, Media & Purchases")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            TextField("Name", text: $state.profileDisplayName)
                .indexed("Apple Account Name", tags: ["profile", "identity"])
            TextField("Email", text: $state.profileEmail)
                .indexed("Apple Account Email", tags: ["contact", "sign-in"])
            SettingsNote("This profile and every device identifier in the demo are fictional sample data.")
        }

        SettingsGroup("Personal Information") {
            SettingsGroup("Name, Phone Numbers, Email", .inline) {
                SettingsValueRow(title: "Name", value: state.profileDisplayName)
                SettingsValueRow(title: "Reachable At", value: state.profileEmail)
                SettingsValueRow(title: "Phone", value: "+1 (415) 555-0142")
                Toggle(isOn: $state.showNotifications) {
                    Text("Apple Announcements")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.automaticUpdates) {
                    Text("Apps, Music, TV & More")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
            SettingsGroup("Password & Security", .inline) {
                SettingsValueRow(title: "Two-Factor Authentication", value: "On")
                SettingsValueRow(title: "Account Recovery", value: "Recovery Contact Added")
                SettingsValueRow(title: "Legacy Contact", value: "1 Contact")
                SettingsValueRow(title: "Automatic Verification", value: "On")
                Button("Change Password") {}
            }
            SettingsGroup("Payment & Shipping", .inline) {
                SettingsValueRow(title: "Payment Method", value: "Apple Pay")
                SettingsValueRow(title: "Shipping Address", value: "Home")
            }
        }

        SettingsGroup("iCloud") {
            SettingsGroup("Storage", .inline) {
                ProgressView(value: 31.6, total: 50)
                SettingsValueRow(title: "Used", value: "31.6 GB of 50 GB")
                StorageUsageRow(title: "Photos", detail: "18.2 GB", color: .blue)
                StorageUsageRow(title: "Backups", detail: "7.4 GB", color: .purple)
                StorageUsageRow(title: "Messages", detail: "3.8 GB", color: .green)
                StorageUsageRow(title: "Documents", detail: "2.2 GB", color: .orange)
                Button("Manage Account Storage") {}
            }
            SettingsGroup("Saved to iCloud", .inline) {
                Toggle(isOn: $state.iCloudPhotos) {
                    Text("Photos")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.iCloudDrive) {
                    Text("iCloud Drive")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.autoFillPasswords) {
                    Text("Passwords & Keychain")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.messagesIMessage) {
                    Text("Messages")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.mailPrivacyProtection) {
                    Text("Mail")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.syncProfileSettings) {
                    Text("Health")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.syncProfileSettings) {
                    Text("Contacts")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.syncProfileSettings) {
                    Text("Calendars")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
            SettingsGroup("Device Backups") {
                Toggle(isOn: $state.syncProfileSettings) {
                    Text("Back Up This iPhone")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Last Successful Backup", value: "Today, 3:42 AM")
                SettingsValueRow(title: "Next Backup Size", value: "2.1 GB")
                Button("Back Up Now") {}
            }
            SettingsGroup("iCloud+ Features", .inline) {
                Toggle(isOn: $state.privateRelay) {
                    Text("Private Relay")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Hide My Email", value: "12 Addresses")
                SettingsValueRow(title: "Custom Email Domain", value: "Not Set Up")
                SettingsValueRow(title: "HomeKit Secure Video", value: "1 Camera")
                Toggle(isOn: $state.advancedDataProtection) {
                    Text("Advanced Data Protection")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
        }
        .settingsTags(["cloud", "backup", "storage", "keychain", "Private Relay"])

        SettingsGroup("Media & Purchases") {
            SettingsGroup("Account", .inline) {
                SettingsValueRow(title: "Apple Account", value: state.profileEmail)
                SettingsValueRow(title: "Country/Region", value: "United States")
                SettingsValueRow(title: "Ratings & Reviews", value: "Sample User")
            }
            SettingsGroup("Downloads", .inline) {
                Toggle(isOn: $state.automaticUpdates) {
                    Text("Music")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.automaticUpdates) {
                    Text("Apps")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.automaticUpdates) {
                    Text("App Updates")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.downloadUpdatesAutomatically) {
                    Text("In-App Content")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.autoFillPasswords) {
                    Text("Always Require Password")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
        }

        SettingsGroup("Find My") {
            SettingsGroup("Find My iPhone", .inline) {
                Toggle(isOn: $state.findMyIPhone) {
                    Text("Find My iPhone")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.findMyIPhone) {
                    Text("Find My Network")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.shareMyLocation) {
                    Text("Send Last Location")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
            Toggle(isOn: $state.shareMyLocation) {
                Text("Share My Location")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "My Location", value: "This Device")
        }

        SettingsGroup("Family") {
            SettingsGroup("Family Members", .inline) {
                SettingsValueRow(title: "Sample User", value: "Organizer")
                SettingsValueRow(title: "Sample Family Member", value: "Adult")
            }
            SettingsGroup("Shared Features", .inline) {
                Toggle(isOn: $state.purchaseSharing) {
                    Text("Purchase Sharing")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Subscriptions", value: "Apple One")
                SettingsValueRow(title: "Location Sharing", value: "On")
                SettingsValueRow(title: "iCloud+", value: "50 GB Shared")
            }
        }

        SettingsGroup("Devices", .inline) {
            SettingsGroup("Sample iPhone") {
                SettingsValueRow(title: "Model", value: "Sample iPhone Pro")
                SettingsValueRow(title: "Version", value: "iOS 27.0")
                SettingsValueRow(title: "Phone Number", value: "(415) 555-0142")
                SettingsValueRow(title: "Find My", value: "On")
                SettingsValueRow(title: "iCloud Backup", value: "On")
                SettingsValueRow(title: "Apple Pay", value: "2 Cards")
            }
            SettingsGroup("Sample Mac") {
                SettingsValueRow(title: "Model", value: "Sample Mac Pro")
                SettingsValueRow(title: "Version", value: "macOS 27.0")
                SettingsValueRow(title: "Find My Mac", value: "On")
            }
            SettingsGroup("Apple Watch") {
                SettingsValueRow(title: "Model", value: "Apple Watch Series 10")
                SettingsValueRow(title: "Version", value: "watchOS 27.0")
            }
        }

        Button("Sign Out", role: .destructive) {}
    }
}
