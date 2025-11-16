import SwiftUI

/// Represents a navigation path to a specific setting
public struct SettingsPath: Equatable, Hashable {
    public let components: [String]

    public init(_ components: String...) {
        self.components = components
    }

    public init(_ components: [String]) {
        self.components = components
    }
}

/// Environment key for the current settings path
struct SettingsPathKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: Binding<SettingsPath?> = .constant(nil)
}

public extension EnvironmentValues {
    var settingsPath: Binding<SettingsPath?> {
        get { self[SettingsPathKey.self] }
        set { self[SettingsPathKey.self] = newValue }
    }
}
