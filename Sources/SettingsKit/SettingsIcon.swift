import SwiftUI

/// A styled icon view for settings, mimicking the iOS Settings app appearance.
///
/// Use `SettingsIcon` to create colored icon backgrounds like those in the iOS Settings app:
///
/// ```swift
/// SettingsGroup("Airplane Mode") {
///     Toggle("Enabled", isOn: $airplaneMode)
/// } icon: {
///     SettingsIcon("airplane", color: .orange)
/// }
/// ```
public struct SettingsIcon: View {
    private let systemName: String
    private let color: Color

    // iOS Settings icon dimensions
    private let iconSize: CGFloat = 29
    private let cornerRadius: CGFloat = 8
    private let iconScale: CGFloat = 0.7

    /// Creates a settings icon with the specified SF Symbol and background color.
    ///
    /// - Parameters:
    ///   - systemName: The name of the SF Symbol to display.
    ///   - color: The background color for the icon.
    public init(_ systemName: String, color: Color) {
        self.systemName = systemName
        self.color = color
    }

    public var body: some View {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
                .frame(width: iconSize, height: iconSize)
                .overlay{
                    Image(systemName: systemName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize * iconScale, height: iconSize * iconScale)
//                        .background(.red)
                        .foregroundStyle(.white)
                }
    }
}

#Preview {
    List {
        Section("Connections") {
            Label { Text("Airplane Mode") } icon: { SettingsIcon("airplane", color: .orange) }
            Label { Text("Wi-Fi") } icon: { SettingsIcon("wifi", color: .blue) }
            Label { Text("Bluetooth") } icon: { SettingsIcon("wave.3.right", color: .blue) }
            Label { Text("Cellular") } icon: { SettingsIcon("antenna.radiowaves.left.and.right", color: .green) }
            Label { Text("Personal Hotspot") } icon: { SettingsIcon("personalhotspot", color: .green) }
        }

        Section("Battery & VPN") {
            Label { Text("Battery") } icon: { SettingsIcon("battery.100", color: .green) }
            Label { Text("VPN") } icon: { SettingsIcon("network", color: .blue) }
        }

        Section("Main Settings") {
            Label { Text("General") } icon: { SettingsIcon("gearshape", color: .gray) }
            Label { Text("Accessibility") } icon: { SettingsIcon("figure.arms.open", color: .blue) }
            Label { Text("Action Button") } icon: { SettingsIcon("button.programmable", color: .blue) }
            Label { Text("Apple Intelligence & Siri") } icon: { SettingsIcon("apple.logo", color: .purple) }
            Label { Text("Camera") } icon: { SettingsIcon("camera.fill", color: .gray) }
            Label { Text("Control Center") } icon: { SettingsIcon("switch.2", color: .gray) }
            Label { Text("Display & Brightness") } icon: { SettingsIcon("sun.max.fill", color: .blue) }
            Label { Text("Home Screen & App Library") } icon: { SettingsIcon("square.grid.2x2", color: .blue) }
        }

        Section("Display & Interface") {
            Label { Text("Search") } icon: { SettingsIcon("magnifyingglass", color: .gray) }
            Label { Text("StandBy") } icon: { SettingsIcon("platter.2.filled.iphone", color: .black) }
            Label { Text("Wallpaper") } icon: { SettingsIcon("photo.on.rectangle", color: .cyan) }
        }

        Section("Notifications & Focus") {
            Label { Text("Notifications") } icon: { SettingsIcon("bell.badge.fill", color: .red) }
            Label { Text("Sounds & Haptics") } icon: { SettingsIcon("speaker.wave.3.fill", color: .pink) }
            Label { Text("Focus") } icon: { SettingsIcon("moon.fill", color: .purple) }
            Label { Text("Screen Time") } icon: { SettingsIcon("hourglass", color: .purple) }
        }

        Section("Safety & Privacy") {
            Label { Text("Emergency SOS") } icon: { SettingsIcon("sos", color: .red) }
            Label { Text("Privacy & Security") } icon: { SettingsIcon("hand.raised.fill", color: .blue) }
        }

        Section("Cloud & Services") {
            Label { Text("Game Center") } icon: { SettingsIcon("gamecontroller.fill", color: .pink) }
            Label { Text("iCloud") } icon: { SettingsIcon("icloud.fill", color: .blue) }
            Label { Text("Wallet & Apple Pay") } icon: { SettingsIcon("wallet.pass.fill", color: .black) }
        }

        Section("Applications") {
            Label { Text("Apps") } icon: { SettingsIcon("square.grid.3x3.fill", color: .blue) }
            Label { Text("Custom UI Demo") } icon: { SettingsIcon("paintbrush.pointed", color: .orange) }
        }

        Section("Nested Icons") {
            Label { Text("About") } icon: { SettingsIcon("info.circle", color: .gray) }
            Label { Text("Software Update") } icon: { SettingsIcon("gear.badge", color: .gray) }
            Label { Text("iPhone Storage") } icon: { SettingsIcon("internaldrive", color: .gray) }
            Label { Text("AirDrop") } icon: { SettingsIcon("airplayaudio", color: .gray) }
            Label { Text("AirPlay & Continuity") } icon: { SettingsIcon("tv.and.hifispeaker.fill", color: .gray) }
            Label { Text("Picture in Picture") } icon: { SettingsIcon("rectangle.on.rectangle", color: .gray) }
            Label { Text("CarPlay") } icon: { SettingsIcon("car", color: .gray) }
            Label { Text("AutoFill & Passwords") } icon: { SettingsIcon("key.fill", color: .gray) }
            Label { Text("Date & Time") } icon: { SettingsIcon("clock", color: .gray) }
            Label { Text("Keyboard") } icon: { SettingsIcon("keyboard", color: .gray) }
            Label { Text("Language & Region") } icon: { SettingsIcon("globe", color: .gray) }
            Label { Text("VPN Configuration") } icon: { SettingsIcon("lock.shield", color: .gray) }
            Label { Text("Advanced") } icon: { SettingsIcon("gearshape.2", color: .gray) }
        }

        Section("Developer") {
            Label { Text("Input Testing") } icon: { SettingsIcon("wrench.and.screwdriver", color: .gray) }
            Label { Text("Profile") } icon: { SettingsIcon("person.crop.circle.fill", color: .gray) }
        }
    }
}
