import SwiftUI

/// A type that applies a custom appearance to settings groups.
///
/// To configure the style for a settings group, use the ``SettingsGroup/settingsGroupStyle(_:)`` modifier.
/// You can also apply this at a higher level to affect all groups in a container.
///
/// ## Creating Custom Styles
///
/// Create custom group styles by defining a type that conforms to `SettingsGroupStyle`
/// and implementing the ``makeBody(configuration:)`` method:
///
/// ```swift
/// struct MyGroupStyle: SettingsGroupStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         VStack(alignment: .leading) {
///             Text(configuration.title)
///                 .font(.headline)
///             configuration.content
///         }
///     }
/// }
/// ```
public protocol SettingsGroupStyle {
    associatedtype Body: View

    /// The properties of a settings group.
    typealias Configuration = SettingsGroupStyleConfiguration

    /// Creates a view that represents the body of a settings group.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// The properties of a settings group that can be used by a style.
public struct SettingsGroupStyleConfiguration {
    /// The title of the group.
    public let title: String

    /// The icon of the group, if any.
    public let icon: String?

    /// The footer text of the group, if any.
    public let footer: String?

    /// The content of the group.
    public let content: AnyView

    /// A view that represents the group's label (title + icon).
    public var label: some View {
        if let icon = icon {
            Label(title, systemImage: icon)
        } else {
            Text(title)
        }
    }
}

// MARK: - Built-in Styles

/// A settings group style that displays the group as a navigation link.
///
/// When tapped, the group navigates to a new screen showing its content.
public struct NavigationSettingsGroupStyle: SettingsGroupStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        NavigationLink {
            List {
                configuration.content
            }
            .navigationTitle(configuration.title)
        } label: {
            configuration.label
        }
    }
}

/// A settings group style that displays the group inline as a section.
///
/// The group's content is shown directly without navigation.
public struct InlineSettingsGroupStyle: SettingsGroupStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        Section {
            configuration.content
        } header: {
            Text(configuration.title)
        } footer: {
            if let footer = configuration.footer {
                Text(footer)
            }
        }
    }
}

/// A settings group style that displays content in a card-like appearance.
public struct CardSettingsGroupStyle: SettingsGroupStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
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

// MARK: - Environment

/// Environment key for settings group style.
struct SettingsGroupStyleKey: EnvironmentKey {
    static let defaultValue: AnySettingsGroupStyle = AnySettingsGroupStyle(NavigationSettingsGroupStyle())
}

extension EnvironmentValues {
    var settingsGroupStyle: AnySettingsGroupStyle {
        get { self[SettingsGroupStyleKey.self] }
        set { self[SettingsGroupStyleKey.self] = newValue }
    }
}

// MARK: - Type Erasure

/// A type-erased settings group style.
public struct AnySettingsGroupStyle: SettingsGroupStyle {
    private let _makeBody: (SettingsGroupStyleConfiguration) -> AnyView

    public init<S: SettingsGroupStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    @MainActor
    public func makeBody(configuration: SettingsGroupStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - View Extension

public extension View {
    /// Sets the style for settings groups within this view.
    func settingsGroupStyle<S: SettingsGroupStyle>(_ style: S) -> some View {
        environment(\.settingsGroupStyle, AnySettingsGroupStyle(style))
    }
}

// MARK: - Static Convenience

public extension SettingsGroupStyle where Self == NavigationSettingsGroupStyle {
    /// A settings group style that displays as a navigation link.
    static var navigation: NavigationSettingsGroupStyle {
        NavigationSettingsGroupStyle()
    }
}

public extension SettingsGroupStyle where Self == InlineSettingsGroupStyle {
    /// A settings group style that displays inline as a section.
    static var inline: InlineSettingsGroupStyle {
        InlineSettingsGroupStyle()
    }
}

public extension SettingsGroupStyle where Self == CardSettingsGroupStyle {
    /// A settings group style that displays in a card-like appearance.
    static var card: CardSettingsGroupStyle {
        CardSettingsGroupStyle()
    }
}
