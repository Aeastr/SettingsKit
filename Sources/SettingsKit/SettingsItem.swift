import SwiftUI

/// A single settings item with metadata and custom content view.
public struct SettingsItem<Content: View>: SettingsContent {
    let id: UUID
    let title: String
    let icon: String?
    let tags: [String]
    let searchable: Bool
    let content: Content

    public init(
        _ title: String,
        icon: String? = nil,
        tags: [String] = [],
        searchable: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        // Use a stable ID based on title and icon to ensure consistency across makeNodes() calls
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(icon)
        let hashValue = hasher.finalize()
        self.id = UUID(uuid: uuid_t(
            UInt8((hashValue >> 56) & 0xFF), UInt8((hashValue >> 48) & 0xFF),
            UInt8((hashValue >> 40) & 0xFF), UInt8((hashValue >> 32) & 0xFF),
            UInt8((hashValue >> 24) & 0xFF), UInt8((hashValue >> 16) & 0xFF),
            UInt8((hashValue >> 8) & 0xFF),  UInt8(hashValue & 0xFF),
            0, 0, 0, 0, 0, 0, 0, 0
        ))

        self.title = title
        self.icon = icon
        self.tags = tags
        self.searchable = searchable
        self.content = content()
    }

    @Environment(\.searchResultIDs) private var searchResultIDs

    public var body: some View {
        // If search filtering is active, only render if this item matches
        if let searchIDs = searchResultIDs {
            let shouldRender = searchIDs.contains(id)
            let _ = print("🔍 Item '\(title)' (ID: \(id)) - shouldRender: \(shouldRender)")
            if shouldRender {
                StyledSettingsItem(
                    title: title,
                    icon: icon,
                    content: content
                )
            }
        } else {
            // No search filtering, render normally
            StyledSettingsItem(
                title: title,
                icon: icon,
                content: content
            )
        }
    }

    public func makeNodes() -> [SettingsNode] {
        // Register the view builder for this item so search can render it
        SettingsNodeViewRegistry.shared.register(id: id) { [content] in
            AnyView(content)
        }

        return [.item(
            id: id,
            title: title,
            icon: icon,
            tags: tags,
            searchable: searchable
            // No content - nodes are metadata only
        )]
    }

    /// Adds search tags to this item.
    public func settingsTags(_ tags: [String]) -> Self {
        SettingsItem(
            title,
            icon: icon,
            tags: tags,
            searchable: searchable,
            content: { content }
        )
    }
}

// MARK: - Styled Item View

/// Internal view that applies the current item style from the environment.
struct StyledSettingsItem<Content: View>: View {
    let title: String
    let icon: String?
    let content: Content

    @Environment(\.settingsStyle) private var style

    var body: some View {
        style.makeItem(
            configuration: SettingsItemConfiguration(
                title: title,
                icon: icon,
                content: AnyView(content)
            )
        )
    }
}
