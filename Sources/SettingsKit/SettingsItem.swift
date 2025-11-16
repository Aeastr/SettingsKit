import SwiftUI

/// A single settings item with metadata and custom content view.
public struct SettingsItem<Content: View>: SettingsContent {
    let id: UUID
    let title: LocalizedStringKey
    let icon: String?
    let tags: [String]
    let searchable: Bool
    let content: Content

    // Title only
    public init(
        _ title: LocalizedStringKey,
        tags: [String] = [],
        searchable: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.id = UUID()
        self.title = title
        self.icon = nil
        self.tags = tags
        self.searchable = searchable
        self.content = content()
    }

    // Title + system image
    public init(
        _ title: LocalizedStringKey,
        systemImage: String,
        tags: [String] = [],
        searchable: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.id = UUID()
        self.title = title
        self.icon = systemImage
        self.tags = tags
        self.searchable = searchable
        self.content = content()
    }

    // Legacy: icon parameter (deprecated in favor of systemImage)
    public init(
        _ title: LocalizedStringKey,
        icon: String?,
        tags: [String] = [],
        searchable: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.tags = tags
        self.searchable = searchable
        self.content = content()
    }

    public var body: some View {
        content
    }

    public func makeNodes() -> [SettingsNode] {
        [.item(
            id: id,
            title: String(localized: title),
            icon: icon,
            tags: tags,
            searchable: searchable,
            content: AnyView(content)
        )]
    }
}
