//
//  ExampleShortcutsGallery.swift
//  SettingsKitDemo
//
//  Created by Aether on 11/18/25.
//

import SwiftUI
import ShortcutsGallery

struct ExampleShortcutsGallery: View {
    var body: some View {
        NavigationView {
            ShortcutsGallery {
                // Pinned groups at the top
                ShortcutGroup(
                    "Shortcuts for Accessibility",
                    subtitle: "Tools to help your accessibility journey",
                    icon: "accessibility"
                ) {
                    ShortcutSection("Access Tools", subtitle: "Easy Tools to Help Your Accessibility Journey") {
                        Shortcut(name: "Red", iCloudLink: "https://www.icloud.com/shortcuts/162c114586f948cba928d8b8656cd6c3", iconColor: 4282601983, iconGlyph: 0)
                        Shortcut(name: "Blue", iCloudLink: "https://www.icloud.com/shortcuts/74d08bf1b58c454b858fa24b29ca6178", iconColor: 463140863, iconGlyph: 0)
                        Shortcut(name: "Green", iCloudLink: "https://www.icloud.com/shortcuts/521e21925f544ee6a537d5255f797ff8", iconColor: 4292093695, iconGlyph: 0)
                    }

                    ShortcutSection("Wellbeing") {
                        Shortcut(name: "Yellow", iCloudLink: "https://www.icloud.com/shortcuts/d2f0cbb13f03424eb72d62d77c94b455", iconColor: 4274264319, iconGlyph: 0)
                        Shortcut(name: "Purple", iCloudLink: "https://www.icloud.com/shortcuts/a528f1d54b2e4f3d895b043ed4edf4fb", iconColor: 2071128575, iconGlyph: 0)
                    }

                    ShortcutSection("Quick Access") {
                        Shortcut(name: "Pink", iCloudLink: "https://www.icloud.com/shortcuts/fabd5267f343499297c548b5444ae954", iconColor: 3980825855, iconGlyph: 0)
                    }
                }

                ShortcutGroup(
                    "Fun and Games with Siri",
                    subtitle: "Entertainment and playful shortcuts",
                    icon: "gamecontroller"
                ) {
                    ShortcutSection("Games") {
                        Shortcut(name: "Teal", iCloudLink: "https://www.icloud.com/shortcuts/33ce1284615b475bb8e8e03a55eb73d0", iconColor: 431817727, iconGlyph: 0)
                        Shortcut(name: "Orange", iCloudLink: "https://www.icloud.com/shortcuts/06714b9479944f51b0dcf4fe28f4efa2", iconColor: 4251333119, iconGlyph: 0)
                    }

                    ShortcutSection("Entertainment") {
                        Shortcut(name: "Magenta", iCloudLink: "https://www.icloud.com/shortcuts/dc7315a2bbde45008b489626b045aac0", iconColor: 3679049983, iconGlyph: 0)
                    }
                }

                // Regular sections below
                ShortcutSection("Essentials", subtitle: "Shortcuts everyone should have in their toolbox") {
                    Shortcut(name: "Light Blue", iCloudLink: "https://www.icloud.com/shortcuts/beea95ffb8a44b5e93d2b0e5f10b2669", iconColor: 1440408063, iconGlyph: 0)
                    Shortcut(name: "Deep Blue", iCloudLink: "https://www.icloud.com/shortcuts/e82f980435534e828430583b14c1ead2", iconColor: 946986751, iconGlyph: 0)
                    Shortcut(name: "Gray", iCloudLink: "https://www.icloud.com/shortcuts/a46df30ceaea44c6b0ce26451c635221", iconColor: 255, iconGlyph: 0)
                    Shortcut(name: "Brown", iCloudLink: "https://www.icloud.com/shortcuts/02ead42f3c1a4d45ad07f36e65cdce98", iconColor: 1448498689, iconGlyph: 0)
                }

                ShortcutSection("Get Stuff Done") {
                    Shortcut(name: "Orange-Yellow", iCloudLink: "https://www.icloud.com/shortcuts/b8ac685625e04cac8cece16cfd9459fd", iconColor: 4271458815, iconGlyph: 0)
                    Shortcut(name: "Green-Gray", iCloudLink: "https://www.icloud.com/shortcuts/c4617cbf1a1f4908a0031540b1e71516", iconColor: 3031607807, iconGlyph: 0)
                }

                ShortcutSection("Quick Shortcuts", subtitle: "Fast actions for everyday tasks") {
                    Shortcut(name: "Red", iCloudLink: "https://www.icloud.com/shortcuts/162c114586f948cba928d8b8656cd6c3", iconColor: 4282601983, iconGlyph: 0)
                    Shortcut(name: "Blue", iCloudLink: "https://www.icloud.com/shortcuts/74d08bf1b58c454b858fa24b29ca6178", iconColor: 463140863, iconGlyph: 0)
                }
            }
            .shortcutsGalleryStyle(.default)
            .navigationTitle("Shortcuts")
        }
    }
}

#Preview {
    ExampleShortcutsGallery()
}
