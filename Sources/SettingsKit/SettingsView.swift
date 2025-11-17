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
            // Show search results as a flat list with actual content
            ForEach(searchResults) { result in
                SearchResultSection(container: container, result: result, navigationPath: $navigationPath)
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

/// Renders search results by filtering the actual view hierarchy
struct SearchResultsView<Container: SettingsContainer>: View {
    let container: Container
    let results: [SettingsSearchResult]
    @Binding var navigationPath: NavigationPath
    @Environment(\.settingsStyle) private var style

    var body: some View {
        let _ = print("🔍 SearchResultsView: rendering with \(matchedIDs.count) matched IDs: \(matchedIDs)")
        // Render the full container body with search filtering applied via environment
        return container.settingsBody
            .environment(\.searchResultIDs, matchedIDs)
    }

    private var matchedIDs: Set<UUID> {
        // Build parent map from all nodes
        let allNodes = container.settingsBody.makeNodes()
        var parentMap: [UUID: UUID] = [:]
        buildParentMap(nodes: allNodes, parentMap: &parentMap)

        var ids = Set<UUID>()
        for result in results {
            // Add the matched group
            ids.insert(result.group.id)
            // Add all matched items
            for item in result.matchedItems {
                ids.insert(item.id)
            }
            // Add all children of the group
            addAllChildren(of: result.group, to: &ids)
            // Add all parents up to root
            addAllParents(of: result.group.id, parentMap: parentMap, to: &ids)
        }
        return ids
    }

    private func buildParentMap(nodes: [SettingsNode], parentMap: inout [UUID: UUID], parent: UUID? = nil) {
        for node in nodes {
            if let parent = parent {
                parentMap[node.id] = parent
            }
            if let children = node.children {
                buildParentMap(nodes: children, parentMap: &parentMap, parent: node.id)
            }
        }
    }

    private func addAllChildren(of node: SettingsNode, to ids: inout Set<UUID>) {
        if let children = node.children {
            for child in children {
                ids.insert(child.id)
                addAllChildren(of: child, to: &ids)
            }
        }
    }

    private func addAllParents(of id: UUID, parentMap: [UUID: UUID], to ids: inout Set<UUID>) {
        var currentID = id
        while let parentID = parentMap[currentID] {
            ids.insert(parentID)
            currentID = parentID
        }
    }
}

// Environment key for filtering content based on search results
private struct SearchResultIDsKey: EnvironmentKey {
    static let defaultValue: Set<UUID>? = nil
}

extension EnvironmentValues {
    var searchResultIDs: Set<UUID>? {
        get { self[SearchResultIDsKey.self] }
        set { self[SearchResultIDsKey.self] = newValue }
    }
}

/// Renders a search result section with actual content from the view hierarchy
struct SearchResultSection<Container: SettingsContainer>: View {
    let container: Container
    let result: SettingsSearchResult
    @Binding var navigationPath: NavigationPath

    var body: some View {
        if case .group(_, let title, let icon, _, _, _) = result.group {
            if result.isNavigation {
                // Navigation result: show as a single tappable row
                NavigationLink(value: result.group.asGroupConfiguration()) {
                    Label(title, systemImage: icon ?? "folder")
                }
            } else {
                // Leaf group result: show as section with actual item content from registry
                Section {
                    ForEach(result.matchedItems) { item in
                        if let view = SettingsNodeViewRegistry.shared.view(for: item.id) {
                            // Render the actual content from the registry
                            view
                        } else {
                            // Fallback to title if no view registered
                            if let icon = item.icon {
                                Label(item.title, systemImage: icon)
                            } else {
                                Text(item.title)
                            }
                        }
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
    }

    private var matchedIDs: Set<UUID> {
        // Build parent map to find all ancestors
        let allNodes = container.settingsBody.makeNodes()
        var parentMap: [UUID: UUID] = [:]
        buildParentMap(nodes: allNodes, parentMap: &parentMap)

        var ids = Set<UUID>()

        // Add the result group itself
        ids.insert(result.group.id)
        print("🔍 SearchResultSection: Added result group '\(result.group.title)' with ID: \(result.group.id)")

        // Add all matched items
        for item in result.matchedItems {
            ids.insert(item.id)
            print("🔍 SearchResultSection: Added matched item '\(item.title)' with ID: \(item.id)")
        }

        // Add all parents of the result group up to root
        addAllParents(of: result.group.id, parentMap: parentMap, to: &ids)

        // Add all children of the result group (to show its content)
        addAllChildren(of: result.group, to: &ids)

        print("🔍 SearchResultSection: Total matched IDs: \(ids.count) - \(ids)")
        return ids
    }

    private func addAllChildren(of node: SettingsNode, to ids: inout Set<UUID>) {
        if let children = node.children {
            for child in children {
                ids.insert(child.id)
                addAllChildren(of: child, to: &ids)
            }
        }
    }

    private func buildParentMap(nodes: [SettingsNode], parentMap: inout [UUID: UUID], parent: UUID? = nil) {
        for node in nodes {
            if let parent = parent {
                parentMap[node.id] = parent
            }
            if let children = node.children {
                buildParentMap(nodes: children, parentMap: &parentMap, parent: node.id)
            }
        }
    }

    private func addAllParents(of id: UUID, parentMap: [UUID: UUID], to ids: inout Set<UUID>) {
        var currentID = id
        while let parentID = parentMap[currentID] {
            ids.insert(parentID)
            currentID = parentID
        }
    }
}

/// Renders an individual item in search results
struct SearchResultItem: View {
    let node: SettingsNode

    var body: some View {
        switch node {
        case .group(_, let title, let icon, _, let presentation, let children):
            // For inline groups in search, show them as sections
            if presentation == .inline {
                Section {
                    ForEach(children) { child in
                        SearchResultItem(node: child)
                    }
                } header: {
                    if let icon = icon {
                        Label(title, systemImage: icon)
                    } else {
                        Text(title)
                    }
                }
            } else {
                // Navigation groups: render children recursively
                ForEach(children) { child in
                    SearchResultItem(node: child)
                }
            }

        case .item(_, let title, let icon, _, _):
            // Items: just show title/icon (can't render actual content from node on this branch)
            if let icon = icon {
                Label(title, systemImage: icon)
            } else {
                Text(title)
            }
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

        case .item(_, let title, let icon, _, _):
            // TODO: Should not render from nodes at all!
            // This is a temporary placeholder
            style.makeItem(
                configuration: SettingsItemConfiguration(
                    title: title,
                    icon: icon,
                    content: AnyView(
                        Text("Item: \(title)")
                            .foregroundStyle(.secondary)
                    )
                )
            )
        }
    }
}
