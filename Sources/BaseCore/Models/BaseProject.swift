//
//  BaseProject.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//

import Foundation

public enum BaseProjectType: Sendable {
    case base
    case prefab
}

public struct BaseProject: Codable, Sendable {

    public var type: BaseProjectType
    public var parts: [BasePart]
    public var baseVersion: Int
    public var extraFields: [String: JSONValue]

    public init(
        type: BaseProjectType = .base,
        parts: [BasePart] = [],
        baseVersion: Int = 8,
        extraFields: [String: JSONValue] = [:]
    ) {
        self.type = type
        self.parts = parts
        self.baseVersion = baseVersion
        self.extraFields = extraFields
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
    
    public init(from decoder: Decoder) throws {

        let container = try decoder.container(
            keyedBy: DynamicCodingKey.self
        )

        let objectsKey = DynamicCodingKey(stringValue: "Objects")
        let prefabKey = DynamicCodingKey(stringValue: "Prefab")
        let versionKey = DynamicCodingKey(stringValue: "BaseVersion")

        if container.contains(objectsKey) {

            type = .base

            parts = try container.decode(
                [BasePart].self,
                forKey: objectsKey
            )

        } else if container.contains(prefabKey) {

            type = .prefab

            parts = try container.decode(
                [BasePart].self,
                forKey: prefabKey
            )

        } else {

            throw DecodingError.dataCorruptedError(
                forKey: objectsKey,
                in: container,
                debugDescription: "Expected Objects or Prefab."
            )
        }

        baseVersion = try container.decode(
            Int.self,
            forKey: versionKey
        )

        let knownKeys: Set<String> = [
            "Objects",
            "Prefab",
            "BaseVersion"
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
    
    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(
            keyedBy: DynamicCodingKey.self
        )

        let partsKey = DynamicCodingKey(
            stringValue: type == .base ? "Objects" : "Prefab"
        )

        let versionKey = DynamicCodingKey(
            stringValue: "BaseVersion"
        )

        try container.encode(parts, forKey: partsKey)
        try container.encode(baseVersion, forKey: versionKey)

        let knownKeys: Set<String> = [
            "Objects",
            "Prefab",
            "BaseVersion"
        ]

        for (key, value) in extraFields {

            guard !knownKeys.contains(key) else {
                continue
            }

            try container.encode(
                value,
                forKey: DynamicCodingKey(stringValue: key)
            )
        }
    }
}
