import Foundation

/// Configuration options for settings import.
///
/// Use this to specify which data sources to import into, how to handle
/// conflicts, and optional key mapping for migrations.
///
/// ## Basic Usage
///
/// ```swift
/// let config = SettingsImportConfiguration(
///     sources: [UserDefaultsDataSource()]
/// )
/// try await SettingsPortable.importSettings(from: url, configuration: config)
/// ```
///
/// ## Conflict Handling
///
/// Specify how to handle existing values:
///
/// ```swift
/// let config = SettingsImportConfiguration(
///     sources: [UserDefaultsDataSource()],
///     conflictStrategy: .keepExisting  // Don't overwrite existing values
/// )
/// ```
///
/// ## Key Mapping
///
/// Rename keys during import (useful for migrations):
///
/// ```swift
/// let config = SettingsImportConfiguration(
///     sources: [UserDefaultsDataSource()],
///     keyMapping: [
///         "oldKeyName": "newKeyName",
///         "legacyTheme": "appearance.theme"
///     ]
/// )
/// ```
public struct SettingsImportConfiguration: @unchecked Sendable {
    /// Data sources to import into, matched by `sourceIdentifier`.
    public let sources: [any SettingsDataSource]

    /// How to handle conflicts with existing values.
    public let conflictStrategy: ConflictStrategy

    /// Whether to validate only without making changes.
    ///
    /// When `true`, performs a dry run that validates the import
    /// but doesn't write any values.
    public let validateOnly: Bool

    /// Optional key mapping for migration scenarios.
    ///
    /// Maps source keys to destination keys. Keys not in the mapping
    /// are imported with their original names.
    public let keyMapping: [String: String]

    /// Optional app identifier to require.
    ///
    /// If set, import will fail if the package was created by a different app.
    /// If `nil`, packages from any app are accepted.
    public let requiredAppIdentifier: String?

    /// Whether to allow importing from a different app.
    public let allowDifferentApp: Bool

    /// Creates an import configuration.
    ///
    /// - Parameters:
    ///   - sources: Data sources to import into.
    ///   - conflictStrategy: How to handle conflicts. Defaults to `.overwrite`.
    ///   - validateOnly: Whether to validate only. Defaults to `false`.
    ///   - keyMapping: Optional key mapping.
    ///   - requiredAppIdentifier: Optional required app identifier.
    ///   - allowDifferentApp: Whether to allow importing from different apps. Defaults to `true`.
    public init(
        sources: [any SettingsDataSource],
        conflictStrategy: ConflictStrategy = .overwrite,
        validateOnly: Bool = false,
        keyMapping: [String: String] = [:],
        requiredAppIdentifier: String? = nil,
        allowDifferentApp: Bool = true
    ) {
        self.sources = sources
        self.conflictStrategy = conflictStrategy
        self.validateOnly = validateOnly
        self.keyMapping = keyMapping
        self.requiredAppIdentifier = requiredAppIdentifier
        self.allowDifferentApp = allowDifferentApp
    }
}

// MARK: - ConflictStrategy

extension SettingsImportConfiguration {
    /// Strategy for handling conflicts during import.
    public enum ConflictStrategy: Sendable, Hashable {
        /// Overwrite existing values with imported values.
        ///
        /// This is the default behavior.
        case overwrite

        /// Keep existing values and skip imported values.
        ///
        /// Only imports values for keys that don't already exist.
        case keepExisting

        /// Merge arrays and dictionaries, overwrite primitives.
        ///
        /// For array values: appends imported items to existing array.
        /// For dictionary values: merges keys, with imported values taking precedence.
        /// For other types: overwrites with imported value.
        case merge

        /// Fail the import if any conflicts exist.
        ///
        /// Use this when you want to ensure no existing data is modified.
        case failOnConflict
    }
}

// MARK: - Convenience Initializers

extension SettingsImportConfiguration {
    /// Creates a configuration for importing to standard UserDefaults.
    ///
    /// - Parameters:
    ///   - conflictStrategy: How to handle conflicts. Defaults to `.overwrite`.
    /// - Returns: A configured import configuration.
    public static func userDefaults(
        conflictStrategy: ConflictStrategy = .overwrite
    ) -> SettingsImportConfiguration {
        SettingsImportConfiguration(
            sources: [UserDefaultsDataSource()],
            conflictStrategy: conflictStrategy
        )
    }

    /// Creates a configuration that only validates without importing.
    ///
    /// - Parameter sources: Data sources to validate against.
    /// - Returns: A validation-only configuration.
    public static func validateOnly(
        sources: [any SettingsDataSource]
    ) -> SettingsImportConfiguration {
        SettingsImportConfiguration(
            sources: sources,
            validateOnly: true
        )
    }

    /// Creates a configuration that requires the package to be from a specific app.
    ///
    /// - Parameters:
    ///   - sources: Data sources to import into.
    ///   - appIdentifier: The required app identifier.
    ///   - conflictStrategy: How to handle conflicts.
    /// - Returns: A configured import configuration.
    public static func requireApp(
        _ appIdentifier: String,
        sources: [any SettingsDataSource],
        conflictStrategy: ConflictStrategy = .overwrite
    ) -> SettingsImportConfiguration {
        SettingsImportConfiguration(
            sources: sources,
            conflictStrategy: conflictStrategy,
            requiredAppIdentifier: appIdentifier,
            allowDifferentApp: false
        )
    }
}
