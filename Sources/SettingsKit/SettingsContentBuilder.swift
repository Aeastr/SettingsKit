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
    /// }
    /// ```
    ///
    /// - Note: Arbitrary views are rendered but don't contribute to search/navigation.
    ///   Only `SettingsGroup` and `SettingsItem` are searchable.
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
/// Only `SettingsGroup` and `SettingsItem` contribute to the searchable node tree.
///
/// - Note: Uses `nonisolated(unsafe)` for concurrency safety. This is safe because views
///   are UI state that always execute on the main thread, even though the compiler can't
///   verify this at compile time.
struct ViewWrapper: SettingsContent {
    /// The wrapped view content stored as type-erased AnyView.
    nonisolated(unsafe) let content: AnyView

    /// Creates a wrapper around any view.
    /// - Parameter content: The view to wrap as SettingsContent.
    nonisolated init<Content: View>(_ content: Content) {
        self.content = AnyView(content)
    }

    var body: some View {
        content
    }

    /// Returns an empty array since arbitrary views don't contribute to search/navigation.
    func makeNodes() -> [SettingsNode] {
        []
    }
}
