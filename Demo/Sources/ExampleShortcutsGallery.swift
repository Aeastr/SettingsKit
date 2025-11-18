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
        NavigationStack {
            ShortcutsGallery {
                // Featured shortcuts
                ShortcutSection("Featured", subtitle: "Handpicked shortcuts") {
                    Shortcut(iCloudLink: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f")
                    Shortcut(iCloudLink: "https://www.icloud.com/shortcuts/d598f4dc52d9469f9161b302f1257350")
                    Shortcut(iCloudLink: "https://www.icloud.com/shortcuts/51a9b025884545e7b7a4c9f3d3c86e35")
                }

                ShortcutSection("Productivity") {
                    Shortcut(iCloudLink: "https://www.icloud.com/shortcuts/85cff63584314ae48ad2c7a8bacc1733")
                    Shortcut(iCloudLink: "https://www.icloud.com/shortcuts/19a26fc124ec413788a4a72720e58b6f")
                    Shortcut(iCloudLink: "https://www.icloud.com/shortcuts/005a1482aa654f1cb874fd6443b0593a")
                }

                ShortcutSection("Utilities") {
                    Shortcut(iCloudLink: "https://www.icloud.com/shortcuts/bb87343631e84c2bb1f4dabf46e4aae2")
                    Shortcut(iCloudLink: "https://www.icloud.com/shortcuts/891705370975472b880c72860a05b221")
                    Shortcut(iCloudLink: "https://www.icloud.com/shortcuts/7557e130f1be4ceba01e69e6b065bacf")
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
