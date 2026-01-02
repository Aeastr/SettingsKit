import Foundation

/// Main API for settings export and import operations.
///
/// `SettingsPortable` provides static methods for exporting settings to
/// a portable file format and importing them back.
///
/// ## Exporting Settings
///
/// ```swift
/// let config = SettingsExportConfiguration(
///     sources: [UserDefaultsDataSource()],
///     appIdentifier: Bundle.main.bundleIdentifier ?? "com.example.app"
/// )
///
/// let url = FileManager.default.temporaryDirectory
///     .appendingPathComponent("MySettings.settings")
///
/// do {
///     let result = try await SettingsPortable.exportSettings(
///         configuration: config,
///         to: url
///     )
///     print("Exported \(result.exportedCount) settings")
/// } catch let error as SettingsPortableError {
///     print("Export failed: \(error.errorDescription ?? "")")
/// }
/// ```
///
/// ## Importing Settings
///
/// ```swift
/// let config = SettingsImportConfiguration(
///     sources: [UserDefaultsDataSource()],
///     conflictStrategy: .overwrite
/// )
///
/// do {
///     let result = try await SettingsPortable.importSettings(
///         from: url,
///         configuration: config
///     )
///     print("Imported \(result.importedCount) settings")
/// } catch let error as SettingsPortableError {
///     print("Import failed: \(error.errorDescription ?? "")")
/// }
/// ```
///
/// ## Previewing Before Import
///
/// ```swift
/// let preview = try await SettingsPortable.previewImport(
///     from: url,
///     configuration: config
/// )
/// print("Would add \(preview.additions.count) settings")
/// print("Would modify \(preview.modifications.count) settings")
/// ```
public enum SettingsPortable {

    // MARK: - Export

    /// Exports settings to a file.
    ///
    /// - Parameters:
    ///   - configuration: Export configuration specifying sources and options.
    ///   - destination: URL where the settings file should be written.
    /// - Returns: Export result with details about what was exported.
    /// - Throws: ``SettingsPortableError`` if export fails.
    @discardableResult
    public static func exportSettings(
        configuration: SettingsExportConfiguration,
        to destination: URL
    ) async throws -> SettingsExportResult {
        let package = try await buildPackage(from: configuration)
        try await package.write(to: destination)

        // Get file size
        let fileSize: Int64
        if let attrs = try? FileManager.default.attributesOfItem(atPath: destination.path),
           let size = attrs[.size] as? Int64 {
            fileSize = size
        } else {
            fileSize = 0
        }

        // Build count by source
        var countBySource: [String: Int] = [:]
        for (sourceId, data) in package.sourceData {
            countBySource[sourceId] = data.settings.count
        }

        return SettingsExportResult(
            exportedCount: package.sourceData.values.reduce(0) { $0 + $1.settings.count },
            countBySource: countBySource,
            destination: destination,
            format: configuration.format,
            fileSize: fileSize
        )
    }

    /// Exports settings and returns the package data directly.
    ///
    /// Useful for sharing via Share Sheet or other mechanisms that work with `Data`.
    ///
    /// - Parameter configuration: Export configuration.
    /// - Returns: The settings package as `Data`.
    /// - Throws: ``SettingsPortableError`` if export fails.
    public static func exportSettingsData(
        configuration: SettingsExportConfiguration
    ) async throws -> Data {
        let package = try await buildPackage(from: configuration)
        return try package.asData()
    }

    // MARK: - Import

    /// Imports settings from a file.
    ///
    /// - Parameters:
    ///   - source: URL of the settings file.
    ///   - configuration: Import configuration specifying sources and options.
    /// - Returns: Import result with details about what was imported.
    /// - Throws: ``SettingsPortableError`` if import fails.
    @discardableResult
    public static func importSettings(
        from source: URL,
        configuration: SettingsImportConfiguration
    ) async throws -> SettingsImportResult {
        let package = try await SettingsPackage.load(from: source)
        return try await applyPackage(package, with: configuration)
    }

    /// Imports settings from raw data.
    ///
    /// - Parameters:
    ///   - data: The settings package data.
    ///   - configuration: Import configuration.
    /// - Returns: Import result with details about what was imported.
    /// - Throws: ``SettingsPortableError`` if import fails.
    @discardableResult
    public static func importSettings(
        from data: Data,
        configuration: SettingsImportConfiguration
    ) async throws -> SettingsImportResult {
        let package = try await SettingsPackage.load(from: data)
        return try await applyPackage(package, with: configuration)
    }

    // MARK: - Validation

    /// Validates a settings package without importing.
    ///
    /// Use this to check if a package is valid and compatible before importing.
    ///
    /// - Parameters:
    ///   - source: URL of the settings file.
    ///   - configuration: Import configuration for validation context.
    /// - Returns: Validation result with any issues found.
    /// - Throws: ``SettingsPortableError`` if the file cannot be read.
    public static func validatePackage(
        at source: URL,
        for configuration: SettingsImportConfiguration
    ) async throws -> SettingsValidationResult {
        let package = try await SettingsPackage.load(from: source)
        return try await validate(package, with: configuration)
    }

    /// Previews what an import would do without making changes.
    ///
    /// - Parameters:
    ///   - source: URL of the settings file.
    ///   - configuration: Import configuration.
    /// - Returns: Preview of what would be imported.
    /// - Throws: ``SettingsPortableError`` if the file cannot be read.
    public static func previewImport(
        from source: URL,
        configuration: SettingsImportConfiguration
    ) async throws -> SettingsImportPreview {
        let package = try await SettingsPackage.load(from: source)
        return try await generatePreview(package, with: configuration)
    }

    /// Reads the manifest from a settings package without fully loading it.
    ///
    /// This is faster than full validation when you only need metadata.
    ///
    /// - Parameter source: URL of the settings file.
    /// - Returns: The package manifest.
    /// - Throws: ``SettingsPortableError`` if reading fails.
    public static func readManifest(from source: URL) async throws -> SettingsManifest {
        let package = try await SettingsPackage.load(from: source)
        return package.manifest
    }

    // MARK: - Private: Building Packages

    private static func buildPackage(
        from configuration: SettingsExportConfiguration
    ) async throws -> SettingsPackage {
        var builder = SettingsPackage.Builder()

        for source in configuration.sources {
            let keys = try await source.availableKeys()
            var entries: [SettingsSourceData.SettingEntry] = []

            for key in keys {
                // Apply key filter
                if let filter = configuration.keyFilter, !filter(key) {
                    continue
                }

                // Read and encode value
                guard let value = try await source.read(key: key) else {
                    continue
                }

                do {
                    let entry = try SettingsSourceData.SettingEntry(key: key, exportable: value)
                    entries.append(entry)
                } catch {
                    throw SettingsPortableError.encodingFailed(
                        key: key,
                        reason: error.localizedDescription
                    )
                }
            }

            let sourceData = SettingsSourceData(
                sourceIdentifier: source.sourceIdentifier,
                settings: entries
            )
            builder.addSource(sourceData, from: source)
        }

        return try builder.build(
            appIdentifier: configuration.appIdentifier,
            appVersion: configuration.appVersion,
            metadata: configuration.metadata
        )
    }

    // MARK: - Private: Applying Packages

    private static func applyPackage(
        _ package: SettingsPackage,
        with configuration: SettingsImportConfiguration
    ) async throws -> SettingsImportResult {
        // Check app identifier if required
        if !configuration.allowDifferentApp,
           let required = configuration.requiredAppIdentifier,
           package.manifest.appIdentifier != required {
            throw SettingsPortableError.appMismatch(
                expected: required,
                found: package.manifest.appIdentifier
            )
        }

        // Build source lookup
        var sourceLookup: [String: any SettingsDataSource] = [:]
        for source in configuration.sources {
            sourceLookup[source.sourceIdentifier] = source
        }

        var importedKeys: [String] = []
        var skippedKeys: [SettingsImportResult.SkippedKey] = []
        var warnings: [String] = []

        // Process each source in the package
        for (sourceId, sourceData) in package.sourceData {
            guard let source = sourceLookup[sourceId] else {
                // No matching source - skip all keys from this source
                for entry in sourceData.settings {
                    skippedKeys.append(SettingsImportResult.SkippedKey(
                        key: entry.key,
                        reason: .noMatchingSource
                    ))
                }
                warnings.append("No data source found for '\(sourceId)' - skipped \(sourceData.settings.count) settings")
                continue
            }

            // Prepare source for import
            if !configuration.validateOnly {
                try await source.prepareForImport()
            }

            do {
                for entry in sourceData.settings {
                    // Apply key mapping
                    let destinationKey = configuration.keyMapping[entry.key] ?? entry.key

                    // Check if import is allowed
                    guard await source.canImport(key: destinationKey) else {
                        skippedKeys.append(SettingsImportResult.SkippedKey(
                            key: entry.key,
                            reason: .notAllowed
                        ))
                        continue
                    }

                    // Check for conflicts
                    if configuration.conflictStrategy != .overwrite {
                        let existingValue = try await source.read(key: destinationKey)
                        if existingValue != nil {
                            switch configuration.conflictStrategy {
                            case .keepExisting:
                                skippedKeys.append(SettingsImportResult.SkippedKey(
                                    key: entry.key,
                                    reason: .existingValue
                                ))
                                continue
                            case .failOnConflict:
                                throw SettingsPortableError.conflictDetected(
                                    key: destinationKey,
                                    existingValue: String(describing: existingValue),
                                    importedValue: String(describing: entry.rawValue)
                                )
                            case .merge, .overwrite:
                                // Continue with import
                                break
                            }
                        }
                    }

                    // Write the value
                    if !configuration.validateOnly {
                        do {
                            try await writeValue(entry.rawValue, to: source, forKey: destinationKey)
                            importedKeys.append(entry.key)
                        } catch {
                            throw SettingsPortableError.writeFailed(
                                source: source.sourceIdentifier,
                                key: destinationKey,
                                underlyingDescription: error.localizedDescription
                            )
                        }
                    } else {
                        importedKeys.append(entry.key)
                    }
                }

                // Finalize import
                if !configuration.validateOnly {
                    try await source.finalizeImport()
                }
            } catch {
                // Rollback on failure
                if !configuration.validateOnly {
                    try? await source.rollbackImport()
                }
                throw error
            }
        }

        return SettingsImportResult(
            importedKeys: importedKeys,
            skippedKeys: skippedKeys,
            warnings: warnings,
            manifest: package.manifest
        )
    }

    private static func writeValue(
        _ value: Any,
        to source: any SettingsDataSource,
        forKey key: String
    ) async throws {
        // Convert the raw value back to an exportable type
        let exportable: any SettingsExportable = try convertToExportable(value)
        try await source.write(exportable, forKey: key)
    }

    private static func convertToExportable(_ value: Any) throws -> any SettingsExportable {
        switch value {
        case let string as String:
            return string
        case let int as Int:
            return int
        case let double as Double:
            return double
        case let bool as Bool:
            return bool
        case let data as Data:
            return data
        case let date as Date:
            return date
        case let url as URL:
            return url
        case let array as [Any]:
            // Encode as JSON string for complex arrays
            let jsonData = try JSONSerialization.data(withJSONObject: array)
            return String(data: jsonData, encoding: .utf8) ?? "[]"
        case let dict as [String: Any]:
            // Encode as JSON string for complex dictionaries
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        default:
            // Try to use the value as-is if it's already exportable
            if let exportable = value as? any SettingsExportable {
                return exportable
            }
            throw SettingsPortableError.decodingFailed(
                key: "unknown",
                reason: "Cannot convert \(type(of: value)) to SettingsExportable"
            )
        }
    }

    // MARK: - Private: Validation

    private static func validate(
        _ package: SettingsPackage,
        with configuration: SettingsImportConfiguration
    ) async throws -> SettingsValidationResult {
        var issues: [ValidationIssue] = []
        var warnings: [String] = []

        // Check app identifier
        if !configuration.allowDifferentApp,
           let required = configuration.requiredAppIdentifier,
           package.manifest.appIdentifier != required {
            issues.append(ValidationIssue(
                key: "appIdentifier",
                issue: .keyNotAllowed(reason: "Package is from '\(package.manifest.appIdentifier)', expected '\(required)'")
            ))
        }

        // Build source lookup
        var sourceLookup: [String: any SettingsDataSource] = [:]
        for source in configuration.sources {
            sourceLookup[source.sourceIdentifier] = source
        }

        // Check each source
        for (sourceId, sourceData) in package.sourceData {
            if sourceLookup[sourceId] == nil {
                issues.append(ValidationIssue(
                    key: sourceId,
                    issue: .missingDataSource(identifier: sourceId)
                ))
                warnings.append("No data source for '\(sourceId)' - \(sourceData.settings.count) settings won't be imported")
            }
        }

        // Build summary
        let totalSettings = package.sourceData.values.reduce(0) { $0 + $1.settings.count }
        let summary = SettingsValidationResult.PackageSummary(
            totalSettings: totalSettings,
            sourceCount: package.manifest.sources.count,
            sourceNames: package.manifest.sources.map(\.displayName),
            createdAt: package.manifest.createdAt,
            createdBy: package.manifest.appIdentifier
        )

        return SettingsValidationResult(
            isValid: issues.isEmpty,
            issues: issues,
            warnings: warnings,
            manifest: package.manifest,
            summary: summary
        )
    }

    // MARK: - Private: Preview

    private static func generatePreview(
        _ package: SettingsPackage,
        with configuration: SettingsImportConfiguration
    ) async throws -> SettingsImportPreview {
        var additions: [String] = []
        var modifications: [SettingsImportPreview.ModifiedKey] = []
        var skipped: [SettingsImportResult.SkippedKey] = []

        // Build source lookup
        var sourceLookup: [String: any SettingsDataSource] = [:]
        for source in configuration.sources {
            sourceLookup[source.sourceIdentifier] = source
        }

        for (sourceId, sourceData) in package.sourceData {
            guard let source = sourceLookup[sourceId] else {
                for entry in sourceData.settings {
                    skipped.append(SettingsImportResult.SkippedKey(
                        key: entry.key,
                        reason: .noMatchingSource
                    ))
                }
                continue
            }

            for entry in sourceData.settings {
                let destinationKey = configuration.keyMapping[entry.key] ?? entry.key

                guard await source.canImport(key: destinationKey) else {
                    skipped.append(SettingsImportResult.SkippedKey(
                        key: entry.key,
                        reason: .notAllowed
                    ))
                    continue
                }

                if let existingValue = try await source.read(key: destinationKey) {
                    switch configuration.conflictStrategy {
                    case .keepExisting:
                        skipped.append(SettingsImportResult.SkippedKey(
                            key: entry.key,
                            reason: .existingValue
                        ))
                    case .failOnConflict:
                        skipped.append(SettingsImportResult.SkippedKey(
                            key: entry.key,
                            reason: .existingValue
                        ))
                    case .overwrite, .merge:
                        modifications.append(SettingsImportPreview.ModifiedKey(
                            key: entry.key,
                            currentValue: String(describing: try existingValue.encodeForExport()),
                            newValue: String(describing: entry.rawValue)
                        ))
                    }
                } else {
                    additions.append(entry.key)
                }
            }
        }

        return SettingsImportPreview(
            additions: additions,
            modifications: modifications,
            skipped: skipped,
            manifest: package.manifest
        )
    }
}
