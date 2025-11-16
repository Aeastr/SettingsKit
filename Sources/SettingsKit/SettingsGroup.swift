import SwiftUI

/// A group of settings that can contain both items and nested groups.
public struct SettingsGroup<Content: SettingsContent>: SettingsContent {
    let id: UUID
    let title: String
    let icon: String?
    let footer: String?
    var tags: [String]
    let content: Content
    var style: AnySettingsGroupStyle?

    public init(
        _ title: String,
        systemImage: String? = nil,
        footer: String? = nil,
        @SettingsContentBuilder content: () -> Content
    ) {
        self.id = UUID()
        self.title = title
        self.icon = systemImage
        self.footer = footer
        self.tags = []
        self.content = content()
        self.style = nil
    }

    public var body: some View {
        StyledSettingsGroup(
            title: title,
            icon: icon,
            footer: footer,
            content: content,
            style: style
        )
    }

    public func makeNodes() -> [SettingsNode] {
        let children = content.makeNodes()

        return [.group(
            id: id,
            title: title,
            icon: icon,
            tags: tags,
            children: children
        )]
    }
}

// MARK: - Styled Group View

/// Internal view that applies the current group style from the environment.
struct StyledSettingsGroup<Content: SettingsContent>: View {
    let title: String
    let icon: String?
    let footer: String?
    let content: Content
    let style: AnySettingsGroupStyle?

    @Environment(\.settingsGroupStyle) private var envStyle

    var body: some View {
        let effectiveStyle = style ?? envStyle
        effectiveStyle.makeBody(
            configuration: SettingsGroupStyleConfiguration(
                title: title,
                icon: icon,
                footer: footer,
                content: AnyView(content)
            )
        )
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

    /// Sets the style for this specific settings group.
    ///
    /// This is different from the View modifier `.settingsGroupStyle()` which
    /// affects all groups in the view hierarchy. This method only affects
    /// this specific group.
    func settingsGroupStyle<S: SettingsGroupStyle>(_ style: S) -> Self {
        var copy = self
        copy.style = AnySettingsGroupStyle(style)
        return copy
    }
}
