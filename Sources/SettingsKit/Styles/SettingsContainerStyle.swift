import SwiftUI

/// A type that applies a custom appearance to the settings container.
///
/// To configure the style for the entire settings container, use the ``settingsContainerStyle(_:)`` modifier.
///
/// ## Creating Custom Styles
///
/// Create custom container styles by defining a type that conforms to `SettingsContainerStyle`
/// and implementing the ``makeBody(configuration:)`` method:
///
/// ```swift
/// struct SidebarContainerStyle: SettingsContainerStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         NavigationSplitView {
///             // Sidebar
///             List {
///                 // Custom sidebar content
///             }
///         } detail: {
///             configuration.content
///         }
///     }
/// }
/// ```
public protocol SettingsContainerStyle {
    associatedtype Body: View

    /// The properties of a settings container.
    typealias Configuration = SettingsContainerStyleConfiguration

    /// Creates a view that represents the body of a settings container.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// The properties of a settings container that can be used by a style.
public struct SettingsContainerStyleConfiguration {
    /// The title of the settings.
    public let title: String

    /// The main content of the settings.
    public let content: AnyView

    /// The search binding, if search is enabled.
    public let searchText: Binding<String>?

    /// The navigation path for programmatic navigation.
    public let navigationPath: Binding<NavigationPath>
}

// MARK: - Built-in Styles

/// The default settings container style using NavigationStack and List.
public struct DefaultSettingsContainerStyle: SettingsContainerStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            List {
                configuration.content
            }
            .navigationTitle(configuration.title)
            .if(configuration.searchText != nil) { view in
                view.searchable(text: configuration.searchText!, prompt: "Search settings")
            }
        }
    }
}

/// A settings container style using a split view with sidebar navigation.
public struct SidebarSettingsContainerStyle: SettingsContainerStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        NavigationSplitView {
            List {
                configuration.content
            }
            .navigationTitle(configuration.title)
        } detail: {
            Text("Select a setting")
                .foregroundStyle(.secondary)
        }
    }
}

/// A settings container style with a floating search bar.
public struct FloatingSearchSettingsContainerStyle: SettingsContainerStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            ZStack(alignment: .top) {
                List {
                    // Add spacing for floating search
                    Color.clear.frame(height: 60)
                        .listRowBackground(Color.clear)

                    configuration.content
                }
                .navigationTitle(configuration.title)

                // Floating search bar
                if let searchText = configuration.searchText {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            TextField("Search settings", text: searchText)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()

                        Spacer()
                    }
                }
            }
        }
    }
}

/// A settings container style with grouped appearance.
public struct GroupedSettingsContainerStyle: SettingsContainerStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            List {
                configuration.content
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
            .navigationTitle(configuration.title)
            .if(configuration.searchText != nil) { view in
                view.searchable(text: configuration.searchText!, prompt: "Search settings")
            }
        }
    }
}

// MARK: - Environment

/// Environment key for settings container style.
struct SettingsContainerStyleKey: EnvironmentKey {
    static let defaultValue: AnySettingsContainerStyle = AnySettingsContainerStyle(DefaultSettingsContainerStyle())
}

extension EnvironmentValues {
    var settingsContainerStyle: AnySettingsContainerStyle {
        get { self[SettingsContainerStyleKey.self] }
        set { self[SettingsContainerStyleKey.self] = newValue }
    }
}

// MARK: - Type Erasure

/// A type-erased settings container style.
public struct AnySettingsContainerStyle: SettingsContainerStyle {
    private let _makeBody: (SettingsContainerStyleConfiguration) -> AnyView

    public init<S: SettingsContainerStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    @MainActor
    public func makeBody(configuration: SettingsContainerStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - View Extension

public extension View {
    /// Sets the style for the settings container.
    func settingsContainerStyle<S: SettingsContainerStyle>(_ style: S) -> some View {
        environment(\.settingsContainerStyle, AnySettingsContainerStyle(style))
    }
}

// MARK: - Static Convenience

public extension SettingsContainerStyle where Self == DefaultSettingsContainerStyle {
    /// The default settings container style.
    static var `default`: DefaultSettingsContainerStyle {
        DefaultSettingsContainerStyle()
    }
}

public extension SettingsContainerStyle where Self == SidebarSettingsContainerStyle {
    /// A settings container style with sidebar navigation.
    static var sidebar: SidebarSettingsContainerStyle {
        SidebarSettingsContainerStyle()
    }
}

public extension SettingsContainerStyle where Self == FloatingSearchSettingsContainerStyle {
    /// A settings container style with floating search.
    static var floatingSearch: FloatingSearchSettingsContainerStyle {
        FloatingSearchSettingsContainerStyle()
    }
}

public extension SettingsContainerStyle where Self == GroupedSettingsContainerStyle {
    /// A settings container style with grouped appearance.
    static var grouped: GroupedSettingsContainerStyle {
        GroupedSettingsContainerStyle()
    }
}

// MARK: - Helper Extension

extension View {
    @MainActor
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
