import SwiftUI

/// Opens a uniquely named settings destination and optionally nested pages.
public struct SettingsNavigationRequest: Identifiable, Hashable {
    public let id = UUID()
    public let groupTitles: [String]

    public init(groupTitles: [String]) {
        self.groupTitles = groupTitles
    }

    func resolve(in nodes: [SettingsNode]) -> [SettingsNode]? {
        guard !groupTitles.isEmpty else { return nil }
        var candidates = nodes
        var destinations: [SettingsNode] = []
        for title in groupTitles {
            let matches = navigationGroups(named: title, in: candidates)
            guard matches.count == 1 else { return nil }
            destinations.append(matches[0])
            candidates = matches[0].children ?? []
        }
        return destinations
    }

    private func navigationGroups(named title: String, in nodes: [SettingsNode]) -> [SettingsNode] {
        nodes.flatMap { node -> [SettingsNode] in
            guard case .group(_, let nodeTitle, _, _, let presentation, let children, _) = node else { return [] }
            if presentation == .inline { return navigationGroups(named: title, in: children) }
            return nodeTitle == title ? [node] : []
        }
    }
}

/// The presentation values SettingsKit provides to an app-owned settings shell.
///
/// The context keeps SettingsKit's indexing, search, and route content while the caller decides where navigation containers, toolbars, tabs, and search UI live.
public struct SettingsPresentationContext: @unchecked Sendable {
    /// The title supplied to the host.
    public let title: String

    /// A binding to the active settings search query.
    public let searchText: Binding<String>

    /// A binding to the host's programmatic navigation path.
    public let navigationPath: Binding<NavigationPath>

    /// The selected top-level destination in split navigation.
    public let selectedGroup: Binding<SettingsGroupConfiguration?>

    /// The complete metadata tree built from the settings container.
    public let nodes: [SettingsNode]

    /// The ordered results for the current search query.
    public let searchResults: [SettingsSearchResult]

    /// The unfiltered, live settings hierarchy.
    public let rootContent: AnyView

    /// The built-in interactive rendering of the current search results.
    public let searchContent: AnyView

    /// The content appropriate for the current query.
    ///
    /// This value is ``rootContent`` when the query is empty and ``searchContent`` while searching.
    public let content: AnyView
    private let makeGroupConfiguration: (SettingsNode) -> SettingsGroupConfiguration?
    private let makeIndexedView: (SettingsNode) -> AnyView?

    init(
        title: String,
        searchText: Binding<String>,
        navigationPath: Binding<NavigationPath>,
        selectedGroup: Binding<SettingsGroupConfiguration?>,
        nodes: [SettingsNode],
        searchResults: [SettingsSearchResult],
        rootContent: AnyView,
        searchContent: AnyView,
        content: AnyView,
        makeGroupConfiguration: @escaping (SettingsNode) -> SettingsGroupConfiguration?,
        makeIndexedView: @escaping (SettingsNode) -> AnyView?
    ) {
        self.title = title
        self.searchText = searchText
        self.navigationPath = navigationPath
        self.selectedGroup = selectedGroup
        self.nodes = nodes
        self.searchResults = searchResults
        self.rootContent = rootContent
        self.searchContent = searchContent
        self.content = content
        self.makeGroupConfiguration = makeGroupConfiguration
        self.makeIndexedView = makeIndexedView
    }

    /// Whether the user currently has a non-empty search query.
    public var isSearching: Bool {
        !searchText.wrappedValue.isEmpty
    }

    /// Resolves a metadata group into live destination content for this host.
    public func groupConfiguration(for node: SettingsNode) -> SettingsGroupConfiguration? {
        makeGroupConfiguration(node)
    }

    /// Resolves an indexed node into its live interactive view for this host.
    public func indexedView(for node: SettingsNode) -> AnyView? {
        makeIndexedView(node)
    }

}

/// A presentation-neutral host for a settings container.
///
/// `SettingsHost` owns only settings runtime state: the metadata index, search query, search results, render scope, and navigation path. Its content closure owns all visible presentation.
///
/// ```swift
/// SettingsHost(container: AppSettings()) { context in
///     NavigationStack(path: context.navigationPath) {
///         ScrollView {
///             context.content
///         }
///         .searchable(text: context.searchText)
///         .toolbar { MySettingsToolbar() }
///         .navigationDestination(for: SettingsGroupConfiguration.self) { group in
///             ScrollView { group.content }
///         }
///     }
/// }
/// ```
public struct SettingsHost<Container: SettingsContainer, Body: View>: View {
    private let container: Container
    private let title: String
    private let navigationRequest: SettingsNavigationRequest?
    private let onNavigationResult: (@MainActor (SettingsNavigationRequest, Bool) -> Void)?
    private let makeBody: (SettingsPresentationContext) -> Body

    @State private var searchText: String
    @State private var navigationPath = NavigationPath()
    @State private var selectedGroup: SettingsGroupConfiguration?
    @State private var registry = SettingsNodeViewRegistry()
    @State private var nodes: [SettingsNode] = []
    @State private var indexedRevision: Int?
    @Environment(\.settingsSearch) private var search

    /// Creates a presentation-neutral settings host.
    ///
    /// - Parameters:
    ///   - container: The settings hierarchy to index and render.
    ///   - title: The title exposed through the presentation context.
    ///   - initialSearchText: The initial value of the host's search query.
    ///   - content: A closure that builds the app-owned presentation from the current context.
    public init(
        container: Container,
        title: String = "Settings",
        initialSearchText: String = "",
        navigationRequest: SettingsNavigationRequest? = nil,
        onNavigationResult: (@MainActor (SettingsNavigationRequest, Bool) -> Void)? = nil,
        @ViewBuilder content: @escaping (SettingsPresentationContext) -> Body
    ) {
        self.container = container
        self.title = title
        self.navigationRequest = navigationRequest
        self.onNavigationResult = onNavigationResult
        self.makeBody = content
        _searchText = State(initialValue: initialSearchText)
    }

    /// The app-owned presentation populated with SettingsKit runtime values.
    public var body: some View {
        // Only the revision can invalidate search metadata. Live status reads
        // belong to the rendered child, not this host's observation scope.
        let indexRevision = container.settingsIndexRevision
        let results = searchResults(in: nodes)
        let rootContent = AnyView(
            SettingsLiveRoot(container: container)
                .environment(\.settingsNodeViewRegistry, registry)
        )
        let searchContent = AnyView(
            SettingsSearchResults(
                query: searchText,
                results: results,
                navigationPath: $navigationPath
            )
            .environment(\.settingsNodeViewRegistry, registry)
        )
        let presentedContent = searchText.isEmpty ? rootContent : searchContent

        makeBody(
            SettingsPresentationContext(
                title: title,
                searchText: $searchText,
                navigationPath: $navigationPath,
                selectedGroup: $selectedGroup,
                nodes: nodes,
                searchResults: results,
                rootContent: rootContent,
                searchContent: searchContent,
                content: presentedContent,
                makeGroupConfiguration: { node in
                    guard node.isGroup else { return nil }
                    return node.asGroupConfiguration(registry: registry)
                },
                makeIndexedView: { node in
                    registry.view(for: node.id)
                }
            )
        )
        .environment(\.settingsNodeViewRegistry, registry)
        .onChange(of: navigationRequest?.id) { _, _ in
            openNavigationRequest()
        }
        .task(id: indexRevision) {
            guard indexedRevision != indexRevision else { return }
            let nextRegistry = SettingsNodeViewRegistry()
            let nextNodes = container.settingsBody.makeNodes(
                in: SettingsContentScope(registry: nextRegistry)
            )
            registry = nextRegistry
            nodes = nextNodes
            indexedRevision = indexRevision
            openNavigationRequest()
        }
    }

    private func openNavigationRequest() {
        guard let navigationRequest, !nodes.isEmpty else { return }
        guard let destinations = navigationRequest.resolve(in: nodes) else {
            onNavigationResult?(navigationRequest, false)
            return
        }
        selectedGroup = destinations[0].asGroupConfiguration(registry: registry)
        navigationPath = NavigationPath()
        for destination in destinations.dropFirst() {
            navigationPath.append(destination.asGroupConfiguration(registry: registry))
        }
        onNavigationResult?(navigationRequest, true)
    }

    private func searchResults(in nodes: [SettingsNode]) -> [SettingsSearchResult] {
        guard !searchText.isEmpty else { return [] }
        return search.search(nodes: nodes, query: searchText)
    }
}

/// Keeps live setting observations below the host that owns search metadata.
private struct SettingsLiveRoot<Container: SettingsContainer>: View {
    let container: Container

    var body: some View {
        container.settingsBody
    }
}

/// The main view for SettingsKit's built-in settings presentation.
///
/// ``SettingsContainer`` uses this view as its default body. Use ``SettingsHost`` directly when the app should own navigation and visible layout.
public struct SettingsView<Container: SettingsContainer>: View {
    private let container: Container
    private let navigationRequest: SettingsNavigationRequest?
    private let onNavigationResult: (@MainActor (SettingsNavigationRequest, Bool) -> Void)?
    @Environment(\.settingsStyle) private var style

    /// Creates the built-in presentation for a settings container.
    ///
    /// - Parameter container: The settings hierarchy to render.
    public init(
        container: Container,
        navigationRequest: SettingsNavigationRequest? = nil,
        onNavigationResult: (@MainActor (SettingsNavigationRequest, Bool) -> Void)? = nil
    ) {
        self.container = container
        self.navigationRequest = navigationRequest
        self.onNavigationResult = onNavigationResult
    }

    /// The settings host rendered with the active ``SettingsStyle``.
    public var body: some View {
        SettingsHost(container: container, navigationRequest: navigationRequest, onNavigationResult: onNavigationResult) { context in
            style.makeContainer(
                configuration: SettingsContainerConfiguration(
                    title: context.title,
                    content: context.content,
                    searchText: context.searchText,
                    navigationPath: context.navigationPath,
                    selectedGroup: context.selectedGroup
                )
            )
        }
    }
}

/// The default interactive rendering for settings search results.
///
/// Custom shells may use `SettingsPresentationContext.searchContent` for this renderer or inspect `searchResults` and provide an entirely custom result UI.
public struct SettingsSearchResults: View {
    /// The query represented by the result collection.
    public let query: String

    /// The ordered search results to render.
    public let results: [SettingsSearchResult]

    /// The navigation path updated when a result selects a destination.
    @Binding public var navigationPath: NavigationPath

    /// Creates the built-in search-results renderer.
    ///
    /// - Parameters:
    ///   - query: The query represented by `results`.
    ///   - results: The ordered result collection to display.
    ///   - navigationPath: The path used for destination navigation.
    public init(
        query: String,
        results: [SettingsSearchResult],
        navigationPath: Binding<NavigationPath>
    ) {
        self.query = query
        self.results = results
        _navigationPath = navigationPath
    }

    /// The interactive results, each in its own list section.
    public var body: some View {
        if results.isEmpty {
            ContentUnavailableView(
                "No Results for \"\(query)\"",
                systemImage: "magnifyingglass",
                description: Text("Check the spelling or try a different search")
            )
        } else {
            ForEach(results) { result in
                SearchResultRow(result: result)
            }
        }
    }
}

private struct SearchResultRow: View {
    let result: SettingsSearchResult
    @Environment(\.settingsNodeViewRegistry) private var registry

    var body: some View {
        Section {
            if result.isNavigation {
                navigationResult
            }
            ForEach(result.matchedItems) { item in
                if let view = registry.view(for: item.id) {
                    view
                } else {
                    fallback(for: item)
                }
            }
        } header: {
            if let parentGroup = result.parentGroup {
                navigationHeader(for: parentGroup)
            }
        }
    }

    private func navigationHeader(for parent: SettingsNode) -> some View {
        let configuration = parent.asGroupConfiguration(registry: registry)
        return NavigationLink(value: configuration) {
            HStack {
                if let systemImage = parent.systemImage {
                    Label(parent.title, systemImage: systemImage)
                } else {
                    Text(parent.title)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var navigationResult: some View {
        let configuration = result.group.asGroupConfiguration(registry: registry)
        NavigationLink(value: configuration) {
            resultLabel
        }
    }

    @ViewBuilder
    private var resultLabel: some View {
        if let systemImage = result.group.systemImage {
            Label(result.group.title, systemImage: systemImage)
        } else {
            Text(result.group.title)
        }
    }

    @ViewBuilder
    private func fallback(for node: SettingsNode) -> some View {
        Text(node.title)
    }
}
