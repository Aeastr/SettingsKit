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
public struct SettingsGroup<Content: SettingsContent>: SettingsContent {
    let id: UUID
    let title: String
    let icon: String?
    let footer: String?
    var tags: [String]
    let presentation: SettingsGroupPresentation
    let content: Content

    public init(
        _ title: String,
        _ presentation: SettingsGroupPresentation = .navigation,
        systemImage: String? = nil,
        footer: String? = nil,
        @SettingsContentBuilder content: () -> Content
    ) {
        // Use a stable ID based on title and icon to ensure consistency across makeNodes() calls
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
        self.icon = systemImage
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
            let _ = print("🔍 Group '\(title)' (ID: \(id)) - shouldRender: \(shouldRender), id in set: \(searchIDs.contains(id))")
            if shouldRender {
                style.makeGroup(
                    configuration: SettingsGroupConfiguration(
                        title: title,
                        icon: icon,
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
                    icon: icon,
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

        return [.group(
            id: id,
            title: title,
            icon: icon,
            tags: tags,
            presentation: presentation,
            children: children
        )]
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
