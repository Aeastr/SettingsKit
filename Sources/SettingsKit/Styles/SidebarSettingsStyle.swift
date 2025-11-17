import SwiftUI

/// A settings style using a split view with sidebar navigation.
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
                .searchable(text: searchText, placement: .sidebar, prompt: "Search settings")
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
