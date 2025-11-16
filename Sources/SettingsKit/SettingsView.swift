import SwiftUI

/// Main view for rendering a settings container.
/// This will eventually support different styles via the environment.
public struct SettingsView<Container: SettingsContainer>: View {
    let container: Container
    @State private var searchText = ""
    @State private var allNodes: [SettingsNode] = []

    public init(_ container: Container) {
        self.container = container
    }

    public var body: some View {
        List {
            if searchText.isEmpty {
                container.settingsBody
            } else {
                ForEach(searchResults) { result in
                    SearchResultSection(result: result)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search settings")
        .onAppear {
            allNodes = container.settingsBody.makeNodes()
        }
    }

    var searchResults: [SearchResult] {
        guard !searchText.isEmpty else { return [] }
        var results: [SearchResult] = []
        searchNodes(allNodes, query: searchText.lowercased(), results: &results)
        return results
    }

    func searchNodes(_ nodes: [SettingsNode], query: String, results: inout [SearchResult]) {
        for node in nodes {
            switch node {
            case .group(let id, let title, let icon, let tags, let children):
                let groupMatches = title.lowercased().contains(query) ||
                                  tags.contains(where: { $0.lowercased().contains(query) })

                let isLeafGroup = children.allSatisfy { !$0.isGroup }

                if isLeafGroup {
                    // Leaf group: check if group or any searchable children match
                    let searchableChildren = children.filter { $0.isSearchable }
                    let childMatches = searchableChildren.contains { child in
                        child.title.lowercased().contains(query) ||
                        child.tags.contains(where: { $0.lowercased().contains(query) })
                    }

                    if groupMatches || childMatches {
                        results.append(SearchResult(group: node, matchedItems: children))
                    }
                } else {
                    // Parent group: recurse into children, don't show the parent itself
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
}

/// Renders a search result section with tappable header
struct SearchResultSection: View {
    let result: SearchResult

    var body: some View {
        if case .group(_, let title, let icon, _, let children) = result.group {
            Section {
                ForEach(result.matchedItems) { item in
                    SearchResultItem(node: item)
                }
            } header: {
                NavigationLink {
                    List {
                        ForEach(children) { child in
                            NodeView(node: child)
                        }
                    }
                    .navigationTitle(title)
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

        case .item(_, _, let icon, _, _, let content):
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundStyle(.secondary)
                }
                content
            }
        }
    }
}

/// Internal view for rendering a single node (group or item)
struct NodeView: View {
    let node: SettingsNode

    var body: some View {
        switch node {
        case .group(_, let title, let icon, _, let children):
            // For groups, create a navigation link to a list of children
            NavigationLink {
                List {
                    ForEach(children) { child in
                        NodeView(node: child)
                    }
                }
                .navigationTitle(title)
            } label: {
                Label(title, systemImage: icon ?? "folder")
            }

        case .item(_, _, let icon, _, _, let content):
            // For items, show the title/icon and render the user's view
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                }
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
