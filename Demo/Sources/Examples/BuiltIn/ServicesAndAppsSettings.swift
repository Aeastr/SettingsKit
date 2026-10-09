import SwiftUI
import SettingsKit

struct ServicesAndAppsSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Services", .inline) {
            SettingsGroup("Game Center") {
                SettingsGroup("Profile", .inline) {
                    Toggle(isOn: $state.gameCenterEnabled) {
                        Text("Game Center")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    SettingsValueRow(title: "Nickname", value: "Sample Player")
                    SettingsValueRow(title: "Avatar", value: "Memoji")
                    Picker("Profile Privacy", selection: $state.profilePrivacy) {
                        Text("Everyone").tag("Everyone")
                        Text("Friends Only").tag("Friends Only")
                        Text("Only You").tag("Only You")
                    }
                }
                SettingsGroup("Friends", .inline) {
                    SettingsValueRow(title: "Friends", value: "24")
                    Toggle(isOn: $state.connectWithFriends) {
                        Text("Allow Invites")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.connectWithFriends) {
                        Text("Connect with Friends")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.nearbyPlayers) {
                        Text("Nearby Players")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                }
                SettingsGroup("Activity", .inline) {
                    SettingsValueRow(title: "Achievements", value: "186")
                    SettingsValueRow(title: "Recently Played", value: "12 Games")
                    SettingsValueRow(title: "Multiplayer", value: "Allowed")
                }
            }

            SettingsGroup("Wallet & Apple Pay") {
                SettingsGroup("Payment Cards", .inline) {
                    SettingsGroup("Sample Card") {
                        SettingsValueRow(title: "Card Number", value: "•••• 0001 · Sample")
                        SettingsValueRow(title: "Billing Address", value: "Home")
                        SettingsValueRow(title: "Transactions", value: "12 This Month")
                        SettingsValueRow(title: "Card Notifications", value: "On")
                    }
                    SettingsGroup("Example Bank Visa") {
                        SettingsValueRow(title: "Card Number", value: "•••• 0002 · Sample")
                        SettingsValueRow(title: "Express Transit", value: "Off")
                        SettingsValueRow(title: "Billing Address", value: "Home")
                    }
                    Button("Add Card") {}
                }
                SettingsGroup("Transaction Defaults", .inline) {
                    SettingsValueRow(title: "Default Card", value: "Sample Card")
                    SettingsValueRow(title: "Shipping Address", value: "Home")
                    SettingsValueRow(title: "Email", value: state.profileEmail)
                    SettingsValueRow(title: "Phone", value: "(415) 555-0142")
                }
                SettingsGroup("Access", .inline) {
                    Toggle(isOn: $state.doubleClickSideButton) {
                        Text("Double-Click Side Button")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.walletOrderTracking) {
                        Text("Order Tracking")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    Toggle(isOn: $state.expressTransit) {
                        Text("Express Transit")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                    SettingsValueRow(title: "Use Apple Pay When Available", value: "On")
                }
            }
            .settingsTags(["Apple Pay", "cards", "payments", "transactions"])
        }

        SettingsGroup("Applications", .inline) {
            SettingsGroup("Apps") {
                SettingsGroup("App Store") {
                    AppStoreSettings(state: state)
                }
                SettingsGroup("Camera App") {
                    CameraSettings(state: state)
                }
                SettingsGroup("Mail") {
                    MailSettings(state: state)
                }
                SettingsGroup("Maps") {
                    MapsSettings(state: state)
                }
                SettingsGroup("Messages") {
                    MessagesSettings(state: state)
                }
                SettingsGroup("Music") {
                    MusicSettings(state: state)
                }
                SettingsGroup("Phone") {
                    PhoneSettings(state: state)
                }
                SettingsGroup("Photos") {
                    PhotosSettings(state: state)
                }
                SettingsGroup("Safari") {
                    SafariSettings(state: state)
                }
                SettingsGroup("SettingsKit Demo") {
                    SettingsGroup("Permissions", .inline) {
                        SettingsValueRow(title: "Siri & Search", value: "On")
                        SettingsValueRow(title: "Notifications", value: "Banners")
                        SettingsValueRow(title: "Cellular Data", value: "On")
                    }
                    SettingsGroup("Demo Data", .inline) {
                        Toggle(isOn: $state.syncProfileSettings) {
                            Text("Sync Settings Between Presentations")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                            .toggleStyle(.switch)
                            .smallControlSizeOnMacOS()
                        SettingsValueRow(title: "Version", value: "1.0 (1)")
                    }
                }
            }
            .settingsTags(["installed apps", "permissions", "defaults", "storage"])
        }
    }
}

private struct AppStoreSettings: SettingsContent {
    @Bindable var state: SettingsState
    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Automatic Downloads", .inline) {
            Toggle(isOn: $state.automaticUpdates) {
                Text("App Downloads")
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
        }
        SettingsGroup("Cellular Data", .inline) {
            Toggle(isOn: $state.cellularDataEnabled) {
                Text("Automatic Downloads")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "App Downloads", value: "Ask If Over 200 MB")
            Toggle(isOn: $state.showNotifications) {
                Text("Video Autoplay")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("Account", .inline) {
            SettingsValueRow(title: "In-App Ratings & Reviews", value: "On")
            SettingsValueRow(title: "Offload Unused Apps", value: state.offloadUnusedApps ? "On" : "Off")
            SettingsValueRow(title: "Personalized Recommendations", value: "On")
        }
    }
}

private struct MailSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Accounts", .inline) {
            SettingsValueRow(title: "iCloud", value: state.profileEmail)
            SettingsValueRow(title: "Work", value: "Exchange")
            SettingsValueRow(title: "Fetch New Data", value: "Push")
            Button("Add Account") {}
        }
        SettingsGroup("Message List", .inline) {
            SettingsValueRow(title: "Preview", value: "2 Lines")
            SettingsValueRow(title: "Show To/Cc Labels", value: "Off")
            SettingsValueRow(title: "Swipe Options", value: "Archive · Flag")
            SettingsValueRow(title: "Ask Before Deleting", value: "Off")
            SettingsValueRow(title: "Load Remote Images", value: "On")
        }
        SettingsGroup("Messages", .inline) {
            Toggle(isOn: $state.mailPrivacyProtection) {
                Text("Protect Mail Activity")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Organize by Thread", value: "On")
            SettingsValueRow(title: "Collapse Read Messages", value: "Off")
            SettingsValueRow(title: "Complete Threads", value: "On")
            SettingsValueRow(title: "Blocked Sender Options", value: "Move to Trash")
        }
        SettingsGroup("Composing", .inline) {
            SettingsValueRow(title: "Always Bcc Myself", value: "Off")
            SettingsValueRow(title: "Mark Addresses", value: "None")
            SettingsValueRow(title: "Increase Quote Level", value: "On")
            SettingsValueRow(title: "Signature", value: "Sent from my iPhone")
            SettingsValueRow(title: "Default Account", value: "iCloud")
        }
    }
}

private struct MapsSettings: SettingsContent {
    @Bindable var state: SettingsState
    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Preferred Type of Travel", .inline) {
            Picker("Preferred Transport", selection: $state.mapsPreferredTransport) {
                Text("Driving").tag("Driving")
                Text("Walking").tag("Walking")
                Text("Transit").tag("Transit")
                Text("Cycling").tag("Cycling")
            }
        }
        SettingsGroup("Directions", .inline) {
            Toggle(isOn: $state.mapsAvoidTolls) {
                Text("Avoid Tolls")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Avoid Highways", value: "Off")
            SettingsValueRow(title: "Avoid Busy Roads", value: "Off")
            SettingsValueRow(title: "Cycling Type", value: "All Roads")
        }
        SettingsGroup("Map Display", .inline) {
            SettingsValueRow(title: "Distance Units", value: "Miles")
            SettingsValueRow(title: "Air Quality Index", value: "On")
            SettingsValueRow(title: "Weather Conditions", value: "On")
            SettingsValueRow(title: "Always in English", value: "Off")
        }
        SettingsGroup("Profile", .inline) {
            SettingsValueRow(title: "My Guides", value: "3")
            SettingsValueRow(title: "Favorites", value: "12")
            SettingsValueRow(title: "Parked Location", value: "On")
        }
    }
}

private struct MessagesSettings: SettingsContent {
    @Bindable var state: SettingsState
    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("iMessage", .inline) {
            Toggle(isOn: $state.messagesIMessage) {
                Text("iMessage")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Send & Receive", value: "2 Addresses")
            SettingsValueRow(title: "Share Name and Photo", value: "Contacts Only")
            SettingsValueRow(title: "Shared with You", value: "On")
            SettingsValueRow(title: "Show Contact Photos", value: "On")
        }
        SettingsGroup("SMS/MMS", .inline) {
            Toggle(isOn: $state.messagesSendAsSMS) {
                Text("Send as Text Message")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.messagesMMS) {
                Text("MMS Messaging")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Group Messaging", value: "On")
            SettingsValueRow(title: "Show Subject Field", value: "Off")
            SettingsValueRow(title: "Character Count", value: "Off")
        }
        SettingsGroup("Message History", .inline) {
            SettingsValueRow(title: "Keep Messages", value: "Forever")
            SettingsValueRow(title: "Unknown & Spam", value: "Filter Unknown Senders")
            SettingsValueRow(title: "Audio Messages Expire", value: "After 2 Minutes")
            SettingsValueRow(title: "Low Quality Image Mode", value: "Off")
        }
    }
}

private struct MusicSettings: SettingsContent {
    @Bindable var state: SettingsState
    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Apple Music", .inline) {
            SettingsValueRow(title: "Show Apple Music", value: "On")
            SettingsValueRow(title: "Add Playlist Songs", value: "On")
            SettingsValueRow(title: "Sync Library", value: "On")
            SettingsValueRow(title: "Animated Art", value: "Wi-Fi Only")
        }
        SettingsGroup("Audio", .inline) {
            Picker("Dolby Atmos", selection: $state.musicDolbyAtmos) {
                Text("Automatic").tag("Automatic")
                Text("Always On").tag("Always On")
                Text("Off").tag("Off")
            }
            Toggle(isOn: $state.musicLossless) {
                Text("Lossless Audio")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Audio Quality", value: "High Quality")
            SettingsValueRow(title: "EQ", value: "Off")
            SettingsValueRow(title: "Sound Check", value: "On")
            SettingsValueRow(title: "Crossfade", value: "4 Seconds")
        }
        SettingsGroup("Downloads", .inline) {
            SettingsValueRow(title: "Automatic Downloads", value: "On")
            SettingsValueRow(title: "Downloaded Music", value: "9.8 GB")
            SettingsValueRow(title: "Optimize Storage", value: "8 GB Minimum")
        }
    }
}

private struct PhoneSettings: SettingsContent {
    @Bindable var state: SettingsState
    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Calls", .inline) {
            SettingsValueRow(title: "My Number", value: "(415) 555-0142")
            SettingsValueRow(title: "Wi-Fi Calling", value: "On")
            SettingsValueRow(title: "Calls on Other Devices", value: "On")
            SettingsValueRow(title: "Respond with Text", value: "3 Replies")
            SettingsValueRow(title: "Call Forwarding", value: "Off")
            SettingsValueRow(title: "Call Waiting", value: "On")
            SettingsValueRow(title: "Show My Caller ID", value: "On")
            SettingsValueRow(title: "Dial Assist", value: "On")
        }
        SettingsGroup("Incoming Calls", .inline) {
            SettingsValueRow(title: "Incoming Calls", value: "Banner")
            SettingsValueRow(title: "Announce Calls", value: "Headphones & Car")
            SettingsValueRow(title: "Silence Unknown Callers", value: "Off")
            SettingsValueRow(title: "Call Blocking & Identification", value: "1 App")
            SettingsValueRow(title: "Blocked Contacts", value: "3")
        }
        SettingsGroup("Voicemail", .inline) {
            SettingsValueRow(title: "Live Voicemail", value: "On")
            SettingsValueRow(title: "Change Voicemail Password", value: "Available")
        }
    }
}

private struct PhotosSettings: SettingsContent {
    @Bindable var state: SettingsState
    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("iCloud", .inline) {
            Toggle(isOn: $state.iCloudPhotos) {
                Text("Sync this iPhone")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Optimize iPhone Storage", value: "On")
            SettingsValueRow(title: "Download and Keep Originals", value: "Off")
            SettingsValueRow(title: "Shared Albums", value: "On")
        }
        SettingsGroup("Library", .inline) {
            SettingsValueRow(title: "Use Face ID", value: "Hidden & Recently Deleted")
            SettingsValueRow(title: "Show Hidden Album", value: "On")
            SettingsValueRow(title: "Show Recently Viewed & Shared", value: "On")
            SettingsValueRow(title: "Show Holiday Events", value: "On")
            SettingsValueRow(title: "Featured Content", value: "On")
        }
        SettingsGroup("Transfer", .inline) {
            SettingsValueRow(title: "Transfer to Mac or PC", value: "Automatic")
            Toggle(isOn: $state.photosCellularData) {
                Text("Cellular Data")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Unlimited Updates", value: "Off")
        }
    }
}

private struct SafariSettings: SettingsContent {
    @Bindable var state: SettingsState
    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Search", .inline) {
            Picker("Search Engine", selection: $state.safariSearchEngine) {
                Text("Google").tag("Google")
                Text("Yahoo").tag("Yahoo")
                Text("Bing").tag("Bing")
                Text("DuckDuckGo").tag("DuckDuckGo")
                Text("Ecosia").tag("Ecosia")
            }
            SettingsValueRow(title: "Private Search Engine", value: "DuckDuckGo")
            SettingsValueRow(title: "Search Engine Suggestions", value: "On")
            SettingsValueRow(title: "Safari Suggestions", value: "On")
            SettingsValueRow(title: "Quick Website Search", value: "On")
            SettingsValueRow(title: "Preload Top Hit", value: "On")
        }
        SettingsGroup("Tabs", .inline) {
            SettingsValueRow(title: "Tab Bar", value: "Bottom")
            SettingsValueRow(title: "Landscape Tab Bar", value: "On")
            SettingsValueRow(title: "Open Links", value: "In New Tab")
            SettingsValueRow(title: "Close Tabs", value: "After One Month")
        }
        SettingsGroup("Privacy & Security", .inline) {
            Toggle(isOn: $state.safariPreventTracking) {
                Text("Prevent Cross-Site Tracking")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.safariBlockPopups) {
                Text("Block Pop-ups")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Fraudulent Website Warning", value: "On")
            SettingsValueRow(title: "Privacy Preserving Ad Measurement", value: "On")
            SettingsValueRow(title: "Hide IP Address", value: "From Trackers")
            SettingsValueRow(title: "Require Face ID to Unlock Private Browsing", value: "On")
            SettingsValueRow(title: "Advanced Tracking Protection", value: "Private Browsing")
        }
        SettingsGroup("History and Website Data", .inline) {
            Button("Clear History and Website Data", role: .destructive) {}
            SettingsValueRow(title: "Downloads", value: "On My iPhone")
            SettingsValueRow(title: "Page Zoom", value: "100%")
            SettingsValueRow(title: "Request Desktop Website", value: "Off")
            SettingsValueRow(title: "Reader", value: "Off")
        }
    }
}
