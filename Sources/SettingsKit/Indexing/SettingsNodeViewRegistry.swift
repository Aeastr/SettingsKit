import SwiftUI

/// Registry that maps node IDs to their view builders.
/// This allows search results to render actual content without storing views in nodes.
class SettingsNodeViewRegistry {
    nonisolated(unsafe) static let shared = SettingsNodeViewRegistry()

    private var viewBuilders: [UUID: () -> AnyView] = [:]

    private init() {}

    /// Register a view builder for a node ID
    func register(id: UUID, builder: @escaping () -> AnyView) {
        viewBuilders[id] = builder
    }

    /// Get the view for a node ID
    func view(for id: UUID) -> AnyView? {
        viewBuilders[id]?()
    }

    /// Clear all registered views (useful for cleanup)
    func clear() {
        viewBuilders.removeAll()
    }
}
