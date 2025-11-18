//
//  Shortcut.swift
//  ShortcutsGallery
//
//  Created by Aether on 11/18/25.
//

import SwiftUI

/// Represents an individual shortcut that can be displayed in the gallery
/// Users only provide the iCloud link - all metadata is fetched automatically
public struct Shortcut: Identifiable, Sendable {
    public let id: String
    public let iCloudLink: String

    /// Create a shortcut from an iCloud share link
    /// The shortcut's name, icon, and color will be fetched automatically from Apple's servers
    /// - Parameter iCloudLink: The iCloud share URL (e.g., "https://www.icloud.com/shortcuts/abc123")
    public init(iCloudLink: String) {
        self.iCloudLink = iCloudLink
        self.id = iCloudLink
    }
}
