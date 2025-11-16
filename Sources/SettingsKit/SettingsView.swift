import SwiftUI

/// Main view for rendering a settings container.
public struct SettingsView<Container: SettingsContainer>: View {
    let container: Container
    @State private var searchText = ""
    @State private var navigationPath = NavigationPath()
    @Environment(\.settingsStyle) private var style

    public init(container: Container) {
        self.container = container
    }

    public var body: some View {
        style.makeContainer(
            configuration: SettingsContainerConfiguration(
                title: "Settings",
                content: AnyView(contentView),
                searchText: $searchText,
                navigationPath: $navigationPath
            )
        )
    }

    @ViewBuilder
    private var contentView: some View {
        if searchText.isEmpty {
            container.settingsBody
        } else if searchResults.isEmpty {
            ContentUnavailableView(
                "No Results for \"\(searchText)\"",
                systemImage: "magnifyingglass",
                description: Text("Check the spelling or try a different search")
            )
        } else {
            ForEach(searchResults) { result in
                SearchResultSection(result: result, navigationPath: $navigationPath)
            }
        }
    }

    var searchResults: [SearchResult] {
        guard !searchText.isEmpty else { return [] }

        // Build fresh nodes on every search to get live state
        let allNodes = container.settingsBody.makeNodes()

        var results: [SearchResult] = []
        searchNodes(allNodes, query: searchText.lowercased(), results: &results)

        // Deduplicate by group ID (keep the one with higher score)
        var seenIDs: [UUID: SearchResult] = [:]
        for result in results {
            let id = result.group.id
            let score = matchScore(for: result.group, query: searchText.lowercased())

            if let existing = seenIDs[id] {
                let existingScore = matchScore(for: existing.group, query: searchText.lowercased())
                if score > existingScore {
                    seenIDs[id] = result
                }
            } else {
                seenIDs[id] = result
            }
        }

        let uniqueResults = Array(seenIDs.values)

        // Sort results by match quality
        let sortedResults = uniqueResults.sorted { lhs, rhs in
            let lhsScore = matchScore(for: lhs.group, query: searchText.lowercased())
            let rhsScore = matchScore(for: rhs.group, query: searchText.lowercased())
            return lhsScore > rhsScore
        }

        // Debug: print what we found
        print("=== Search results for '\(searchText)' ===")
        for result in sortedResults {
            if case .group(_, let title, _, _, let children) = result.group {
                let score = matchScore(for: result.group, query: searchText.lowercased())
                print("- \(title) (score: \(score))")
            }
        }

        return sortedResults
    }

    func normalize(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "&", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
    }

    func matchScore(for node: SettingsNode, query: String) -> Int {
        let title = node.title
        let normalizedTitle = normalize(title)
        let normalizedQuery = normalize(query)

        // Exact match (normalized)
        if normalizedTitle == normalizedQuery {
            return 1000
        }

        // Starts with (normalized)
        if normalizedTitle.hasPrefix(normalizedQuery) {
            return 500
        }

        // Starts with (original, case-insensitive)
        if title.lowercased().hasPrefix(query) {
            return 400
        }

        // Contains (normalized)
        if normalizedTitle.contains(normalizedQuery) {
            return 300
        }

        // Contains (original, case-insensitive)
        if title.lowercased().contains(query) {
            return 200
        }

        // Tag match
        if node.tags.contains(where: { normalize($0).contains(normalizedQuery) }) {
            return 100
        }

        return 0
    }

    func searchNodes(_ nodes: [SettingsNode], query: String, results: inout [SearchResult]) {
        for node in nodes {
            switch node {
            case .group(let id, let title, let icon, let tags, let children):
                let groupMatches = title.lowercased().contains(query) ||
                                  tags.contains(where: { $0.lowercased().contains(query) })

                let isLeafGroup = children.allSatisfy { !$0.isGroup }

                print("Group '\(title)': isLeaf=\(isLeafGroup), children=\(children.count), matches=\(groupMatches)")

                if isLeafGroup {
                    // Leaf group: check if group or any searchable children match
                    let searchableChildren = children.filter { $0.isSearchable }
                    let childMatches = searchableChildren.contains { child in
                        child.title.lowercased().contains(query) ||
                        child.tags.contains(where: { $0.lowercased().contains(query) })
                    }

                    if groupMatches || childMatches {
                        print("  -> Adding as LEAF group")
                        results.append(SearchResult(group: node, matchedItems: children, isNavigation: false))
                    }
                } else {
                    // Parent group: show as navigation link
                    if groupMatches {
                        print("  -> Adding as NAVIGATION group")
                        results.append(SearchResult(group: node, matchedItems: [], isNavigation: true))

                        // Add all immediate children as separate results
                        for child in children {
                            if case .group(_, _, _, _, let grandchildren) = child {
                                let isLeafChild = grandchildren.allSatisfy { !$0.isGroup }
                                if isLeafChild {
                                    print("  -> Also adding child '\(child.title)' as LEAF group")
                                    results.append(SearchResult(group: child, matchedItems: grandchildren, isNavigation: false))
                                } else {
                                    // Also add navigation children
                                    print("  -> Also adding child '\(child.title)' as NAVIGATION group")
                                    results.append(SearchResult(group: child, matchedItems: [], isNavigation: true))
                                }
                            }
                        }
                    }
                    // Always recurse into children to find deeper matches
                    searchNodes(children, query: query, results: &results)
                }

            case .item:
                // Items should be handled by their parent group
                break
            }
        }
    }
}

/// Represents a search result: a group with its items
struct SearchResult: Identifiable {
    let id = UUID()
    let group: SettingsNode
    let matchedItems: [SettingsNode]
    let isNavigation: Bool // true = show as nav link, false = show items inline
}

/// Renders a search result section with tappable header
struct SearchResultSection: View {
    let result: SearchResult
    @Binding var navigationPath: NavigationPath

    var body: some View {
        if case .group(_, let title, let icon, _, let children) = result.group {
            Group {
                if result.isNavigation {
                    // Navigation result: show as a single tappable row
                    NavigationLink(value: result.group) {
                        Label(title, systemImage: icon ?? "folder")
                    }
                } else {
                    // Leaf group result: show as section with items
                    Section {
                        ForEach(result.matchedItems) { item in
                            SearchResultItem(node: item)
                        }
                    } header: {
                        Button {
                            navigationPath.append(result.group)
                        } label: {
                            HStack {
                                if let icon = icon {
                                    Image(systemName: icon)
                                }
                                Text(title)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .onAppear {
                print("Rendering '\(title)': isNav=\(result.isNavigation), items=\(result.matchedItems.count)")
            }
        }
    }
}

/// Renders an individual item in search results
struct SearchResultItem: View {
    let node: SettingsNode

    var body: some View {
        switch node {
        case .group(_, _, _, _, let children):
            ForEach(children) { child in
                SearchResultItem(node: child)
            }

        case .item(_, _, _, _, _, let content):
            content
        }
    }
}

/// Detail view for a settings node (used in programmatic navigation)
struct SettingsNodeDetailView: View {
    let node: SettingsNode

    var body: some View {
        if case .group(_, let title, _, _, let children) = node {
            List {
                ForEach(children) { child in
                    NodeView(node: child)
                }
            }
            .navigationTitle(title)
        }
    }
}

/// Internal view for rendering a single node (group or item)
struct NodeView: View {
    let node: SettingsNode

    var body: some View {
        switch node {
        case .group(_, let title, let icon, _, _):
            // For groups, create a navigation link
            NavigationLink(value: node) {
                Label(title, systemImage: icon ?? "folder")
            }

        case .item(_, _, _, _, _, let content):
            // For items, render the actual content
            content
        }
    }
}
