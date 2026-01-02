import SwiftUI

/// A single-column settings style with standard navigation and list appearance.
public struct SingleColumnSettingsStyle: @preconcurrency SettingsStyle {
    public init() {}

    @MainActor
    public func makeContainer(configuration: ContainerConfiguration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            Group {
                if let searchText = configuration.searchText {
                    List {
                        configuration.content
                    }
                    .navigationTitle(configuration.title)
                    .searchable(text: searchText, prompt: "Search settings")
                } else {
                    List {
                        configuration.content
                    }
                    .navigationTitle(configuration.title)
#if !os(tvOS) && !os(macOS)
                    .navigationBarTitleDisplayMode(.inline)
#endif
                }
            }
            .navigationDestination(for: SettingsGroupConfiguration.self) { groupConfig in
                if groupConfig.isCustomContent {
                    // Custom content renders directly without List wrapper
                    groupConfig.content
                        .navigationTitle(groupConfig.title)
#if !os(tvOS) && !os(macOS)
                        .navigationBarTitleDisplayMode(.inline)
#endif
                } else {
                    List {
                        groupConfig.content
                    }
                    .navigationTitle(groupConfig.title)
#if !os(tvOS) && !os(macOS)
                    .navigationBarTitleDisplayMode(.inline)
#endif
                }
            }
        }
    }

    @MainActor
    public func makeGroup(configuration: GroupConfiguration) -> some View {
        switch configuration.presentation {
        case .navigation:
            NavigationLink(value: configuration) {
                configuration.label
            }
        case .inline:
            Section {
                configuration.content
            } header: {
                configuration.label
            } footer: {
                if let footer = configuration.footer {
                    Text(footer)
                }
            }
        }
    }

    @MainActor
    public func makeItem(configuration: ItemConfiguration) -> some View {
        configuration.content
    }
}
