import SwiftUI

// MARK: - Result Builder

/// Result builder for declaratively composing settings content.
///
/// ``SettingsContainer/settingsBody`` and ``SettingsGroup`` content closures apply this builder automatically. Apply `@SettingsContentBuilder` explicitly to the `body` of a custom ``SettingsContent`` type when it contains multiple top-level settings expressions.
@resultBuilder
public struct SettingsContentBuilder {
    /// Combines a variadic list of settings content into one content group.
    ///
    /// - Parameter components: The content values declared in the builder block.
    /// - Returns: A group that renders and indexes each component in order.
    @MainActor
    public static func buildBlock(_ components: any SettingsContent...) -> SettingsContentGroup {
        SettingsContentGroup(Array(components))
    }

    /// Combines content produced by a loop.
    ///
    /// - Parameter components: The settings content produced by loop iterations.
    /// - Returns: A group containing the flattened iteration content.
    @MainActor
    public static func buildArray(_ components: [any SettingsContent]) -> SettingsContentGroup {
        SettingsContentGroup(components)
    }

    /// Represents optional settings content.
    ///
    /// - Parameter component: The conditionally produced content, if present.
    /// - Returns: The content or an empty settings placeholder.
    public static func buildOptional(_ component: (any SettingsContent)?) -> any SettingsContent {
        component ?? EmptySettingsContent()
    }

    /// Selects the first branch of a conditional declaration.
    ///
    /// - Parameter component: The content produced by the first branch.
    /// - Returns: The selected content.
    public static func buildEither(first component: any SettingsContent) -> any SettingsContent {
        component
    }

    /// Selects the second branch of a conditional declaration.
    ///
    /// - Parameter component: The content produced by the second branch.
    /// - Returns: The selected content.
    public static func buildEither(second component: any SettingsContent) -> any SettingsContent {
        component
    }

    /// Passes existing settings content through the builder.
    ///
    /// - Parameter expression: A value that already conforms to ``SettingsContent``.
    /// - Returns: The original settings content.
    @preconcurrency
    public static func buildExpression(_ expression: any SettingsContent) -> any SettingsContent {
        expression
    }

    /// Allow arbitrary Views to be included in the settings hierarchy.
    ///
    /// This enables view modifiers and custom views to be used within `SettingsContainer`:
    /// ```swift
    /// SettingsContainer {
    ///     SettingsGroup("Apps") { ... }
    ///     .toolbar { }  // ✅ Works - wrapped as ViewWrapper
    ///
    ///     Text("Custom content")  // ✅ Works - wrapped as ViewWrapper
    ///
    ///     Toggle("Dark Mode", isOn: $isDark)
    ///         .indexed("Dark Mode")  // ✅ Make it searchable
    /// }
    /// ```
    ///
    /// - Note: Views are rendered but don't contribute to search unless you use `.indexed()`.
    @preconcurrency
    public static func buildExpression<V: View>(_ view: V) -> any SettingsContent {
        ViewWrapper(view)
    }
}

// MARK: - Content Group

/// A type-erased collection of settings content values.
///
/// The result builder uses this type to preserve declaration order while rendering and indexing heterogeneous ``SettingsContent`` values.
public struct SettingsContentGroup: SettingsContent {
    let items: [any SettingsContent]
    @Environment(\.settingsContentRowDecoration) private var rowDecoration

    /// Creates a content group.
    ///
    /// - Parameter items: The heterogeneous content values to group.
    public init(_ items: [any SettingsContent]) {
        self.items = items
    }

    /// The settings content rendered in declaration order.
    public var body: some View {
        let items = renderItems

        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            renderedItem(item, showsSeparator: index < items.count - 1)
        }
    }

    @ViewBuilder
    private func renderedItem(_ item: SettingsContentRenderItem, showsSeparator: Bool) -> some View {
        if rowDecoration {
            switch item.rowRole {
            case .inlineGroup:
                AnyView(erasing: item.content)
            case .navigationGroup:
                VStack(spacing: 0) {
                    AnyView(erasing: item.content)
                    if showsSeparator {
                        SettingsContentRowSeparator()
                    }
                }
            case .content:
                VStack(spacing: 0) {
                    AnyView(erasing: item.content)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                    if showsSeparator {
                        SettingsContentRowSeparator()
                    }
                }
            }
        } else {
            AnyView(erasing: item.content)
        }
    }

    /// SwiftUI must not identify heterogeneous settings solely by their array position. A settings shell can replace one hierarchy with another (tabs are a common example), and positional identity would make controls in the new hierarchy inherit the view state and animations of the old one.
    var renderItems: [SettingsContentRenderItem] {
        var occurrences: [AnyHashable: Int] = [:]

        return items.enumerated().map { index, content in
            if let semanticID = (content as? any SettingsContentIdentityProviding)?.settingsContentIdentity {
                let occurrence = occurrences[semanticID, default: 0]
                occurrences[semanticID] = occurrence + 1
                return SettingsContentRenderItem(
                    id: .semantic(semanticID, occurrence: occurrence),
                    content: content
                )
            }

            return SettingsContentRenderItem(id: .position(index), content: content)
        }
    }

    private func AnyView(erasing view: any View) -> AnyView {
        SwiftUI.AnyView(view)
    }

    /// Builds child metadata using the shared registration scope.
    ///
    /// - Returns: The flattened nodes from all grouped content.
    public func makeNodes() -> [SettingsNode] {
        makeNodes(in: .shared)
    }

    /// Builds child metadata in a host-local registration scope.
    ///
    /// - Parameter scope: The scope forwarded to every grouped value.
    /// - Returns: The flattened nodes from all grouped content.
    public func makeNodes(in scope: SettingsContentScope) -> [SettingsNode] {
        items.flatMap { $0.makeNodes(in: scope) }
    }
}

/// Internal semantic identity used by the result builder when rendering type-erased `SettingsContent` values.
@MainActor
protocol SettingsContentIdentityProviding {
    var settingsContentIdentity: AnyHashable? { get }
}

enum SettingsContentRenderID: Hashable {
    case semantic(AnyHashable, occurrence: Int)
    case position(Int)
}

struct SettingsContentRenderItem: Identifiable {
    let id: SettingsContentRenderID
    let content: any SettingsContent

    @MainActor
    var rowRole: SettingsContentRowRole {
        (content as? any SettingsContentRowRoleProviding)?.settingsContentRowRole ?? .content
    }
}

private struct SettingsContentRowSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.14))
            .frame(height: 1)
    }
}

enum SettingsContentRowRole {
    case content
    case inlineGroup
    case navigationGroup
}

@MainActor
protocol SettingsContentRowRoleProviding {
    var settingsContentRowRole: SettingsContentRowRole { get }
}

private struct SettingsContentRowDecorationKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var settingsContentRowDecoration: Bool {
        get { self[SettingsContentRowDecorationKey.self] }
        set { self[SettingsContentRowDecorationKey.self] = newValue }
    }
}

// MARK: - Helper Types

/// Empty content for conditionals
struct EmptySettingsContent: SettingsContent {
    var body: some View {
        EmptyView()
    }

    func makeNodes() -> [SettingsNode] {
        []
    }

    func makeNodes(in scope: SettingsContentScope) -> [SettingsNode] {
        []
    }
}

/// Wraps an arbitrary View as SettingsContent.
///
/// This wrapper allows any SwiftUI view to be used within the `@SettingsContentBuilder`, enabling view modifiers like `.toolbar { }` and custom views to be included in the settings hierarchy.
///
/// The wrapper renders the view normally but returns an empty node array from `makeNodes()`, meaning these views won't appear in search results or contribute to navigation structure. Use `.indexed(_:tags:)` on any view to make it searchable.
///
/// - Note: Uses `nonisolated(unsafe)` for concurrency safety. This is safe because views are UI state that always execute on the main thread, even though the compiler can't verify this at compile time.
struct ViewWrapper: SettingsContent, SettingsContentIdentityProviding {
    /// The wrapped view content stored as type-erased AnyView.
    nonisolated(unsafe) let content: AnyView

    /// The search title for this view. Nil means not indexed.
    let title: String?

    /// Additional tags for search indexing.
    let tags: [String]

    /// Indexed views already have a semantic identity. Non-indexed views retain positional identity within their semantically identified parent group.
    nonisolated(unsafe) let settingsContentIdentity: AnyHashable?

    /// Creates a non-indexed wrapper for use by `buildExpression`.
    ///
    /// This is called automatically when raw views are used in settings without `.indexed()`. The view renders normally but won't appear in search results.
    nonisolated init<Content: View>(_ content: Content) {
        self.content = AnyView(content)
        self.title = nil
        self.tags = []
        self.settingsContentIdentity = nil
    }

    /// Creates an indexed wrapper with a title only.
    nonisolated init<Content: View>(_ content: Content, title: String) {
        self.content = AnyView(content)
        self.title = title
        self.tags = []
        self.settingsContentIdentity = AnyHashable(Self.stableID(title: title, tags: []))
    }

    /// Creates an indexed wrapper with tags only.
    nonisolated init<Content: View>(_ content: Content, tags: [String]) {
        self.content = AnyView(content)
        self.title = nil
        self.tags = tags
        self.settingsContentIdentity = AnyHashable(Self.stableID(title: nil, tags: tags))
    }

    /// Creates an indexed wrapper with both title and additional tags.
    nonisolated init<Content: View>(_ content: Content, title: String, tags: [String], id: String? = nil) {
        self.content = AnyView(content)
        self.title = title
        self.tags = tags
        self.settingsContentIdentity = AnyHashable(Self.stableID(title: id ?? title, tags: tags))
    }

    var body: some View {
        content
    }

    /// Returns nodes for search if indexed (has title or tags).
    func makeNodes() -> [SettingsNode] {
        makeNodes(in: .shared)
    }

    func makeNodes(in scope: SettingsContentScope) -> [SettingsNode] {
        // Not indexed if no title and no tags
        guard title != nil || !tags.isEmpty else { return [] }

        let id = scope.scopedID((settingsContentIdentity?.base as? UUID) ?? Self.stableID(title: title, tags: tags))

        // Register view for search results
        scope.registry.register(id: id) { [content] in
            content
        }

        return [.item(
            id: id,
            title: title ?? tags.first ?? "",
            tags: tags,
            searchable: true
        )]
    }

    nonisolated private static func stableID(title: String?, tags: [String]) -> UUID {
        var hasher = Hasher()
        hasher.combine(title ?? tags.first)
        let hashValue = hasher.finalize()
        return UUID(uuid: uuid_t(
            UInt8((hashValue >> 56) & 0xFF), UInt8((hashValue >> 48) & 0xFF),
            UInt8((hashValue >> 40) & 0xFF), UInt8((hashValue >> 32) & 0xFF),
            UInt8((hashValue >> 24) & 0xFF), UInt8((hashValue >> 16) & 0xFF),
            UInt8((hashValue >> 8) & 0xFF),  UInt8(hashValue & 0xFF),
            0, 0, 0, 0, 0, 0, 0, 0
        ))
    }
}

// MARK: - Tag Sets

/// A protocol for defining reusable sets of search tags.
///
/// Conform to this protocol to create predefined tag collections that can be shared across multiple settings views:
///
/// ```swift
/// struct ThemeTags: SettingsTagSet {
///     var tags: [String] { ["theme", "appearance", "display", "colors"] }
/// }
///
/// struct AccessibilityTags: SettingsTagSet {
///     var tags: [String] { ["accessibility", "a11y", "vision", "hearing"] }
/// }
/// ```
///
/// Then use them with the `.indexed()` modifier:
///
/// ```swift
/// Toggle("Dark Mode", isOn: $isDarkMode)
///     .indexed("Dark Mode", ThemeTags())
///
/// Toggle("Reduce Motion", isOn: $reduceMotion)
///     .indexed("Reduce Motion", AccessibilityTags())
/// ```
public protocol SettingsTagSet {
    /// The collection of search keywords in this tag set.
    var tags: [String] { get }
}

/// A simple tag set initialized with an array of strings.
///
/// Use this for inline tag set creation:
/// ```swift
/// let networkTags = Tags(["network", "wifi", "cellular", "connection"])
/// ```
public struct Tags: SettingsTagSet {
    /// The search keywords in the set.
    public let tags: [String]

    /// Creates a reusable tag set.
    ///
    /// - Parameter tags: The search keywords to store.
    public init(_ tags: [String]) {
        self.tags = tags
    }
}

// MARK: - View Extension for Search Indexing

public extension View {
    /// Indexes this view for settings search with a title.
    ///
    /// Use this modifier to make any SwiftUI view discoverable in settings search. Without this modifier, views render normally but won't appear in search results.
    ///
    /// ## Why is this needed?
    ///
    /// SwiftUI doesn't provide a way to extract label text from views at runtime. When you write `Toggle("Dark Mode", ...)`, the "Dark Mode" string is embedded in the view's type and inaccessible. This modifier explicitly provides the searchable title and keywords.
    ///
    /// ## Basic Usage
    ///
    /// ```swift
    /// // With a title
    /// Toggle("Dark Mode", isOn: $isDarkMode)
    ///     .indexed("Dark Mode")
    ///
    /// // With a title and additional tags
    /// Toggle("Dark Mode", isOn: $isDarkMode)
    ///     .indexed("Dark Mode", tags: ["theme", "appearance", "night"])
    ///
    /// // With tags only
    /// Toggle("Dark Mode", isOn: $isDarkMode)
    ///     .indexed(tags: ["Dark Mode", "theme", "appearance"])
    /// ```
    ///
    /// ## Using Tag Sets
    ///
    /// For consistent tagging across multiple views, define reusable tag sets:
    ///
    /// ```swift
    /// struct ThemeTags: SettingsTagSet {
    ///     var tags: [String] { ["theme", "appearance", "display"] }
    /// }
    ///
    /// Toggle("Dark Mode", isOn: $isDarkMode)
    ///     .indexed("Dark Mode", tagSet: ThemeTags())
    ///
    /// Picker("App Icon", selection: $appIcon) { ... }
    ///     .indexed("App Icon", tagSet: ThemeTags())
    /// ```
    ///
    /// - Parameter title: The primary search title for this view. This appears in search results.
    /// - Returns: A searchable settings content wrapper.
    func indexed(_ title: String) -> some SettingsContent {
        ViewWrapper(self, title: title)
    }

    /// Indexes this view for settings search with a title and additional tags.
    ///
    /// - Parameters:
    ///   - title: The primary search title for this view.
    ///   - tags: Additional keywords that will match this view in search.
    ///   - id: A stable model identity for same-named sibling rows.
    /// - Returns: A searchable settings content wrapper.
    func indexed(_ title: String, tags: [String], id: String? = nil) -> some SettingsContent {
        ViewWrapper(self, title: title, tags: tags, id: id)
    }

    /// Indexes this view for settings search using tags.
    ///
    /// ```swift
    /// Toggle("Dark Mode", isOn: $isDarkMode)
    ///     .indexed(tags: ["Dark Mode", "theme", "appearance"])
    /// ```
    ///
    /// - Note: Tag order matters for search ranking.
    /// - Parameter tags: Keywords that will match this view in search.
    /// - Returns: A searchable settings content wrapper.
    func indexed(tags: [String]) -> some SettingsContent {
        ViewWrapper(self, tags: tags)
    }

    /// Indexes this view for settings search using a tag set.
    ///
    /// ```swift
    /// struct NetworkTags: SettingsTagSet {
    ///     var tags: [String] { ["network", "wifi", "cellular", "internet"] }
    /// }
    ///
    /// Toggle("Wi-Fi", isOn: $wifiEnabled)
    ///     .indexed(tagSet: NetworkTags())
    /// ```
    ///
    /// - Parameter tagSet: A ``SettingsTagSet`` providing search keywords.
    /// - Returns: A searchable settings content wrapper.
    func indexed(tagSet: some SettingsTagSet) -> some SettingsContent {
        ViewWrapper(self, tags: tagSet.tags)
    }

    /// Indexes this view for settings search with a title and a tag set.
    ///
    /// ```swift
    /// struct NetworkTags: SettingsTagSet {
    ///     var tags: [String] { ["network", "wifi", "cellular", "internet"] }
    /// }
    ///
    /// Toggle("Wi-Fi", isOn: $wifiEnabled)
    ///     .indexed("Wi-Fi", tagSet: NetworkTags())
    /// ```
    ///
    /// - Parameters:
    ///   - title: The primary search title for this view.
    ///   - tagSet: A ``SettingsTagSet`` providing additional search keywords.
    /// - Returns: A searchable settings content wrapper.
    func indexed(_ title: String, tagSet: some SettingsTagSet) -> some SettingsContent {
        ViewWrapper(self, title: title, tags: tagSet.tags)
    }

    /// Indexes this view for settings search with a title and multiple tag sets.
    ///
    /// Combine multiple tag sets when a view belongs to several categories:
    ///
    /// ```swift
    /// Toggle("Reduce Motion", isOn: $reduceMotion)
    ///     .indexed("Reduce Motion", tagSets: AccessibilityTags(), AnimationTags())
    /// ```
    ///
    /// - Parameters:
    ///   - title: The primary search title for this view.
    ///   - tagSets: Multiple ``SettingsTagSet`` instances to combine.
    /// - Returns: A searchable settings content wrapper.
    func indexed(_ title: String, tagSets: any SettingsTagSet...) -> some SettingsContent {
        let combinedTags = tagSets.flatMap { $0.tags }
        return ViewWrapper(self, title: title, tags: combinedTags)
    }
}
