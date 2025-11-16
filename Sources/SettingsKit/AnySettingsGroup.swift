import SwiftUI

/// Type-erased wrapper for SettingsGroup to enable navigation
@MainActor
public struct AnySettingsGroup: Identifiable, Hashable, View {
    public let id: UUID
    let title: String
    let icon: String?
    private let _body: AnyView

    public init<Content: SettingsContent>(_ group: SettingsGroup<Content>) {
        self.id = group.id
        self.title = group.title
        self.icon = group.icon
        // Store the actual group view, not its content
        // This way the view renders in context and bindings work
        self._body = AnyView(group.content)
    }

    public var body: some View {
        _body
    }

    public func renderBody() -> AnyView {
        _body
    }

    nonisolated public static func == (lhs: AnySettingsGroup, rhs: AnySettingsGroup) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
