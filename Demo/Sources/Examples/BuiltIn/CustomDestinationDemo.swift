import SwiftUI

/// An intentionally non-standard destination demonstrating that
/// `CustomSettingsGroup` can host an arbitrary SwiftUI interface.
struct CustomDestinationDemo: View {
    @Bindable var state: SettingsState

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            hero

            HStack(spacing: 12) {
                metricCard(
                    title: "Devices",
                    value: "4",
                    symbol: "iphone.and.arrow.forward",
                    color: .blue
                )
                metricCard(
                    title: "Automations",
                    value: "12",
                    symbol: "bolt.fill",
                    color: .orange
                )
            }

            VStack(alignment: .leading, spacing: 14) {
                Label("Live Controls", systemImage: "slider.horizontal.3")
                    .font(.headline)

                Toggle(isOn: $state.customDashboardEnabled) {
                    Text("Enable Dashboard")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()

                Picker("Profile", selection: $state.customDashboardProfile) {
                    Text("Quiet").tag("Quiet")
                    Text("Balanced").tag("Balanced")
                    Text("Maximum").tag("Maximum")
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Intensity")
                        Spacer()
                        Text("\(Int(state.customDashboardIntensity * 100))%")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $state.customDashboardIntensity, in: 0...1)
                }
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            Button {
                state.customDashboardRefreshCount += 1
            } label: {
                Label(
                    state.customDashboardRefreshCount == 0
                        ? "Run Custom Action"
                        : "Actions Run: \(state.customDashboardRefreshCount)",
                    systemImage: "arrow.clockwise.circle.fill"
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)

            Text("This entire screen is one arbitrary SwiftUI view. SettingsKit indexes and navigates to the destination, but does not impose a settings-row structure on its contents.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    private var hero: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("CUSTOM DESTINATION")
                    .font(.caption.bold())
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.72))
                Text("Device Studio")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("A fully app-owned SwiftUI surface")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))
            }

            Spacer(minLength: 8)

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.22), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: state.customDashboardIntensity)
                    .stroke(.white, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(state.customDashboardIntensity * 100))")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
            .frame(width: 82, height: 82)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.indigo, .purple, .pink.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }

    private func metricCard(
        title: String,
        value: String,
        symbol: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title.bold())
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            color.opacity(0.10),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }
}

#Preview {
    Form {
        CustomDestinationDemo(state: SettingsState())
    }
}
