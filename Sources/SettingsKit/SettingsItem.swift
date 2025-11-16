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
            title: title,
            icon: icon,
            tags: tags,
            searchable: searchable,
            content: AnyView(content)
        )]
    }
}
