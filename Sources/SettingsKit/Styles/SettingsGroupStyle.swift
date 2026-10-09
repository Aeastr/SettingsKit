import SwiftUI

/// A type that controls the appearance and interaction of a settings group.
///
/// Unlike ``SettingsStyle``, a group style does not own a navigation container, search field, toolbar, or window chrome. Use it with ``SettingsHost`` when the surrounding settings layout should remain ordinary, app-owned SwiftUI.
public protocol SettingsGroupStyle {
    /// The view produced for a settings group.
    associatedtype Body: View

    /// The values available while rendering a group.
    typealias Configuration = SettingsGroupConfiguration

    /// Creates the view that represents a settings group.
    ///
    /// - Parameter configuration: The group's identity, semantic metadata, and live content.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
}

struct SettingsGroupStyleKey: EnvironmentKey {
    static let defaultValue = AnySettingsGroupStyle(adapting: SidebarSettingsStyle())
}

extension EnvironmentValues {
    var settingsGroupStyle: AnySettingsGroupStyle {
        get { self[SettingsGroupStyleKey.self] }
        set { self[SettingsGroupStyleKey.self] = newValue }
    }
}

/// A type-erased settings group style.
public struct AnySettingsGroupStyle: SettingsGroupStyle, @unchecked Sendable {
    private let makeBodyClosure: (SettingsGroupConfiguration) -> AnyView

    /// Erases a concrete group style.
    ///
    /// - Parameter style: The group style to wrap.
    public init<S: SettingsGroupStyle>(_ style: S) {
        makeBodyClosure = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    init<S: SettingsStyle>(adapting style: S) {
        makeBodyClosure = { configuration in
            AnyView(style.makeGroup(configuration: configuration))
        }
    }

    /// Creates a group view with the wrapped style.
    ///
    /// - Parameter configuration: The group values to render.
    public func makeBody(configuration: Configuration) -> some View {
        makeBodyClosure(configuration)
    }
}

public extension View {
    /// Sets the appearance of settings groups without changing the surrounding navigation, search, toolbar, or layout containers.
    ///
    /// - Parameter style: The style used to render each settings group.
    /// - Returns: A view with the group style in its environment.
    func settingsGroupStyle<S: SettingsGroupStyle>(_ style: S) -> some View {
        environment(\.settingsGroupStyle, AnySettingsGroupStyle(style))
    }
}
