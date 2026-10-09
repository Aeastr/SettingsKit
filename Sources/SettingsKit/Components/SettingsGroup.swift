import SwiftUI

/// The presentation mode for a settings group.
public enum SettingsGroupPresentation: Sendable, Hashable {
    /// Display the group as a navigation link that opens its content.
    case navigation

    /// Display the group inline as a section.
    case inline
}

/// A titled group that contains settings controls or nested groups.
///
/// `SettingsGroup` describes semantic hierarchy only. Visual decoration belongs to ``SettingsStyle`` or ``SettingsGroupStyle``; arbitrary SwiftUI views remain available inside `content` when an application needs custom UI.
public struct SettingsGroup<Content: SettingsContent>: SettingsContent, SettingsContentIdentityProviding, SettingsContentRowRoleProviding {
    var id: UUID
    let title: String
    let systemImage: String?
    let footer: String?
    var tags: [String]
    let presentation: SettingsGroupPresentation
    let content: Content

    var settingsContentIdentity: AnyHashable? { id }

    var settingsContentRowRole: SettingsContentRowRole {
        presentation == .inline ? .inlineGroup : .navigationGroup
    }

    /// Creates a semantic settings group.
    ///
    /// - Parameters:
    ///   - title: The title used by navigation, styles, and search.
    ///   - presentation: Whether the group navigates or renders inline.
    ///   - footer: Optional explanatory text for the group.
    ///   - content: The controls and nested groups contained by the group.
    public init(
        _ title: String,
        _ presentation: SettingsGroupPresentation = .navigation,
        systemImage: String? = nil,
        footer: String? = nil,
        @SettingsContentBuilder content: () -> Content
    ) {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(presentation)
        hasher.combine(systemImage)
        let hashValue = hasher.finalize()
        self.id = UUID(uuid: uuid_t(
            UInt8((hashValue >> 56) & 0xFF), UInt8((hashValue >> 48) & 0xFF),
            UInt8((hashValue >> 40) & 0xFF), UInt8((hashValue >> 32) & 0xFF),
            UInt8((hashValue >> 24) & 0xFF), UInt8((hashValue >> 16) & 0xFF),
            UInt8((hashValue >> 8) & 0xFF), UInt8(hashValue & 0xFF),
            0, 0, 0, 0, 0, 0, 0, 0
        ))

        self.title = title
        self.systemImage = systemImage
        self.footer = footer
        self.tags = []
        self.presentation = presentation
        self.content = content()
    }

    @Environment(\.settingsGroupStyle) private var groupStyle
    @Environment(\.settingsNodeViewRegistry) private var registry
    @Environment(\.settingsIndexParentID) private var parentID

    /// The representation produced by the active group style.
    public var body: some View {
        let id = SettingsContentScope(registry: registry, parentID: parentID).scopedID(self.id)
        let children = registry.children(for: id)
            ?? content.makeNodes(in: SettingsContentScope(registry: registry, parentID: id))
        let presentedContent: AnyView = switch presentation {
        case .navigation:
            AnyView(
                RegisteredSettingsNodeContent(id: id, registry: registry)
            )
        case .inline:
            AnyView(content.environment(\.settingsIndexParentID, id))
        }

        groupStyle.makeBody(
            configuration: SettingsGroupConfiguration(
                id: id,
                title: title,
                systemImage: systemImage,
                footer: footer,
                presentation: presentation,
                content: presentedContent,
                children: children
            )
        )
    }

    /// Builds metadata using the shared compatibility scope.
    public func makeNodes() -> [SettingsNode] {
        makeNodes(in: .shared)
    }

    /// Builds semantic metadata and registers the group's live destination.
    public func makeNodes(in scope: SettingsContentScope) -> [SettingsNode] {
        let id = scope.scopedID(self.id)
        let children = content.makeNodes(in: SettingsContentScope(registry: scope.registry, parentID: id))
        scope.registry.registerChildren(children, for: id)

        scope.registry.register(id: id) { [content] in
            // Resolve the live SettingsContent value when a search destination
            // mounts instead of caching an eagerly evaluated `body` value.
            AnyView(content.environment(\.settingsIndexParentID, id))
        }

        return [.group(
            id: id,
            title: title,
            systemImage: systemImage,
            tags: tags,
            presentation: presentation,
            children: children
        )]
    }
}

public extension SettingsGroup {
    /// Distinguishes siblings with the same title using a stable model identity.
    func settingsID(_ value: String) -> Self {
        var copy = self
        copy.id = SettingsContentScope.identity(value)
        return copy
    }

    /// Adds alternate search terms to the group.
    func settingsTags(_ tags: [String]) -> Self {
        var copy = self
        copy.tags = tags
        return copy
    }
}
