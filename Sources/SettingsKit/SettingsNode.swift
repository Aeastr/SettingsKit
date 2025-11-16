import SwiftUI

/// Internal representation of the settings tree structure.
/// This is what we use to power search, navigation, and rendering.
public enum SettingsNode: Identifiable {
    case group(
        id: UUID,
        title: String,
        icon: String?,
        tags: [String],
        children: [SettingsNode]
    )
    case item(
        id: UUID,
        title: String,
        icon: String?,
        tags: [String],
        content: AnyView
    )

    public var id: UUID {
        switch self {
        case .group(let id, _, _, _, _):
            return id
        case .item(let id, _, _, _, _):
            return id
        }
    }

    public var title: String {
        switch self {
        case .group(_, let title, _, _, _):
            return title
        case .item(_, let title, _, _, _):
            return title
        }
    }

    public var icon: String? {
        switch self {
        case .group(_, _, let icon, _, _):
            return icon
        case .item(_, _, let icon, _, _):
            return icon
        }
    }

    public var tags: [String] {
        switch self {
        case .group(_, _, _, let tags, _):
            return tags
        case .item(_, _, _, let tags, _):
            return tags
        }
    }

    public var children: [SettingsNode]? {
        switch self {
        case .group(_, _, _, _, let children):
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
}
