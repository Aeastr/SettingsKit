import SwiftUI
import SettingsKit

struct ConnectivitySettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Connectivity", .inline) {
            SettingsGroup("Airplane Mode") {
                SettingsGroup("Airplane Mode", .inline, footer: "Airplane Mode turns off cellular and wireless features. Wi-Fi and Bluetooth can be turned back on separately when permitted by the airline.") {
                    Toggle(isOn: $state.airplaneModeEnabled) {
                        Text("Airplane Mode")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                        .indexed("Airplane Mode", tags: ["flight", "travel", "offline", "radio"])
                }

                SettingsGroup("Wireless Overrides", .inline) {
                    Toggle(isOn: $state.wifiEnabled) {
                        Text("Wi-Fi")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                        .indexed("Wi-Fi in Airplane Mode", tags: ["flight", "wireless"])
                    Toggle(isOn: $state.bluetoothEnabled) {
                        Text("Bluetooth")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                        .indexed("Bluetooth in Airplane Mode", tags: ["flight", "accessories"])
                    SettingsValueRow(title: "Cellular", value: state.airplaneModeEnabled ? "Off" : "On")
                }

                SettingsGroup("Before You Fly", .inline) {
                    SettingsValueRow(title: "Downloaded Music", value: "8.4 GB")
                    SettingsValueRow(title: "Offline Maps", value: "California")
                    SettingsValueRow(title: "Emergency Calls", value: "Unavailable")
                    SettingsNote("Location services that do not require a network, including GPS, remain available in Airplane Mode.")
                }
            }
            .settingsTags(["flight", "travel", "offline"])

            SettingsGroup("Wi-Fi") {
                SettingsGroup("Wi-Fi", .inline) {
                    Toggle(isOn: $state.wifiEnabled) {
                        Text("Wi-Fi")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                        .indexed("Wi-Fi", tags: ["wireless", "internet", "network"])
                }

                if state.wifiEnabled {
                    SettingsGroup("Connected Network", .inline) {
                        SettingsGroup("Sample Home Wi-Fi") {
                            WiFiNetworkDetails(state: state)
                        }
                        .settingsTags(["SSID", "router", "IP address", "DNS", "proxy"])
                    }

                    SettingsGroup("My Networks", .inline) {
                        NetworkRow(name: "Sample Home Wi-Fi", detail: "Connected", strength: "wifi", secured: true)
                            .indexed("Sample Home Wi-Fi", tags: ["Wi-Fi", "connected", "network"])
                        NetworkRow(name: "Sample Studio Wi-Fi", detail: nil, strength: "wifi", secured: true)
                            .indexed("Sample Studio Wi-Fi", tags: ["wireless", "saved network"])
                    }

                    SettingsGroup("Other Networks", .inline) {
                        NetworkRow(name: "Coffee House", detail: nil, strength: "wifi", secured: true)
                        NetworkRow(name: "Guest Network", detail: nil, strength: "wifi", secured: false)
                        NetworkRow(name: "Neighbor's Wi-Fi", detail: nil, strength: "wifi.exclamationmark", secured: true)
                        SettingsGroup("Other…") {
                            TextField("Network Name", text: $state.preferredWiFiNetwork)
                            SettingsValueRow(title: "Security", value: "WPA2/WPA3")
                            TextField("Password", text: $state.hotspotPassword)
                            Button("Join") {}
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }

                SettingsGroup("Joining Networks", .inline, footer: "Known networks are joined automatically. If no known networks are available, you can be notified before joining a new network.") {
                    Picker("Ask to Join Networks", selection: $state.askToJoinNetworks) {
                        Text("Off").tag("Off")
                        Text("Notify").tag("Notify")
                        Text("Ask").tag("Ask")
                    }
                    .indexed("Ask to Join Networks", tags: ["Wi-Fi", "prompt", "notify"])

                    Picker("Auto-Join Hotspot", selection: $state.autoJoinHotspot) {
                        Text("Never").tag("Never")
                        Text("Ask to Join").tag("Ask to Join")
                        Text("Automatic").tag("Automatic")
                    }
                    .indexed("Auto-Join Hotspot", tags: ["Wi-Fi", "personal hotspot"])

                    SettingsGroup("Edit Known Networks") {
                        SettingsGroup("Known Networks", .inline) {
                            SettingsValueRow(title: "Sample Home Wi-Fi", value: "Auto-Join")
                            SettingsValueRow(title: "Sample Studio Wi-Fi", value: "Auto-Join")
                            SettingsValueRow(title: "Airport Free Wi-Fi", value: "Not Joined")
                        }
                        Button("Remove Expired Passpoint Networks") {}
                    }
                }
            }
            .settingsTags(["wireless", "internet", "SSID", "router"])

            SettingsGroup("Bluetooth") {
                SettingsGroup("Bluetooth", .inline, footer: "This iPhone is discoverable as “Sample iPhone” while this screen is open.") {
                    Toggle(isOn: $state.bluetoothEnabled) {
                        Text("Bluetooth")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                        .indexed("Bluetooth", tags: ["wireless", "accessories", "pairing"])
                }

                if state.bluetoothEnabled {
                    SettingsGroup("My Devices", .inline) {
                        SettingsGroup("AirPods Pro") {
                            BluetoothDeviceDetails(state: state)
                        }
                        DeviceRow(name: "Apple Watch", detail: "Connected", symbol: "applewatch")
                        DeviceRow(name: "Magic Keyboard", detail: "Not Connected", symbol: "keyboard")
                        DeviceRow(name: "Car Audio", detail: "Not Connected", symbol: "car.fill")
                    }

                    SettingsGroup("Other Devices", .inline) {
                        DeviceRow(name: "Living Room Speaker", detail: "Pair", symbol: "hifispeaker.fill")
                        Toggle(isOn: $state.bluetoothSystemNotifications) {
                            Text("Show System Notifications")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                            .toggleStyle(.switch)
                            .smallControlSizeOnMacOS()
                            .indexed("Bluetooth System Notifications", tags: ["accessory", "alerts"])
                    }
                }
            }
            .settingsTags(["wireless", "accessories", "pairing", "AirPods"])

            SettingsGroup("Cellular") {
                CellularSettings(state: state)
            }
            .settingsTags(["mobile data", "5G", "LTE", "carrier", "SIM"])

            SettingsGroup("Personal Hotspot") {
                SettingsGroup("Personal Hotspot", .inline, footer: "Allow other devices signed in to your iCloud account to connect without asking when Wi-Fi and Bluetooth are enabled.") {
                    Toggle(isOn: $state.personalHotspotEnabled) {
                        Text("Allow Others to Join")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                        .indexed("Allow Others to Join Personal Hotspot", tags: ["tethering", "internet sharing"])
                    TextField("Wi-Fi Password", text: $state.hotspotPassword)
                        .indexed("Personal Hotspot Wi-Fi Password", tags: ["tethering", "security"])
                    Toggle(isOn: $state.hotspotMaxCompatibility) {
                        Text("Maximize Compatibility")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                        .indexed("Maximize Hotspot Compatibility", tags: ["2.4 GHz", "tethering"])
                }

                SettingsGroup("How to Connect", .inline) {
                    SettingsValueRow(title: "Wi-Fi", value: "Sample iPhone")
                    SettingsValueRow(title: "Bluetooth", value: "Pair, then connect")
                    SettingsValueRow(title: "USB", value: "Trust this computer")
                }
            }
            .settingsTags(["tethering", "internet sharing", "Wi-Fi password"])

            SettingsGroup("VPN") {
                SettingsGroup("Status", .inline) {
                    Toggle(isOn: $state.vpnQuickEnabled) {
                        Text("VPN")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .toggleStyle(.switch)
                        .smallControlSizeOnMacOS()
                        .indexed("VPN Status", tags: ["privacy", "network", "tunnel"])
                }
                SettingsGroup("Configurations", .inline) {
                    SettingsGroup("Work VPN") {
                        SettingsValueRow(title: "Type", value: "IKEv2")
                        SettingsValueRow(title: "Description", value: "Work VPN")
                        SettingsValueRow(title: "Server", value: "vpn.example.com")
                        SettingsValueRow(title: "Remote ID", value: "example.com")
                        SettingsValueRow(title: "Authentication", value: "Certificate")
                        Toggle(isOn: $state.vpnQuickEnabled) {
                            Text("Connect On Demand")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                            .toggleStyle(.switch)
                            .smallControlSizeOnMacOS()
                    }
                    Button("Add VPN Configuration…") {}
                }
            }
            .settingsTags(["privacy", "network", "IKEv2", "tunnel"])
        }
    }
}

private struct WiFiNetworkDetails: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Connection", .inline) {
            Toggle(isOn: $state.wifiAutoJoin) {
                Text("Auto-Join")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.wifiLowDataMode) {
                Text("Low Data Mode")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Wi-Fi 6E Mode", value: "Automatic")
        }
        SettingsGroup("Privacy & Security", .inline) {
            SettingsValueRow(title: "Security", value: "WPA3 Personal")
            Toggle(isOn: $state.wifiPrivateAddress) {
                Text("Private Wi-Fi Address")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.wifiLimitIPTracking) {
                Text("Limit IP Address Tracking")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("IPv4 Address", .inline) {
            Picker("Configure IP", selection: $state.configureIP) {
                Text("Automatic").tag("Automatic")
                Text("Manual").tag("Manual")
            }
            SettingsValueRow(title: "IP Address", value: "192.168.1.42")
            SettingsValueRow(title: "Subnet Mask", value: "255.255.255.0")
            SettingsValueRow(title: "Router", value: "192.168.1.1")
        }
        SettingsGroup("DNS", .inline) {
            Picker("Configure DNS", selection: $state.configureDNS) {
                Text("Automatic").tag("Automatic")
                Text("Manual").tag("Manual")
            }
            SettingsValueRow(title: "DNS Servers", value: "192.168.1.1")
            SettingsValueRow(title: "Search Domains", value: "home")
        }
        SettingsGroup("HTTP Proxy", .inline) {
            Picker("Configure Proxy", selection: $state.httpProxy) {
                Text("Off").tag("Off")
                Text("Manual").tag("Manual")
                Text("Automatic").tag("Automatic")
            }
        }
        Button("Forget This Network", role: .destructive) {}
    }
}

private struct BluetoothDeviceDetails: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("AirPods Pro", .inline) {
            SettingsValueRow(title: "Connected", value: "Yes")
            SettingsValueRow(title: "Battery", value: "AirPods 86% · Case 72%")
            TextField("Name", text: $state.profileDisplayName)
        }
        SettingsGroup("Noise Control", .inline) {
            Picker("Listening Mode", selection: $state.siriResponses) {
                Text("Noise Cancellation").tag("Noise Cancellation")
                Text("Adaptive").tag("Adaptive")
                Text("Transparency").tag("Transparency")
                Text("Off").tag("Off")
            }
            Toggle(isOn: $state.bluetoothDiscoverable) {
                Text("Conversation Awareness")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.bluetoothSystemNotifications) {
                Text("Personalized Volume")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("Microphone", .inline) {
            SettingsValueRow(title: "Microphone", value: "Automatically Switch AirPods")
            SettingsValueRow(title: "Model Number", value: "A-SAMPLE")
            SettingsValueRow(title: "Version", value: "SAMPLE.1")
        }
        Button("Forget This Device", role: .destructive) {}
    }
}

private struct CellularSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Cellular Data", .inline) {
            Toggle(isOn: $state.cellularDataEnabled) {
                Text("Cellular Data")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
                .indexed("Cellular Data", tags: ["mobile", "internet", "carrier"])
            SettingsGroup("Cellular Data Options") {
                Toggle(isOn: $state.dataRoaming) {
                    Text("Data Roaming")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Picker("Voice & Data", selection: $state.voiceAndData) {
                    Text("5G Auto").tag("5G Auto")
                    Text("5G On").tag("5G On")
                    Text("LTE").tag("LTE")
                }
                Picker("Data Mode", selection: $state.dataMode) {
                    Text("Allow More Data on 5G").tag("Allow More Data on 5G")
                    Text("Standard").tag("Standard")
                    Text("Low Data Mode").tag("Low Data Mode")
                }
                Toggle(isOn: $state.cellularLimitIPTracking) {
                    Text("Limit IP Address Tracking")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
            SettingsValueRow(title: "Personal Hotspot", value: state.personalHotspotEnabled ? "On" : "Off")
        }

        SettingsGroup("SIMs", .inline) {
            SettingsGroup("Primary") {
                Toggle(isOn: $state.cellularLineEnabled) {
                    Text("Turn On This Line")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Label", value: "Primary")
                SettingsValueRow(title: "Carrier", value: "Example Wireless")
                SettingsValueRow(title: "My Number", value: "(415) 555-0142")
                SettingsValueRow(title: "Network Selection", value: "Automatic")
                SettingsValueRow(title: "Wi-Fi Calling", value: "On")
                SettingsValueRow(title: "Calls on Other Devices", value: "On")
                SettingsValueRow(title: "SIM PIN", value: "Off")
            }
            Button("Add eSIM") {}
        }

        SettingsGroup("Cellular Data Usage", .inline, footer: "Current Period: 18.7 GB · Roaming: 0 bytes") {
            SettingsValueRow(title: "Photos", value: "4.8 GB")
            SettingsValueRow(title: "Music", value: "3.1 GB")
            SettingsValueRow(title: "Safari", value: "2.6 GB")
            SettingsValueRow(title: "Maps", value: "1.3 GB")
            SettingsValueRow(title: "System Services", value: "2.1 GB")
            Toggle(isOn: $state.wifiAssist) {
                Text("Wi-Fi Assist")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.iCloudDriveCellular) {
                Text("iCloud Drive")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }

        SettingsGroup("Carrier Services", .inline) {
            SettingsValueRow(title: "Carrier Services", value: "Example Wireless")
            SettingsValueRow(title: "SIM Applications", value: "None")
            Button("Reset Statistics") {}
        }
    }
}
