import SwiftUI

/// A settings style using a split view with sidebar navigation.
///
/// ## Navigation Architecture & Known Issues
///
/// This style uses different navigation approaches on macOS vs iOS due to a platform-specific SwiftUI issue.
///
/// ### The Observed Problem
/// On **macOS only**, when using selection-based navigation with `NavigationSplitView`:
/// - Controls (Toggle, Slider, TextField, etc.) in the detail view don't visually update when interacted with
/// - The underlying state **does** change correctly (verified by watching state values in the sidebar)
/// - The sidebar renders updates properly, proving state propagation works
/// - The detail view simply fails to re-render when state changes
///
/// ### Suspected Root Causes (Unconfirmed)
/// The issue appears related to how content is stored and rendered:
/// 1. **AnyView type erasure**: Content is wrapped in `AnyView` for type erasure in the node/configuration system
/// 2. **Node-based rendering**: We render from cached node content rather than directly from the view hierarchy
/// 3. **macOS NavigationSplitView caching**: macOS may aggressively cache detail column content in ways iOS doesn't
///
/// **Note**: The `refactor/nodes-metadata-only` branch explores removing `AnyView` content from nodes entirely,
/// making them metadata-only for indexing/search and rendering directly from the view hierarchy instead.
/// This architectural change may resolve the root cause but requires significant refactoring.
///
/// ### The Current Solution (Platform-Specific Workaround)
///
/// **macOS:**
/// - Uses **destination-based** `NavigationLink` with nested `NavigationStack` in each destination
/// - Each navigation creates a fresh view hierarchy, bypassing the caching issue
/// - Controls update properly ✅
/// - Nested navigation works (General → AirDrop pushes correctly) ✅
/// - Works because macOS sidebar is always visible, so destination-based links push into detail column
///
/// **iOS/iPadOS:**
/// - Uses **selection-based** `NavigationLink(value:)` with centralized detail view
/// - No control update issues on iOS (SwiftUI handles this better on mobile platforms)
/// - Works in both portrait (sidebar collapsed) and landscape (sidebar visible) ✅
/// - Rotation doesn't reset navigation since we always use the same approach ✅
///
/// ### Tradeoffs & Future Work
/// - This is a **workaround** that treats symptoms rather than addressing the root cause
/// - Maintaining two different navigation paradigms adds complexity and platform-specific code
/// - A proper fix likely requires architectural changes (see `refactor/nodes-metadata-only` branch)
///   to eliminate `AnyView` wrappers and render directly from the view hierarchy
///
public struct SidebarSettingsStyle: SettingsStyle {
    public init() {}
    
    public func makeContainer(configuration: ContainerConfiguration) -> some View {
        SidebarContainer(configuration: configuration)
    }
    
    public func makeGroup(configuration: GroupConfiguration) -> some View {
        switch configuration.presentation {
        case .navigation:
            // For sidebar, we'll use a custom approach to ensure fresh rendering
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
    
    public func makeItem(configuration: ItemConfiguration) -> some View {
        configuration.content
    }
}

// Custom navigation link that adapts based on platform
//
// NAVIGATION APPROACH:
// - macOS: destination-based (fixes control update bug)
// - iOS: selection-based (works properly, no bugs)
private struct SidebarNavigationLink: View {
    let configuration: SettingsGroupConfiguration
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
#if os(macOS)
        // macOS: Use destination-based navigation
        // WHY: Works around the control update bug where selection-based navigation causes
        //      controls in the detail view to not visually update (though state changes correctly)
        // SUSPECTED CAUSE: Combination of AnyView type erasure + macOS NavigationSplitView caching
        destinationBasedLink
#else
        // iOS/iPadOS: Use selection-based navigation
        // WHY: Destination-based doesn't work with NavigationSplitView on iOS
        //      (attempts to push to a non-existent third column)
        // NOTE: iOS doesn't exhibit the control update issue that macOS has
        selectionBasedLink
#endif
    }

    // DESTINATION-BASED NAVIGATION (macOS only)
    // Creates a fresh NavigationStack for each destination.
    // This works around the control update bug by creating fresh view instances rather than
    // rendering from cached node content in a selection-based detail view.
    private var destinationBasedLink: some View {
        NavigationLink {
            NavigationStack {
                List {
                    // Render from children nodes to get fresh views
                    ForEach(configuration.children) { child in
                        NodeView(node: child)
                    }
                }
                .navigationTitle(configuration.title)
            }
        } label: {
            configuration.label
        }
    }

    // SELECTION-BASED NAVIGATION (iOS only)
    // Uses NavigationLink(value:) which updates the selectedGroup binding
    // The detail view then renders based on that selection
    private var selectionBasedLink: some View {
        NavigationLink(value: configuration) {
            configuration.label
        }
    }
}

private struct SidebarContainer: View {
    let configuration: SettingsContainerConfiguration
    @State private var selectedGroup: SettingsGroupConfiguration?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        NavigationSplitView {
            if let searchText = configuration.searchText {
                List(selection: selectionBinding) {
                    configuration.content
                }
                .navigationTitle(configuration.title)
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
            }
        } detail: {
#if os(macOS)
            // macOS: Static detail placeholder
            // REASON: Navigation happens via destination-based links that create their own NavigationStack
            //         The detail column just shows placeholder text until a link is tapped
            Text("Select a setting")
                .foregroundStyle(.secondary)
#else
            // iOS/iPadOS: Dynamic detail based on selection
            // REASON: Selection-based navigation requires the detail view to respond to selection changes
            //         Works in both compact (sidebar collapsed) and regular (sidebar visible) size classes
            NavigationStack(path: configuration.navigationPath) {
                if let selectedGroup {
                    List {
                        // Render from children nodes for proper state observation
                        ForEach(selectedGroup.children) { child in
                            NodeView(node: child)
                        }
                    }
                    .navigationTitle(selectedGroup.title)
                    // Handle nested navigation (e.g., General → AirDrop)
                    .navigationDestination(for: SettingsGroupConfiguration.self) { nestedGroupConfig in
                        List {
                            ForEach(nestedGroupConfig.children) { child in
                                NodeView(node: child)
                            }
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

    // Selection binding controls whether the List uses selection-based navigation
    private var selectionBinding: Binding<SettingsGroupConfiguration?>? {
#if os(macOS)
        // macOS: No selection binding (uses destination-based navigation instead)
        return nil
#else
        // iOS: Always use selection binding
        // This enables the detail view to show content based on what's tapped in the sidebar
        // Works across all size classes and rotations without resetting navigation state
        return $selectedGroup
#endif
    }
}
