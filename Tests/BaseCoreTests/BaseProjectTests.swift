//
//  BaseProjectTests.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//


import XCTest
@testable import BaseCore

final class BaseProjectTests: XCTestCase {

    func testDecodeBase() throws {

        let json = """
        {
            "Objects": [
                {
                    "ObjectID": "^SOME_PART",
                    "Position": [10, 20, 30],
                    "Up": [0, 1, 0],
                    "At": [0, 0, 1],
                    "Timestamp": 1234567890,
                    "UserData": 0
                }
            ],
            "BaseVersion": 8
        }
        """

        let project = try JSONDecoder().decode(
            BaseProject.self,
            from: Data(json.utf8)
        )

        XCTAssertEqual(project.type, .base)
        XCTAssertEqual(project.baseVersion, 8)
        XCTAssertEqual(project.parts.count, 1)
        XCTAssertEqual(
            project.parts.first?.objectID,
            "^SOME_PART"
        )
    }

    func testDecodePrefab() throws {

        let json = """
        {
            "Prefab": [],
            "BaseVersion": 8
        }
        """

        let project = try JSONDecoder().decode(
            BaseProject.self,
            from: Data(json.utf8)
        )

        XCTAssertEqual(project.type, .prefab)
        XCTAssertTrue(project.parts.isEmpty)
    }

    func testPreserveTopLevelMetadata() throws {

        let json = """
        {
            "Objects": [],
            "BaseVersion": 8,
            "Presets": [
                {
                    "Name": "TestPreset",
                    "Enabled": true
                }
            ],
            "CustomMetadata": {
                "Author": "Test"
            }
        }
        """

        let project = try JSONDecoder().decode(
            BaseProject.self,
            from: Data(json.utf8)
        )

        let encoded = try JSONEncoder().encode(project)

        let restored = try JSONDecoder().decode(
            BaseProject.self,
            from: encoded
        )

        XCTAssertEqual(
            restored.extraFields,
            project.extraFields
        )

        XCTAssertNotNil(
            restored.extraFields["Presets"]
        )
    }

    func testBaseRoundTrip() throws {

        let original = BaseProject(
            type: .base,
            parts: [
                BasePart(
                    objectID: "^SOME_PART",
                    position: [1, 2, 3],
                    up: [0, 1, 0],
                    at: [0, 0, 1],
                    timestamp: 1234567890,
                    userData: 0
                )
            ]
        )

        let encoded = try JSONEncoder().encode(original)

        let restored = try JSONDecoder().decode(
            BaseProject.self,
            from: encoded
        )

        XCTAssertEqual(restored.type, .base)
        XCTAssertEqual(restored.parts.count, 1)
        XCTAssertEqual(
            restored.parts[0].position,
            [1, 2, 3]
        )
    }
}