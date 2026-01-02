import Foundation

/// A data source that provides settings for export and accepts settings on import.
///
/// Implement this protocol to enable export/import for custom storage backends.
/// The framework provides ``UserDefaultsDataSource`` for standard `UserDefaults`
/// and `@AppStorage` usage.
///
/// ## Implementing a Custom Data Source
///
/// ```swift
/// struct KeychainDataSource: SettingsDataSource {
///     let sourceIdentifier = "keychain"
///     let displayName = "Keychain"
///
///     func availableKeys() async throws -> [String] {
///         // Return all keys stored in keychain
///         return try KeychainManager.allKeys()
///     }
///
///     func read(key: String) async throws -> (any SettingsExportable)? {
///         return try KeychainManager.read(key: key)
///     }
///
///     func write(_ value: any SettingsExportable, forKey key: String) async throws {
///         try KeychainManager.write(value, forKey: key)
///     }
/// }
/// ```
public protocol SettingsDataSource: Sendable {
    /// Unique identifier for this data source.
    ///
    /// This identifier is used in the settings package manifest to match
    /// data sources during import. Use a consistent identifier across
    /// app versions.
    var sourceIdentifier: String { get }

    /// Human-readable name for this data source.
    ///
    /// Displayed in UI and logs to help users identify the source.
    var displayName: String { get }

    /// Returns all keys available for export from this data source.
    ///
    /// - Returns: Array of setting keys that can be exported.
    /// - Throws: ``SettingsPortableError/readFailed(source:key:underlyingDescription:)``
    ///   if reading keys fails.
    func availableKeys() async throws -> [String]

    /// Reads a setting value for export.
    ///
    /// - Parameter key: The setting key to read.
    /// - Returns: The exportable value, or `nil` if not set.
    /// - Throws: ``SettingsPortableError/readFailed(source:key:underlyingDescription:)``
    ///   if reading fails.
    func read(key: String) async throws -> (any SettingsExportable)?

    /// Writes a setting value during import.
    ///
    /// - Parameters:
    ///   - value: The value to write.
    ///   - key: The setting key.
    /// - Throws: ``SettingsPortableError/writeFailed(source:key:underlyingDescription:)``
    ///   if writing fails.
    func write(_ value: any SettingsExportable, forKey key: String) async throws

    /// Validates whether a key can be imported.
    ///
    /// Override this to prevent importing certain keys or to perform
    /// pre-flight validation.
    ///
    /// - Parameter key: The key to validate.
    /// - Returns: `true` if this key can be written, `false` otherwise.
    func canImport(key: String) async -> Bool

    /// Called before import begins.
    ///
    /// Use this to prepare the data source for batch writes, start a transaction,
    /// or perform other setup.
    func prepareForImport() async throws

    /// Called after import completes successfully.
    ///
    /// Use this to commit a transaction or perform cleanup.
    func finalizeImport() async throws

    /// Called if import fails after `prepareForImport` was called.
    ///
    /// Use this to rollback changes if your data source supports transactions.
    func rollbackImport() async throws
}

// MARK: - Default Implementations

extension SettingsDataSource {
    public func canImport(key: String) async -> Bool {
        true
    }

    public func prepareForImport() async throws {
        // Default: no-op
    }

    public func finalizeImport() async throws {
        // Default: no-op
    }

    public func rollbackImport() async throws {
        // Default: no-op
    }
}

// MARK: - Type Erasure

/// A type-erased wrapper for any `SettingsDataSource`.
public struct AnySettingsDataSource: SettingsDataSource {
    private let _sourceIdentifier: @Sendable () -> String
    private let _displayName: @Sendable () -> String
    private let _availableKeys: @Sendable () async throws -> [String]
    private let _read: @Sendable (String) async throws -> (any SettingsExportable)?
    private let _write: @Sendable (any SettingsExportable, String) async throws -> Void
    private let _canImport: @Sendable (String) async -> Bool
    private let _prepareForImport: @Sendable () async throws -> Void
    private let _finalizeImport: @Sendable () async throws -> Void
    private let _rollbackImport: @Sendable () async throws -> Void

    public init<S: SettingsDataSource>(_ source: S) {
        _sourceIdentifier = { source.sourceIdentifier }
        _displayName = { source.displayName }
        _availableKeys = { try await source.availableKeys() }
        _read = { try await source.read(key: $0) }
        _write = { try await source.write($0, forKey: $1) }
        _canImport = { await source.canImport(key: $0) }
        _prepareForImport = { try await source.prepareForImport() }
        _finalizeImport = { try await source.finalizeImport() }
        _rollbackImport = { try await source.rollbackImport() }
    }

    public var sourceIdentifier: String { _sourceIdentifier() }
    public var displayName: String { _displayName() }

    public func availableKeys() async throws -> [String] {
        try await _availableKeys()
    }

    public func read(key: String) async throws -> (any SettingsExportable)? {
        try await _read(key)
    }

    public func write(_ value: any SettingsExportable, forKey key: String) async throws {
        try await _write(value, key)
    }

    public func canImport(key: String) async -> Bool {
        await _canImport(key)
    }

    public func prepareForImport() async throws {
        try await _prepareForImport()
    }

    public func finalizeImport() async throws {
        try await _finalizeImport()
    }

    public func rollbackImport() async throws {
        try await _rollbackImport()
    }
}
