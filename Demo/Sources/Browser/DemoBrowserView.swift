import SwiftUI
import SettingsKit

/// Side-by-side examples of the two built-in presentations.
///
/// Both tabs resolve `SettingsState` from the app environment, so a value changed
/// in one presentation is immediately reflected in the other presentation.
struct DemoBrowserView: View {
    var body: some View {

            DemoSettings()
                .settingsStyle(.sidebar)
    }
}

#Preview {
    DemoBrowserView()
        .environment(SettingsState())
}
