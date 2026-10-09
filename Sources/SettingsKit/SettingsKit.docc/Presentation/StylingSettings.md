# Styling Settings

Customize either individual group presentation or the entire built-in settings shell.

## Style groups inside an app-owned shell

Conform to ``SettingsGroupStyle`` when the app owns navigation, search, and layout. The style receives a ``SettingsGroupConfiguration`` for each group.

```swift
struct CardGroupStyle: SettingsGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
}

AppSettingsShell()
    .settingsGroupStyle(CardGroupStyle())
```

Apply the style with `settingsGroupStyle(_:)`. It changes group rendering without introducing a navigation container or search UI.

## Style the built-in presentation

``SettingsStyle`` customizes the complete built-in settings presentation. It receives ``SettingsContainerConfiguration`` for navigation, search placement, and root layout, plus ``SettingsGroupConfiguration`` for navigation and inline groups.

```swift
struct CardPresentationStyle: SettingsStyle {
    func makeContainer(configuration: ContainerConfiguration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    configuration.content
                }
                .padding()
            }
            .navigationTitle(configuration.title)
            .navigationDestination(for: SettingsGroupConfiguration.self) { group in
                ScrollView { group.content }
                    .navigationTitle(group.title)
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
                configuration.label
            }
        case .inline:
            VStack(alignment: .leading) {
                configuration.label
                configuration.content
            }
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: 20))
        }
    }
}

AppSettings()
    .settingsStyle(CardPresentationStyle())
```

Individual settings remain ordinary SwiftUI views rather than style configurations. Apply shared control appearance through SwiftUI environment modifiers such as `tint`, `controlSize`, `toggleStyle`, or `buttonStyle` from `makeContainer(configuration:)` or `makeGroup(configuration:)`, and style specialized rows in their own view definitions.

SettingsKit includes ``SidebarSettingsStyle`` and ``SingleColumnSettingsStyle``. The shorthand values ``SettingsStyle/sidebar`` and ``SettingsStyle/single`` construct them. Both styles accept a ``SettingsSearchPlacement`` when search should appear only at the root, only inside destinations, at both levels, or nowhere:

```swift
AppSettings()
    .settingsStyle(.sidebar(search: .root))

AppSettings()
    .settingsStyle(.single(search: .destinations))
```

Use ``AnySettingsGroupStyle`` or ``AnySettingsStyle`` when a concrete style type must be stored without preserving its generic type.
