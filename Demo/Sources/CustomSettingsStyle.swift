import SwiftUI
import SettingsKit

struct CustomSettingsStyle: SettingsStyle {
    func makeContainer(configuration: ContainerConfiguration) -> some View {
        NavigationStack(path: configuration.navigationPath) {
            ScrollView {
                VStack(spacing: 16) {
                    configuration.content
                }
                .padding()
            }
            .navigationTitle(configuration.title)
            .background(Color.blue.opacity(0.05))
        }
    }

    func makeGroup(configuration: GroupConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            configuration.label
                .font(.headline)
                .foregroundColor(.purple)
            configuration.content
                .padding(.leading, 8)
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }

    func makeItem(configuration: ItemConfiguration) -> some View {
        HStack {
            configuration.label
                .foregroundColor(.green)
            Spacer()
            configuration.content
        }
        .padding(12)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}
