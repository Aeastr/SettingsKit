import SwiftUI

// MARK: - ForEach + SettingsContent

extension ForEach: SettingsContent where Content: SettingsContent {
    /// Builds metadata for every element using the shared scope.
    ///
    /// - Returns: The flattened nodes produced by each element.
    @MainActor
    public func makeNodes() -> [SettingsNode] {
        makeNodes(in: .shared)
    }

    /// Builds metadata for every element using a host-local scope.
    ///
    /// - Parameter scope: The scope forwarded to each element's content.
    /// - Returns: The flattened nodes produced by each element.
    @MainActor
    public func makeNodes(in scope: SettingsContentScope) -> [SettingsNode] {
        // ForEach can't be iterated at build time in SwiftUI
        // We need to manually iterate the data and call makeNodes on each content
        var nodes: [SettingsNode] = []

        // Use a temporary storage to collect nodes from each iteration
        for element in data {
            let elementContent = content(element)
            nodes.append(contentsOf: elementContent.makeNodes(in: scope))
        }

        return nodes
    }
}
