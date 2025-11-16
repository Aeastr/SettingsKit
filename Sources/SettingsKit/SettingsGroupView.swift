import SwiftUI

/// Default rendering for a SettingsGroup - shows as a NavigationLink
public struct SettingsGroupView<Content: SettingsContent>: View {
    let title: String
    let icon: String?
    let content: Content
    @State private var searchText = ""
    @State private var allNodes: [SettingsNode] = []

    public init(title: String, icon: String?, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    public var body: some View {
        NavigationLink {
            List {
                if searchText.isEmpty {
                    content
                } else {
                    ForEach(filteredResults) { node in
                        SearchResultView(node: node)
                    }
                }
            }
            .navigationTitle(title)
            .searchable(text: $searchText, prompt: "Search \(title)")
            .onAppear {
                allNodes = content.makeNodes()
            }
        } label: {
            Label(title, systemImage: icon ?? "folder")
        }
    }

    var filteredResults: [SettingsNode] {
        var results: [SettingsNode] = []
        searchNodes(allNodes, query: searchText.lowercased(), results: &results)
        return results
    }

    func searchNodes(_ nodes: [SettingsNode], query: String, results: inout [SettingsNode]) {
        for node in nodes {
            let matches = node.title.lowercased().contains(query) ||
                         node.tags.contains(where: { $0.lowercased().contains(query) })

            if matches {
                results.append(node)
            }

            if let children = node.children {
                searchNodes(children, query: query, results: &results)
            }
        }
    }
}
