import Foundation

/// Defines the file format for settings packages.
///
/// Use this to customize the file extension and UTI for your app's settings files.
///
/// ## Default Format
///
/// The default format uses `.settings` as the file extension:
///
/// ```swift
/// let format = SettingsPackageFormat.default
/// // format.fileExtension == "settings"
/// // format.uniformTypeIdentifier == "com.settingskit.settings-package"
/// ```
///
/// ## Custom Format
///
/// Create a custom format for your app:
///
/// ```swift
/// let format = SettingsPackageFormat(
///     fileExtension: "myappsettings",
///     uniformTypeIdentifier: "com.mycompany.myapp.settings"
/// )
/// ```
///
/// ## Xcode Setup
///
/// To enable your app to open settings files, add these to your Info.plist:
///
/// ### Exported Type Identifiers (UTExportedTypeDeclarations)
/// ```xml
/// <dict>
///     <key>UTTypeIdentifier</key>
///     <string>com.yourapp.settings</string>
///     <key>UTTypeDescription</key>
///     <string>App Settings</string>
///     <key>UTTypeConformsTo</key>
///     <array>
///         <string>public.data</string>
///         <string>public.archive</string>
///     </array>
///     <key>UTTypeTagSpecification</key>
///     <dict>
///         <key>public.filename-extension</key>
///         <array><string>settings</string></array>
///     </dict>
/// </dict>
/// ```
///
/// ### Document Types (CFBundleDocumentTypes)
/// ```xml
/// <dict>
///     <key>CFBundleTypeName</key>
///     <string>App Settings</string>
///     <key>LSHandlerRank</key>
///     <string>Owner</string>
///     <key>LSItemContentTypes</key>
///     <array><string>com.yourapp.settings</string></array>
/// </dict>
/// ```
public struct SettingsPackageFormat: Sendable, Hashable {
    /// The file extension without the leading dot (e.g., "settings").
    public let fileExtension: String

    /// The Uniform Type Identifier for this format (e.g., "com.yourapp.settings").
    public let uniformTypeIdentifier: String

    /// The MIME type for this format.
    public let mimeType: String

    /// A human-readable description of this format.
    public let typeDescription: String

    /// Creates a custom settings package format.
    ///
    /// - Parameters:
    ///   - fileExtension: The file extension without the leading dot.
    ///   - uniformTypeIdentifier: The UTI for this format.
    ///   - mimeType: The MIME type. Defaults to "application/x-settings".
    ///   - typeDescription: Human-readable description. Defaults to "Settings Package".
    public init(
        fileExtension: String,
        uniformTypeIdentifier: String,
        mimeType: String = "application/x-settings",
        typeDescription: String = "Settings Package"
    ) {
        self.fileExtension = fileExtension
        self.uniformTypeIdentifier = uniformTypeIdentifier
        self.mimeType = mimeType
        self.typeDescription = typeDescription
    }

    /// The default settings package format using `.settings` extension.
    public static let `default` = SettingsPackageFormat(
        fileExtension: "settings",
        uniformTypeIdentifier: "com.settingskit.settings-package",
        mimeType: "application/x-settings",
        typeDescription: "Settings Package"
    )

    /// Returns a filename with this format's extension.
    ///
    /// - Parameter baseName: The base filename without extension.
    /// - Returns: The filename with the format's extension.
    public func filename(for baseName: String) -> String {
        "\(baseName).\(fileExtension)"
    }

    /// Returns a URL by appending this format's extension to the base URL.
    ///
    /// - Parameter baseURL: The base URL without extension.
    /// - Returns: The URL with the format's extension appended.
    public func url(for baseURL: URL) -> URL {
        baseURL.appendingPathExtension(fileExtension)
    }

    /// Checks if a URL matches this format's extension.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: `true` if the URL has this format's extension.
    public func matches(_ url: URL) -> Bool {
        url.pathExtension.lowercased() == fileExtension.lowercased()
    }
}
