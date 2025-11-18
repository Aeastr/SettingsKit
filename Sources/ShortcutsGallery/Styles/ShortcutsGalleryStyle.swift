//
//  ShortcutsGalleryStyle.swift
//  ShortcutsGallery
//
//  Created by Aether on 11/18/25.
//

import SwiftUI

/// Protocol for defining the visual style of a shortcuts gallery
public protocol ShortcutsGalleryStyle {
    associatedtype Body: View

    /// Creates the view for the gallery with the given configuration
    @ViewBuilder
    func makeBody(configuration: ShortcutsGalleryStyleConfiguration) -> Body
}

/// Configuration passed to gallery styles
public struct ShortcutsGalleryStyleConfiguration {
    /// The pinned groups displayed at the top of the gallery
    public let groups: [ShortcutGroup]

    /// The sections displayed below the groups
    public let sections: [ShortcutSection]

    /// The current search text
    @Binding public var searchText: String

    public init(
        groups: [ShortcutGroup],
        sections: [ShortcutSection],
        searchText: Binding<String>
    ) {
        self.groups = groups
        self.sections = sections
        self._searchText = searchText
    }
}

/// Extension to provide static style instances
extension ShortcutsGalleryStyle where Self == DefaultShortcutsGalleryStyle {
    public static var `default`: DefaultShortcutsGalleryStyle {
        DefaultShortcutsGalleryStyle()
    }
}
