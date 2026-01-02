import SwiftUI
import SettingsKit

// MARK: - Stress Test Settings

@Observable
class StressTestSettings {
    var items: [StressTestItem] = (0..<1000).map { StressTestItem(index: $0) }
}

struct StressTestItem: Identifiable {
    let id = UUID()
    let index: Int
    var isEnabled = false
    var value = 50.0
}

// MARK: - Stress Test Container

struct StressTestSettingsContainer: SettingsContainer {
    @Bindable var settings: StressTestSettings

    var settingsBody: some SettingsContent {
        // Test 1: 100 groups with 10 items each
        ForEach(0..<100, id: \.self) { groupIndex in
            SettingsGroup("Group \(groupIndex)", systemImage: "folder") {
                ForEach(0..<10, id: \.self) { itemIndex in
                    let globalIndex = groupIndex * 10 + itemIndex
                    Toggle("Enable \(globalIndex)", isOn: $settings.items[globalIndex].isEnabled)
                        .settingsTags(["setting", "toggle"])
                }
            }
        }

        // Test 2: Single group with 1000 items inline
        SettingsGroup("Massive Group", systemImage: "square.stack.3d.up") {
            ForEach(settings.items) { item in
                Toggle("Toggle \(item.index)", isOn: $settings.items[item.index].isEnabled)
                Slider(value: $settings.items[item.index].value, in: 0...100)
            }
        }
        .settingsTags(["massive"])

        // Test 3: Nested groups (10 levels deep, 10 items per level)
        SettingsGroup("Deep Nesting Test", systemImage: "arrow.down.circle") {
            DeepNestedGroup(level: 0, maxLevel: 10, settings: settings)
        }

        // Test 4: Mixed inline and navigation groups
        ForEach(0..<20, id: \.self) { groupIndex in
            SettingsGroup("Mixed Group \(groupIndex)", groupIndex.isMultiple(of: 2) ? .inline : .navigation, systemImage: "circle") {
                ForEach(0..<10, id: \.self) { itemIndex in
                    let globalIndex = (groupIndex + 100) * 10 + itemIndex
                    if globalIndex < 1000 {
                        Toggle("Enable \(globalIndex)", isOn: $settings.items[globalIndex].isEnabled)
                    }
                }
            }
        }
    }
}

// MARK: - Deep Nested Helper

struct DeepNestedGroup: SettingsContent {
    let level: Int
    let maxLevel: Int
    @Bindable var settings: StressTestSettings

    var body: some SettingsContent {
        SettingsGroup("Level \(level)", systemImage: "chevron.right") {
            ForEach(0..<10, id: \.self) { itemIndex in
                let globalIndex = level * 10 + itemIndex
                if globalIndex < 1000 {
                    Toggle("Enable L\(level)-\(itemIndex)", isOn: $settings.items[globalIndex].isEnabled)
                        .settingsTags(["nested", "deep"])
                }
            }

            // Recurse to next level
            if level + 1 < maxLevel {
                DeepNestedGroup(level: level + 1, maxLevel: maxLevel, settings: settings)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StressTestSettingsContainer(settings: StressTestSettings())
        .settingsStyle(.sidebar)
}
