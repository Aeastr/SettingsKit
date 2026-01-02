import Foundation

/// The manifest describing a settings package.
///
/// The manifest contains metadata about the package, including when it was created,
/// which app created it, and what data sources are included.
public struct SettingsManifest: Codable, Sendable, Hashable {
    /// The format version of the manifest.
    ///
    /// Current version is "1.0".
    public let formatVersion: String

    /// When this package was created.
    public let createdAt: Date

    /// The bundle identifier of the app that created this package.
    public let appIdentifier: String

    /// The version of the app that created this package.
    public let appVersion: String?

    /// Information about the device that created this package.
    public let deviceInfo: DeviceInfo

    /// Data sources included in this package.
    public let sources: [SourceInfo]

    /// Custom metadata provided during export.
    public let metadata: [String: String]

    /// SHA-256 checksum for integrity verification.
    public let checksum: String

    /// The current format version.
    public static let currentFormatVersion = "1.0"

    // MARK: - Initialization

    /// Creates a new manifest.
    ///
    /// - Parameters:
    ///   - appIdentifier: The app's bundle identifier.
    ///   - appVersion: The app's version string.
    ///   - sources: Information about included data sources.
    ///   - metadata: Custom metadata.
    ///   - checksum: Integrity checksum.
    public init(
        appIdentifier: String,
        appVersion: String?,
        sources: [SourceInfo],
        metadata: [String: String],
        checksum: String
    ) {
        self.formatVersion = Self.currentFormatVersion
        self.createdAt = Date()
        self.appIdentifier = appIdentifier
        self.appVersion = appVersion
        self.deviceInfo = DeviceInfo.current
        self.sources = sources
        self.metadata = metadata
        self.checksum = checksum
    }

    // MARK: - Validation

    /// Checks if this manifest is compatible with the current format version.
    public var isCompatible: Bool {
        formatVersion == Self.currentFormatVersion
    }

    /// Checks if this manifest was created by the specified app.
    ///
    /// - Parameter bundleIdentifier: The app's bundle identifier.
    /// - Returns: `true` if the manifest was created by the specified app.
    public func isFrom(app bundleIdentifier: String) -> Bool {
        appIdentifier == bundleIdentifier
    }
}

// MARK: - DeviceInfo

extension SettingsManifest {
    /// Information about the device that created a settings package.
    public struct DeviceInfo: Codable, Sendable, Hashable {
        /// The platform (e.g., "iOS", "macOS", "watchOS").
        public let platform: String

        /// The OS version (e.g., "17.2").
        public let osVersion: String

        /// The device model name, if available (e.g., "iPhone 15 Pro").
        public let modelName: String?

        /// Creates device info.
        public init(platform: String, osVersion: String, modelName: String?) {
            self.platform = platform
            self.osVersion = osVersion
            self.modelName = modelName
        }

        /// Device info for the current device.
        public static var current: DeviceInfo {
            #if os(iOS)
            return DeviceInfo(
                platform: "iOS",
                osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
                modelName: deviceModelName()
            )
            #elseif os(macOS)
            return DeviceInfo(
                platform: "macOS",
                osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
                modelName: macModelName()
            )
            #elseif os(watchOS)
            return DeviceInfo(
                platform: "watchOS",
                osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
                modelName: nil
            )
            #elseif os(tvOS)
            return DeviceInfo(
                platform: "tvOS",
                osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
                modelName: nil
            )
            #elseif os(visionOS)
            return DeviceInfo(
                platform: "visionOS",
                osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
                modelName: nil
            )
            #else
            return DeviceInfo(
                platform: "unknown",
                osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
                modelName: nil
            )
            #endif
        }

        #if os(iOS)
        private static func deviceModelName() -> String? {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }
        #endif

        #if os(macOS)
        private static func macModelName() -> String? {
            var size = 0
            sysctlbyname("hw.model", nil, &size, nil, 0)
            var model = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.model", &model, &size, nil, 0)
            // Remove null terminator and decode
            if let nullIndex = model.firstIndex(of: 0) {
                model = Array(model[..<nullIndex])
            }
            return String(decoding: model.map { UInt8(bitPattern: $0) }, as: UTF8.self)
        }
        #endif
    }
}

// MARK: - SourceInfo

extension SettingsManifest {
    /// Information about a data source included in a settings package.
    public struct SourceInfo: Codable, Sendable, Hashable {
        /// The unique identifier of the data source.
        public let identifier: String

        /// The human-readable display name.
        public let displayName: String

        /// The number of settings exported from this source.
        public let keyCount: Int

        /// The relative path to the source's data file within the package.
        public let fileName: String

        /// Creates source info.
        public init(
            identifier: String,
            displayName: String,
            keyCount: Int,
            fileName: String
        ) {
            self.identifier = identifier
            self.displayName = displayName
            self.keyCount = keyCount
            self.fileName = fileName
        }
    }
}
