import SwiftUI

/// A settings style using a split view with sidebar navigation.
///
/// ## Navigation Architecture
///
/// Uses **destination-based** `NavigationLink` on all platforms with direct view hierarchy rendering.
///
/// **How it works:**
/// - Each navigation link renders `configuration.content` (the actual view hierarchy)
/// - macOS: Wraps content in `NavigationStack` for nested navigation support
/// - iOS: Lets `NavigationSplitView` handle the navigation naturally
/// - Both: Render directly from view hierarchy (no AnyView, no nodes) for proper state observation
///
/// **Why this approach:**
///
/// The hybrid architecture uses:
/// 1. **Metadata-only nodes** - For search indexing and navigation matching
/// 2. **View registry** - Maps node IDs to view builders for search results
/// 3. **Direct rendering** - Normal navigation renders from actual view hierarchy, not from nodes
///
/// This ensures controls update reactively with proper SwiftUI state observation while still enabling
/// powerful search capabilities that show actual interactive controls in search results.
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
        HStack {
            if let icon = configuration.icon {
                Label(configuration.title, systemImage: icon)
            } else {
                Text(configuration.title)
            }
            Spacer()
            configuration.content
        }
    }
}

// Custom navigation link that renders fresh content directly
private struct SidebarNavigationLink: View {
    let configuration: SettingsGroupConfiguration

    var body: some View {
        // Always use destination-based navigation for fresh rendering!
        NavigationLink {
#if os(macOS)
            // On macOS: wrap in NavigationStack for nested navigation
            NavigationStack {
                List {
                    configuration.content
                }
                .navigationTitle(configuration.title)
            }
#else
            // On iOS: let NavigationSplitView handle navigation
            List {
                configuration.content
            }
            .navigationTitle(configuration.title)
            .navigationBarTitleDisplayMode(.inline)
#endif
        } label: {
            configuration.label
        }
    }
}

private struct SidebarContainer: View {
    let configuration: SettingsContainerConfiguration

    var body: some View {
        NavigationSplitView {
            if let searchText = configuration.searchText {
                List {
                    configuration.content
                }
                .navigationTitle(configuration.title)
#if os(watchOS)
                .searchable(text: searchText, prompt: "Search settings")
#else
                .searchable(text: searchText, placement: .sidebar, prompt: "Search settings")
#endif
            } else {
                List {
                    configuration.content
                }
                .navigationTitle(configuration.title)
            }
        } detail: {
            Text("Select a setting")
                .foregroundStyle(.secondary)
        }
    }
}
