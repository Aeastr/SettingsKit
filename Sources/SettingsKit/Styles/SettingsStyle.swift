import SwiftUI

/// A type that applies a custom appearance to settings components.
///
/// To configure the style for all settings components, use the ``settingsStyle(_:)`` modifier.
///
/// ## Creating Custom Styles
///
/// Create custom styles by defining a type that conforms to `SettingsStyle`
/// and implementing the required methods:
///
/// ```swift
/// struct MySettingsStyle: SettingsStyle {
///     func makeContainer(configuration: ContainerConfiguration) -> some View {
///         NavigationStack(path: configuration.navigationPath) {
///             List {
///                 configuration.content
///             }
///             .navigationTitle(configuration.title)
///         }
///     }
///
///     func makeGroup(configuration: GroupConfiguration) -> some View {
///         NavigationLink {
///             List {
///                 configuration.content
///             }
///             .navigationTitle(configuration.title)
///         } label: {
///             configuration.label
///         }
///     }
///
///     func makeItem(configuration: ItemConfiguration) -> some View {
///         configuration.content
///     }
/// }
/// ```
public protocol SettingsStyle {
    associatedtype ContainerBody: View
    associatedtype GroupBody: View
    associatedtype ItemBody: View

    /// Configuration for the settings container.
    typealias ContainerConfiguration = SettingsContainerConfiguration

    /// Configuration for a settings group.
    typealias GroupConfiguration = SettingsGroupConfiguration

    /// Configuration for a settings item.
    typealias ItemConfiguration = SettingsItemConfiguration

    /// Creates a view that represents the settings container.
    @ViewBuilder func makeContainer(configuration: ContainerConfiguration) -> ContainerBody

    /// Creates a view that represents a settings group.
    @ViewBuilder func makeGroup(configuration: GroupConfiguration) -> GroupBody

    /// Creates a view that represents a settings item.
    @ViewBuilder func makeItem(configuration: ItemConfiguration) -> ItemBody
}

// MARK: - Configuration Types

/// The properties of a settings container that can be used by a style.
public struct SettingsContainerConfiguration: @unchecked Sendable {
    /// The title of the settings.
    public let title: String

    /// The main content of the settings.
    public let content: AnyView

    /// The search binding, if search is enabled.
    public let searchText: Binding<String>?

    /// The navigation path for programmatic navigation.
    public let navigationPath: Binding<NavigationPath>
}

/// The properties of a settings group that can be used by a style.
public struct SettingsGroupConfiguration: @unchecked Sendable, Hashable {
    /// The title of the group.
    public let title: String

    /// The icon of the group, if any.
    public let icon: String?

    /// The footer text of the group, if any.
    public let footer: String?

    /// The presentation mode of the group.
    public let presentation: SettingsGroupPresentation

    /// The content of the group.
    public let content: AnyView

    /// Internal ID for hashing
    private let id = UUID()

    /// A view that represents the group's label (title + icon).
    @ViewBuilder
    public var label: some View {
        if let icon = icon {
            Label(title, systemImage: icon)
        } else {
            Text(title)
        }
    }

    public static func == (lhs: SettingsGroupConfiguration, rhs: SettingsGroupConfiguration) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// The properties of a settings item that can be used by a style.
public struct SettingsItemConfiguration: @unchecked Sendable {
    /// The title of the item.
    public let title: String

    /// The icon of the item, if any.
    public let icon: String?

    /// The content of the item.
    public let content: AnyView

    /// A view that represents the item's label (title + icon).
    @ViewBuilder
    public var label: some View {
        if let icon = icon {
            Label(title, systemImage: icon)
        } else {
            Text(title)
        }
    }
}

// MARK: - Built-in Styles

/// The default settings style with standard navigation and list appearance.
public struct DefaultSettingsStyle: SettingsStyle {
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
                }
            }
            .navigationDestination(for: SettingsGroupConfiguration.self) { groupConfig in
                List {
                    groupConfig.content
                }
                .navigationTitle(groupConfig.title)
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

/// A settings style using a split view with sidebar navigation.
public struct SidebarSettingsStyle: SettingsStyle {
    public init() {}

    public func makeContainer(configuration: ContainerConfiguration) -> some View {
        SidebarContainer(configuration: configuration)
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

private struct SidebarContainer: View {
    let configuration: SettingsContainerConfiguration
    @State private var selectedGroup: SettingsGroupConfiguration?

    var body: some View {
        NavigationSplitView {
            if let searchText = configuration.searchText {
                List(selection: $selectedGroup) {
                    configuration.content
                }
                .navigationTitle(configuration.title)
                .searchable(text: searchText, prompt: "Search settings")
            } else {
                List(selection: $selectedGroup) {
                    configuration.content
                }
                .navigationTitle(configuration.title)
            }
        } detail: {
            if let selectedGroup {
                NavigationStack(path: configuration.navigationPath) {
                    List {
                        selectedGroup.content
                    }
                    .navigationTitle(selectedGroup.title)
                    .navigationDestination(for: SettingsGroupConfiguration.self) { groupConfig in
                        List {
                            groupConfig.content
                        }
                        .navigationTitle(groupConfig.title)
                    }
                }
            } else {
                Text("Select a setting")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// A settings style with grouped/inset appearance.
public struct GroupedSettingsStyle: SettingsStyle {
    public init() {}

    public func makeContainer(configuration: ContainerConfiguration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            Group {
                if let searchText = configuration.searchText {
                    List {
                        configuration.content
                    }
                    #if os(iOS)
                    .listStyle(.insetGrouped)
                    #endif
                    .navigationTitle(configuration.title)
                    .searchable(text: searchText, prompt: "Search settings")
                } else {
                    List {
                        configuration.content
                    }
                    #if os(iOS)
                    .listStyle(.insetGrouped)
                    #endif
                    .navigationTitle(configuration.title)
                }
            }
            .navigationDestination(for: SettingsGroupConfiguration.self) { groupConfig in
                List {
                    groupConfig.content
                }
                #if os(iOS)
                .listStyle(.insetGrouped)
                #endif
                .navigationTitle(groupConfig.title)
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
        HStack {
            configuration.label
            Spacer()
            configuration.content
        }
    }
}

/// A settings style with card-based appearance.
public struct CardSettingsStyle: SettingsStyle {
    public init() {}

    public func makeContainer(configuration: ContainerConfiguration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            ScrollView {
                VStack(spacing: 16) {
                    configuration.content
                }
                .padding()
            }
            .navigationTitle(configuration.title)
            .navigationDestination(for: SettingsGroupConfiguration.self) { groupConfig in
                ScrollView {
                    VStack(spacing: 16) {
                        groupConfig.content
                    }
                    .padding()
                }
                .navigationTitle(groupConfig.title)
            }
        }
    }

    public func makeGroup(configuration: GroupConfiguration) -> some View {
        switch configuration.presentation {
        case .navigation:
            NavigationLink(value: configuration) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        configuration.label
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                }
                .background(.background.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        case .inline:
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    configuration.label
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                configuration.content
                    .padding(.horizontal)

                if let footer = configuration.footer {
                    Text(footer)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    public func makeItem(configuration: ItemConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label
                .font(.headline)
            configuration.content
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Environment

/// Environment key for settings style.
struct SettingsStyleKey: EnvironmentKey {
    static let defaultValue: AnySettingsStyle = AnySettingsStyle(DefaultSettingsStyle())
}

extension EnvironmentValues {
    var settingsStyle: AnySettingsStyle {
        get { self[SettingsStyleKey.self] }
        set { self[SettingsStyleKey.self] = newValue }
    }
}

// MARK: - Type Erasure

/// A type-erased settings style.
public struct AnySettingsStyle: SettingsStyle, @unchecked Sendable {
    private let _makeContainer: (SettingsContainerConfiguration) -> AnyView
    private let _makeGroup: (SettingsGroupConfiguration) -> AnyView
    private let _makeItem: (SettingsItemConfiguration) -> AnyView

    public init<S: SettingsStyle>(_ style: S) {
        _makeContainer = { configuration in
            AnyView(style.makeContainer(configuration: configuration))
        }
        _makeGroup = { configuration in
            AnyView(style.makeGroup(configuration: configuration))
        }
        _makeItem = { configuration in
            AnyView(style.makeItem(configuration: configuration))
        }
    }

    public func makeContainer(configuration: SettingsContainerConfiguration) -> some View {
        _makeContainer(configuration)
    }

    public func makeGroup(configuration: SettingsGroupConfiguration) -> some View {
        _makeGroup(configuration)
    }

    public func makeItem(configuration: SettingsItemConfiguration) -> some View {
        _makeItem(configuration)
    }
}

// MARK: - View Extension

public extension View {
    /// Sets the style for all settings components within this view.
    func settingsStyle<S: SettingsStyle>(_ style: S) -> some View {
        environment(\.settingsStyle, AnySettingsStyle(style))
    }
}

// MARK: - Static Convenience

public extension SettingsStyle where Self == DefaultSettingsStyle {
    /// The default settings style.
    static var `default`: DefaultSettingsStyle {
        DefaultSettingsStyle()
    }
}

public extension SettingsStyle where Self == SidebarSettingsStyle {
    /// A settings style with sidebar navigation.
    static var sidebar: SidebarSettingsStyle {
        SidebarSettingsStyle()
    }
}

public extension SettingsStyle where Self == GroupedSettingsStyle {
    /// A settings style with grouped appearance.
    static var grouped: GroupedSettingsStyle {
        GroupedSettingsStyle()
    }
}

public extension SettingsStyle where Self == CardSettingsStyle {
    /// A settings style with card-based appearance.
    static var card: CardSettingsStyle {
        CardSettingsStyle()
    }
}
