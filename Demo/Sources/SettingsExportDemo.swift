import SwiftUI
import UniformTypeIdentifiers
import SettingsKitPortable

// MARK: - Settings File Document

/// A transferable document for settings export/import.
struct SettingsDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.settingsPackage] }
    static var writableContentTypes: [UTType] { [.settingsPackage] }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

extension UTType {
    static var settingsPackage: UTType {
        UTType(exportedAs: "com.settingskit.settings-package", conformingTo: .data)
    }
}

// MARK: - Settings Export/Import View

struct SettingsExportDemo: View {
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var exportDocument: SettingsDocument?
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var showingResult = false
    @State private var resultMessage = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("Export & Import")
                    .font(.headline)

                Text("Transfer your settings to another device or restore after reinstalling.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button {
                    Task { await prepareExport() }
                } label: {
                    Label("Export Settings", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isExporting)

                Button {
                    showingImporter = true
                } label: {
                    Label("Import Settings", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isImporting)
            }

            Spacer()
        }
        .padding()
        .fileExporter(
            isPresented: $showingExporter,
            document: exportDocument,
            contentType: .settingsPackage,
            defaultFilename: "Settings"
        ) { result in
            switch result {
            case .success(let url):
                resultMessage = "Settings exported to \(url.lastPathComponent)"
                showingResult = true
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
            exportDocument = nil
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.settingsPackage, .data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    Task { await importSettings(from: url) }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        .alert("Success", isPresented: $showingResult) {
            Button("OK") { }
        } message: {
            Text(resultMessage)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Export

    private func prepareExport() async {
        isExporting = true
        defer { isExporting = false }

        do {
            let source = UserDefaultsDataSource()
            let config = SettingsExportConfiguration(
                sources: [source],
                appIdentifier: Bundle.main.bundleIdentifier ?? "com.settingskit.demo",
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            )

            let data = try await SettingsPortable.exportSettingsData(configuration: config)
            exportDocument = SettingsDocument(data: data)
            showingExporter = true

        } catch let error as SettingsPortableError {
            errorMessage = error.errorDescription ?? "Export failed"
            if let recovery = error.recoverySuggestion {
                errorMessage += "\n\n\(recovery)"
            }
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Import

    private func importSettings(from url: URL) async {
        isImporting = true
        defer { isImporting = false }

        // Start accessing security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "Unable to access the selected file"
            showError = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let dataSource = UserDefaultsDataSource()
            let config = SettingsImportConfiguration(
                sources: [dataSource],
                conflictStrategy: .overwrite
            )

            let result = try await SettingsPortable.importSettings(
                from: url,
                configuration: config
            )

            var message = "Imported \(result.importedCount) settings"
            if result.skippedCount > 0 {
                message += "\nSkipped \(result.skippedCount) settings"
            }
            if !result.warnings.isEmpty {
                message += "\n\nWarnings:\n" + result.warnings.joined(separator: "\n")
            }

            resultMessage = message
            showingResult = true

        } catch let error as SettingsPortableError {
            errorMessage = error.errorDescription ?? "Import failed"
            if let recovery = error.recoverySuggestion {
                errorMessage += "\n\n\(recovery)"
            }
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Example: Custom Data Source

/// Example of implementing a custom data source for a different storage backend.
struct PlistDataSource: SettingsDataSource {
    let fileURL: URL

    var sourceIdentifier: String { "plist.custom" }
    var displayName: String { "Custom Plist" }

    func availableKeys() async throws -> [String] {
        guard let dict = NSDictionary(contentsOf: fileURL) as? [String: Any] else {
            return []
        }
        return Array(dict.keys)
    }

    func read(key: String) async throws -> (any SettingsExportable)? {
        guard let dict = NSDictionary(contentsOf: fileURL) as? [String: Any] else {
            return nil
        }
        guard let value = dict[key] else {
            return nil
        }
        switch value {
        case let string as String: return string
        case let int as Int: return int
        case let double as Double: return double
        case let bool as Bool: return bool
        default: return nil
        }
    }

    func write(_ value: any SettingsExportable, forKey key: String) async throws {
        var dict = (NSDictionary(contentsOf: fileURL) as? [String: Any]) ?? [:]
        dict[key] = try value.encodeForExport()
        try (dict as NSDictionary).write(to: fileURL)
    }
}

#Preview {
    NavigationStack {
        SettingsExportDemo()
    }
}
