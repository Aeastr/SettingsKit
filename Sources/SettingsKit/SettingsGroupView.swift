import SwiftUI

/// Default rendering for a SettingsGroup - shows as a NavigationLink
public struct SettingsGroupView<Group: SettingsGroup>: View {
    let title: String
    let icon: String?
    let group: Group

    public init(title: String, icon: String?, group: Group) {
        self.title = title
        self.icon = icon
        self.group = group
    }

    public var body: some View {
        NavigationLink {
            List {
                group.settingsBody
            }
            .navigationTitle(title)
        } label: {
            Label(title, systemImage: icon ?? "folder")
        }
    }
}

/// Rendering for inline SettingsGroup - shows as a Section
struct InlineGroupView<Group: SettingsGroup>: View {
    let group: Group
    let footer: String?

    var body: some View {
        Section {
            group.settingsBody
        } footer: {
            if let footer = footer {
                Text(footer)
            }
        }
    }
}
