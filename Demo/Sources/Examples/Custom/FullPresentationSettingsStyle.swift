import SwiftUI
import SettingsKit

/// A complete custom presentation built through `SettingsStyle`.
///
/// The style owns navigation, scrolling, search placement, destination layout, and group presentation. Individual controls remain ordinary SwiftUI views and inherit the tint and control size applied by the container.
struct FullPresentationSettingsStyle: SettingsStyle {
    func makeContainer(configuration: ContainerConfiguration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            Group {
                if let searchText = configuration.searchText {
                    rootContent(configuration)
                        .searchable(text: searchText, prompt: "Search the spectrum")
                } else {
                    rootContent(configuration)
                }
            }
            .navigationTitle(configuration.title)
            .navigationDestination(for: SettingsGroupConfiguration.self) { group in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        group.content
                    }
                    .padding(20)
                }
                .navigationTitle(group.title)
                .background(presentationBackground)
            }
        }
        .tint(.indigo)
        .controlSize(.large)
    }

    @ViewBuilder
    func makeGroup(configuration: GroupConfiguration) -> some View {
        switch configuration.presentation {
        case .navigation:
            NavigationLink(value: configuration) {
                HStack(spacing: 12) {
                    configuration.label
                        .font(.headline)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
                .padding(18)
                .fullStyleCard()
            }
            .buttonStyle(.plain)

        case .inline:
            VStack(alignment: .leading, spacing: 12) {
                configuration.label
                    .font(.headline)
                    .foregroundStyle(.indigo)

                VStack(spacing: 12) {
                    configuration.content
                }

                if let footer = configuration.footer {
                    Text(footer)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(18)
            .fullStyleCard()
        }
    }

    private func rootContent(_ configuration: ContainerConfiguration) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                configuration.content
            }
            .padding(20)
        }
        .background(presentationBackground)
    }

    private var presentationBackground: some View {
        LinearGradient(
            colors: [
                Color.indigo.opacity(0.14),
                Color.cyan.opacity(0.08),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private extension View {
    func fullStyleCard() -> some View {
        background(.regularMaterial, in: .rect(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.indigo.opacity(0.4), .cyan.opacity(0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
    }
}
