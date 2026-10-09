import SwiftUI

/// Semantic metadata for a group or indexed item in a settings hierarchy.
///
/// Nodes contain no SwiftUI views or presentation decoration. A ``SettingsContentScope`` associates identifiers with live content while a host builds the hierarchy.
public enum SettingsNode: Identifiable, Hashable, @unchecked Sendable {
    /// A group in the settings hierarchy.
    case group(
        id: UUID,
        title: String,
        systemImage: String? = nil,
        tags: [String],
        presentation: SettingsGroupPresentation,
        children: [SettingsNode],
        searchable: Bool = true
    )

    /// An individually indexed settings control.
    case item(
        id: UUID,
        title: String,
        tags: [String],
        searchable: Bool
    )

    /// The identity used for lookup, navigation, and SwiftUI diffing.
    public var id: UUID {
        switch self {
        case .group(let id, _, _, _, _, _, _), .item(let id, _, _, _): id
        }
    }

    /// The semantic title used by navigation and search.
    public var title: String {
        switch self {
        case .group(_, let title, _, _, _, _, _), .item(_, let title, _, _): title
        }
    }

    /// The SF Symbol associated with a group, if any.
    public var systemImage: String? {
        guard case .group(_, _, let systemImage, _, _, _, _) = self else { return nil }
        return systemImage
    }

    /// Additional search keywords.
    public var tags: [String] {
        switch self {
        case .group(_, _, _, let tags, _, _, _), .item(_, _, let tags, _): tags
        }
    }

    /// The group's presentation mode, or `nil` for an item.
    public var presentation: SettingsGroupPresentation? {
        guard case .group(_, _, _, _, let presentation, _, _) = self else { return nil }
        return presentation
    }

    /// Whether the node can contribute a search result.
    public var isSearchable: Bool {
        switch self {
        case .group(_, _, _, _, let presentation, _, let searchable): searchable && presentation == .navigation
        case .item(_, _, _, let searchable): searchable
        }
    }

    /// Whether search may inspect this node. Unlike `isSearchable`, this also
    /// includes inline sections whose titles can match their child controls.
    /// Custom search implementations should skip excluded nodes and their children.
    public var isIncludedInSearch: Bool {
        switch self {
        case .group(_, _, _, _, _, _, let searchable), .item(_, _, _, let searchable): searchable
        }
    }

    /// Nested nodes for a group, or `nil` for an item.
    public var children: [SettingsNode]? {
        guard case .group(_, _, _, _, _, let children, _) = self else { return nil }
        return children
    }

    /// Whether this node represents a group.
    public var isGroup: Bool {
        if case .group = self { return true }
        return false
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: SettingsNode, rhs: SettingsNode) -> Bool {
        lhs.id == rhs.id
    }

    /// Resolves a group with the shared compatibility registry.
    @MainActor
    public func asGroupConfiguration() -> SettingsGroupConfiguration {
        asGroupConfiguration(registry: .shared)
    }

    @MainActor
    func asGroupConfiguration(registry: SettingsNodeViewRegistry) -> SettingsGroupConfiguration {
        guard case .group(let id, let title, let systemImage, _, let presentation, let children, _) = self else {
            fatalError("asGroupConfiguration() can only be called on group nodes")
        }

        return SettingsGroupConfiguration(
            id: id,
            title: title,
            systemImage: systemImage,
            footer: nil,
            presentation: presentation,
            content: AnyView(
                RegisteredSettingsNodeContent(id: id, registry: registry)
            ),
            children: children
        )
    }
}

/// Resolves registry-backed destination content only after SwiftUI installs the destination in its navigation hierarchy.
///
/// In particular, macOS `NavigationSplitView` can cache an `AnyView` resolved while its link is still in the sidebar. Keeping the lookup in a concrete destination view preserves the control's live observation and binding behavior when the destination becomes active.
struct RegisteredSettingsNodeContent: View {
    let id: UUID
    let registry: SettingsNodeViewRegistry

    @ViewBuilder
    var body: some View {
        if let content = registry.view(for: id) {
            content
        } else {
            Text("Content not available")
                .foregroundStyle(.secondary)
        }
    }
}
