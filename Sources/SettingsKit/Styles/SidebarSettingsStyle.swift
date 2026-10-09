import SwiftUI
#if os(macOS)
import AppKit
#endif

/// Root toolbar title choices, independent of nested destination styles.
public enum SettingsRootTitleDisplayMode: Sendable {
    case automatic
    case inline
    case inlineLarge

    var toolbarMode: ToolbarTitleDisplayMode {
        switch self {
        case .automatic: .automatic
        case .inline: .inline
        case .inlineLarge:
            #if os(watchOS) || os(tvOS)
            .inline
            #else
            .inlineLarge
            #endif
        }
    }
}

/// A full settings style that uses a split view with sidebar navigation.
///
/// The style keeps one selected group in the split view and renders that
/// selection in a central detail hierarchy. macOS uses a custom System
/// Settings-inspired detail surface, while iOS and iPadOS use native forms.
///
/// Search uses the same host-scoped metadata and live-view registry as every other presentation. See <doc:SettingsKitArchitecture> for how the rendering paths fit together.
///
public struct SidebarSettingsStyle: SettingsStyle {
    private let searchPlacement: SettingsSearchPlacement
    private let rootTitleDisplayMode: SettingsRootTitleDisplayMode

    /// Creates the built-in sidebar style.
    ///
    /// - Parameters:
    ///   - search: Where the style presents search UI.
    ///   - rootTitleDisplayMode: The title style on the sidebar list itself, without changing destination titles.
    public init(search: SettingsSearchPlacement = .all, rootTitleDisplayMode: SettingsRootTitleDisplayMode = .automatic) {
        self.searchPlacement = search
        self.rootTitleDisplayMode = rootTitleDisplayMode
    }

    /// Creates a split-view settings container.
    public func makeContainer(configuration: ContainerConfiguration) -> some View {
        SidebarContainer(
            configuration: configuration,
            searchPlacement: searchPlacement,
            rootTitleDisplayMode: rootTitleDisplayMode
        )
    }

    /// Creates a destination link or inline section for a group.
    public func makeGroup(configuration: GroupConfiguration) -> some View {
        switch configuration.presentation {
        case .navigation:
            SidebarNavigationLink(configuration: configuration)
        case .inline:
            Section {
                configuration.content
            } footer: {
                if let footer = configuration.footer {
                    Text(footer)
                }
            }
        }
    }

}

// A value-based link lets NavigationSplitView own selection on every platform.
// In particular, macOS must not retain a separate prepared destination inside
// each sidebar row: AppKit can restore that destination's old control state
// when the row is revisited even though the binding's model has changed.
private struct SidebarNavigationLink: View {
    let configuration: SettingsGroupConfiguration

    var body: some View {
        NavigationLink(value: configuration) {
            configuration.label
        }
    }
}

#if os(macOS)
/// The macOS sidebar detail surface uses an app-like scroll layout instead of SwiftUI's platform `Form`, whose default macOS presentation is substantially different from System Settings.
struct MacOSSidebarDetail: View {
    let configuration: SettingsGroupConfiguration

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    if containsGroups {
                        configuration.content
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        VStack(alignment: .leading, spacing: 14) {
                            configuration.content
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .macOSSettingsCard()
                    }
                }
                .settingsGroupStyle(MacOSSidebarDetailGroupStyle())
            }
            .environment(\.settingsContentRowDecoration, true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle(configuration.title)
    }

    private var containsGroups: Bool {
        configuration.children.contains { node in
            if case .group = node {
                return true
            }
            return false
        }
    }
}

/// A detail-only group style that creates the rounded section cards and navigation rows used by macOS System Settings without changing the sidebar hierarchy.
private struct MacOSSidebarDetailGroupStyle: @preconcurrency SettingsGroupStyle {
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        switch configuration.presentation {
        case .navigation:
            MacOSSidebarNavigationRow(configuration: configuration)

        case .inline:
            VStack(alignment: .leading, spacing: 8) {
                configuration.label
                    .font(.headline)
                    .padding(.horizontal, 4)

                VStack(alignment: .leading, spacing: 0) {
                    configuration.content
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .environment(\.isInsideMacOSSettingsCard, true)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .macOSSettingsCard()

                if let footer = configuration.footer {
                    Text(footer)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                }
            }
        }
    }
}

/// A navigation group can appear either inside an inline section's card or as
/// a direct child of the current destination. Direct children need their own
/// card; nested rows reuse the card supplied by the inline section.
private struct MacOSSidebarNavigationRow: View {
    let configuration: SettingsGroupConfiguration
    @Environment(\.isInsideMacOSSettingsCard) private var isInsideCard

    var body: some View {
        if isInsideCard {
            link
        } else {
            link
                .padding(.horizontal, 20)
                .macOSSettingsCard()
        }
    }

    private var link: some View {
        NavigationLink(value: configuration) {
            HStack(spacing: 12) {
                configuration.label
                Spacer(minLength: 16)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct MacOSSettingsCardContextKey: EnvironmentKey {
    static let defaultValue = false
}

private extension EnvironmentValues {
    var isInsideMacOSSettingsCard: Bool {
        get { self[MacOSSettingsCardContextKey.self] }
        set { self[MacOSSettingsCardContextKey.self] = newValue }
    }
}

private extension View {
    func macOSSettingsCard() -> some View {
        background(Color.primary.opacity(0.075), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
#endif

private struct SidebarContainer: View {
    let configuration: SettingsContainerConfiguration
    let searchPlacement: SettingsSearchPlacement
    let rootTitleDisplayMode: SettingsRootTitleDisplayMode
    @State private var detailGeneration = 0

    private var selectedGroup: SettingsGroupConfiguration? {
        configuration.selectedGroup.wrappedValue
    }

    nonisolated init(configuration: SettingsContainerConfiguration,
                     searchPlacement: SettingsSearchPlacement,
                     rootTitleDisplayMode: SettingsRootTitleDisplayMode) {
        self.configuration = configuration
        self.searchPlacement = searchPlacement
        self.rootTitleDisplayMode = rootTitleDisplayMode
    }

    var body: some View {
        NavigationSplitView {
            if searchPlacement.includesRoot, let searchText = configuration.searchText {
                List(selection: selectionBinding) {
                    configuration.content
                }
                .navigationTitle(configuration.title)
                .toolbarTitleDisplayMode(rootTitleDisplayMode.toolbarMode)
#if os(watchOS)
                .searchable(text: searchText, prompt: "Search settings")
#else
                .searchable(text: searchText, placement: .sidebar, prompt: "Search settings")
#endif
            } else {
                List(selection: selectionBinding) {
                    configuration.content
                }
                .navigationTitle(configuration.title)
                .toolbarTitleDisplayMode(rootTitleDisplayMode.toolbarMode)
            }
        } detail: {
#if os(macOS)
            NavigationStack(path: configuration.navigationPath) {
                if let selectedGroup {
                    MacOSSidebarDetail(configuration: selectedGroup)
                        .id(detailGeneration)
                        .navigationDestination(for: SettingsGroupConfiguration.self) { nestedGroup in
                            MacOSSidebarDetail(configuration: nestedGroup)
                        }
                } else {
                    Text("Select a setting")
                        .foregroundStyle(.secondary)
                }
            }
#elseif os(iOS)
            // iOS/iPadOS: Dynamic detail based on selection
            // REASON: Selection-based navigation requires the detail view to respond to selection changes
            //         Works in both compact (sidebar collapsed) and regular (sidebar visible) size classes
            NavigationStack(path: configuration.navigationPath) {
                if let selectedGroup {
                    IOSSearchableSettingsDetail(
                        configuration: selectedGroup,
                        navigationPath: configuration.navigationPath,
                        searchEnabled: searchPlacement.includesDestinations
                    )
                    .id(selectedGroup.id)
                    .navigationDestination(for: SettingsGroupConfiguration.self) { nestedGroupConfig in
                        IOSSearchableSettingsDetail(
                            configuration: nestedGroupConfig,
                            navigationPath: configuration.navigationPath,
                            searchEnabled: searchPlacement.includesDestinations
                        )
                    }
                } else {
                    Text("Select a setting")
                        .foregroundStyle(.secondary)
                }
            }
#else
            NavigationStack(path: configuration.navigationPath) {
                if let selectedGroup {
                    Form {
                        selectedGroup.content
                    }
                    .navigationTitle(selectedGroup.title)
                    .navigationDestination(for: SettingsGroupConfiguration.self) { nestedGroupConfig in
                        Form {
                            nestedGroupConfig.content
                        }
                        .navigationTitle(nestedGroupConfig.title)
                    }
                } else {
                    Text("Select a setting")
                        .foregroundStyle(.secondary)
                }
            }
#endif
        }
    }

    // The selected value is also the sole source of detail content. Keeping the
    // binding enabled on macOS prevents sidebar rows from owning cached detail
    // controls independently of the split view.
    private var selectionBinding: Binding<SettingsGroupConfiguration?>? {
        Binding(
            get: { selectedGroup },
            set: { newSelection in
                guard selectedGroup?.id != newSelection?.id else {
                    configuration.selectedGroup.wrappedValue = newSelection
                    return
                }

                configuration.selectedGroup.wrappedValue = newSelection

                // A new sidebar selection must install a new detail hierarchy.
                // Without a generation identity, macOS can reuse the AppKit
                // controls from the destination's first presentation. Those
                // controls then display their original values even though their
                // bindings have already written newer values to the model.
                detailGeneration &+= 1
                configuration.navigationPath.wrappedValue = NavigationPath()
            }
        )
    }
}

#if os(iOS)
/// A searchable iOS detail destination. Search begins at the current group's
/// children, which keeps matches scoped to the hierarchy the user is viewing.
/// Search occupies the top toolbar rather than the system’s automatic placement.
struct IOSSearchableSettingsDetail: View {
    let configuration: SettingsGroupConfiguration
    let navigationPath: Binding<NavigationPath>
    let searchEnabled: Bool

    @State private var searchText = ""
    @State private var introductionVisibility: [UUID: Bool] = [:]
    @Environment(\.settingsNodeViewRegistry) private var registry
    @Environment(\.settingsSearch) private var search

    @ViewBuilder
    var body: some View {
        if searchEnabled {
            if #available(iOS 26.0, *) {
                detailForm
                    // Let DefaultToolbarItem own placement. The older .toolbar
                    // search placement can request a drawer below the iPhone bar.
                    .searchable(text: $searchText, prompt: "Search \(configuration.title)")
                    .searchToolbarBehavior(.minimize)
                    .toolbar {
                        DefaultToolbarItem(kind: .search, placement: .topBarTrailing)
                    }
            } else {
                detailForm
                    .searchable(text: $searchText, placement: .toolbar, prompt: "Search \(configuration.title)")
            }
        } else {
            detailForm
        }
    }

    private var hasIntroduction: Bool {
        guard #available(iOS 18.0, *) else { return false }
        // Registration hides the title on the first frame. Runtime reports also
        // support intro rows inside opaque/custom Views that produce no metadata.
        return registry.hasIntroduction(in: configuration.id)
            || introductionVisibility[configuration.id] != nil
    }

    private var detailForm: some View {
        pageForm
            .environment(\.settingsIntroductionVisibility, introductionBinding)
            .modifier(SettingsIntroductionTitle(
                title: configuration.title,
                isVisible: !hasIntroduction || !searchText.isEmpty
                    || !(introductionVisibility[configuration.id] ?? true)
            ))
            // Explicitly override a parent sidebar's inlineLarge toolbar mode.
            // The legacy navigationBarTitleDisplayMode modifier alone is not
            // the toolbar display-mode contract used by the settings root.
            .toolbarTitleDisplayMode(.inline)
    }

    private var introductionBinding: Binding<Bool> {
        // Capture the page ID so a late callback cannot change another page.
        let pageID = configuration.id
        return Binding(
            get: { introductionVisibility[pageID] ?? true },
            set: { introductionVisibility[pageID] = $0 }
        )
    }

    private var pageForm: some View {
        Form {
            if searchText.isEmpty {
                configuration.content
            } else {
                SettingsSearchResults(
                    query: searchText,
                    results: search.search(nodes: configuration.children, query: searchText),
                    navigationPath: navigationPath
                )
            }
        }
        .navigationTitle(configuration.title)
    }
}
#endif
