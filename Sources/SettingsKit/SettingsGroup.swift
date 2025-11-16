import SwiftUI

/// A group of settings that can contain both items and nested groups.
public struct SettingsGroup<Content: SettingsContent>: SettingsContent {
    let id: UUID
    let title: String
    let icon: String?
    let footer: String?
    var tags: [String]
    var style: SettingsGroupStyle
    let content: Content

    public init(
        _ title: String,
        systemImage: String? = nil,
        footer: String? = nil,
        @SettingsContentBuilder content: () -> Content
    ) {
        // Create a stable ID based on title and icon
        // This ensures the same group always has the same ID across makeNodes() calls
        let idString = "\(title)-\(systemImage ?? "")"
        self.id = UUID(uuidString: idString.toUUIDString()) ?? UUID()
        self.title = title
        self.icon = systemImage
        self.footer = footer
        self.tags = []
        self.style = .navigation
        self.content = content()
    }

    public var body: some View {
        Group {
            switch style {
            case .navigation:
                SettingsGroupView(title: title, icon: icon, group: self)
            case .inline:
                InlineGroupView(group: self, footer: footer)
            }
        }
    }

    public func makeNodes() -> [SettingsNode] {
        let children = content.makeNodes()

        // All groups create nodes for themselves, both inline and navigation
        // The style is stored in the node to control rendering
        return [.group(
            id: id,
            title: title,
            icon: icon,
            tags: tags,
            style: style,
            children: children,
            liveGroup: AnySettingsGroup(self)
        )]
    }
}

// MARK: - Modifiers

public extension SettingsGroup {
    func settingsTags(_ tags: [String]) -> Self {
        var copy = self
        copy.tags = tags
        return copy
    }

    func settingsStyle(_ style: SettingsGroupStyle) -> Self {
        var copy = self
        copy.style = style
        return copy
    }
}

// MARK: - Helpers

private extension String {
    func toUUIDString() -> String {
        // Create a deterministic UUID from a string using MD5-like approach
        // Pad or truncate to 32 hex chars (16 bytes)
        let hex = self.utf8.reduce(into: "") { result, byte in
            result += String(format: "%02x", byte)
        }
        let paddedHex = (hex + String(repeating: "0", count: 32)).prefix(32)
        // Format as UUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        let formatted = "\(paddedHex.prefix(8))-\(paddedHex.dropFirst(8).prefix(4))-\(paddedHex.dropFirst(12).prefix(4))-\(paddedHex.dropFirst(16).prefix(4))-\(paddedHex.dropFirst(20).prefix(12))"
        return String(formatted)
    }
}
