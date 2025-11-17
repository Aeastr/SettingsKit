import SwiftUI

/// A single-column settings style with standard navigation and list appearance.
public struct SingleColumnSettingsStyle: SettingsStyle {
    public init() {}

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
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .navigationDestination(for: SettingsGroupConfiguration.self) { groupConfig in
                List {
                    groupConfig.content
                }
                .navigationTitle(groupConfig.title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

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

    public func makeItem(configuration: ItemConfiguration) -> some View {
        configuration.content
    }
}
