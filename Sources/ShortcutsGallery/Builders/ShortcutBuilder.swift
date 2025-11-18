//
//  ShortcutBuilder.swift
//  ShortcutsGallery
//
//  Created by Aether on 11/18/25.
//

import SwiftUI

/// Result builder for creating arrays of Shortcuts
@resultBuilder
public struct ShortcutBuilder {
    public static func buildBlock(_ components: Shortcut...) -> [Shortcut] {
        components
    }

    public static func buildArray(_ components: [[Shortcut]]) -> [Shortcut] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [Shortcut]?) -> [Shortcut] {
        component ?? []
    }

    public static func buildEither(first component: [Shortcut]) -> [Shortcut] {
        component
    }

    public static func buildEither(second component: [Shortcut]) -> [Shortcut] {
        component
    }

    public static func buildExpression(_ expression: Shortcut) -> [Shortcut] {
        [expression]
    }

    public static func buildExpression(_ expression: [Shortcut]) -> [Shortcut] {
        expression
    }
}
