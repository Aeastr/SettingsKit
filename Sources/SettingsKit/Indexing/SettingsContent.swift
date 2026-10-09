import SwiftUI

/// Content that can participate in a settings hierarchy and metadata index.
///
/// Conformance to `View` lets SwiftUI install state and environment property wrappers normally. Built-in groups and indexed controls also produce ``SettingsNode`` metadata used by navigation and search.
///
/// A custom conformance whose `body` contains multiple top-level settings expressions must apply ``SettingsContentBuilder`` explicitly:
///
/// ```swift
/// struct AccountSettings: SettingsContent {
///     @SettingsContentBuilder
///     var body: some SettingsContent {
///         SettingsGroup("Profile") { /* ... */ }
///         SettingsGroup("Security") { /* ... */ }
///     }
/// }
/// ```
///
/// Without the annotation, the inherited SwiftUI `ViewBuilder` combines those expressions into a `TupleView`, which does not conform to `SettingsContent`. The annotation is unnecessary for a single top-level expression, for ``SettingsContainer/settingsBody``, or inside a ``SettingsGroup`` content closure.
public protocol SettingsContent: View {
    /// Converts this content into metadata using the shared registration scope.
    ///
    /// - Returns: The nodes contributed by this content.
    func makeNodes() -> [SettingsNode]

    /// Convert this content into nodes using a presentation-scoped view registry.
    ///
    /// SettingsKit's built-in content types use this entry point to keep rendered views local to a specific host. Custom content that is composed from other ``SettingsContent`` values can rely on the default implementation.
    ///
    /// - Parameter scope: The scope receiving registrations for live views.
    /// - Returns: The nodes contributed by this content.
    func makeNodes(in scope: SettingsContentScope) -> [SettingsNode]
}

public extension SettingsContent {
    /// Default implementation that extracts nodes from the body.
    ///
    /// This allows you to create custom `SettingsContent` types without manually implementing `makeNodes()`:
    ///
    /// ```swift
    /// struct ProfileSettingsGroup: SettingsContent {
    ///     var body: some SettingsContent {
    ///         SettingsGroup("Profile") {
    ///             TextField("Name", text: $name)
    ///             TextField("Email", text: $email)
    ///                 .indexed("Email", tags: ["contact"])
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

    /// Extracts nodes from the content's body using the supplied scope.
    ///
    /// - Parameter scope: The scope forwarded to nested settings content.
    /// - Returns: The nodes contributed by the nested body, or an empty array.
    func makeNodes(in scope: SettingsContentScope) -> [SettingsNode] {
        if let content = body as? any SettingsContent {
            return content.makeNodes(in: scope)
        }
        return []
    }
}

/// A container for settings content, typically the root-level settings view.
public protocol SettingsContainer: View {
    /// The concrete settings content produced by this container.
    associatedtype SettingsBody: SettingsContent

    /// The root settings hierarchy.
    @SettingsContentBuilder
    var settingsBody: SettingsBody { get }

    /// Change this value when the titles, tags, or structure of settings change.
    /// Live control values do not need to invalidate the search index.
    var settingsIndexRevision: Int { get }
}

public extension SettingsContainer {
    var settingsIndexRevision: Int { 0 }

    /// The built-in settings presentation.
    ///
    /// Use ``SettingsHost`` directly when the app should own the visible shell.
    var body: some View {
        SettingsView(container: self)
    }
}
