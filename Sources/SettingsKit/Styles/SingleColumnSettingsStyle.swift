import SwiftUI

/// A single-column settings style with standard navigation and form appearance.
public struct SingleColumnSettingsStyle: @preconcurrency SettingsStyle {
    private let searchPlacement: SettingsSearchPlacement

    /// Creates the built-in single-column style.
    ///
    /// - Parameter search: Where the style presents search UI.
    public init(search: SettingsSearchPlacement = .all) {
        self.searchPlacement = search
    }

    /// Creates a navigation-stack settings container.
    @MainActor
    public func makeContainer(configuration: ContainerConfiguration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            Group {
                if searchPlacement.includesRoot, let searchText = configuration.searchText {
                    Form {
                        configuration.content
                    }
                    .navigationTitle(configuration.title)
                    .searchable(text: searchText, prompt: "Search settings")
                } else {
                    Form {
                        configuration.content
                    }
                    .navigationTitle(configuration.title)
#if !os(tvOS) && !os(macOS)
                    .navigationBarTitleDisplayMode(.inline)
#endif
                }
            }
            .navigationDestination(for: SettingsGroupConfiguration.self) { groupConfig in
#if os(iOS)
                IOSSearchableSettingsDetail(
                    configuration: groupConfig,
                    navigationPath: configuration.navigationPath,
                    searchEnabled: searchPlacement.includesDestinations
                )
#else
                Form {
                    groupConfig.content
                }
                .navigationTitle(groupConfig.title)
#if !os(tvOS) && !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
#endif
            }
        }
    }

    /// Creates a destination link or inline section for a group.
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

}
