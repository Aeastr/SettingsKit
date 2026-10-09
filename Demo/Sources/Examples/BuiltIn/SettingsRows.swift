import SwiftUI

extension View {
    /// Uses the compact macOS control size without changing iOS presentation.
    @ViewBuilder
    func smallControlSizeOnMacOS() -> some View {
#if os(macOS)
        controlSize(.small)
#else
        self
#endif
    }
}

/// A compact value row matching the label/value rhythm used throughout Settings.
struct SettingsValueRow: View {
    let title: String
    let value: String

    var body: some View {
        LabeledContent(title, value: value)
    }
}

struct SettingsNote: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct StorageUsageRow: View {
    let title: String
    let detail: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(title)
            Spacer()
            Text(detail)
                .foregroundStyle(.secondary)
        }
    }
}

struct NetworkRow: View {
    let name: String
    let detail: String?
    let strength: String
    var secured = true

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if secured {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Image(systemName: strength)
                .foregroundStyle(.secondary)
        }
    }
}

struct DeviceRow: View {
    let name: String
    let detail: String
    let symbol: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .frame(width: 24)
                .foregroundStyle(.secondary)
            Text(name)
            Spacer()
            Text(detail)
                .foregroundStyle(.secondary)
        }
    }
}
