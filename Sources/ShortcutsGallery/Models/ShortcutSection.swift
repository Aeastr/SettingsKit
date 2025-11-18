//
//  ShortcutSection.swift
//  ShortcutsGallery
//
//  Created by Aether on 11/18/25.
//

import SwiftUI

/// Represents a section of shortcuts with a title, optional subtitle, and list of shortcuts
public struct ShortcutSection: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let shortcuts: [Shortcut]

    public init(
        id: String? = nil,
        _ title: String,
        subtitle: String? = nil,
        @ShortcutBuilder shortcuts: () -> [Shortcut]
    ) {
        self.id = id ?? title
        self.title = title
        self.subtitle = subtitle
        self.shortcuts = shortcuts()
    }

    public init(
        id: String? = nil,
        _ title: String,
        subtitle: String? = nil,
        shortcuts: [Shortcut]
    ) {
        self.id = id ?? title
        self.title = title
        self.subtitle = subtitle
        self.shortcuts = shortcuts
    }
}
