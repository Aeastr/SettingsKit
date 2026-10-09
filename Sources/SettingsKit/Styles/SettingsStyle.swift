import SwiftUI

/// Controls where a built-in settings style presents search UI.
public enum SettingsSearchPlacement: Sendable, Hashable {
    /// Show search only at the root of the settings hierarchy.
    case root

    /// Show search only inside navigated destinations.
    case destinations

    /// Show search at the root and inside navigated destinations.
    case all

    /// Do not show built-in search UI.
    case none

    var includesRoot: Bool {
        self == .root || self == .all
    }

    var includesDestinations: Bool {
        self == .destinations || self == .all
    }
}

/// A type that controls a complete built-in settings presentation.
///
/// To configure the style for all settings components, use the `settingsStyle(_:)` modifier.
///
/// A settings style owns the container and group presentation. Controls inside groups remain ordinary SwiftUI views; customize them with standard SwiftUI view modifiers and control styles in the settings declaration, group body, or container body.
///
/// ## Creating Custom Styles
///
/// Create custom styles by defining a type that conforms to `SettingsStyle` and implementing the required methods:
///
/// ```swift
/// struct MySettingsStyle: SettingsStyle {
///     func makeContainer(configuration: ContainerConfiguration) -> some View {
///         NavigationStack(path: configuration.navigationPath) {
///             Form {
///                 configuration.content
///             }
///             .navigationTitle(configuration.title)
///         }
///     }
///
///     func makeGroup(configuration: GroupConfiguration) -> some View {
///         NavigationLink {
///             Form {
///                 configuration.content
///             }
///             .navigationTitle(configuration.title)
///         } label: {
///             configuration.label
///         }
///     }
///
/// }
/// ```
public protocol SettingsStyle {
    /// The view that renders the complete settings presentation.
    associatedtype ContainerBody: View

    /// The view that renders an individual group.
    associatedtype GroupBody: View

    /// Configuration for the settings container.
    typealias ContainerConfiguration = SettingsContainerConfiguration

    /// Configuration for a settings group.
    typealias GroupConfiguration = SettingsGroupConfiguration

    /// Creates a view that represents the settings container.
    @ViewBuilder func makeContainer(configuration: ContainerConfiguration) -> ContainerBody

    /// Creates a view that represents a settings group.
    @ViewBuilder func makeGroup(configuration: GroupConfiguration) -> GroupBody
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

    /// The selected top-level destination in split navigation.
    public let selectedGroup: Binding<SettingsGroupConfiguration?>
}

/// The properties of a settings group that can be used by a style.
public struct SettingsGroupConfiguration: @unchecked Sendable, Hashable {
    /// The stable identity of the group.
    public let id: UUID

    /// The title of the group.
    public let title: String

    /// The SF Symbol associated with the group, if any.
    public let systemImage: String?

    /// The footer text of the group, if any.
    public let footer: String?

    /// The presentation mode of the group.
    public let presentation: SettingsGroupPresentation

    /// The content of the group.
    public let content: AnyView

    /// The child nodes of this group (for search purposes).
    public let children: [SettingsNode]

    /// The semantic group label. Styles decide its typography and placement.
    @ViewBuilder
    public var label: some View {
        if let systemImage {
            Label(title, systemImage: systemImage)
        } else {
            Text(title)
        }
    }

    /// Returns whether two configurations represent the same group identity.
    public static func == (lhs: SettingsGroupConfiguration, rhs: SettingsGroupConfiguration) -> Bool {
        lhs.id == rhs.id
    }

    /// Hashes the configuration by its group identifier.
    ///
    /// - Parameter hasher: The hasher to update.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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

    /// Erases a concrete full-presentation style.
    ///
    /// - Parameter style: The style to wrap.
    public init<S: SettingsStyle>(_ style: S) {
        _makeContainer = { configuration in
            AnyView(style.makeContainer(configuration: configuration))
        }
        _makeGroup = { configuration in
            AnyView(style.makeGroup(configuration: configuration))
        }
    }

    /// Creates the container view with the wrapped style.
    public func makeContainer(configuration: SettingsContainerConfiguration) -> some View {
        _makeContainer(configuration)
    }

    /// Creates a group view with the wrapped style.
    public func makeGroup(configuration: SettingsGroupConfiguration) -> some View {
        _makeGroup(configuration)
    }

}

// MARK: - View Extension

public extension View {
    /// Sets the full-presentation style for settings in this view hierarchy.
    ///
    /// - Parameter style: The style used for the container and groups.
    /// - Returns: A view with the style in its environment.
    func settingsStyle<S: SettingsStyle>(_ style: S) -> some View {
        environment(\.settingsStyle, AnySettingsStyle(style))
            .environment(\.settingsGroupStyle, AnySettingsGroupStyle(adapting: style))
    }
}

// MARK: - Static Convenience

public extension SettingsStyle where Self == SidebarSettingsStyle {
    /// The built-in split-view sidebar style.
    static var sidebar: SidebarSettingsStyle {
        SidebarSettingsStyle()
    }

    /// Creates the sidebar style with explicit search placement.
    static func sidebar(search: SettingsSearchPlacement, rootTitleDisplayMode: SettingsRootTitleDisplayMode = .automatic) -> SidebarSettingsStyle {
        SidebarSettingsStyle(search: search, rootTitleDisplayMode: rootTitleDisplayMode)
    }
}

public extension SettingsStyle where Self == SingleColumnSettingsStyle {
    /// The built-in single-column navigation style.
    static var single: SingleColumnSettingsStyle {
        SingleColumnSettingsStyle()
    }

    /// Creates the single-column style with explicit search placement.
    static func single(search: SettingsSearchPlacement) -> SingleColumnSettingsStyle {
        SingleColumnSettingsStyle(search: search)
    }
}
