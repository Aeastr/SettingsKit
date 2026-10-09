import SwiftUI
import SettingsKit
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A custom shell using `SettingsHost` and `SettingsGroupStyle`; SettingsKit supplies search and live content while the demo owns all visible UI.
struct TabbedCardsSettingsDemo: View {
    @Environment(SettingsState.self) private var settings
    @State private var selectedSection = SettingsDemoTab.general
    @State private var loadedSections: Set<SettingsDemoTab> = [.general]

    var body: some View {
        VStack(spacing: 0) {
            SettingsTabPicker(selection: $selectedSection)
                .padding(.top, 6)
                .padding(.horizontal, 6)
                .padding(.bottom, 8)

            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: CardLayout.windowWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .tint(.accentColor.opacity(0.72))
        .onChange(of: selectedSection) { _, section in
            loadedSections.insert(section)
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        ZStack(alignment: .top) {
            if loadedSections.contains(.general) {
                settingsPage(.general)
                    .id(SettingsDemoTab.general)
                    .persistentSettingsTab(selectedSection == .general)
            }

            if loadedSections.contains(.appearance) {
                settingsPage(.appearance)
                    .id(SettingsDemoTab.appearance)
                    .persistentSettingsTab(selectedSection == .appearance)
            }

            if loadedSections.contains(.automation) {
                settingsPage(.automation)
                    .id(SettingsDemoTab.automation)
                    .persistentSettingsTab(selectedSection == .automation)
            }

            if loadedSections.contains(.search) {
                searchPage
                    .id(SettingsDemoTab.search)
                    .persistentSettingsTab(selectedSection == .search)
            }
        }
    }

    private func settingsPage(_ section: SettingsDemoTab) -> some View {
        SettingsHost(
            container: TabbedSettingsContainer(settings: settings, section: section),
            title: section.rawValue
        ) { context in
            NavigationStack(path: context.navigationPath) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: CardLayout.sectionSpacing) {
                        context.rootContent
                            .id(section)
                    }
                    .settingsGroupStyle(CardGroupStyle())
                    .padding(.top, 8)
                    .padding(.bottom, CardLayout.contentPadding)
                    .padding(.horizontal, CardLayout.contentPadding)
                }
                .scrollIndicators(.hidden)
                .navigationDestination(for: SettingsGroupConfiguration.self) { group in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: CardLayout.sectionSpacing) {
                            group.content
                        }
                        .settingsGroupStyle(CardGroupStyle())
                        .padding(CardLayout.contentPadding)
                    }
                    .scrollIndicators(.hidden)
                    .navigationTitle(group.title)
                }
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
        }
        .settingsSearch(TabbedSettingsSearch())
    }

    private var searchPage: some View {
        SettingsHost(
            container: TabbedSettingsContainer(settings: settings, section: .search),
            title: SettingsDemoTab.search.rawValue
        ) { context in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CardLayout.sectionSpacing) {
                    VStack(spacing: 0) {
                        CardRow {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)

                            TextField("Search settings", text: context.searchText)
                                .textFieldStyle(.roundedBorder)

                            if context.isSearching {
                                Button {
                                    context.searchText.wrappedValue = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Clear Search")
                            }
                        }

                        if !context.isSearching {
                            CardRowDivider()
                            CardRow {
                                Text("Search General, Appearance, and Automation")
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .cardBackground()

                    if context.isSearching {
                        if context.searchResults.isEmpty {
                            ContentUnavailableView.search(text: context.searchText.wrappedValue)
                        } else {
                            ForEach(groupedSearchResults(context.searchResults)) { section in
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(section.title)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 14)

                                    VStack(spacing: 0) {
                                        ForEach(section.entries) { entry in
                                            if let item = entry.item,
                                               let view = context.indexedView(for: item) {
                                                view
                                            } else {
                                                CardRow {
                                                    Text(entry.title)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                            }

                                            if entry.id != section.entries.last?.id {
                                                CardRowDivider()
                                            }
                                        }
                                    }
                                    .cardBackground()
                                }
                            }
                        }
                    }
                }
                .padding(CardLayout.contentPadding)
            }
            .scrollIndicators(.hidden)
        }
        .settingsSearch(TabbedSettingsSearch())
    }

    /// The Bubble-inspired example groups search results by its own tabs. This
    /// categorization is presentation policy and is not supplied by SettingsKit.
    private func groupedSearchResults(_ results: [SettingsSearchResult]) -> [TabbedSearchSection] {
        SettingsDemoTab.contentTabs.compactMap { tab in
            let entries = results
                .filter { tab.containsSearchGroup($0.group.title) }
                .flatMap { result -> [TabbedSearchEntry] in
                    if result.matchedItems.isEmpty {
                        return [TabbedSearchEntry(id: result.group.id, title: result.group.title)]
                    }

                    return result.matchedItems.map {
                        TabbedSearchEntry(id: $0.id, title: $0.title, item: $0)
                    }
                }
                .reduce(into: [TabbedSearchEntry]()) { entries, entry in
                    guard !entries.contains(where: { $0.id == entry.id }) else { return }
                    entries.append(entry)
                }

            guard !entries.isEmpty else { return nil }
            return TabbedSearchSection(tab: tab, entries: entries)
        }
    }
}

private enum CardLayout {
    static let windowWidth: CGFloat = 410
    static let cornerRadius: CGFloat = 26
    static let contentPadding: CGFloat = 16
    static let rowSpacing: CGFloat = 12
    static let sectionSpacing: CGFloat = 16
    static let textEntryWidth: CGFloat = 76
}

private enum CardSystemColor {
    static var cellBackground: Color {
        #if os(macOS)
        Color(nsColor: .controlBackgroundColor).opacity(0.45)
        #elseif canImport(UIKit)
        Color(uiColor: .secondarySystemBackground).opacity(0.72)
        #else
        Color.primary.opacity(0.08)
        #endif
    }

    static var control: Color {
        #if os(macOS)
        Color(nsColor: .controlColor).opacity(0.55)
        #elseif canImport(UIKit)
        Color(uiColor: .tertiarySystemFill)
        #else
        Color.primary.opacity(0.10)
        #endif
    }

    static var separator: Color {
        #if os(macOS)
        Color(nsColor: .separatorColor).opacity(0.4)
        #elseif canImport(UIKit)
        Color(uiColor: .separator).opacity(0.4)
        #else
        Color.secondary.opacity(0.25)
        #endif
    }
}

private enum SettingsDemoTab: String, CaseIterable, Identifiable {
    case general = "General"
    case appearance = "Appearance"
    case automation = "Automation"
    case search = "Search"

    var id: Self { self }

    static let contentTabs: [Self] = [.general, .appearance, .automation]

    func containsSearchGroup(_ title: String) -> Bool {
        switch self {
        case .general:
            ["Application", "Workspace", "Keyboard Shortcuts", "Update Preferences"].contains(title)
        case .appearance:
            title == "Theme"
        case .automation:
            ["Automation", "Workflows", "Schedules"].contains(title)
        case .search:
            false
        }
    }
}

private struct TabbedSearchSection: Identifiable {
    let tab: SettingsDemoTab
    let entries: [TabbedSearchEntry]

    var id: SettingsDemoTab { tab }
    var title: String { tab.rawValue }
}

private struct TabbedSearchEntry: Identifiable {
    let id: UUID
    let title: String
    var item: SettingsNode? = nil
}

private struct TabbedSettingsContainer: SettingsContainer {
    @Bindable var settings: SettingsState
    let section: SettingsDemoTab

    @SettingsContentBuilder
    var settingsBody: some SettingsContent {
        switch section {
        case .general:
            generalSettings
        case .appearance:
            appearanceSettings
        case .automation:
            automationSettings
        case .search:
            generalSettings
            appearanceSettings
            automationSettings
        }
    }

    @SettingsContentBuilder
    private var generalSettings: some SettingsContent {
        SettingsGroup("Application", .inline) {
            CardToggleRow("Launch at login", isOn: $settings.launchAtLogin)
                .indexed("Launch at login", tags: ["startup", "boot", "open"])
            CardRowDivider()
            CardToggleRow("Show notifications", isOn: $settings.showNotifications)
                .indexed("Show notifications", tags: ["alerts", "banners"])
            CardRowDivider()
            CardToggleRow("Check for updates automatically", isOn: $settings.automaticUpdates)
                .indexed("Check for updates automatically", tags: ["software", "version"])
            CardRowDivider()
            CardRow {
                Text("Open new windows with")
                    .frame(maxWidth: .infinity, alignment: .leading)
                CardMenuPicker(
                    selection: $settings.newWindowBehavior,
                    options: ["Home", "Last Workspace", "Blank"]
                )
            }
            .indexed("Open new windows with", tags: ["home", "workspace", "startup"])
        }

        SettingsGroup("Workspace", .inline, footer: "Workspace preferences apply to every new window.") {
            CardToggleRow(
                "Restore open documents",
                systemImage: "doc.on.doc",
                isOn: $settings.restoreDocuments
            )
            .indexed("Restore open documents", tags: ["workspace", "reopen", "files"])

            if settings.restoreDocuments {
                CardRowDivider()
                CardRow {
                    Text("Default workspace")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CardTextField("Workspace", text: $settings.defaultWorkspace, width: 112)
                }
                .indexed("Default workspace", tags: ["folder", "project", "documents"])
                CardRowDivider()
                CardToggleRow("Confirm before closing", isOn: $settings.confirmBeforeClosing)
                    .indexed("Confirm before closing", tags: ["warning", "documents"])
            }
        }

        SettingsGroup("Keyboard Shortcuts", .inline) {
            CardToggleRow(
                "Enable global shortcut",
                systemImage: "command.square",
                isOn: $settings.shortcutsEnabled
            )
            .indexed("Enable global shortcut", tags: ["shortcut", "keyboard"])

            if settings.shortcutsEnabled {
                CardRowDivider()
                CardRow {
                    Text("Shortcut")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CardEntryCapsule(width: 92) {
                        Text("⌘⇧Space")
                    }
                }
                .indexed("Global shortcut", tags: ["command", "shift", "keyboard"])
                CardRowDivider()
                CardRow {
                    Text("Shortcut behavior")
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CardMenuPicker(
                        selection: $settings.shortcutBehavior,
                        options: ["Show Window", "Quick Action", "New Document"]
                    )
                }
                .indexed("Shortcut behavior", tags: ["action", "keyboard"])
            }
        }

        SettingsGroup("Update Preferences") {
            SettingsGroup("Downloads", .inline) {
                CardToggleRow(
                    "Download updates automatically",
                    isOn: $settings.downloadUpdatesAutomatically
                )
                .indexed("Download updates automatically", tags: ["software", "network", "background"])
                CardRowDivider()
                CardToggleRow(
                    "Install updates automatically",
                    isOn: $settings.installUpdatesAutomatically
                )
                .indexed("Install updates automatically", tags: ["software", "restart", "background"])
            }

            SettingsGroup("Release Channel", .inline) {
                CardRow {
                    Text("Update channel")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CardMenuPicker(
                        selection: $settings.updateChannel,
                        options: ["Stable", "Preview"]
                    )
                }
                .indexed("Update channel", tags: ["stable", "preview", "beta", "software"])
            }
        }
        .settingsTags(["software", "updates", "version"])
    }

    @SettingsContentBuilder
    private var appearanceSettings: some SettingsContent {
        SettingsGroup("Theme", .inline) {
            CardRow(horizontalPadding: 7) {
                ThemeSegmentPicker(selection: $settings.interfaceTheme)
            }
            .indexed("Interface theme", tags: ["light", "dark", "system", "appearance"])
            CardRowDivider()
            CardRow {
                Text("Accent color")
                    .frame(maxWidth: .infinity, alignment: .leading)
                CardMenuPicker(
                    selection: $settings.accentColorName,
                    options: ["Blue", "Purple", "Green", "Orange"]
                )
            }
            .indexed("Accent color", tags: ["tint", "theme", "appearance"])
            CardRowDivider()
            CardToggleRow("Use compact spacing", isOn: $settings.compactSpacing)
                .indexed("Use compact spacing", tags: ["density", "layout"])
            CardRowDivider()
            CardRow {
                VStack(spacing: 10) {
                    HStack {
                        Text("Interface scale")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(settings.interfaceScale, format: .percent.precision(.fractionLength(0)))
                            .monospacedDigit()
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(CardSystemColor.control, in: .capsule)
                            .overlay { Capsule().stroke(CardSystemColor.control.opacity(0.4)) }
                    }
                    Slider(value: $settings.interfaceScale, in: 0.8...1.4, step: 0.1)
                }
                .padding(.top, 4)
                .padding(.bottom, 6)
            }
            .indexed("Interface scale", tags: ["text", "size", "appearance"])
        }
    }

    @SettingsContentBuilder
    private var automationSettings: some SettingsContent {
        SettingsGroup("Automation", .inline) {
            CardToggleRow("Enable automations", isOn: $settings.automationsEnabled)
                .indexed("Enable automations", tags: ["workflow", "actions"])
            CardRowDivider()
            CardToggleRow("Run while app is inactive", isOn: $settings.runAutomationsInBackground)
                .indexed("Run while app is inactive", tags: ["background", "workflow"])
            CardRowDivider()
            CardToggleRow("Notify after completion", isOn: $settings.automationNotifications)
                .indexed("Notify after completion", tags: ["alerts", "workflow"])
        }

        SettingsGroup("Workflows", .inline) {
            CardAddButton("Add Workflow", systemImage: "plus.circle.fill")
                .indexed("Add Workflow", tags: ["automation", "action", "task"])
            CardRowDivider()
            CardEmptyStateRow("No workflows configured")
        }

        SettingsGroup("Schedules", .inline) {
            CardAddButton("Add Schedule", systemImage: "plus.circle.fill")
                .indexed("Add Schedule", tags: ["automation", "time", "calendar"])
            CardRowDivider()
            CardEmptyStateRow("No schedules configured")
        }
    }
}

/// A group-only card style that leaves tabs, search, and navigation app-owned.
private struct CardGroupStyle: SettingsGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        switch configuration.presentation {
        case .navigation:
            NavigationLink(value: configuration) {
                CardRow {
                    Text(configuration.title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .cardBackground()
            }
            .buttonStyle(.plain)

        case .inline:
            VStack(alignment: .leading, spacing: 7) {
                VStack(spacing: 0) {
                    configuration.content
                }
                .cardBackground()

                if let footer = configuration.footer {
                    Text(footer)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 14)
                }
            }
        }
    }
}

private struct CardRow<Content: View>: View {
    var horizontalPadding: CGFloat = CardLayout.contentPadding
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: CardLayout.rowSpacing) {
            content
        }
        .font(.system(size: 14))
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, 7)
        .frame(minHeight: 42)
    }
}

private struct CardToggleRow: View {
    let title: String
    let systemImage: String?
    @Binding var isOn: Bool

    init(_ title: String, systemImage: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.systemImage = systemImage
        _isOn = isOn
    }

    var body: some View {
        CardRow {
            Toggle(isOn: $isOn) {
                HStack(spacing: 10) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.tint)
                            .frame(width: 20)
                    }
                    Text(title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .controlSize(.small)
            .toggleStyle(.switch)
        }
    }
}

private struct CardRowDivider: View {
    var body: some View {
        CardSystemColor.separator
            .frame(height: 1)
            .padding(.horizontal, 18)
    }
}

private struct CardEntryCapsule<Content: View>: View {
    let width: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        content
            .lineLimit(1)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(width: width)
            .background(CardSystemColor.control, in: .capsule)
            .overlay { Capsule().stroke(CardSystemColor.control.opacity(0.4)) }
    }
}

private struct CardTextField: View {
    let title: String
    @Binding var text: String
    let width: CGFloat
    @FocusState private var isFocused: Bool

    init(_ title: String, text: Binding<String>, width: CGFloat = CardLayout.textEntryWidth) {
        self.title = title
        _text = text
        self.width = width
    }

    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.center)
            .focused($isFocused)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(width: width)
            .background(CardSystemColor.control, in: .capsule)
            .overlay { Capsule().stroke(CardSystemColor.control.opacity(0.4)) }
            .accessibilityLabel(title)
            .onSubmit { isFocused = false }
    }
}

private struct CardMenuLabel: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .lineLimit(1)
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(4)
                .background(CardSystemColor.control, in: .capsule)
                .overlay { Capsule().stroke(CardSystemColor.control.opacity(0.4)) }
        }
        .font(.system(size: 14))
    }
}

private struct CardMenuPicker<Option: Hashable>: View {
    @Binding var selection: Option
    let options: [Option]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    if option == selection {
                        Label(String(describing: option), systemImage: "checkmark")
                    } else {
                        Text(String(describing: option))
                    }
                }
            }
        } label: {
            CardMenuLabel(String(describing: selection))
        }
        .buttonStyle(.plain)
    }
}

private struct ThemeSegmentPicker: View {
    @Binding var selection: String
    private let themes = ["System", "Light", "Dark"]

    private var picker: some View {
        Picker("", selection: $selection) {
            ForEach(themes, id: \.self) { theme in
                Text(theme).tag(theme)
            }
        }
        .labelsHidden()
    }

    @ViewBuilder
    var body: some View {
        #if os(macOS)
        #if compiler(>=6.4)
        if #available(macOS 27.0, *) {
            picker
                .pickerStyle(.tabs)
                .controlSize(.extraLarge)
                .buttonSizing(.flexible)
        } else if #available(macOS 26.0, *) {
            picker
                .pickerStyle(.segmented)
                .controlSize(.extraLarge)
                .buttonSizing(.flexible)
        } else {
            picker.pickerStyle(.segmented)
        }
        #else
        picker
            .pickerStyle(.segmented)
            .controlSize(.extraLarge)
            .buttonSizing(.flexible)
        #endif
        #else
        picker.pickerStyle(.segmented)
        #endif
    }
}

private struct CardAddButton: View {
    let title: String
    let systemImage: String

    init(_ title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
    }

    var body: some View {
        Button {} label: {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(CardSystemColor.control, in: .capsule)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }
}

private struct CardEmptyStateRow: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        CardRow {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

private struct SettingsTabPicker: View {
    @Binding var selection: SettingsDemoTab

    private var picker: some View {
        Picker("", selection: $selection) {
            ForEach(SettingsDemoTab.allCases) { section in
                Text(section.rawValue).tag(section)
            }
        }
        .labelsHidden()
    }

    @ViewBuilder
    var body: some View {
        #if os(macOS)
        #if compiler(>=6.4)
        if #available(macOS 27.0, *) {
            picker
                .pickerStyle(.tabs)
                .controlSize(.extraLarge)
                .buttonSizing(.flexible)
        } else if #available(macOS 26.0, *) {
            picker
                .pickerStyle(.segmented)
                .controlSize(.extraLarge)
                .buttonSizing(.flexible)
        } else {
            picker.pickerStyle(.segmented)
        }
        #else
        picker
            .pickerStyle(.segmented)
            .controlSize(.extraLarge)
            .buttonSizing(.flexible)
        #endif
        #else
        picker.pickerStyle(.segmented)
        #endif
    }
}

private struct TabbedSettingsSearch: SettingsSearch {
    private let defaultSearch = DefaultSettingsSearch()
    private let aliases = [
        "boot": "launch",
        "keyboard": "shortcut",
        "dense": "compact",
        "background": "inactive"
    ]

    func search(nodes: [SettingsNode], query: String) -> [SettingsSearchResult] {
        let directResults = defaultSearch.search(nodes: nodes, query: query)
        guard directResults.isEmpty, let alias = aliases[query.lowercased()] else {
            return directResults
        }
        return defaultSearch.search(nodes: nodes, query: alias)
    }
}

private extension View {
    func cardBackground() -> some View {
        background(CardSystemColor.cellBackground, in: .rect(cornerRadius: CardLayout.cornerRadius))
    }

    func persistentSettingsTab(_ isSelected: Bool) -> some View {
        opacity(isSelected ? 1 : 0)
            .allowsHitTesting(isSelected)
            .accessibilityHidden(!isSelected)
            .zIndex(isSelected ? 1 : 0)
    }
}

#Preview {
    TabbedCardsSettingsDemo()
        .environment(SettingsState())
        .frame(width: 422, height: 725)
}
