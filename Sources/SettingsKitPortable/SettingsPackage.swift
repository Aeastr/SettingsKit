import Foundation
import ZIPFoundation
import CryptoKit

/// Internal representation of a settings package (ZIP archive).
///
/// A settings package is a ZIP file containing:
/// - `manifest.json`: Package metadata
/// - `settings/`: Directory containing source data files
public struct SettingsPackage: Sendable {
    /// The package manifest.
    public let manifest: SettingsManifest

    /// The source data, keyed by source identifier.
    public let sourceData: [String: SettingsSourceData]

    // MARK: - Constants

    private static let manifestFileName = "manifest.json"
    private static let settingsDirectoryName = "settings"

    // MARK: - Loading

    /// Loads a settings package from a file URL.
    ///
    /// - Parameter url: The URL of the `.settings` file.
    /// - Returns: The loaded package.
    /// - Throws: ``SettingsPortableError`` if loading fails.
    public static func load(from url: URL) async throws -> SettingsPackage {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw SettingsPortableError.fileNotFound(path: url.path)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw SettingsPortableError.invalidPackage(
                reason: "Failed to read file: \(error.localizedDescription)"
            )
        }

        return try await load(from: data)
    }

    /// Loads a settings package from raw data.
    ///
    /// - Parameter data: The package data.
    /// - Returns: The loaded package.
    /// - Throws: ``SettingsPortableError`` if loading fails.
    public static func load(from data: Data) async throws -> SettingsPackage {
        let archive: Archive
        do {
            archive = try Archive(data: data, accessMode: .read)
        } catch {
            throw SettingsPortableError.archiveCorrupt(
                underlyingDescription: "Failed to open archive as ZIP: \(error.localizedDescription)"
            )
        }

        // Extract manifest
        guard let manifestEntry = archive[manifestFileName] else {
            throw SettingsPortableError.manifestMissing
        }

        var manifestData = Data()
        do {
            _ = try archive.extract(manifestEntry) { chunk in
                manifestData.append(chunk)
            }
        } catch {
            throw SettingsPortableError.extractionFailed(
                entry: manifestFileName,
                underlyingDescription: error.localizedDescription
            )
        }

        let manifest: SettingsManifest
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            manifest = try decoder.decode(SettingsManifest.self, from: manifestData)
        } catch {
            throw SettingsPortableError.manifestCorrupt(
                reason: error.localizedDescription
            )
        }

        // Validate version
        guard manifest.isCompatible else {
            throw SettingsPortableError.incompatibleVersion(
                found: manifest.formatVersion,
                required: SettingsManifest.currentFormatVersion
            )
        }

        // Extract source data files
        var sourceData: [String: SettingsSourceData] = [:]
        for source in manifest.sources {
            guard let entry = archive[source.fileName] else {
                throw SettingsPortableError.extractionFailed(
                    entry: source.fileName,
                    underlyingDescription: "Entry not found in archive"
                )
            }

            var entryData = Data()
            do {
                _ = try archive.extract(entry) { chunk in
                    entryData.append(chunk)
                }
            } catch {
                throw SettingsPortableError.extractionFailed(
                    entry: source.fileName,
                    underlyingDescription: error.localizedDescription
                )
            }

            do {
                let parsed = try SettingsSourceData.decode(from: entryData)
                sourceData[source.identifier] = parsed
            } catch {
                throw SettingsPortableError.decodingFailed(
                    key: source.identifier,
                    reason: "Failed to parse source data: \(error.localizedDescription)"
                )
            }
        }

        // Verify checksum
        let computedChecksum = try computeChecksum(for: sourceData)
        guard computedChecksum == manifest.checksum else {
            throw SettingsPortableError.archiveCorrupt(
                underlyingDescription: "Checksum mismatch - data may be corrupted"
            )
        }

        return SettingsPackage(manifest: manifest, sourceData: sourceData)
    }

    // MARK: - Writing

    /// Writes the package to a file URL.
    ///
    /// - Parameter url: The destination URL.
    /// - Throws: ``SettingsPortableError`` if writing fails.
    public func write(to url: URL) async throws {
        let data = try asData()
        do {
            try data.write(to: url)
        } catch {
            throw SettingsPortableError.fileWriteFailed(
                path: url.path,
                underlyingDescription: error.localizedDescription
            )
        }
    }

    /// Converts the package to raw data.
    ///
    /// - Returns: The package as ZIP data.
    /// - Throws: ``SettingsPortableError`` if encoding fails.
    public func asData() throws -> Data {
        let archive: Archive
        do {
            archive = try Archive(accessMode: .create)
        } catch {
            throw SettingsPortableError.packageCreationFailed(
                reason: "Failed to create ZIP archive: \(error.localizedDescription)"
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        // Add manifest
        let manifestData: Data
        do {
            manifestData = try encoder.encode(manifest)
        } catch {
            throw SettingsPortableError.encodingFailed(
                key: "manifest",
                reason: error.localizedDescription
            )
        }

        do {
            try archive.addEntry(
                with: Self.manifestFileName,
                type: .file,
                uncompressedSize: Int64(manifestData.count),
                provider: { (position: Int64, size: Int) in
                    manifestData.subdata(in: Int(position)..<(Int(position) + size))
                }
            )
        } catch {
            throw SettingsPortableError.compressionFailed(
                entry: Self.manifestFileName,
                underlyingDescription: error.localizedDescription
            )
        }

        // Add source data files
        for source in manifest.sources {
            guard let data = sourceData[source.identifier] else { continue }

            let jsonData: Data
            do {
                jsonData = try data.encodeToJSON()
            } catch {
                throw SettingsPortableError.encodingFailed(
                    key: source.identifier,
                    reason: error.localizedDescription
                )
            }

            do {
                try archive.addEntry(
                    with: source.fileName,
                    type: .file,
                    uncompressedSize: Int64(jsonData.count),
                    provider: { (position: Int64, size: Int) in
                        jsonData.subdata(in: Int(position)..<(Int(position) + size))
                    }
                )
            } catch {
                throw SettingsPortableError.compressionFailed(
                    entry: source.fileName,
                    underlyingDescription: error.localizedDescription
                )
            }
        }

        guard let archiveData = archive.data else {
            throw SettingsPortableError.packageCreationFailed(
                reason: "Failed to finalize ZIP archive"
            )
        }

        return archiveData
    }

    // MARK: - Checksum

    /// Computes a SHA-256 checksum for the given source data.
    ///
    /// - Parameter sourceData: The source data to checksum.
    /// - Returns: The hex-encoded checksum.
    /// - Throws: If encoding fails.
    public static func computeChecksum(
        for sourceData: [String: SettingsSourceData]
    ) throws -> String {
        var hasher = SHA256()

        // Sort by source identifier for deterministic ordering
        for identifier in sourceData.keys.sorted() {
            guard let data = sourceData[identifier] else { continue }
            let jsonData = try data.encodeToJSON()
            hasher.update(data: jsonData)
        }

        let digest = hasher.finalize()
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Building

extension SettingsPackage {
    /// A builder for creating settings packages.
    public struct Builder: Sendable {
        private var sourceData: [String: SettingsSourceData] = [:]
        private var sourceInfos: [SettingsManifest.SourceInfo] = []

        /// Creates a new builder.
        public init() {}

        /// Adds source data to the package.
        ///
        /// - Parameters:
        ///   - data: The source data.
        ///   - source: The data source it came from.
        /// - Returns: Self for chaining.
        public mutating func addSource(
            _ data: SettingsSourceData,
            from source: any SettingsDataSource
        ) {
            let fileName = "\(SettingsPackage.settingsDirectoryName)/\(source.sourceIdentifier).json"
            sourceData[source.sourceIdentifier] = data
            sourceInfos.append(SettingsManifest.SourceInfo(
                identifier: source.sourceIdentifier,
                displayName: source.displayName,
                keyCount: data.settings.count,
                fileName: fileName
            ))
        }

        /// Builds the package with the given configuration.
        ///
        /// - Parameters:
        ///   - appIdentifier: The app's bundle identifier.
        ///   - appVersion: The app's version string.
        ///   - metadata: Custom metadata.
        /// - Returns: The built package.
        /// - Throws: If building fails.
        public func build(
            appIdentifier: String,
            appVersion: String?,
            metadata: [String: String]
        ) throws -> SettingsPackage {
            let checksum = try SettingsPackage.computeChecksum(for: sourceData)

            let manifest = SettingsManifest(
                appIdentifier: appIdentifier,
                appVersion: appVersion,
                sources: sourceInfos,
                metadata: metadata,
                checksum: checksum
            )

            return SettingsPackage(manifest: manifest, sourceData: sourceData)
        }
    }
}
