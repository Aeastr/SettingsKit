import Foundation

/// A type that can be exported to and imported from portable settings format.
///
/// Conform to this protocol to enable custom types in settings export.
/// Most common Swift types already conform via the default `Codable` extension.
///
/// ## Example
///
/// ```swift
/// struct UserPreferences: SettingsExportable, Codable {
///     var theme: String
///     var fontSize: Int
/// }
/// ```
///
/// For types that don't conform to `Codable`, implement the protocol directly:
///
/// ```swift
/// extension MyCustomType: SettingsExportable {
///     func encodeForExport() throws -> Any {
///         return ["value": self.rawValue]
///     }
///
///     static func decodeFromImport(_ value: Any) throws -> Self {
///         guard let dict = value as? [String: Any],
///               let rawValue = dict["value"] as? String else {
///             throw SettingsPortableError.decodingFailed(
///                 key: "MyCustomType",
///                 reason: "Invalid format"
///             )
///         }
///         return MyCustomType(rawValue: rawValue)
///     }
/// }
/// ```
public protocol SettingsExportable: Sendable {
    /// Encode this value to a portable representation.
    ///
    /// The returned value must be JSON-compatible: `String`, `Int`, `Double`,
    /// `Bool`, `Array`, `Dictionary`, or `nil`.
    ///
    /// - Returns: A JSON-compatible value.
    /// - Throws: ``SettingsPortableError/encodingFailed(key:reason:)`` if encoding fails.
    func encodeForExport() throws -> Any

    /// Decode a value from portable representation.
    ///
    /// - Parameter value: The JSON-compatible value from the settings package.
    /// - Returns: The decoded value.
    /// - Throws: ``SettingsPortableError/decodingFailed(key:reason:)`` if decoding fails.
    static func decodeFromImport(_ value: Any) throws -> Self
}

// MARK: - Default Codable Implementation

extension SettingsExportable where Self: Codable {
    public func encodeForExport() throws -> Any {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.dataEncodingStrategy = .base64
        let data = try encoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
    }

    public static func decodeFromImport(_ value: Any) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.dataDecodingStrategy = .base64
        return try decoder.decode(Self.self, from: data)
    }
}

// MARK: - Built-in Conformances

extension String: SettingsExportable {
    public func encodeForExport() throws -> Any { self }
    public static func decodeFromImport(_ value: Any) throws -> String {
        guard let string = value as? String else {
            throw SettingsPortableError.decodingFailed(key: "String", reason: "Expected String, got \(type(of: value))")
        }
        return string
    }
}

extension Int: SettingsExportable {
    public func encodeForExport() throws -> Any { self }
    public static func decodeFromImport(_ value: Any) throws -> Int {
        if let int = value as? Int { return int }
        if let number = value as? NSNumber { return number.intValue }
        throw SettingsPortableError.decodingFailed(key: "Int", reason: "Expected Int, got \(type(of: value))")
    }
}

extension Double: SettingsExportable {
    public func encodeForExport() throws -> Any { self }
    public static func decodeFromImport(_ value: Any) throws -> Double {
        if let double = value as? Double { return double }
        if let number = value as? NSNumber { return number.doubleValue }
        throw SettingsPortableError.decodingFailed(key: "Double", reason: "Expected Double, got \(type(of: value))")
    }
}

extension Float: SettingsExportable {
    public func encodeForExport() throws -> Any { Double(self) }
    public static func decodeFromImport(_ value: Any) throws -> Float {
        if let float = value as? Float { return float }
        if let double = value as? Double { return Float(double) }
        if let number = value as? NSNumber { return number.floatValue }
        throw SettingsPortableError.decodingFailed(key: "Float", reason: "Expected Float, got \(type(of: value))")
    }
}

extension Bool: SettingsExportable {
    public func encodeForExport() throws -> Any { self }
    public static func decodeFromImport(_ value: Any) throws -> Bool {
        if let bool = value as? Bool { return bool }
        if let number = value as? NSNumber { return number.boolValue }
        throw SettingsPortableError.decodingFailed(key: "Bool", reason: "Expected Bool, got \(type(of: value))")
    }
}

extension Data: SettingsExportable {
    public func encodeForExport() throws -> Any {
        base64EncodedString()
    }

    public static func decodeFromImport(_ value: Any) throws -> Data {
        guard let string = value as? String else {
            throw SettingsPortableError.decodingFailed(key: "Data", reason: "Expected base64 String, got \(type(of: value))")
        }
        guard let data = Data(base64Encoded: string) else {
            throw SettingsPortableError.decodingFailed(key: "Data", reason: "Invalid base64 encoding")
        }
        return data
    }
}

extension Date: SettingsExportable {
    public func encodeForExport() throws -> Any {
        ISO8601DateFormatter().string(from: self)
    }

    public static func decodeFromImport(_ value: Any) throws -> Date {
        guard let string = value as? String else {
            throw SettingsPortableError.decodingFailed(key: "Date", reason: "Expected ISO8601 String, got \(type(of: value))")
        }
        guard let date = ISO8601DateFormatter().date(from: string) else {
            throw SettingsPortableError.decodingFailed(key: "Date", reason: "Invalid ISO8601 date format")
        }
        return date
    }
}

extension URL: SettingsExportable {
    public func encodeForExport() throws -> Any {
        absoluteString
    }

    public static func decodeFromImport(_ value: Any) throws -> URL {
        guard let string = value as? String else {
            throw SettingsPortableError.decodingFailed(key: "URL", reason: "Expected String, got \(type(of: value))")
        }
        guard let url = URL(string: string) else {
            throw SettingsPortableError.decodingFailed(key: "URL", reason: "Invalid URL format")
        }
        return url
    }
}

extension Array: SettingsExportable where Element: SettingsExportable {
    public func encodeForExport() throws -> Any {
        try map { try $0.encodeForExport() }
    }

    public static func decodeFromImport(_ value: Any) throws -> [Element] {
        guard let array = value as? [Any] else {
            throw SettingsPortableError.decodingFailed(key: "Array", reason: "Expected Array, got \(type(of: value))")
        }
        return try array.map { try Element.decodeFromImport($0) }
    }
}

extension Dictionary: SettingsExportable where Key == String, Value: SettingsExportable {
    public func encodeForExport() throws -> Any {
        try mapValues { try $0.encodeForExport() }
    }

    public static func decodeFromImport(_ value: Any) throws -> [String: Value] {
        guard let dict = value as? [String: Any] else {
            throw SettingsPortableError.decodingFailed(key: "Dictionary", reason: "Expected Dictionary, got \(type(of: value))")
        }
        return try dict.mapValues { try Value.decodeFromImport($0) }
    }
}

extension Optional: SettingsExportable where Wrapped: SettingsExportable {
    public func encodeForExport() throws -> Any {
        switch self {
        case .none:
            return NSNull()
        case .some(let value):
            return try value.encodeForExport()
        }
    }

    public static func decodeFromImport(_ value: Any) throws -> Wrapped? {
        if value is NSNull { return nil }
        return try Wrapped.decodeFromImport(value)
    }
}
