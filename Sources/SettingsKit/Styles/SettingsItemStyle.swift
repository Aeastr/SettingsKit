import SwiftUI

/// A type that applies a custom appearance to settings items.
///
/// To configure the style for settings items, use the ``settingsItemStyle(_:)`` modifier.
///
/// ## Creating Custom Styles
///
/// Create custom item styles by defining a type that conforms to `SettingsItemStyle`
/// and implementing the ``makeBody(configuration:)`` method:
///
/// ```swift
/// struct MyItemStyle: SettingsItemStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         HStack {
///             Text(configuration.title)
///             Spacer()
///             configuration.content
///         }
///         .padding()
///     }
/// }
/// ```
@MainActor
public protocol SettingsItemStyle {
    associatedtype Body: View

    /// The properties of a settings item.
    typealias Configuration = SettingsItemStyleConfiguration

    /// Creates a view that represents the body of a settings item.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// The properties of a settings item that can be used by a style.
public struct SettingsItemStyleConfiguration {
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

/// The default settings item style that displays content inline.
public struct DefaultSettingsItemStyle: SettingsItemStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
    }
}

/// A settings item style that displays the title and content in a row.
public struct RowSettingsItemStyle: SettingsItemStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            configuration.content
        }
    }
}

/// A settings item style that displays the title above the content.
public struct VerticalSettingsItemStyle: SettingsItemStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label
                .font(.headline)
            configuration.content
        }
    }
}

/// A settings item style with prominent styling.
public struct ProminentSettingsItemStyle: SettingsItemStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            if let icon = configuration.icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(configuration.title)
                    .font(.headline)
                configuration.content
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Environment

/// Environment key for settings item style.
struct SettingsItemStyleKey: EnvironmentKey {
    static let defaultValue: AnySettingsItemStyle = AnySettingsItemStyle(DefaultSettingsItemStyle())
}

extension EnvironmentValues {
    var settingsItemStyle: AnySettingsItemStyle {
        get { self[SettingsItemStyleKey.self] }
        set { self[SettingsItemStyleKey.self] = newValue }
    }
}

// MARK: - Type Erasure

/// A type-erased settings item style.
public struct AnySettingsItemStyle: SettingsItemStyle {
    private let _makeBody: (SettingsItemStyleConfiguration) -> AnyView

    public init<S: SettingsItemStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    @MainActor
    public func makeBody(configuration: SettingsItemStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - View Extension

public extension View {
    /// Sets the style for settings items within this view.
    func settingsItemStyle<S: SettingsItemStyle>(_ style: S) -> some View {
        environment(\.settingsItemStyle, AnySettingsItemStyle(style))
    }
}

// MARK: - Static Convenience

public extension SettingsItemStyle where Self == DefaultSettingsItemStyle {
    /// The default settings item style.
    static var `default`: DefaultSettingsItemStyle {
        DefaultSettingsItemStyle()
    }
}

public extension SettingsItemStyle where Self == RowSettingsItemStyle {
    /// A settings item style that displays in a row.
    static var row: RowSettingsItemStyle {
        RowSettingsItemStyle()
    }
}

public extension SettingsItemStyle where Self == VerticalSettingsItemStyle {
    /// A settings item style that displays vertically.
    static var vertical: VerticalSettingsItemStyle {
        VerticalSettingsItemStyle()
    }
}

public extension SettingsItemStyle where Self == ProminentSettingsItemStyle {
    /// A settings item style with prominent appearance.
    static var prominent: ProminentSettingsItemStyle {
        ProminentSettingsItemStyle()
    }
}
