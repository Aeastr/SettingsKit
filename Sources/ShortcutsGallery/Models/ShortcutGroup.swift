//
//  ShortcutGroup.swift
//  ShortcutsGallery
//
//  Created by Aether on 11/18/25.
//

import SwiftUI

/// Represents a group of sections that can be displayed as a pinned card
/// When tapped, opens a sheet with the contained sections
public struct ShortcutGroup: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let icon: String?
    public let sections: [ShortcutSection]

    public init(
        id: String? = nil,
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        @ShortcutSectionBuilder sections: () -> [ShortcutSection]
    ) {
        self.id = id ?? title
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.sections = sections()
    }

    public init(
        id: String? = nil,
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        sections: [ShortcutSection]
    ) {
        self.id = id ?? title
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.sections = sections
    }
}
