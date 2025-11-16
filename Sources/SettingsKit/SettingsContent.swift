import SwiftUI

/// Protocol representing any content that can appear in a settings hierarchy.
/// This includes both groups and individual items.
/// Conforms to View so SwiftUI properly installs @State and other property wrappers.
public protocol SettingsContent: View, Sendable {
    /// Convert this content into the internal node representation
    func makeNodes() -> [SettingsNode]
}

/// A container for settings content, typically the root-level settings view.
public protocol SettingsContainer {
    associatedtype Body: SettingsContent

    @SettingsContentBuilder
    var body: Body { get }
}

/// Display style for a settings group
public enum SettingsGroupStyle {
    /// Shows as a NavigationLink that pushes to a new page
    case navigation
    /// Renders content inline as a Sectionf
    case inline
}

/// A group of settings that can contain both items and nested groups.
public protocol SettingsGroup: SettingsContent {
    associatedtype SettingsBody: SettingsContent

    /// The display title for this group
    var title: String { get }

    /// Optional SF Symbol icon name
    var icon: String? { get }

    /// Optional search tags for discoverability
    var tags: [String] { get }

    /// Display style - navigation (default) or inline
    var style: SettingsGroupStyle { get }

    /// Optional footer text (only shown for inline style)
    var footer: String? { get }

    @SettingsContentBuilder
    var settingsBody: SettingsBody { get }
}

// Default implementations
public extension SettingsGroup {
    var icon: String? { nil }
    var tags: [String] { [] }
    var style: SettingsGroupStyle { .navigation }
    var footer: String? { nil }

    // Implement View.body based on style
    var body: some View {
        Group {
            switch style {
            case .navigation:
                SettingsGroupView(title: title, icon: icon) {
                    settingsBody
                }
            case .inline:
                Section {
                    settingsBody
                } footer: {
                    if let footer = footer {
                        Text(footer)
                    }
                }
            }
        }
    }

    func makeNodes() -> [SettingsNode] {
        return [.group(
            id: UUID(),
            title: title,
            icon: icon,
            tags: tags,
            isInline: style == .inline,
            children: settingsBody.makeNodes()
        )]
    }
}

