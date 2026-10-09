import SwiftUI

// MARK: - Protocol

/// A type that defines how settings search behaves.
public protocol SettingsSearch {
    /// Searches through settings nodes and returns matching results.
    /// - Parameters:
    ///   - nodes: The settings tree to search through
    ///   - query: The search query string
    /// - Returns: Array of search results, sorted by relevance
    func search(nodes: [SettingsNode], query: String) -> [SettingsSearchResult]
}

// MARK: - Search Result

/// A ranked group or item collection returned from a settings search.
public struct SettingsSearchResult: Identifiable {
    /// The result identity, derived from its group node.
    public var id: UUID { group.id }

    /// The group represented by this result.
    public let group: SettingsNode

    /// Indexed child items that matched within `group`.
    ///
    /// Navigation results retain these items. The built-in renderer shows
    /// them as live controls alongside a link to their containing group. Custom
    /// renderers can resolve them with
    /// ``SettingsPresentationContext/indexedView(for:)``.
    public let matchedItems: [SettingsNode]

    /// Whether the result includes a link to the group alongside any matched controls.
    public let isNavigation: Bool

    /// The group's declaration order in the source hierarchy.
    public let orderIndex: Int

    /// The nearest navigation ancestor used to group results in a UI.
    public let parentGroup: SettingsNode?

    /// Creates a settings search result.
    ///
    /// - Parameters:
    ///   - group: The group represented by the result.
    ///   - matchedItems: Indexed controls that matched inside the group.
    ///   - isNavigation: Whether to show a link to `group` with any matched controls.
    ///   - orderIndex: The group's declaration order for stable sorting.
    ///   - parentGroup: The nearest navigation ancestor, if one exists.
    public init(
        group: SettingsNode,
        matchedItems: [SettingsNode],
        isNavigation: Bool,
        orderIndex: Int,
        parentGroup: SettingsNode? = nil
    ) {
        self.group = group
        self.matchedItems = matchedItems
        self.isNavigation = isNavigation
        self.orderIndex = orderIndex
        self.parentGroup = parentGroup
    }
}

// MARK: - Environment

/// Environment key for settings search.
struct SettingsSearchKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: AnySettingsSearch = AnySettingsSearch(DefaultSettingsSearch())
}

extension EnvironmentValues {
    var settingsSearch: AnySettingsSearch {
        get { self[SettingsSearchKey.self] }
        set { self[SettingsSearchKey.self] = newValue }
    }
}

// MARK: - Type Erasure

/// A type-erased settings search.
public struct AnySettingsSearch {
    private let _search: ([SettingsNode], String) -> [SettingsSearchResult]

    /// Erases a concrete search implementation.
    ///
    /// - Parameter search: The search implementation to wrap.
    public init<S: SettingsSearch>(_ search: S) {
        _search = { nodes, query in
            search.search(nodes: nodes, query: query)
        }
    }

    /// Searches a settings hierarchy with the wrapped implementation.
    ///
    /// - Parameters:
    ///   - nodes: The metadata hierarchy to search.
    ///   - query: The user's search query.
    /// - Returns: The ordered matching results.
    public func search(nodes: [SettingsNode], query: String) -> [SettingsSearchResult] {
        _search(nodes, query)
    }
}

// MARK: - View Extension

public extension View {
    /// Sets the search implementation for settings in this view hierarchy.
    ///
    /// - Parameter search: The implementation used to match and rank nodes.
    /// - Returns: A view with the search implementation in its environment.
    func settingsSearch<S: SettingsSearch>(_ search: S) -> some View {
        environment(\.settingsSearch, AnySettingsSearch(search))
    }
}

// MARK: - Static Convenience

public extension SettingsSearch where Self == DefaultSettingsSearch {
    /// The built-in relevance-ranked settings search.
    static var `default`: DefaultSettingsSearch {
        DefaultSettingsSearch()
    }
}
