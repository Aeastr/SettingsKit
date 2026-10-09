import SwiftUI

public extension View {
    /// Marks this row as the current settings page's introduction.
    ///
    /// On iOS 18 and later, built-in destination pages hide their visual title
    /// while the row is visible and gently reveal it after the row scrolls out.
    /// The row's layout and search metadata are unchanged. Use one introductory
    /// row per page, declared directly in SettingsContent (or an inline group).
    /// Pages without a marked row retain their normal navigation title.
    func settingsIntroduction() -> some SettingsContent {
        SettingsIntroductionContent(content: self)
    }
}

private struct SettingsIntroductionContent<Content: View>: SettingsContent,
    SettingsContentIdentityProviding, SettingsContentRowRoleProviding {
    let content: Content
    @Environment(\.settingsIntroductionVisibility) private var visibility

    var settingsContentIdentity: AnyHashable? {
        (content as? any SettingsContentIdentityProviding)?.settingsContentIdentity
    }

    var settingsContentRowRole: SettingsContentRowRole {
        (content as? any SettingsContentRowRoleProviding)?.settingsContentRowRole ?? .content
    }

    @ViewBuilder
    var body: some View {
        #if os(iOS)
        if #available(iOS 18.0, *) {
            content.onScrollVisibilityChange(threshold: 0.01) { isVisible in
                visibility?.wrappedValue = isVisible
            }
        } else {
            content
        }
        #else
        content
        #endif
    }

    func makeNodes() -> [SettingsNode] { makeNodes(in: .shared) }

    func makeNodes(in scope: SettingsContentScope) -> [SettingsNode] {
        scope.registry.registerIntroduction(in: scope.parentID)
        return (content as? any SettingsContent)?.makeNodes(in: scope) ?? []
    }
}

private struct SettingsIntroductionVisibilityKey: EnvironmentKey {
    static var defaultValue: Binding<Bool>? { nil }
}

extension EnvironmentValues {
    var settingsIntroductionVisibility: Binding<Bool>? {
        get { self[SettingsIntroductionVisibilityKey.self] }
        set { self[SettingsIntroductionVisibilityKey.self] = newValue }
    }
}

#if os(iOS)
/// Centralizes title presentation without changing the semantic navigation title.
struct SettingsIntroductionTitle: ViewModifier {
    let title: String
    let isVisible: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text(title)
                        .font(.headline)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: !isVisible && !reduceMotion ? 6 : 0)
                        .animation(.easeInOut(duration: reduceMotion ? 0.15 : 0.22), value: isVisible)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityHidden(!isVisible)
                        .allowsHitTesting(false)
                }
            }
    }
}
#endif
