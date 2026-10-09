import SwiftUI

/// A navigable settings group whose destination is an arbitrary SwiftUI view.
///
/// The title and tags participate in search. Destination content is rendered as supplied but is not recursively indexed. Visual treatment remains the active settings style's responsibility.
public struct CustomSettingsGroup<Content: View>: SettingsContent, SettingsContentIdentityProviding, SettingsContentRowRoleProviding {
    let id: UUID
    let title: String
    let tags: [String]
    let content: Content

    var settingsContentIdentity: AnyHashable? { id }
    var settingsContentRowRole: SettingsContentRowRole { .navigationGroup }

    @Environment(\.settingsGroupStyle) private var groupStyle
    @Environment(\.settingsIndexParentID) private var parentID
    @Environment(\.settingsNodeViewRegistry) private var registry

    /// Creates a custom navigation destination.
    ///
    /// - Parameters:
    ///   - title: The semantic title used by navigation and search.
    ///   - tags: Additional search terms.
    ///   - content: The arbitrary destination view.
    public init(
        _ title: String,
        tags: [String] = [],
        @ViewBuilder content: () -> Content
    ) {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine("custom")
        let hashValue = hasher.finalize()
        self.id = UUID(uuid: uuid_t(
            UInt8((hashValue >> 56) & 0xFF), UInt8((hashValue >> 48) & 0xFF),
            UInt8((hashValue >> 40) & 0xFF), UInt8((hashValue >> 32) & 0xFF),
            UInt8((hashValue >> 24) & 0xFF), UInt8((hashValue >> 16) & 0xFF),
            UInt8((hashValue >> 8) & 0xFF), UInt8(hashValue & 0xFF),
            0, 0, 0, 0, 0, 0, 0, 0
        ))

        self.title = title
        self.tags = tags
        self.content = content()
    }

    /// The navigation row produced by the active group style.
    public var body: some View {
        groupStyle.makeBody(
            configuration: SettingsGroupConfiguration(
                id: SettingsContentScope(registry: registry, parentID: parentID).scopedID(id),
                title: title,
                systemImage: nil,
                footer: nil,
                presentation: .navigation,
                content: AnyView(content),
                children: []
            )
        )
    }

    /// Builds metadata using the shared compatibility scope.
    public func makeNodes() -> [SettingsNode] {
        makeNodes(in: .shared)
    }

    /// Registers the live destination and builds semantic metadata.
    public func makeNodes(in scope: SettingsContentScope) -> [SettingsNode] {
        let id = scope.scopedID(self.id)
        scope.registry.register(id: id) { [content] in
            AnyView(content)
        }

        return [.group(
            id: id,
            title: title,
            systemImage: nil,
            tags: tags,
            presentation: .navigation,
            children: []
        )]
    }
}

public extension CustomSettingsGroup {
    /// Returns a copy with alternate search terms.
    func settingsTags(_ tags: [String]) -> Self {
        CustomSettingsGroup(title, tags: tags) { content }
    }
}
