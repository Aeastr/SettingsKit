import SwiftUI

/// Internal representation of the settings tree structure.
/// This is what we use to power search, navigation, and rendering.
public enum SettingsNode: Identifiable, Hashable, @unchecked Sendable {
    case group(
        id: UUID,
        title: String,
        icon: String?,
        tags: [String],
        style: SettingsGroupStyle,
        children: [SettingsNode]
    )
    case item(
        id: UUID,
        title: String,
        icon: String?,
        tags: [String],
        searchable: Bool,
        content: AnyView
    )

    public var id: UUID {
        switch self {
        case .group(let id, _, _, _, _, _):
            return id
        case .item(let id, _, _, _, _, _):
            return id
        }
    }

    public var title: String {
        switch self {
        case .group(_, let title, _, _, _, _):
            return title
        case .item(_, let title, _, _, _, _):
            return title
        }
    }

    public var icon: String? {
        switch self {
        case .group(_, _, let icon, _, _, _):
            return icon
        case .item(_, _, let icon, _, _, _):
            return icon
        }
    }

    public var tags: [String] {
        switch self {
        case .group(_, _, _, let tags, _, _):
            return tags
        case .item(_, _, _, let tags, _, _):
            return tags
        }
    }

    public var isSearchable: Bool {
        switch self {
        case .group:
            return true
        case .item(_, _, _, _, let searchable, _):
            return searchable
        }
    }

    public var children: [SettingsNode]? {
        switch self {
        case .group(_, _, _, _, _, let children):
            return children
        case .item:
            return nil
        }
    }

    public var isGroup: Bool {
        if case .group = self {
            return true
        }
        return false
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: SettingsNode, rhs: SettingsNode) -> Bool {
        lhs.id == rhs.id
    }
}
