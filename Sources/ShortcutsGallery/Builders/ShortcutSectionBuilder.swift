//
//  ShortcutSectionBuilder.swift
//  ShortcutsGallery
//
//  Created by Aether on 11/18/25.
//

import SwiftUI

/// Result builder for creating arrays of ShortcutSections
@resultBuilder
public struct ShortcutSectionBuilder {
    public static func buildBlock(_ components: [ShortcutSection]...) -> [ShortcutSection] {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[ShortcutSection]]) -> [ShortcutSection] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [ShortcutSection]?) -> [ShortcutSection] {
        component ?? []
    }

    public static func buildEither(first component: [ShortcutSection]) -> [ShortcutSection] {
        component
    }

    public static func buildEither(second component: [ShortcutSection]) -> [ShortcutSection] {
        component
    }

    public static func buildExpression(_ expression: ShortcutSection) -> [ShortcutSection] {
        [expression]
    }

    public static func buildExpression(_ expression: [ShortcutSection]) -> [ShortcutSection] {
        expression
    }
}
