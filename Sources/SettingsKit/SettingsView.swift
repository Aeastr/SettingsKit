import SwiftUI

/// Main view for rendering a settings container.
/// This will eventually support different styles via the environment.
public struct SettingsView<Container: SettingsContainer>: View {
    let container: Container

    public init(_ container: Container) {
        self.container = container
    }

    public var body: some View {
        List {
            container.body
        }
    }
}

/// Internal view for rendering a single node (group or item)
struct NodeView: View {
    let node: SettingsNode

    var body: some View {
        switch node {
        case .group(_, let title, let icon, _, let children):
            // For groups, create a navigation link to a list of children
            NavigationLink {
                List {
                    ForEach(children) { child in
                        NodeView(node: child)
                    }
                }
                .navigationTitle(title)
            } label: {
                Label(title, systemImage: icon ?? "folder")
            }

        case .item(_, let title, let icon, _, let content):
            // For items, show the title/icon and render the user's view
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                }
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
