//
//  ShortcutsGalleryContentBuilder.swift
//  ShortcutsGallery
//
//  Created by Aether on 11/18/25.
//

import SwiftUI

/// Result builder for creating gallery content (groups and sections)
@resultBuilder
public struct ShortcutsGalleryContentBuilder {
    public static func buildBlock(_ components: [ShortcutsGalleryContent]...) -> [ShortcutsGalleryContent] {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[ShortcutsGalleryContent]]) -> [ShortcutsGalleryContent] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [ShortcutsGalleryContent]?) -> [ShortcutsGalleryContent] {
        component ?? []
    }

    public static func buildEither(first component: [ShortcutsGalleryContent]) -> [ShortcutsGalleryContent] {
        component
    }

    public static func buildEither(second component: [ShortcutsGalleryContent]) -> [ShortcutsGalleryContent] {
        component
    }

    public static func buildExpression(_ expression: ShortcutGroup) -> [ShortcutsGalleryContent] {
        [.group(expression)]
    }

    public static func buildExpression(_ expression: ShortcutSection) -> [ShortcutsGalleryContent] {
        [.section(expression)]
    }

    public static func buildExpression(_ expression: [ShortcutsGalleryContent]) -> [ShortcutsGalleryContent] {
        expression
    }
}

/// Enum representing content that can appear in a shortcuts gallery
public enum ShortcutsGalleryContent {
    case group(ShortcutGroup)
    case section(ShortcutSection)
}
