import SwiftUI

/// Main view for rendering a settings container.
public struct SettingsView<Container: SettingsContainer>: View {
    let container: Container
    @State private var searchText = ""
    @State private var navigationPath = NavigationPath()
    @Environment(\.settingsStyle) private var style
    @Environment(\.settingsSearch) private var search

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

    var searchResults: [SettingsSearchResult] {
        guard !searchText.isEmpty else { return [] }

        // Build fresh nodes on every search to get live state
        let allNodes = container.settingsBody.makeNodes()

        // Use the search implementation from environment
        return search.search(nodes: allNodes, query: searchText)
    }
}

/// Renders a search result section with tappable header
struct SearchResultSection: View {
    let result: SettingsSearchResult
    @Binding var navigationPath: NavigationPath

    var body: some View {
        if case .group(_, let title, let icon, _, _, _) = result.group {
            Group {
                if result.isNavigation {
                    // Navigation result: show as a single tappable row
                    NavigationLink(value: result.group.asGroupConfiguration()) {
                        Label(title, systemImage: icon ?? "folder")
                    }
                } else {
                    // Leaf group result: show as section with items
                    Section {
                        ForEach(result.matchedItems) { item in
                            SearchResultItem(node: item)
                        }
                    } header: {
                        NavigationLink(value: result.group.asGroupConfiguration()) {
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
        case .group(_, _, _, _, _, let children):
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
        if case .group(_, let title, _, _, _, let children) = node {
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
    @Environment(\.settingsStyle) private var style

    var body: some View {
        switch node {
        case .group(_, let title, let icon, _, let presentation, let children):
            // Render group using the style system to respect inline/navigation presentation
            style.makeGroup(
                configuration: SettingsGroupConfiguration(
                    title: title,
                    icon: icon,
                    footer: nil,
                    presentation: presentation,
                    content: AnyView(
                        ForEach(children) { child in
                            NodeView(node: child)
                        }
                    ),
                    children: children
                )
            )

        case .item(_, _, _, _, _, let content):
            // For items, render the actual content
            content
        }
    }
}
