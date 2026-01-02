import SwiftUI

/// Registry that maps node IDs to their view builders.
/// This allows search results to render actual content without storing views in nodes.
class SettingsNodeViewRegistry {
    nonisolated(unsafe) static let shared = SettingsNodeViewRegistry()

    private var viewBuilders: [UUID: () -> AnyView] = [:]
    private var iconBuilders: [UUID: () -> AnyView] = [:]

    private init() {}

    /// Register a view builder for a node ID
    func register(id: UUID, builder: @escaping () -> AnyView) {
        viewBuilders[id] = builder
    }

    /// Register an icon view builder for a node ID
    func registerIcon(id: UUID, builder: @escaping () -> AnyView) {
        iconBuilders[id] = builder
    }

    /// Get the view for a node ID
    func view(for id: UUID) -> AnyView? {
        viewBuilders[id]?()
    }

    /// Get the icon view for a node ID
    func iconView(for id: UUID) -> AnyView? {
        iconBuilders[id]?()
    }

    /// Clear all registered views (useful for cleanup)
    func clear() {
        viewBuilders.removeAll()
        iconBuilders.removeAll()
    }
}
