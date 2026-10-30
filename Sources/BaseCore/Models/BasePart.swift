//
//  BasePart.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//


import Foundation

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
