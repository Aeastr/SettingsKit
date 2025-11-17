import SwiftUI

/// Protocol representing any content that can appear in a settings hierarchy.
/// This includes both groups and individual items.
/// Conforms to View so SwiftUI properly installs @State and other property wrappers.
public protocol SettingsContent: View {
    /// Convert this content into the internal node representation
    func makeNodes() -> [SettingsNode]
}

public extension SettingsContent {
    /// Default implementation that extracts nodes from the body.
    ///
    /// This allows you to create custom `SettingsContent` types without manually
    /// implementing `makeNodes()`:
    ///
    /// ```swift
    /// struct ProfileSettingsGroup: SettingsContent {
    ///     var body: some SettingsContent {
    ///         SettingsGroup("Profile") {
    ///             SettingsItem("Name") { ... }
    ///             SettingsItem("Email") { ... }
    ///         }
    ///     }
    ///     // makeNodes() is automatic! ✅
    /// }
    /// ```
    func makeNodes() -> [SettingsNode] {
        // Extract nodes from body if it conforms to SettingsContent
        if let content = body as? any SettingsContent {
            return content.makeNodes()
        }
        return []
    }
}

/// A container for settings content, typically the root-level settings view.
public protocol SettingsContainer: View {
    associatedtype SettingsBody: SettingsContent

    @SettingsContentBuilder
    var settingsBody: SettingsBody { get }
}

public extension SettingsContainer {
    var body: some View {
        SettingsView(container: self)
    }
}
