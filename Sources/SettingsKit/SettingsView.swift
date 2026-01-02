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
            // Group results by parent
            let grouped = groupResultsByParent(searchResults)
            ForEach(grouped, id: \.parent?.id) { group in
                SearchResultGroup(container: container, parentGroup: group.parent, results: group.results, navigationPath: $navigationPath)
            }
        }
    }

    /// Groups search results by their parent navigation group
    private func groupResultsByParent(_ results: [SettingsSearchResult]) -> [(parent: SettingsNode?, results: [SettingsSearchResult])] {
        // Group by parent ID using dictionary
        var groupedByParent: [UUID?: [SettingsSearchResult]] = [:]
        var parentNodes: [UUID?: SettingsNode?] = [:]
        var firstSeenOrder: [UUID?: Int] = [:]

        for (index, result) in results.enumerated() {
            let parentID = result.parentGroup?.id
            if groupedByParent[parentID] == nil {
                groupedByParent[parentID] = []
                parentNodes[parentID] = result.parentGroup
                firstSeenOrder[parentID] = index
            }
            groupedByParent[parentID]?.append(result)
        }

        // Sort groups by first appearance order to maintain relevance
        let sortedKeys = groupedByParent.keys.sorted { lhs, rhs in
            (firstSeenOrder[lhs] ?? 0) < (firstSeenOrder[rhs] ?? 0)
        }

        return sortedKeys.map { key in
            (parent: parentNodes[key] ?? nil, results: groupedByParent[key] ?? [])
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
        // Render the full container body with search filtering applied via environment
        container.settingsBody
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

/// Renders a group of search results under a common parent
struct SearchResultGroup<Container: SettingsContainer>: View {
    let container: Container
    let parentGroup: SettingsNode?
    let results: [SettingsSearchResult]
    @Binding var navigationPath: NavigationPath

    var body: some View {
        if let parent = parentGroup {
            // Results under a parent group - show as section with parent header
            Section {
                ForEach(results) { result in
                    SearchResultRow(container: container, result: result, navigationPath: $navigationPath)
                }
            } header: {
                parentHeader(for: parent)
            }
        } else {
            // Top-level results (no parent) - show without section wrapper
            ForEach(results) { result in
                SearchResultRow(container: container, result: result, navigationPath: $navigationPath)
            }
        }
    }

    @ViewBuilder
    private func parentHeader(for parent: SettingsNode) -> some View {
        let config = parent.asGroupConfiguration()
#if os(macOS)
        NavigationLink {
            NavigationStack {
                List {
                    config.content
                }
                .navigationTitle(config.title)
            }
        } label: {
            HStack {
                if let iconView = SettingsNodeViewRegistry.shared.iconView(for: parent.id) {
                    iconView
                } else if let iconName = parent.icon {
                    Image(systemName: iconName)
                }
                Text(parent.title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
#else
        NavigationLink(value: config) {
            HStack {
                if let iconView = SettingsNodeViewRegistry.shared.iconView(for: parent.id) {
                    iconView
                } else if let iconName = parent.icon {
                    Image(systemName: iconName)
                }
                Text(parent.title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
#endif
    }
}

/// Renders a single search result row (either navigation link or inline items)
struct SearchResultRow<Container: SettingsContainer>: View {
    let container: Container
    let result: SettingsSearchResult
    @Binding var navigationPath: NavigationPath

    var body: some View {
        if case .group(let id, let title, let icon, _, _, _) = result.group {
            if result.isNavigation {
                // Navigation result: show as a single tappable row
                let config = result.group.asGroupConfiguration()
#if os(macOS)
                NavigationLink {
                    NavigationStack {
                        List {
                            config.content
                        }
                        .navigationTitle(config.title)
                    }
                } label: {
                    searchResultLabel(id: id, title: title, iconName: icon)
                }
#else
                NavigationLink(value: config) {
                    searchResultLabel(id: id, title: title, iconName: icon)
                }
#endif
            } else {
                // Leaf group result: show items inline
                ForEach(result.matchedItems) { item in
                    if let view = SettingsNodeViewRegistry.shared.view(for: item.id) {
                        view
                    } else {
                        if let icon = item.icon {
                            Label(item.title, systemImage: icon)
                        } else {
                            Text(item.title)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func searchResultLabel(id: UUID, title: String, iconName: String?) -> some View {
        Label {
            Text(title)
        } icon: {
            if let iconView = SettingsNodeViewRegistry.shared.iconView(for: id) {
                iconView
            } else if let iconName = iconName {
                Image(systemName: iconName)
            }
        }
    }
}

/// Renders a search result section with actual content from the view hierarchy
struct SearchResultSection<Container: SettingsContainer>: View {
    let container: Container
    let result: SettingsSearchResult
    @Binding var navigationPath: NavigationPath

    var body: some View {
        if case .group(let id, let title, let icon, _, _, _) = result.group {
            if result.isNavigation {
                // Navigation result: show as a single tappable row
                let config = result.group.asGroupConfiguration()
#if os(macOS)
                // macOS: Use destination-based navigation (matches SidebarNavigationLink)
                NavigationLink {
                    NavigationStack {
                        List {
                            config.content
                        }
                        .navigationTitle(config.title)
                    }
                } label: {
                    searchResultLabel(id: id, title: title, iconName: icon)
                }
#else
                // iOS: Use selection-based navigation (matches SidebarNavigationLink)
                NavigationLink(value: config) {
                    searchResultLabel(id: id, title: title, iconName: icon)
                }
#endif
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
                    let config = result.group.asGroupConfiguration()
#if os(macOS)
                    // macOS: Use destination-based navigation (matches SidebarNavigationLink)
                    NavigationLink {
                        NavigationStack {
                            List {
                                config.content
                            }
                            .navigationTitle(config.title)
                        }
                    } label: {
                        HStack {
                            searchResultIcon(id: id, iconName: icon)
                            Text(title)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
#else
                    // iOS: Use selection-based navigation (matches SidebarNavigationLink)
                    NavigationLink(value: config) {
                        HStack {
                            searchResultIcon(id: id, iconName: icon)
                            Text(title)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
#endif
                }
            }
        }
    }

    /// Creates a label for search results using the registered icon view if available
    @ViewBuilder
    private func searchResultLabel(id: UUID, title: String, iconName: String?) -> some View {
        Label {
            Text(title)
        } icon: {
            searchResultIcon(id: id, iconName: iconName)
        }
    }

    /// Gets the icon view from registry or falls back to system image
    @ViewBuilder
    private func searchResultIcon(id: UUID, iconName: String?) -> some View {
        if let iconView = SettingsNodeViewRegistry.shared.iconView(for: id) {
            iconView
        } else if let iconName = iconName {
            Image(systemName: iconName)
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

        // Add all matched items
        for item in result.matchedItems {
            ids.insert(item.id)
        }

        // Add all parents of the result group up to root
        addAllParents(of: result.group.id, parentMap: parentMap, to: &ids)

        // Add all children of the result group (to show its content)
        addAllChildren(of: result.group, to: &ids)

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

