//
//  JSONValue.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//


import Foundation

public indirect enum JSONValue: Codable, Equatable, Sendable {

    case string(String)
    case number(Decimal)
    case bool(Bool)
    case array([JSONValue])
    case object([String: JSONValue])
    case null

    public init(from decoder: Decoder) throws {

        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Decimal.self) {
            self = .number(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported JSON value."
            )
        }
    }

    public func encode(to encoder: Encoder) throws {

        var container = encoder.singleValueContainer()

        switch self {

        case .string(let value):
            try container.encode(value)

        case .number(let value):
            try container.encode(value)

        case .bool(let value):
            try container.encode(value)

        case .array(let values):
            try container.encode(values)

        case .object(let values):
            try container.encode(values)

        case .null:
            try container.encodeNil()
        }
    }
}