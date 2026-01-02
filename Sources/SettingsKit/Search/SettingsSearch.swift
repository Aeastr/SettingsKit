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

/// Represents a single search result.
public struct SettingsSearchResult: Identifiable {
    public let id = UUID()
    public let group: SettingsNode
    public let matchedItems: [SettingsNode]
    public let isNavigation: Bool // true = show as nav link, false = show items inline
    public let orderIndex: Int // Original order in the tree for stable sorting
    public let parentGroup: SettingsNode? // The nearest navigation parent (for grouping in UI)

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

    public init<S: SettingsSearch>(_ search: S) {
        _search = { nodes, query in
            search.search(nodes: nodes, query: query)
        }
    }

    public func search(nodes: [SettingsNode], query: String) -> [SettingsSearchResult] {
        _search(nodes, query)
    }
}

// MARK: - View Extension

public extension View {
    /// Sets the search implementation for all settings within this view.
    func settingsSearch<S: SettingsSearch>(_ search: S) -> some View {
        environment(\.settingsSearch, AnySettingsSearch(search))
    }
}

// MARK: - Static Convenience

public extension SettingsSearch where Self == DefaultSettingsSearch {
    /// The default settings search implementation.
    static var `default`: DefaultSettingsSearch {
        DefaultSettingsSearch()
    }
}
