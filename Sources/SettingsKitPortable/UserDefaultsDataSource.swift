import Foundation

/// A data source for `UserDefaults` and `@AppStorage` values.
///
/// This is the built-in data source for exporting and importing settings
/// stored in `UserDefaults`.
///
/// ## Basic Usage
///
/// Export settings from standard `UserDefaults`:
///
/// ```swift
/// let source = UserDefaultsDataSource()
/// let config = SettingsExportConfiguration(
///     sources: [source],
///     appIdentifier: "com.example.app"
/// )
/// try await SettingsPortable.exportSettings(configuration: config, to: url)
/// ```
///
/// ## App Groups
///
/// Export settings from an app group suite:
///
/// ```swift
/// let source = UserDefaultsDataSource(suiteName: "group.com.example.app")
/// ```
///
/// ## Filtering Keys
///
/// Export only keys with a specific prefix:
///
/// ```swift
/// let source = UserDefaultsDataSource(keyPrefix: "user.")
/// ```
///
/// ## Excluding System Keys
///
/// By default, system keys with prefixes like "Apple", "NS", and "com.apple"
/// are excluded. You can customize this:
///
/// ```swift
/// let source = UserDefaultsDataSource(excludedPrefixes: ["Apple", "NS", "internal."])
/// ```
public final class UserDefaultsDataSource: SettingsDataSource, @unchecked Sendable {
    private let defaults: UserDefaults
    private let suiteName: String?
    private let keyPrefix: String?
    private let excludedPrefixes: [String]

    // MARK: - Initialization

    /// Creates a data source for standard `UserDefaults`.
    ///
    /// - Parameters:
    ///   - keyPrefix: Only export keys with this prefix. Pass `nil` to export all keys.
    ///   - excludedPrefixes: Prefixes to exclude from export.
    ///     Defaults to `["Apple", "NS", "com.apple"]`.
    public init(
        keyPrefix: String? = nil,
        excludedPrefixes: [String] = ["Apple", "NS", "com.apple"]
    ) {
        self.defaults = .standard
        self.suiteName = nil
        self.keyPrefix = keyPrefix
        self.excludedPrefixes = excludedPrefixes
    }

    /// Creates a data source for a specific `UserDefaults` suite.
    ///
    /// - Parameters:
    ///   - suiteName: The suite name (e.g., app group identifier).
    ///   - keyPrefix: Only export keys with this prefix.
    ///   - excludedPrefixes: Prefixes to exclude from export.
    /// - Throws: ``SettingsPortableError/dataSourceNotFound(identifier:)`` if the suite cannot be created.
    public init(
        suiteName: String,
        keyPrefix: String? = nil,
        excludedPrefixes: [String] = ["Apple", "NS", "com.apple"]
    ) throws {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            throw SettingsPortableError.dataSourceNotFound(
                identifier: "userdefaults.\(suiteName)"
            )
        }
        self.defaults = defaults
        self.suiteName = suiteName
        self.keyPrefix = keyPrefix
        self.excludedPrefixes = excludedPrefixes
    }

    // MARK: - SettingsDataSource

    public var sourceIdentifier: String {
        if let suiteName = suiteName {
            return "userdefaults.\(suiteName)"
        }
        return "userdefaults.standard"
    }

    public var displayName: String {
        if let suiteName = suiteName {
            return "UserDefaults (\(suiteName))"
        }
        return "UserDefaults (Standard)"
    }

    public func availableKeys() async throws -> [String] {
        let allKeys = defaults.dictionaryRepresentation().keys

        return allKeys.filter { key in
            // Apply prefix filter
            if let prefix = keyPrefix, !key.hasPrefix(prefix) {
                return false
            }

            // Apply exclusion filter
            for excluded in excludedPrefixes {
                if key.hasPrefix(excluded) {
                    return false
                }
            }

            return true
        }.sorted()
    }

    public func read(key: String) async throws -> (any SettingsExportable)? {
        guard let value = defaults.object(forKey: key) else {
            return nil
        }

        return try convertToExportable(value, forKey: key)
    }

    public func write(_ value: any SettingsExportable, forKey key: String) async throws {
        let encoded = try value.encodeForExport()
        defaults.set(encoded, forKey: key)
    }

    public func canImport(key: String) async -> Bool {
        // Allow all keys that pass the exclusion filter
        for excluded in excludedPrefixes {
            if key.hasPrefix(excluded) {
                return false
            }
        }
        return true
    }

    // MARK: - Value Conversion

    private func convertToExportable(_ value: Any, forKey key: String) throws -> any SettingsExportable {
        switch value {
        case let string as String:
            return string

        case let number as NSNumber:
            // Distinguish between Bool and numeric types
            // CFBoolean is toll-free bridged to NSNumber but has a specific type ID
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue
            } else if floor(number.doubleValue) == number.doubleValue {
                // Integer value
                return number.intValue
            } else {
                return number.doubleValue
            }

        case let data as Data:
            return data

        case let date as Date:
            return date

        case let url as URL:
            return url

        case let array as [Any]:
            return try encodeAsJSONString(array, forKey: key)

        case let dict as [String: Any]:
            return try encodeAsJSONString(dict, forKey: key)

        default:
            throw SettingsPortableError.encodingFailed(
                key: key,
                reason: "Unsupported type: \(type(of: value))"
            )
        }
    }

    private func encodeAsJSONString(_ value: Any, forKey key: String) throws -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys])
            guard let string = String(data: data, encoding: .utf8) else {
                throw SettingsPortableError.encodingFailed(
                    key: key,
                    reason: "Failed to encode as UTF-8"
                )
            }
            return string
        } catch let error as SettingsPortableError {
            throw error
        } catch {
            throw SettingsPortableError.encodingFailed(
                key: key,
                reason: "JSON serialization failed: \(error.localizedDescription)"
            )
        }
    }
}

// MARK: - Convenience Extensions

extension UserDefaultsDataSource {
    /// Creates a data source for standard `UserDefaults` with the given key prefix.
    ///
    /// - Parameter prefix: Only export keys with this prefix.
    /// - Returns: A configured data source.
    public static func standard(keyPrefix prefix: String? = nil) -> UserDefaultsDataSource {
        UserDefaultsDataSource(keyPrefix: prefix)
    }

    /// Creates a data source for an app group suite.
    ///
    /// - Parameters:
    ///   - groupIdentifier: The app group identifier (e.g., "group.com.example.app").
    ///   - keyPrefix: Only export keys with this prefix.
    /// - Returns: A configured data source.
    /// - Throws: ``SettingsPortableError/dataSourceNotFound(identifier:)`` if the suite cannot be created.
    public static func appGroup(
        _ groupIdentifier: String,
        keyPrefix: String? = nil
    ) throws -> UserDefaultsDataSource {
        try UserDefaultsDataSource(suiteName: groupIdentifier, keyPrefix: keyPrefix)
    }
}
