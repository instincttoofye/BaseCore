//
//  BasePart.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//


import Foundation
import simd

public struct BasePart: Codable, Sendable {

    public var objectID: String
    public var position: [Float]
    public var up: [Float]
    public var at: [Float]
    public var timestamp: Int
    public var userData: Int
    
    public var extraFields: [String: JSONValue] = [:]

    public init(
        objectID: String,
        position: [Float],
        up: [Float],
        at: [Float],
        timestamp: Int,
        userData: Int
    ) {
        self.objectID = objectID
        self.position = position
        self.up = up
        self.at = at
        self.timestamp = timestamp
        self.userData = userData
    }
    
    public var transform: NMSTransform {
        get throws {
            guard position.count == 3,
                  up.count == 3,
                  at.count == 3 else {
                throw TransformError.invalidVectorLength
            }

            return NMSTransform(
                position: SIMD3<Float>(
                    position[0],
                    position[1],
                    position[2]
                ),
                up: SIMD3<Float>(
                    up[0],
                    up[1],
                    up[2]
                ),
                at: SIMD3<Float>(
                    at[0],
                    at[1],
                    at[2]
                )
            )
        }
    }
    
    public mutating func updateTransform(
        _ transform: NMSTransform
    ) {
        position = [
            transform.position.x,
            transform.position.y,
            transform.position.z
        ]

        up = [
            transform.up.x,
            transform.up.y,
            transform.up.z
        ]

        at = [
            transform.at.x,
            transform.at.y,
            transform.at.z
        ]
    }
    
    public enum TransformError: Error {
        case invalidVectorLength
    }

    enum CodingKeys: String, CodingKey {
        case objectID = "ObjectID"
        case position = "Position"
        case up = "Up"
        case at = "At"
        case timestamp = "Timestamp"
        case userData = "UserData"
    }
    
    private struct DynamicCodingKey: CodingKey {

        var stringValue: String
        var intValue: Int? { nil }

        init(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            return nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(
            keyedBy: DynamicCodingKey.self
        )

        func encode<T: Encodable>(
            _ value: T,
            forKey key: String
        ) throws {

            try container.encode(
                value,
                forKey: DynamicCodingKey(stringValue: key)
            )
        }

        try encode(objectID, forKey: "ObjectID")
        try encode(position, forKey: "Position")
        try encode(up, forKey: "Up")
        try encode(at, forKey: "At")
        try encode(timestamp, forKey: "Timestamp")
        try encode(userData, forKey: "UserData")

        let knownKeys: Set<String> = [
            "ObjectID",
            "Position",
            "Up",
            "At",
            "Timestamp",
            "UserData"
        ]

        for (key, value) in extraFields {

            guard !knownKeys.contains(key) else {
                continue
            }

            try encode(value, forKey: key)
        }
    }
    
    public init(from decoder: Decoder) throws {

        let container = try decoder.container(
            keyedBy: DynamicCodingKey.self
        )

        func decode<T: Decodable>(
            _ type: T.Type,
            forKey key: String
        ) throws -> T {

            try container.decode(
                type,
                forKey: DynamicCodingKey(stringValue: key)
            )
        }

        objectID = try decode(String.self, forKey: "ObjectID")
        position = try decode([Float].self, forKey: "Position")
        up = try decode([Float].self, forKey: "Up")
        at = try decode([Float].self, forKey: "At")
        timestamp = try decode(Int.self, forKey: "Timestamp")
        userData = try decode(Int.self, forKey: "UserData")

        let knownKeys: Set<String> = [
            "ObjectID",
            "Position",
            "Up",
            "At",
            "Timestamp",
            "UserData"
        ]

        extraFields = [:]

        for key in container.allKeys {

            guard !knownKeys.contains(key.stringValue) else {
                continue
            }

            extraFields[key.stringValue] = try container.decode(
                JSONValue.self,
                forKey: key
            )
        }
    }
}
