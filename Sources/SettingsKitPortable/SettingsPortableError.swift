import Foundation

/// A specific issue found during import validation.
public struct ValidationIssue: Sendable, CustomStringConvertible, Hashable {
    /// The key associated with this issue.
    public let key: String

    /// The type of issue encountered.
    public let issue: IssueType

    /// Types of validation issues.
    public enum IssueType: Sendable, Hashable {
        /// The value type doesn't match what was expected.
        case typeMismatch(expected: String, found: String)
        /// The type is not supported for import.
        case unsupportedType(typeName: String)
        /// The required data source is not available.
        case missingDataSource(identifier: String)
        /// The key is not allowed to be imported.
        case keyNotAllowed(reason: String)
    }

    public init(key: String, issue: IssueType) {
        self.key = key
        self.issue = issue
    }

    public var description: String {
        switch issue {
        case .typeMismatch(let expected, let found):
            return "\(key): expected \(expected), found \(found)"
        case .unsupportedType(let typeName):
            return "\(key): unsupported type '\(typeName)'"
        case .missingDataSource(let identifier):
            return "\(key): data source '\(identifier)' not available"
        case .keyNotAllowed(let reason):
            return "\(key): \(reason)"
        }
    }
}

/// Errors that can occur during settings export/import operations.
public enum SettingsPortableError: Error, LocalizedError, Sendable {
    // MARK: - Export Errors

    /// Failed to encode a setting value for export.
    case encodingFailed(key: String, reason: String)

    /// Failed to read a value from a data source.
    case readFailed(source: String, key: String, underlyingDescription: String?)

    /// Failed to create the settings package.
    case packageCreationFailed(reason: String)

    /// Failed to write to the output file.
    case fileWriteFailed(path: String, underlyingDescription: String)

    // MARK: - Import Errors

    /// The file does not exist or cannot be accessed.
    case fileNotFound(path: String)

    /// The file is not a valid settings package.
    case invalidPackage(reason: String)

    /// The package manifest is missing.
    case manifestMissing

    /// The package manifest is malformed.
    case manifestCorrupt(reason: String)

    /// The package was created by an incompatible version.
    case incompatibleVersion(found: String, required: String)

    /// The package was created for a different app.
    case appMismatch(expected: String, found: String)

    /// Failed to decode a setting value during import.
    case decodingFailed(key: String, reason: String)

    /// Failed to write a value to a data source.
    case writeFailed(source: String, key: String, underlyingDescription: String?)

    /// A required data source is not available.
    case dataSourceNotFound(identifier: String)

    /// Import validation failed with one or more issues.
    case validationFailed(issues: [ValidationIssue])

    /// Import failed due to conflict with existing data.
    case conflictDetected(key: String, existingValue: String, importedValue: String)

    // MARK: - Archive Errors

    /// The ZIP archive is corrupted.
    case archiveCorrupt(underlyingDescription: String)

    /// Failed to extract an entry from the ZIP archive.
    case extractionFailed(entry: String, underlyingDescription: String)

    /// Failed to compress an entry into the ZIP archive.
    case compressionFailed(entry: String, underlyingDescription: String)

    // MARK: - General Errors

    /// The operation was cancelled.
    case cancelled

    /// An unexpected error occurred.
    case unexpected(message: String, underlyingDescription: String?)

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .encodingFailed(let key, let reason):
            return "Failed to encode '\(key)': \(reason)"

        case .readFailed(let source, let key, let underlying):
            let detail = underlying.map { ": \($0)" } ?? ""
            return "Failed to read '\(key)' from \(source)\(detail)"

        case .packageCreationFailed(let reason):
            return "Failed to create settings package: \(reason)"

        case .fileWriteFailed(let path, let underlying):
            return "Failed to write to '\(path)': \(underlying)"

        case .fileNotFound(let path):
            return "Settings file not found: \(path)"

        case .invalidPackage(let reason):
            return "Invalid settings file: \(reason)"

        case .manifestMissing:
            return "Settings file is incomplete or damaged (missing required metadata)"

        case .manifestCorrupt(let reason):
            return "Settings file metadata is unreadable: \(reason)"

        case .incompatibleVersion(let found, let required):
            let comparison = found < required ? "older" : "newer"
            return "This settings file uses a \(comparison) format (version \(found)) that isn't compatible with this app (requires version \(required))"

        case .appMismatch(let expected, let found):
            return "This settings file was created by a different app ('\(found)') and cannot be imported into '\(expected)'"

        case .decodingFailed(let key, let reason):
            return "Failed to decode '\(key)': \(reason)"

        case .writeFailed(let source, let key, let underlying):
            let detail = underlying.map { ": \($0)" } ?? ""
            return "Failed to write '\(key)' to \(source)\(detail)"

        case .dataSourceNotFound(let identifier):
            return "Data source '\(identifier)' not found"

        case .validationFailed(let issues):
            let issueList = issues.map(\.description).joined(separator: "; ")
            return "Import validation failed: \(issueList)"

        case .conflictDetected(let key, _, _):
            return "Conflict detected for '\(key)'"

        case .archiveCorrupt(let underlying):
            return "Settings archive is corrupt: \(underlying)"

        case .extractionFailed(let entry, let underlying):
            return "Failed to extract '\(entry)': \(underlying)"

        case .compressionFailed(let entry, let underlying):
            return "Failed to compress '\(entry)': \(underlying)"

        case .cancelled:
            return "Operation was cancelled"

        case .unexpected(let message, let underlying):
            if let underlying = underlying {
                return "\(message) (Details: \(underlying))"
            }
            return message
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "Check that the file exists and you have permission to read it."

        case .invalidPackage, .manifestMissing, .manifestCorrupt, .archiveCorrupt:
            return "The file may be corrupted. Try exporting again from the original device."

        case .incompatibleVersion(let found, let required):
            if found < required {
                return "This settings file was created by an older version of the app. Export a new settings file from the current version."
            } else {
                return "Update this app to the latest version to import this settings file."
            }

        case .appMismatch(_, let found):
            return "This settings file can only be imported by '\(found)'. Make sure you're using the correct app."

        case .conflictDetected:
            return "Choose a different conflict strategy or backup your current settings first."

        case .dataSourceNotFound:
            return "Ensure all required data sources are registered before importing."

        case .validationFailed:
            return "Review the validation issues and ensure the settings file is compatible."

        default:
            return nil
        }
    }
}
