//
//  DefaultShortcutsGalleryStyle.swift
//  ShortcutsGallery
//
//  Created by Aether on 11/18/25.
//

import SwiftUI

/// The default shortcuts gallery style that mimics Apple's Shortcuts app
public struct DefaultShortcutsGalleryStyle: ShortcutsGalleryStyle {
    public init() {}

    public func makeBody(configuration: ShortcutsGalleryStyleConfiguration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Pinned groups at the top
                if !configuration.groups.isEmpty {
                    pinnedGroupsSection(configuration.groups)
                }

                // Regular sections
                ForEach(configuration.sections) { section in
                    sectionView(section)
                }
            }
            .padding()
        }
        .searchable(text: configuration.$searchText, prompt: "Search Shortcuts")
    }

    @ViewBuilder
    private func pinnedGroupsSection(_ groups: [ShortcutGroup]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(groups) { group in
                GroupCardView(group: group)
            }
        }
    }

    @ViewBuilder
    private func sectionView(_ section: ShortcutSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    if let subtitle = section.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button("See All") {}
                    .font(.subheadline)
            }

            // Horizontal scrolling shortcuts
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(section.shortcuts) { shortcut in
                        ShortcutCardView(shortcut: shortcut)
                            .frame(width: 150)
                    }
                }
            }
        }
    }
}

// MARK: - Group Card View

private struct GroupCardView: View {
    let group: ShortcutGroup
    @State private var showingSheet = false

    var body: some View {
        Button {
            showingSheet = true
        } label: {
            HStack {
                if let icon = group.icon {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(group.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if let subtitle = group.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(white: 0.95))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showingSheet) {
            NavigationStack {
                GroupDetailView(group: group)
            }
        }
    }
}

// MARK: - Group Detail View

private struct GroupDetailView: View {
    let group: ShortcutGroup
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(group.sections) { section in
                    sectionView(section)
                }
            }
            .padding()
        }
        .navigationTitle(group.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    @ViewBuilder
    private func sectionView(_ section: ShortcutSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    if let subtitle = section.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button("See All") {}
                    .font(.subheadline)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(section.shortcuts) { shortcut in
                        ShortcutCardView(shortcut: shortcut)
                            .frame(width: 150)
                    }
                }
            }
        }
    }
}
