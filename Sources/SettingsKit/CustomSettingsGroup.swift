import SwiftUI

/// A settings group that navigates to a completely custom view.
///
/// Use `CustomSettingsGroup` when you need to show a fully custom interface that doesn't
/// fit into the standard settings structure. The group itself (title, icon, tags) is indexed
/// and searchable, but the content is not indexed—it's rendered as-is when navigated to.
///
/// ## Overview
///
/// `CustomSettingsGroup` is perfect for scenarios where you need complete control over the UI:
/// - Complex custom layouts that don't use standard settings controls
/// - Data visualizations, charts, or graphs
/// - Third-party UI components or frameworks
/// - Custom interactive experiences within your settings
///
/// ## Basic Usage
///
/// ```swift
/// CustomSettingsGroup("Developer Tools", systemImage: "hammer") {
///     VStack(spacing: 20) {
///         Text("Custom Developer UI")
///             .font(.largeTitle)
///
///         Button("Clear Cache") {
///             clearCache()
///         }
///     }
///     .padding()
/// }
/// ```
///
/// ## Improving Searchability
///
/// Add tags to make your custom group easier to find in search:
///
/// ```swift
/// CustomSettingsGroup("Advanced Settings", systemImage: "gearshape.2")
///     .settingsTags(["debug", "developer", "advanced"])
/// {
///     MyCompletelyCustomView()
/// }
/// ```
///
/// When users search for terms matching the title, icon, or tags, the group appears in
/// search results. Tapping it navigates to your custom view.
///
/// ## Architecture Details
///
/// The group creates a single node in the settings tree with no children. The custom
/// content view is registered in the `SettingsNodeViewRegistry` and rendered when
/// the user navigates to the group.
///
/// - Important: Unlike `SettingsGroup`, custom groups only support navigation presentation,
///   not inline presentation. They always appear as tappable navigation rows.
/// - Note: Individual elements within your custom view are not indexed for search.
///   Only the group itself (title, icon, tags) is searchable.
public struct CustomSettingsGroup<Content: View>: SettingsContent {
    let id: UUID
    let title: String
    let icon: String?
    let tags: [String]
    let content: Content

    /// Creates a custom settings group with a title, optional icon, and custom content.
    ///
    /// - Parameters:
    ///   - title: The display title for the group, shown in the navigation row and search results.
    ///   - icon: An optional SF Symbol name for the group icon.
    ///   - tags: Additional search keywords to improve discoverability (default: empty).
    ///   - content: A view builder that returns your custom SwiftUI view.
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
    ///
    /// Tags provide additional keywords that users can search for to find this group.
    /// This is particularly useful for groups that might be searched using alternate
    /// terminology or related concepts.
    ///
    /// - Parameter tags: An array of search keywords (e.g., `["debug", "developer", "advanced"]`).
    /// - Returns: A new custom settings group with the specified tags.
    ///
    /// ## Example
    ///
    /// ```swift
    /// CustomSettingsGroup("Developer Tools", systemImage: "hammer")
    ///     .settingsTags(["debug", "testing", "diagnostics"])
    /// {
    ///     DeveloperToolsView()
    /// }
    /// ```
    func settingsTags(_ tags: [String]) -> Self {
        CustomSettingsGroup(
            title,
            systemImage: icon,
            tags: tags,
            content: { content }
        )
    }
}
