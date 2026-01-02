import SwiftUI

// MARK: - Presentation

/// The presentation mode for a settings group.
public enum SettingsGroupPresentation: Sendable {
    /// Display the group as a navigation link that navigates to a detail view.
    case navigation

    /// Display the group inline as a section.
    case inline
}

// MARK: - Group

/// A group of settings that can contain both items and nested groups.
public struct SettingsGroup<Content: SettingsContent, Icon: View>: SettingsContent {
    let id: UUID
    let title: String
    let iconName: String?
    let iconView: Icon
    let footer: String?
    var tags: [String]
    let presentation: SettingsGroupPresentation
    let content: Content

    /// Creates a settings group with a custom icon view.
    public init(
        _ title: String,
        _ presentation: SettingsGroupPresentation = .navigation,
        footer: String? = nil,
        @SettingsContentBuilder content: () -> Content,
        @ViewBuilder icon: () -> Icon
    ) {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(presentation)
        let hashValue = hasher.finalize()
        self.id = UUID(uuid: uuid_t(
            UInt8((hashValue >> 56) & 0xFF), UInt8((hashValue >> 48) & 0xFF),
            UInt8((hashValue >> 40) & 0xFF), UInt8((hashValue >> 32) & 0xFF),
            UInt8((hashValue >> 24) & 0xFF), UInt8((hashValue >> 16) & 0xFF),
            UInt8((hashValue >> 8) & 0xFF),  UInt8(hashValue & 0xFF),
            0, 0, 0, 0, 0, 0, 0, 0
        ))

        self.title = title
        self.iconName = nil
        self.iconView = icon()
        self.footer = footer
        self.tags = []
        self.presentation = presentation
        self.content = content()
    }

    @Environment(\.settingsStyle) private var style
    @Environment(\.searchResultIDs) private var searchResultIDs

    public var body: some View {
        let children = content.makeNodes()

        // If search filtering is active, only render if this group or its children match
        if let searchIDs = searchResultIDs {
            let shouldRender = searchIDs.contains(id) || children.contains(where: { searchIDs.contains($0.id) })
            if shouldRender {
                style.makeGroup(
                    configuration: SettingsGroupConfiguration(
                        title: title,
                        iconName: iconName,
                        iconView: AnyView(iconView),
                        footer: footer,
                        presentation: presentation,
                        content: AnyView(content.body),
                        children: children
                    )
                )
            }
        } else {
            // No search filtering, render normally
            style.makeGroup(
                configuration: SettingsGroupConfiguration(
                    title: title,
                    iconName: iconName,
                    iconView: AnyView(iconView),
                    footer: footer,
                    presentation: presentation,
                    content: AnyView(content.body),
                    children: children
                )
            )
        }
    }

    public func makeNodes() -> [SettingsNode] {
        let children = content.makeNodes()

        // Register the view builder for this group so search/navigation can render it
        SettingsNodeViewRegistry.shared.register(id: id) { [content] in
            AnyView(content.body)
        }

        // Register the icon view for search results (only for custom icon ViewBuilder, not systemImage)
        if iconName == nil {
            SettingsNodeViewRegistry.shared.registerIcon(id: id) { [iconView] in
                AnyView(iconView)
            }
        }

        return [.group(
            id: id,
            title: title,
            icon: iconName,
            tags: tags,
            presentation: presentation,
            children: children
        )]
    }
}

// MARK: - Convenience Initializer (no icon)

public extension SettingsGroup where Icon == EmptyView {
    /// Creates a settings group with an optional system image icon.
    init(
        _ title: String,
        _ presentation: SettingsGroupPresentation = .navigation,
        systemImage: String? = nil,
        footer: String? = nil,
        @SettingsContentBuilder content: () -> Content
    ) {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(systemImage)
        hasher.combine(presentation)
        let hashValue = hasher.finalize()
        self.id = UUID(uuid: uuid_t(
            UInt8((hashValue >> 56) & 0xFF), UInt8((hashValue >> 48) & 0xFF),
            UInt8((hashValue >> 40) & 0xFF), UInt8((hashValue >> 32) & 0xFF),
            UInt8((hashValue >> 24) & 0xFF), UInt8((hashValue >> 16) & 0xFF),
            UInt8((hashValue >> 8) & 0xFF),  UInt8(hashValue & 0xFF),
            0, 0, 0, 0, 0, 0, 0, 0
        ))

        self.title = title
        self.iconName = systemImage
        self.iconView = EmptyView()
        self.footer = footer
        self.tags = []
        self.presentation = presentation
        self.content = content()
    }
}

// MARK: - Modifiers

public extension SettingsGroup {
    /// Adds tags to the settings group for improved searchability.
    func settingsTags(_ tags: [String]) -> Self {
        var copy = self
        copy.tags = tags
        return copy
    }
}
