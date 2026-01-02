import Foundation

/// Result of a successful import operation.
///
/// Contains details about what was imported, skipped, and any warnings.
public struct SettingsImportResult: Sendable, Hashable {
    /// Number of settings successfully imported.
    public let importedCount: Int

    /// Number of settings skipped.
    public let skippedCount: Int

    /// Keys that were successfully imported.
    public let importedKeys: [String]

    /// Keys that were skipped, with reasons.
    public let skippedKeys: [SkippedKey]

    /// Non-fatal warnings generated during import.
    public let warnings: [String]

    /// The manifest of the imported package.
    public let manifest: SettingsManifest

    /// Creates an import result.
    public init(
        importedKeys: [String],
        skippedKeys: [SkippedKey],
        warnings: [String],
        manifest: SettingsManifest
    ) {
        self.importedCount = importedKeys.count
        self.skippedCount = skippedKeys.count
        self.importedKeys = importedKeys
        self.skippedKeys = skippedKeys
        self.warnings = warnings
        self.manifest = manifest
    }

    /// Whether the import was successful with no issues.
    public var isClean: Bool {
        skippedCount == 0 && warnings.isEmpty
    }

    /// A key that was skipped during import.
    public struct SkippedKey: Sendable, Hashable, CustomStringConvertible {
        /// The key that was skipped.
        public let key: String

        /// The reason it was skipped.
        public let reason: SkipReason

        public var description: String {
            "\(key): \(reason)"
        }

        /// Reasons a key might be skipped.
        public enum SkipReason: Sendable, Hashable, CustomStringConvertible {
            /// The key already exists and conflict strategy was `.keepExisting`.
            case existingValue

            /// The data source doesn't allow importing this key.
            case notAllowed

            /// No matching data source was found.
            case noMatchingSource

            /// The value type couldn't be decoded.
            case decodingFailed(String)

            public var description: String {
                switch self {
                case .existingValue:
                    return "kept existing value"
                case .notAllowed:
                    return "import not allowed for this key"
                case .noMatchingSource:
                    return "no matching data source"
                case .decodingFailed(let reason):
                    return "decoding failed: \(reason)"
                }
            }
        }
    }
}

// MARK: - SettingsValidationResult

/// Result of validating a settings package without importing.
public struct SettingsValidationResult: Sendable {
    /// Whether the package is valid and can be imported.
    public let isValid: Bool

    /// Issues found during validation that would cause import to fail.
    public let issues: [ValidationIssue]

    /// Warnings that wouldn't prevent import but may indicate problems.
    public let warnings: [String]

    /// The package manifest.
    public let manifest: SettingsManifest

    /// Summary of what the package contains.
    public let summary: PackageSummary

    /// Creates a validation result.
    public init(
        isValid: Bool,
        issues: [ValidationIssue],
        warnings: [String],
        manifest: SettingsManifest,
        summary: PackageSummary
    ) {
        self.isValid = isValid
        self.issues = issues
        self.warnings = warnings
        self.manifest = manifest
        self.summary = summary
    }

    /// Summary information about a package.
    public struct PackageSummary: Sendable, Hashable {
        /// Total number of settings across all sources.
        public let totalSettings: Int

        /// Number of data sources in the package.
        public let sourceCount: Int

        /// Names of the data sources.
        public let sourceNames: [String]

        /// When the package was created.
        public let createdAt: Date

        /// The app that created the package.
        public let createdBy: String

        public init(
            totalSettings: Int,
            sourceCount: Int,
            sourceNames: [String],
            createdAt: Date,
            createdBy: String
        ) {
            self.totalSettings = totalSettings
            self.sourceCount = sourceCount
            self.sourceNames = sourceNames
            self.createdAt = createdAt
            self.createdBy = createdBy
        }
    }
}

// MARK: - SettingsImportPreview

/// Preview of what an import would do without making changes.
public struct SettingsImportPreview: Sendable {
    /// Keys that would be added (don't currently exist).
    public let additions: [String]

    /// Keys that would be modified (already exist).
    public let modifications: [ModifiedKey]

    /// Keys that would be skipped.
    public let skipped: [SettingsImportResult.SkippedKey]

    /// The package manifest.
    public let manifest: SettingsManifest

    /// Total number of changes that would be made.
    public var totalChanges: Int {
        additions.count + modifications.count
    }

    /// Whether any changes would be made.
    public var hasChanges: Bool {
        totalChanges > 0
    }

    /// Creates an import preview.
    public init(
        additions: [String],
        modifications: [ModifiedKey],
        skipped: [SettingsImportResult.SkippedKey],
        manifest: SettingsManifest
    ) {
        self.additions = additions
        self.modifications = modifications
        self.skipped = skipped
        self.manifest = manifest
    }

    /// A key that would be modified during import.
    public struct ModifiedKey: Sendable, Hashable {
        /// The key that would be modified.
        public let key: String

        /// String representation of the current value.
        public let currentValue: String

        /// String representation of the new value.
        public let newValue: String

        public init(key: String, currentValue: String, newValue: String) {
            self.key = key
            self.currentValue = currentValue
            self.newValue = newValue
        }
    }
}

// MARK: - SettingsExportResult

/// Result of a successful export operation.
public struct SettingsExportResult: Sendable, Hashable {
    /// Total number of settings exported.
    public let exportedCount: Int

    /// Number of settings per source.
    public let countBySource: [String: Int]

    /// The destination URL where the package was written.
    public let destination: URL

    /// The package format used.
    public let format: SettingsPackageFormat

    /// Size of the exported file in bytes.
    public let fileSize: Int64

    /// Creates an export result.
    public init(
        exportedCount: Int,
        countBySource: [String: Int],
        destination: URL,
        format: SettingsPackageFormat,
        fileSize: Int64
    ) {
        self.exportedCount = exportedCount
        self.countBySource = countBySource
        self.destination = destination
        self.format = format
        self.fileSize = fileSize
    }
}
