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

    /// The child nodes of this group (for search purposes).
    public let children: [SettingsNode]

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

// MARK: - Environment

/// Environment key for settings style.
struct SettingsStyleKey: EnvironmentKey {
    static let defaultValue: AnySettingsStyle = AnySettingsStyle(SidebarSettingsStyle())
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

public extension SettingsStyle where Self == SidebarSettingsStyle {
    /// A settings style with sidebar navigation (default).
    static var sidebar: SidebarSettingsStyle {
        SidebarSettingsStyle()
    }
}

public extension SettingsStyle where Self == SingleColumnSettingsStyle {
    /// A single-column settings style.
    static var single: SingleColumnSettingsStyle {
        SingleColumnSettingsStyle()
    }
}
