import SwiftUI

/// A settings style using a split view with sidebar navigation.
///
/// ## Navigation Architecture
///
/// This style uses different navigation approaches on macOS vs iOS to provide optimal behavior on each platform.
///
/// ### Platform-Specific Navigation
///
/// **macOS:**
/// - Uses **destination-based** `NavigationLink` with nested `NavigationStack` in each destination
/// - Each navigation creates a fresh view hierarchy with proper state observation
/// - Controls update reactively ✅
/// - Nested navigation works (General → AirDrop pushes correctly) ✅
/// - Works because macOS sidebar is always visible, so destination-based links push into detail column
///
/// **iOS/iPadOS:**
/// - Uses **selection-based** `NavigationLink(value:)` with centralized detail view
/// - Selection-based navigation works seamlessly on iOS
/// - Works in both portrait (sidebar collapsed) and landscape (sidebar visible) ✅
/// - Rotation doesn't reset navigation since we always use the same approach ✅
///
/// ### Why Platform-Specific?
///
/// Early versions used the same navigation approach on all platforms, which revealed a critical macOS-only bug:
/// controls in the detail view wouldn't visually update even though state changed correctly. This was caused by
/// **AnyView type erasure combined with macOS NavigationSplitView's aggressive caching**.
///
/// The solution was to:
/// 1. Remove content from nodes entirely (metadata-only nodes)
/// 2. Use direct view hierarchy rendering (no AnyView in normal paths)
/// 3. Create a view registry for search results
/// 4. Use destination-based navigation on macOS (fresh view hierarchies)
///
/// This hybrid architecture solved the problem: normal navigation uses direct view hierarchies preserving
/// SwiftUI's state observation, while search results use the view registry to render actual interactive controls.
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
// - macOS: destination-based (creates fresh view hierarchies)
// - iOS: selection-based (optimal for split view behavior)
private struct SidebarNavigationLink: View {
    let configuration: SettingsGroupConfiguration
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
#if os(macOS)
        // macOS: Use destination-based navigation
        // WHY: Creates fresh view hierarchies with proper state observation
        //      Part of the hybrid architecture solution (see file header)
        destinationBasedLink
#else
        // iOS/iPadOS: Use selection-based navigation
        // WHY: Optimal for NavigationSplitView on iOS (works in all size classes)
        //      Handles portrait/landscape transitions smoothly
        selectionBasedLink
#endif
    }

    // DESTINATION-BASED NAVIGATION (macOS only)
    // Creates a fresh NavigationStack for each destination.
    // Provides proper state observation as part of the hybrid architecture.
    private var destinationBasedLink: some View {
        NavigationLink {
            NavigationStack {
                List {
                    // Render directly from view hierarchy for proper state observation
                    configuration.content
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
                        // Render directly from view hierarchy for proper state observation
                        selectedGroup.content
                    }
                    .navigationTitle(selectedGroup.title)
                    // Handle nested navigation (e.g., General → AirDrop)
                    .navigationDestination(for: SettingsGroupConfiguration.self) { nestedGroupConfig in
                        List {
                            // Render directly from view hierarchy for proper state observation
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
