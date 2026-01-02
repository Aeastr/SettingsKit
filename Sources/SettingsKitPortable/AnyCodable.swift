import Foundation

/// A type-erased `Codable` value for JSON serialization.
///
/// This wrapper enables encoding and decoding of arbitrary JSON-compatible values
/// while maintaining type information for proper round-tripping.
public struct AnyCodable: Codable, Hashable, @unchecked Sendable {
    /// The underlying value.
    public let value: Any

    /// The type name of the underlying value.
    public let typeName: String

    // MARK: - Initialization

    /// Creates an `AnyCodable` wrapping the given value.
    ///
    /// - Parameter value: A JSON-compatible value (String, Int, Double, Bool, Array, Dictionary, nil).
    public init(_ value: Any) {
        self.value = value
        self.typeName = Self.typeName(for: value)
    }

    /// Creates an `AnyCodable` from a `SettingsExportable` value.
    ///
    /// - Parameter exportable: The exportable value.
    /// - Throws: If encoding fails.
    public init(exportable: any SettingsExportable) throws {
        let encoded = try exportable.encodeForExport()
        self.value = encoded
        self.typeName = String(describing: type(of: exportable))
    }

    // MARK: - Type Names

    private static func typeName(for value: Any) -> String {
        switch value {
        case is String: return "string"
        case is Bool: return "bool"
        case is Int: return "int"
        case is Double: return "double"
        case is Float: return "float"
        case is Data: return "data"
        case is Date: return "date"
        case is [Any]: return "array"
        case is [String: Any]: return "object"
        case is NSNull: return "null"
        default: return "unknown"
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        typeName = try container.decode(String.self, forKey: .type)

        switch typeName {
        case "string":
            value = try container.decode(String.self, forKey: .value)
        case "bool":
            value = try container.decode(Bool.self, forKey: .value)
        case "int":
            value = try container.decode(Int.self, forKey: .value)
        case "double":
            value = try container.decode(Double.self, forKey: .value)
        case "float":
            value = try container.decode(Float.self, forKey: .value)
        case "data":
            let base64 = try container.decode(String.self, forKey: .value)
            guard let data = Data(base64Encoded: base64) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Invalid base64 data"
                    )
                )
            }
            value = data
        case "date":
            let dateString = try container.decode(String.self, forKey: .value)
            guard let date = ISO8601DateFormatter().date(from: dateString) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Invalid ISO8601 date: \(dateString)"
                    )
                )
            }
            value = date
        case "array":
            value = try container.decode([AnyCodable].self, forKey: .value).map(\.value)
        case "object":
            value = try container.decode([String: AnyCodable].self, forKey: .value)
                .mapValues(\.value)
        case "null":
            value = NSNull()
        default:
            // Try to decode as a generic JSON value
            value = try container.decode(JSONValue.self, forKey: .value).unwrap()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .type)

        switch value {
        case let string as String:
            try container.encode(string, forKey: .value)
        case let bool as Bool:
            try container.encode(bool, forKey: .value)
        case let int as Int:
            try container.encode(int, forKey: .value)
        case let double as Double:
            try container.encode(double, forKey: .value)
        case let float as Float:
            try container.encode(float, forKey: .value)
        case let data as Data:
            try container.encode(data.base64EncodedString(), forKey: .value)
        case let date as Date:
            try container.encode(ISO8601DateFormatter().string(from: date), forKey: .value)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) }, forKey: .value)
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) }, forKey: .value)
        case is NSNull:
            try container.encodeNil(forKey: .value)
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Unsupported type: \(type(of: value))"
                )
            )
        }
    }

    // MARK: - Hashable

    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        lhs.typeName == rhs.typeName && areEqual(lhs.value, rhs.value)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(typeName)
        // Hash based on string representation for simplicity
        hasher.combine(String(describing: value))
    }

    private static func areEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        switch (lhs, rhs) {
        case let (l, r) as (String, String): return l == r
        case let (l, r) as (Bool, Bool): return l == r
        case let (l, r) as (Int, Int): return l == r
        case let (l, r) as (Double, Double): return l == r
        case let (l, r) as (Data, Data): return l == r
        case let (l, r) as (Date, Date): return l == r
        case is (NSNull, NSNull): return true
        default: return false
        }
    }
}

// MARK: - JSONValue Helper

/// A helper enum for decoding arbitrary JSON values.
private enum JSONValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([JSONValue])
    case object([String: JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSONValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.typeMismatch(
                JSONValue.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to decode JSON value"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }

    func unwrap() -> Any {
        switch self {
        case .string(let value): return value
        case .int(let value): return value
        case .double(let value): return value
        case .bool(let value): return value
        case .array(let value): return value.map { $0.unwrap() }
        case .object(let value): return value.mapValues { $0.unwrap() }
        case .null: return NSNull()
        }
    }
}
