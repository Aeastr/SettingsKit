import SwiftUI

public extension SettingsContent {
    /// Excludes this content and its descendants from settings search.
    ///
    /// Navigation, bindings, identity and group styling remain unchanged. Apply
    /// this after `indexed`, `settingsID` or `settingsTags`. Exclusion wins over
    /// any indexed descendants. Ordinary SwiftUI views are already unindexed.
    func unindexed() -> some SettingsContent {
        UnindexedSettingsContent(content: self)
    }
}

private struct UnindexedSettingsContent<Content: SettingsContent>: SettingsContent,
    SettingsContentIdentityProviding, SettingsContentRowRoleProviding {
    let content: Content

    var settingsContentIdentity: AnyHashable? {
        (content as? any SettingsContentIdentityProviding)?.settingsContentIdentity
    }

    var settingsContentRowRole: SettingsContentRowRole {
        (content as? any SettingsContentRowRoleProviding)?.settingsContentRowRole ?? .content
    }

    @Environment(\.settingsNodeViewRegistry) private var registry
    @Environment(\.settingsIndexParentID) private var parentID

    var body: some View {
        // Transient groups may appear after the host built its index. Register
        // their live destination in the rendering scope without exposing search.
        let _ = makeNodes(in: SettingsContentScope(registry: registry, parentID: parentID))
        content
    }

    func makeNodes() -> [SettingsNode] { makeNodes(in: .shared) }

    func makeNodes(in scope: SettingsContentScope) -> [SettingsNode] {
        // Register live destinations normally, then mark their metadata excluded.
        // Retain navigation nodes: sidebar structure also depends on this tree.
        func exclude(_ node: SettingsNode) -> SettingsNode {
            switch node {
            case .group(let id, let title, let image, let tags, let presentation, let children, _):
                let excludedChildren = children.map(exclude)
                // Page-scoped search reads children from this same registry.
                scope.registry.registerChildren(excludedChildren, for: id)
                return .group(id: id, title: title, systemImage: image, tags: tags,
                              presentation: presentation, children: excludedChildren, searchable: false)
            case .item(let id, let title, let tags, _):
                return .item(id: id, title: title, tags: tags, searchable: false)
            }
        }
        return content.makeNodes(in: scope).map(exclude)
    }
}
