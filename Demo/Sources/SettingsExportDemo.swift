import SwiftUI
import SettingsKitPortable

// MARK: - Example: Settings Export/Import View

/// Example view demonstrating how to use SettingsKitPortable for exporting and importing settings.
///
/// This is a minimal example showing the core functionality. In a real app, you would integrate
/// this with your app's UI and potentially use system file dialogs.
struct SettingsExportDemo: View {
    @State private var isExporting = false
    @State private var isImporting = false
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
                    Task { await exportSettings() }
                } label: {
                    Label("Export Settings", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isExporting)

                Button {
                    Task { await importSettings() }
                } label: {
                    Label("Import Settings", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isImporting)
            }

            Divider()

            VStack(spacing: 12) {
                Text("Advanced")
                    .font(.headline)

                Button {
                    Task { await previewImport() }
                } label: {
                    Label("Preview Before Import", systemImage: "eye")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding()
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

    // MARK: - Export Example

    private func exportSettings() async {
        isExporting = true
        defer { isExporting = false }

        do {
            // 1. Create data source(s)
            let source = UserDefaultsDataSource()

            // 2. Create export configuration
            let config = SettingsExportConfiguration(
                sources: [source],
                appIdentifier: Bundle.main.bundleIdentifier ?? "com.example.app",
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                metadata: ["exportReason": "manual backup"]
            )

            // 3. Choose destination
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destination = documentsURL.appendingPathComponent("MySettings").appendingPathExtension("settings")

            // 4. Export
            let result = try await SettingsPortable.exportSettings(
                configuration: config,
                to: destination
            )

            resultMessage = "Exported \(result.exportedCount) settings to \(destination.lastPathComponent)"
            showingResult = true

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

    // MARK: - Import Example

    private func importSettings() async {
        isImporting = true
        defer { isImporting = false }

        do {
            // 1. Get source file (in a real app, use file picker)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let source = documentsURL.appendingPathComponent("MySettings.settings")

            // 2. Create data source(s)
            let dataSource = UserDefaultsDataSource()

            // 3. Create import configuration
            let config = SettingsImportConfiguration(
                sources: [dataSource],
                conflictStrategy: .overwrite  // or .keepExisting, .merge, .failOnConflict
            )

            // 4. Import
            let result = try await SettingsPortable.importSettings(
                from: source,
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

    // MARK: - Preview Example

    private func previewImport() async {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let source = documentsURL.appendingPathComponent("MySettings.settings")

            let config = SettingsImportConfiguration(
                sources: [UserDefaultsDataSource()]
            )

            let preview = try await SettingsPortable.previewImport(
                from: source,
                configuration: config
            )

            var message = """
            Would add \(preview.additions.count) new settings
            Would modify \(preview.modifications.count) existing settings
            Would skip \(preview.skipped.count) settings

            Created by: \(preview.manifest.appIdentifier)
            Created at: \(preview.manifest.createdAt.formatted())
            """

            resultMessage = message
            showingResult = true

        } catch let error as SettingsPortableError {
            errorMessage = error.errorDescription ?? "Preview failed"
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Example: Custom Data Source

/// Example of implementing a custom data source for a different storage backend.
///
/// This example shows how to create a data source for a custom plist file.
/// You can adapt this pattern for Keychain, Core Data, file-based storage, etc.
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
        // Convert to exportable type
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

// MARK: - Xcode Setup Documentation
/*

 ## Setting Up Your Xcode Project for .settings Files

 To enable your app to open .settings files (or your custom extension), you need to:

 ### 1. Declare the File Type (Info.plist - UTExportedTypeDeclarations)

 Add this to your app's Info.plist to declare the file type:

 ```xml
 <key>UTExportedTypeDeclarations</key>
 <array>
     <dict>
         <key>UTTypeIdentifier</key>
         <string>com.yourcompany.yourapp.settings</string>
         <key>UTTypeDescription</key>
         <string>App Settings</string>
         <key>UTTypeConformsTo</key>
         <array>
             <string>public.data</string>
             <string>public.archive</string>
         </array>
         <key>UTTypeTagSpecification</key>
         <dict>
             <key>public.filename-extension</key>
             <array>
                 <string>settings</string>
             </array>
             <key>public.mime-type</key>
             <string>application/x-settings</string>
         </dict>
     </dict>
 </array>
 ```

 ### 2. Register as Handler (Info.plist - CFBundleDocumentTypes)

 Add this to allow your app to open .settings files:

 ```xml
 <key>CFBundleDocumentTypes</key>
 <array>
     <dict>
         <key>CFBundleTypeName</key>
         <string>App Settings</string>
         <key>CFBundleTypeRole</key>
         <string>Editor</string>
         <key>LSHandlerRank</key>
         <string>Owner</string>
         <key>LSItemContentTypes</key>
         <array>
             <string>com.yourcompany.yourapp.settings</string>
         </array>
     </dict>
 </array>
 ```

 ### 3. Handle Incoming Files (SwiftUI)

 In your app, handle incoming files using the `onOpenURL` modifier:

 ```swift
 @main
 struct MyApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
                 .onOpenURL { url in
                     Task {
                         await handleSettingsFile(url)
                     }
                 }
         }
     }

     func handleSettingsFile(_ url: URL) async {
         let config = SettingsImportConfiguration(
             sources: [UserDefaultsDataSource()]
         )

         do {
             // Show preview first
             let preview = try await SettingsPortable.previewImport(
                 from: url,
                 configuration: config
             )

             // Ask user for confirmation, then import
             let result = try await SettingsPortable.importSettings(
                 from: url,
                 configuration: config
             )

             print("Imported \(result.importedCount) settings")
         } catch {
             print("Import failed: \(error)")
         }
     }
 }
 ```

 ### 4. Custom File Extension

 If you want a custom extension instead of .settings, use `SettingsPackageFormat`:

 ```swift
 let customFormat = SettingsPackageFormat(
     fileExtension: "myappsettings",
     uniformTypeIdentifier: "com.mycompany.myapp.settings"
 )

 let config = SettingsExportConfiguration(
     sources: [UserDefaultsDataSource()],
     appIdentifier: "com.mycompany.myapp",
     format: customFormat
 )
 ```

 Then update your Info.plist to use your custom extension and UTI.

 */

#Preview {
    NavigationStack {
        SettingsExportDemo()
    }
}
