import SwiftUI

// MARK: - ForEach + SettingsContent

extension ForEach: SettingsContent where Content: SettingsContent {
    @MainActor
    public func makeNodes() -> [SettingsNode] {
        // ForEach can't be iterated at build time in SwiftUI
        // We need to manually iterate the data and call makeNodes on each content
        var nodes: [SettingsNode] = []

        // Use a temporary storage to collect nodes from each iteration
        for element in data {
            let elementContent = content(element)
            nodes.append(contentsOf: elementContent.makeNodes())
        }

        return nodes
    }
}
