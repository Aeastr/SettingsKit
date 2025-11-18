//
//  Shortcut.swift
//  ShortcutsGallery
//
//  Created by Aether on 11/18/25.
//

import SwiftUI

/// Represents an individual shortcut that can be displayed in the gallery
public struct Shortcut: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let iCloudLink: String
    public let iconColor: Int64
    public let iconGlyph: Int64
    public let iconURL: String?

    public init(
        id: String? = nil,
        name: String,
        iCloudLink: String,
        iconColor: Int64,
        iconGlyph: Int64,
        iconURL: String? = nil
    ) {
        self.id = id ?? iCloudLink
        self.name = name
        self.iCloudLink = iCloudLink
        self.iconColor = iconColor
        self.iconGlyph = iconGlyph
        self.iconURL = iconURL
    }

    /// Convenience initializer for when metadata will be fetched from iCloud
    public init(iCloudLink: String) {
        self.id = iCloudLink
        self.name = ""
        self.iCloudLink = iCloudLink
        self.iconColor = 0
        self.iconGlyph = 0
        self.iconURL = nil
    }
}
