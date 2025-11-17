import SwiftUI

/// A settings group that navigates to a completely custom view.
///
/// Use `CustomSettingsGroup` when you need to show a fully custom interface that doesn't
/// fit into the standard settings structure. The group itself (title, icon, tags) is indexed
/// and searchable, but the content is not indexed - it's rendered as-is when navigated to.
///
/// ```swift
/// CustomSettingsGroup("Advanced Settings", systemImage: "gearshape.2") {
///     MyCompletelyCustomView()
/// }
/// ```
///
/// - Note: Unlike `SettingsGroup`, this only supports navigation presentation (no inline).
public struct CustomSettingsGroup<Content: View>: SettingsContent {
    let id: UUID
    let title: String
    let icon: String?
    let tags: [String]
    let content: Content

    public init(
        _ title: String,
        systemImage icon: String? = nil,
        tags: [String] = [],
        @ViewBuilder content: () -> Content
    ) {
        // Use hash-based stable ID
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(icon)
        hasher.combine("custom") // Distinguish from regular groups
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
        self.content = content()
    }

    public var body: some View {
        let style = EnvironmentValues().settingsStyle

        // Always render as navigation group
        style.makeGroup(
            configuration: SettingsGroupConfiguration(
                title: title,
                icon: icon,
                footer: nil,
                presentation: .navigation,
                content: AnyView(content),
                children: [] // No indexed children
            )
        )
    }

    public func makeNodes() -> [SettingsNode] {
        // Register the custom view content in the registry
        SettingsNodeViewRegistry.shared.register(id: id) { [content] in
            AnyView(content)
        }

        // Create a group node with no children (content is not indexed)
        return [.group(
            id: id,
            title: title,
            icon: icon,
            tags: tags,
            presentation: .navigation,
            children: [] // Empty - custom content is not indexed
        )]
    }
}

// MARK: - Modifiers

public extension CustomSettingsGroup {
    /// Adds tags to the custom settings group for improved searchability.
    func settingsTags(_ tags: [String]) -> Self {
        CustomSettingsGroup(
            title,
            systemImage: icon,
            tags: tags,
            content: { content }
        )
    }
}
