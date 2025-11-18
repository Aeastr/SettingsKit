//
//  ShortcutsGallery.swift
//  ShortcutsGallery
//
//  Created by Aether on 11/18/25.
//

import SwiftUI

/// The main view for displaying a shortcuts gallery with groups and sections
public struct ShortcutsGallery: View {
    private let groups: [ShortcutGroup]
    private let sections: [ShortcutSection]
    @State private var searchText = ""
    @Environment(\.shortcutsGalleryStyle) private var style

    public init(
        @ShortcutsGalleryContentBuilder content: () -> [ShortcutsGalleryContent]
    ) {
        let items = content()
        self.groups = items.compactMap {
            if case .group(let group) = $0 { return group }
            return nil
        }
        self.sections = items.compactMap {
            if case .section(let section) = $0 { return section }
            return nil
        }
    }

    public var body: some View {
        let configuration = ShortcutsGalleryStyleConfiguration(
            groups: groups,
            sections: sections,
            searchText: $searchText
        )
        AnyView(style.makeBody(configuration: configuration))
    }
}

// MARK: - Environment Key for Style

private struct ShortcutsGalleryStyleKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: any ShortcutsGalleryStyle = DefaultShortcutsGalleryStyle()
}

extension EnvironmentValues {
    var shortcutsGalleryStyle: any ShortcutsGalleryStyle {
        get { self[ShortcutsGalleryStyleKey.self] }
        set { self[ShortcutsGalleryStyleKey.self] = newValue }
    }
}

// MARK: - Style Modifier

extension ShortcutsGallery {
    public func shortcutsGalleryStyle(_ style: some ShortcutsGalleryStyle) -> some View {
        environment(\.shortcutsGalleryStyle, style)
    }
}
