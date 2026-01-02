import Foundation

/// Configuration options for settings export.
///
/// Use this to specify which data sources to export, filtering options,
/// and metadata to include in the package.
///
/// ## Basic Usage
///
/// ```swift
/// let config = SettingsExportConfiguration(
///     sources: [UserDefaultsDataSource()],
///     appIdentifier: Bundle.main.bundleIdentifier ?? "com.example.app"
/// )
/// ```
///
/// ## With Filtering
///
/// Export only specific keys:
///
/// ```swift
/// let config = SettingsExportConfiguration(
///     sources: [UserDefaultsDataSource()],
///     appIdentifier: "com.example.app",
///     keyFilter: { key in
///         key.hasPrefix("user.") || key.hasPrefix("preferences.")
///     }
/// )
/// ```
///
/// ## With Metadata
///
/// Include custom metadata:
///
/// ```swift
/// let config = SettingsExportConfiguration(
///     sources: [UserDefaultsDataSource()],
///     appIdentifier: "com.example.app",
///     metadata: [
///         "exportReason": "backup",
///         "userName": currentUser.name
///     ]
/// )
/// ```
public struct SettingsExportConfiguration: @unchecked Sendable {
    /// Data sources to include in the export.
    public let sources: [any SettingsDataSource]

    /// The app's bundle identifier.
    public let appIdentifier: String

    /// Optional app version to include in the manifest.
    public let appVersion: String?

    /// Optional filter for which keys to export.
    ///
    /// Return `true` to include the key, `false` to exclude it.
    /// If `nil`, all keys are exported.
    public let keyFilter: (@Sendable (String) -> Bool)?

    /// Optional custom metadata to include in the package.
    public let metadata: [String: String]

    /// The package format to use.
    public let format: SettingsPackageFormat

    /// Creates an export configuration.
    ///
    /// - Parameters:
    ///   - sources: Data sources to export.
    ///   - appIdentifier: The app's bundle identifier.
    ///   - appVersion: Optional app version string.
    ///   - keyFilter: Optional key filter.
    ///   - metadata: Optional custom metadata.
    ///   - format: The package format. Defaults to `.default`.
    public init(
        sources: [any SettingsDataSource],
        appIdentifier: String,
        appVersion: String? = nil,
        keyFilter: (@Sendable (String) -> Bool)? = nil,
        metadata: [String: String] = [:],
        format: SettingsPackageFormat = .default
    ) {
        self.sources = sources
        self.appIdentifier = appIdentifier
        self.appVersion = appVersion
        self.keyFilter = keyFilter
        self.metadata = metadata
        self.format = format
    }
}

// MARK: - Convenience Initializers

extension SettingsExportConfiguration {
    /// Creates a configuration for exporting standard UserDefaults.
    ///
    /// - Parameters:
    ///   - appIdentifier: The app's bundle identifier.
    ///   - appVersion: Optional app version string.
    ///   - keyPrefix: Only export keys with this prefix.
    /// - Returns: A configured export configuration.
    public static func userDefaults(
        appIdentifier: String,
        appVersion: String? = nil,
        keyPrefix: String? = nil
    ) -> SettingsExportConfiguration {
        SettingsExportConfiguration(
            sources: [UserDefaultsDataSource(keyPrefix: keyPrefix)],
            appIdentifier: appIdentifier,
            appVersion: appVersion
        )
    }

    /// Creates a configuration for the current app bundle.
    ///
    /// Uses `Bundle.main.bundleIdentifier` and version info.
    ///
    /// - Parameter sources: Data sources to export.
    /// - Returns: A configured export configuration.
    public static func currentApp(
        sources: [any SettingsDataSource]
    ) -> SettingsExportConfiguration {
        let bundle = Bundle.main
        return SettingsExportConfiguration(
            sources: sources,
            appIdentifier: bundle.bundleIdentifier ?? "unknown",
            appVersion: bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        )
    }
}
