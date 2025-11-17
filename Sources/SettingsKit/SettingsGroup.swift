import SwiftUI

// MARK: - Presentation

/// The presentation mode for a settings group.
public enum SettingsGroupPresentation: Sendable {
    /// Display the group as a navigation link that navigates to a detail view.
    case navigation

    /// Display the group inline as a section.
    case inline
}

// MARK: - Group

/// A group of settings that can contain both items and nested groups.
public struct SettingsGroup<Content: SettingsContent>: SettingsContent {
    let id: UUID
    let title: String
    let icon: String?
    let footer: String?
    var tags: [String]
    let presentation: SettingsGroupPresentation
    let content: Content

    public init(
        _ title: String,
        _ presentation: SettingsGroupPresentation = .navigation,
        systemImage: String? = nil,
        footer: String? = nil,
        @SettingsContentBuilder content: () -> Content
    ) {
        self.id = UUID()
        self.title = title
        self.icon = systemImage
        self.footer = footer
        self.tags = []
        self.presentation = presentation
        self.content = content()
    }

    @Environment(\.settingsStyle) private var style

    public var body: some View {
        style.makeGroup(
            configuration: SettingsGroupConfiguration(
                title: title,
                icon: icon,
                footer: footer,
                presentation: presentation,
                content: AnyView(content)
            )
        )
    }

    public func makeNodes() -> [SettingsNode] {
        let children = content.makeNodes()

        return [.group(
            id: id,
            title: title,
            icon: icon,
            tags: tags,
            presentation: presentation,
            children: children
        )]
    }
}

// MARK: - Modifiers

public extension SettingsGroup {
    /// Adds tags to the settings group for improved searchability.
    func settingsTags(_ tags: [String]) -> Self {
        var copy = self
        copy.tags = tags
        return copy
    }
}
