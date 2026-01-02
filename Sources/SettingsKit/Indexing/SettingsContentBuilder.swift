import SwiftUI

// MARK: - Result Builder

/// Result builder for declaratively composing settings content.
@resultBuilder
public struct SettingsContentBuilder {
    @MainActor
    public static func buildBlock(_ components: any SettingsContent...) -> SettingsContentGroup {
        SettingsContentGroup(Array(components))
    }

    @MainActor
    public static func buildArray(_ components: [any SettingsContent]) -> SettingsContentGroup {
        SettingsContentGroup(components)
    }

    public static func buildOptional(_ component: (any SettingsContent)?) -> any SettingsContent {
        component ?? EmptySettingsContent()
    }

    public static func buildEither(first component: any SettingsContent) -> any SettingsContent {
        component
    }

    public static func buildEither(second component: any SettingsContent) -> any SettingsContent {
        component
    }

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

/// Internal wrapper that groups multiple SettingsContent items
public struct SettingsContentGroup: SettingsContent {
    let items: [any SettingsContent]

    public init(_ items: [any SettingsContent]) {
        self.items = items
    }

    public var body: some View {
        ForEach(Array(items.indices), id: \.self) { index in
            AnyView(erasing: items[index])
        }
    }

    private func AnyView(erasing view: any View) -> AnyView {
        SwiftUI.AnyView(view)
    }

    public func makeNodes() -> [SettingsNode] {
        items.flatMap { $0.makeNodes() }
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
}

/// Wraps an arbitrary View as SettingsContent.
///
/// This wrapper allows any SwiftUI view to be used within the `@SettingsContentBuilder`,
/// enabling view modifiers like `.toolbar { }` and custom views to be included in the
/// settings hierarchy.
///
/// The wrapper renders the view normally but returns an empty node array from `makeNodes()`,
/// meaning these views won't appear in search results or contribute to navigation structure.
/// Use `.indexed(_:tags:)` on any view to make it searchable.
///
/// - Note: Uses `nonisolated(unsafe)` for concurrency safety. This is safe because views
///   are UI state that always execute on the main thread, even though the compiler can't
///   verify this at compile time.
struct ViewWrapper: SettingsContent {
    /// The wrapped view content stored as type-erased AnyView.
    nonisolated(unsafe) let content: AnyView

    /// The search title for this view. Nil means not indexed.
    let title: String?

    /// Additional tags for search indexing.
    let tags: [String]

    /// Creates a non-indexed wrapper for use by `buildExpression`.
    ///
    /// This is called automatically when raw views are used in settings without `.indexed()`.
    /// The view renders normally but won't appear in search results.
    nonisolated init<Content: View>(_ content: Content) {
        self.content = AnyView(content)
        self.title = nil
        self.tags = []
    }

    /// Creates an indexed wrapper with a title only.
    nonisolated init<Content: View>(_ content: Content, title: String) {
        self.content = AnyView(content)
        self.title = title
        self.tags = []
    }

    /// Creates an indexed wrapper with tags only.
    nonisolated init<Content: View>(_ content: Content, tags: [String]) {
        self.content = AnyView(content)
        self.title = nil
        self.tags = tags
    }

    /// Creates an indexed wrapper with both title and additional tags.
    nonisolated init<Content: View>(_ content: Content, title: String, tags: [String]) {
        self.content = AnyView(content)
        self.title = title
        self.tags = tags
    }

    var body: some View {
        content
    }

    /// Returns nodes for search if indexed (has title or tags).
    func makeNodes() -> [SettingsNode] {
        // Not indexed if no title and no tags
        guard title != nil || !tags.isEmpty else { return [] }

        // Generate stable ID from title or first tag
        var hasher = Hasher()
        hasher.combine(title ?? tags.first)
        let hashValue = hasher.finalize()
        let id = UUID(uuid: uuid_t(
            UInt8((hashValue >> 56) & 0xFF), UInt8((hashValue >> 48) & 0xFF),
            UInt8((hashValue >> 40) & 0xFF), UInt8((hashValue >> 32) & 0xFF),
            UInt8((hashValue >> 24) & 0xFF), UInt8((hashValue >> 16) & 0xFF),
            UInt8((hashValue >> 8) & 0xFF),  UInt8(hashValue & 0xFF),
            0, 0, 0, 0, 0, 0, 0, 0
        ))

        // Register view for search results
        SettingsNodeViewRegistry.shared.register(id: id) { [content] in
            content
        }

        return [.item(
            id: id,
            title: title ?? tags.first ?? "",
            icon: nil,
            tags: tags,
            searchable: true
        )]
    }
}

// MARK: - Tag Sets

/// A protocol for defining reusable sets of search tags.
///
/// Conform to this protocol to create predefined tag collections that can be
/// shared across multiple settings views:
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
    public let tags: [String]

    public init(_ tags: [String]) {
        self.tags = tags
    }
}

// MARK: - View Extension for Search Indexing

public extension View {
    /// Indexes this view for settings search with a title.
    ///
    /// Use this modifier to make any SwiftUI view discoverable in settings search.
    /// Without this modifier, views render normally but won't appear in search results.
    ///
    /// ## Why is this needed?
    ///
    /// SwiftUI doesn't provide a way to extract label text from views at runtime.
    /// When you write `Toggle("Dark Mode", ...)`, the "Dark Mode" string is embedded
    /// in the view's type and inaccessible. This modifier explicitly provides the
    /// searchable title and keywords.
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
    /// - Returns: A searchable settings content wrapper.
    func indexed(_ title: String, tags: [String]) -> some SettingsContent {
        ViewWrapper(self, title: title, tags: tags)
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
