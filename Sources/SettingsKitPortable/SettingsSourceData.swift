import Foundation

/// Data for a single source within a settings package.
///
/// This represents the JSON content of a source file within the package.
public struct SettingsSourceData: Codable, Sendable {
    /// The format version of this source data.
    public let formatVersion: String

    /// The identifier of the source this data came from.
    public let sourceIdentifier: String

    /// The settings entries.
    public let settings: [SettingEntry]

    /// The current format version.
    public static let currentFormatVersion = "1.0"

    // MARK: - Initialization

    /// Creates source data.
    ///
    /// - Parameters:
    ///   - sourceIdentifier: The data source identifier.
    ///   - settings: The setting entries.
    public init(sourceIdentifier: String, settings: [SettingEntry]) {
        self.formatVersion = Self.currentFormatVersion
        self.sourceIdentifier = sourceIdentifier
        self.settings = settings
    }

    // MARK: - Lookup

    /// Returns the entry for the given key, if present.
    ///
    /// - Parameter key: The setting key.
    /// - Returns: The entry, or `nil` if not found.
    public func entry(forKey key: String) -> SettingEntry? {
        settings.first { $0.key == key }
    }

    /// Returns all keys in this source data.
    public var keys: [String] {
        settings.map(\.key)
    }
}

// MARK: - SettingEntry

extension SettingsSourceData {
    /// A single setting entry within the source data.
    public struct SettingEntry: Codable, Sendable, Hashable {
        /// The setting key.
        public let key: String

        /// The value wrapped in `AnyCodable`.
        public let value: AnyCodable

        /// Creates a setting entry.
        ///
        /// - Parameters:
        ///   - key: The setting key.
        ///   - value: The value as `AnyCodable`.
        public init(key: String, value: AnyCodable) {
            self.key = key
            self.value = value
        }

        /// Creates a setting entry from an exportable value.
        ///
        /// - Parameters:
        ///   - key: The setting key.
        ///   - exportable: The exportable value.
        /// - Throws: If encoding fails.
        public init(key: String, exportable: any SettingsExportable) throws {
            self.key = key
            self.value = try AnyCodable(exportable: exportable)
        }

        /// The type name of the value.
        public var typeName: String {
            value.typeName
        }

        /// The underlying value.
        public var rawValue: Any {
            value.value
        }
    }
}

// MARK: - Encoding/Decoding Helpers

extension SettingsSourceData {
    /// Encodes this source data to JSON data.
    ///
    /// - Returns: The JSON-encoded data.
    /// - Throws: If encoding fails.
    public func encodeToJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }

    /// Decodes source data from JSON data.
    ///
    /// - Parameter data: The JSON data.
    /// - Returns: The decoded source data.
    /// - Throws: If decoding fails.
    public static func decode(from data: Data) throws -> SettingsSourceData {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SettingsSourceData.self, from: data)
    }
}
