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
        self.id = UUID()
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
            children: children
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
