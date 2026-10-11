import SwiftUI
import SettingsKit

@main
struct SettingsKitDemoApp: App {
    @State private var settings = SettingsState()

    var body: some Scene {
        WindowGroup {
            Group{
                SettingsHost(container: DemoSettings()) { context in
                    NavigationStack(path: context.navigationPath) {
                        Form { context.content }
                            .navigationTitle(context.title)
                            .searchable(text: context.searchText)
                            .navigationDestination(for: SettingsGroupConfiguration.self) { group in
                                Form { group.content }.navigationTitle(group.title)
                            }
                    }
                }
            }
                .environment(settings)
        }
    }
}
