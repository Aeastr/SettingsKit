import SwiftUI

/// The rendering scope supplied when SettingsKit builds a metadata index.
///
/// Custom `SettingsContent` normally relies on the default implementation of `makeNodes(in:)`. The scope exists so advanced conformances can forward the same host-local registration scope to nested settings content.
///
/// A scope deliberately exposes no registry operations publicly. Pass the value unchanged when recursively building child metadata.
public struct SettingsContentScope {
    let registry: SettingsNodeViewRegistry
    let parentID: UUID?

    init(registry: SettingsNodeViewRegistry, parentID: UUID? = nil) {
        self.registry = registry
        self.parentID = parentID
    }

    func scopedID(_ id: UUID) -> UUID {
        guard let parentID else { return id }
        return Self.identity(parentID.uuidString + "/" + id.uuidString)
    }

    static func identity(_ value: String) -> UUID {
        var hasher = Hasher()
        hasher.combine(value)
        let hash = UInt64(bitPattern: Int64(hasher.finalize()))
        let bytes = (0..<8).map { UInt8(truncatingIfNeeded: hash >> ($0 * 8)) }
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
                           0, 0, 0, 0, 0, 0, 0, 0))
    }

    static var shared: SettingsContentScope {
        SettingsContentScope(registry: .shared)
    }
}

final class SettingsNodeViewRegistry {
    nonisolated(unsafe) static let shared = SettingsNodeViewRegistry()

    private var viewBuilders: [UUID: () -> AnyView] = [:]
    private var indexedChildren: [UUID: [SettingsNode]] = [:]
    private var introductionParents: Set<UUID> = []

    init() {}

    /// Register a view builder for a node ID
    func register(id: UUID, builder: @escaping () -> AnyView) {
        viewBuilders[id] = builder
    }

    /// Get the view for a node ID
    func view(for id: UUID) -> AnyView? {
        viewBuilders[id]?()
    }

    func registerChildren(_ children: [SettingsNode], for id: UUID) {
        indexedChildren[id] = children
    }

    func children(for id: UUID) -> [SettingsNode]? {
        indexedChildren[id]
    }

    func registerIntroduction(in parentID: UUID?) {
        guard let parentID else { return }
        introductionParents.insert(parentID)
    }

    /// Only inline descendants belong to this page. A nested navigation page's
    /// introduction must never hide its parent's title.
    func hasIntroduction(in id: UUID) -> Bool {
        if introductionParents.contains(id) { return true }
        return (indexedChildren[id] ?? []).contains { child in
            child.presentation == .inline && hasIntroduction(in: child.id)
        }
    }

    /// Clear all registered views (useful for cleanup)
    func clear() {
        viewBuilders.removeAll()
        indexedChildren.removeAll()
        introductionParents.removeAll()
    }
}

private struct SettingsNodeViewRegistryKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = SettingsNodeViewRegistry.shared
}

private struct SettingsIndexParentKey: EnvironmentKey {
    static let defaultValue: UUID? = nil
}

extension EnvironmentValues {
    var settingsIndexParentID: UUID? {
        get { self[SettingsIndexParentKey.self] }
        set { self[SettingsIndexParentKey.self] = newValue }
    }
    var settingsNodeViewRegistry: SettingsNodeViewRegistry {
        get { self[SettingsNodeViewRegistryKey.self] }
        set { self[SettingsNodeViewRegistryKey.self] = newValue }
    }
}
