import SwiftUI

/// Default rendering for a SettingsGroup - shows as a NavigationLink
public struct SettingsGroupView<Content: SettingsContent>: View {
    let title: String
    let icon: String?
    let content: Content

    public init(title: String, icon: String?, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    public var body: some View {
        NavigationLink {
            List {
                content
            }
            .navigationTitle(title)
        } label: {
            Label(title, systemImage: icon ?? "folder")
        }
    }
}
