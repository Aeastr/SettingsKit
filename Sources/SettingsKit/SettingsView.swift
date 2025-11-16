import SwiftUI

/// Main view for rendering a settings container.
/// This will eventually support different styles via the environment.
public struct SettingsView<Container: SettingsContainer>: View {
    let container: Container
    @State private var searchText = ""
    @State private var allNodes: [SettingsNode] = []
    @State private var navigationPath: [String] = []
    @Binding private var deepLinkPath: SettingsPath?

    public init(_ container: Container, path: Binding<SettingsPath?> = .constant(nil)) {
        self.container = container
        self._deepLinkPath = path
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            SettingsRenderView(content: container.body, searchText: $searchText, allNodes: $allNodes)
                .searchable(text: $searchText, prompt: "Search settings")
                .onAppear {
                    // Build the searchable index
                    allNodes = container.body.makeNodes()
                }
                .navigationDestination(for: String.self) { groupTitle in
                    // Find the group node and render its content
                    if let groupNode = findNode(withTitle: groupTitle, in: allNodes) {
                        GroupDetailView(node: groupNode, allNodes: allNodes)
                    }
                }
                .onChange(of: deepLinkPath) { _, newPath in
                    if let path = newPath {
                        navigationPath = path.components
                        deepLinkPath = nil // Clear after navigating
                    }
                }
        }
    }

    private func findNode(withTitle title: String, in nodes: [SettingsNode]) -> SettingsNode? {
        for node in nodes {
            if node.title == title {
                return node
            }
            if let children = node.children,
               let found = findNode(withTitle: title, in: children) {
                return found
            }
        }
        return nil
    }
}

/// Internal view that knows how to render SettingsContent with proper navigation
struct SettingsRenderView<Content: SettingsContent>: View {
    let content: Content
    @Binding var searchText: String
    @Binding var allNodes: [SettingsNode]

    var body: some View {
        List {
            if searchText.isEmpty {
                content
            } else {
                ForEach(groupedResults.keys.sorted(), id: \.self) { groupTitle in
                    Section(groupTitle) {
                        ForEach(groupedResults[groupTitle] ?? []) { node in
                            SearchResultView(node: node)
                        }
                    }
                }
            }
        }
    }

    var groupedResults: [String: [SettingsNode]] {
        var grouped: [String: [SettingsNode]] = [:]
        searchNodes(allNodes, query: searchText.lowercased(), parentTitle: nil, results: &grouped)
        return grouped
    }

    func searchNodes(_ nodes: [SettingsNode], query: String, parentTitle: String?, results: inout [String: [SettingsNode]]) {
        for node in nodes {
            let matches = node.title.lowercased().contains(query) ||
                         node.tags.contains(where: { $0.lowercased().contains(query) })

            if matches {
                let sectionTitle = parentTitle ?? "Settings"
                if results[sectionTitle] == nil {
                    results[sectionTitle] = []
                }
                results[sectionTitle]?.append(node)
            }

            // Recursively search children
            if let children = node.children {
                searchNodes(children, query: query, parentTitle: node.title, results: &results)
            }
        }
    }
}

/// View for rendering a search result
struct SearchResultView: View {
    let node: SettingsNode

    var body: some View {
        switch node {
        case .group(_, let title, let icon, _, let isInline, let children):
            if isInline {
                // Inline groups show their children directly
                ForEach(children) { child in
                    SearchResultView(node: child)
                }
            } else {
                // Navigation groups show as links
                NavigationLink {
                    List {
                        ForEach(children) { child in
                            SearchResultView(node: child)
                        }
                    }
                    .navigationTitle(title)
                } label: {
                    Label(title, systemImage: icon ?? "folder")
                }
            }

        case .item(_, _, let icon, _, let content):
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

        case .item(_, let title, let icon, _, let content):
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
