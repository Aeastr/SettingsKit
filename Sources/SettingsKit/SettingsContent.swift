import SwiftUI

/// Protocol representing any content that can appear in a settings hierarchy.
/// This includes both groups and individual items.
/// Conforms to View so SwiftUI properly installs @State and other property wrappers.
public protocol SettingsContent: View, Sendable {
    /// Convert this content into the internal node representation
    func makeNodes() -> [SettingsNode]
}

/// A container for settings content, typically the root-level settings view.
public protocol SettingsContainer: View {
    associatedtype SettingsBody: SettingsContent

    @SettingsContentBuilder
    var settingsBody: SettingsBody { get }
}

public extension SettingsContainer {
    var body: some View {
        settingsBody
    }
}
