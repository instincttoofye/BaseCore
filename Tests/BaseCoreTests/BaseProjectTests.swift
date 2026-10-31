//
//  BaseProjectTests.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//


import XCTest
import simd
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
    
    func testPresetWithoutBaseVersion() throws {

        let json = """
        {
            "Objects": [
                {
                    "ObjectID": "^BUILDPAVINGTALL",
                    "Position": [0.0, 0.0, 0.0],
                    "Up": [0.0, 1.0, 1.1920928955078125e-07],
                    "At": [0.0, -1.1920928955078125e-07, 1.0],
                    "Timestamp": 1539023700,
                    "UserData": 0
                }
            ]
        }
        """

        let project = try JSONDecoder().decode(
            BaseProject.self,
            from: Data(json.utf8)
        )

        XCTAssertEqual(project.parts.count, 1)
        XCTAssertEqual(project.baseVersion, 8)
        XCTAssertFalse(project.includesBaseVersion)

        let encoded = try JSONEncoder().encode(project)

        let restoredJSON = try JSONSerialization.jsonObject(
            with: encoded
        ) as! [String: Any]

        XCTAssertNil(restoredJSON["BaseVersion"])
        XCTAssertNotNil(restoredJSON["Objects"])
    }
    
    func testLampPostRoundTrip() throws {

        // Load the real NMS preset.
        let url = try XCTUnwrap(
            Bundle.module.url(
                forResource: "LampPostA",
                withExtension: "json"
            )
        )

        let originalData = try Data(contentsOf: url)

        // Decode the original preset.
        let original = try JSONDecoder().decode(
            BaseProject.self,
            from: originalData
        )

        // Encode it back into JSON.
        let exportedData = try JSONEncoder().encode(original)

        // Decode our exported JSON.
        let restored = try JSONDecoder().decode(
            BaseProject.self,
            from: exportedData
        )

        // Verify the project structure.
        XCTAssertEqual(original.parts.count, 10)
        XCTAssertEqual(restored.parts.count, 10)

        XCTAssertEqual(original.type, restored.type)
        XCTAssertEqual(original.baseVersion, restored.baseVersion)
        XCTAssertEqual(
            original.includesBaseVersion,
            restored.includesBaseVersion
        )

        // Verify every building component.
        for index in original.parts.indices {

            let originalPart = original.parts[index]
            let restoredPart = restored.parts[index]

            XCTAssertEqual(
                originalPart.objectID,
                restoredPart.objectID
            )

            XCTAssertEqual(
                originalPart.position,
                restoredPart.position
            )

            XCTAssertEqual(
                originalPart.up,
                restoredPart.up
            )

            XCTAssertEqual(
                originalPart.at,
                restoredPart.at
            )

            XCTAssertEqual(
                originalPart.timestamp,
                restoredPart.timestamp
            )

            XCTAssertEqual(
                originalPart.userData,
                restoredPart.userData
            )

            XCTAssertEqual(
                originalPart.extraFields,
                restoredPart.extraFields
            )
        }

        XCTAssertEqual(
            original.extraFields,
            restored.extraFields
        )
    }
    
    func testLampPostCoordinatePrecision() throws {

        let url = try XCTUnwrap(
            Bundle.module.url(
                forResource: "LampPostA",
                withExtension: "json"
            )
        )

        let data = try Data(contentsOf: url)

        let project = try JSONDecoder().decode(
            BaseProject.self,
            from: data
        )

        // Actual coordinate from LampPostA.json.
        let originalCoordinate = -0.4140320122241974

        // The second building component contains this position.
        let importedCoordinate = Double(
            project.parts[1].position[0]
        )

        let difference = abs(
            originalCoordinate - importedCoordinate
        )

        print("Original coordinate: \(originalCoordinate)")
        print("Imported coordinate: \(importedCoordinate)")
        print("Precision difference: \(difference)")

        XCTAssertLessThan(difference, 0.000001)
    }
    
    func testLampPostTransformMatrices() throws {

        let url = try XCTUnwrap(
            Bundle.module.url(
                forResource: "LampPostA",
                withExtension: "json"
            )
        )

        let data = try Data(contentsOf: url)

        let project = try JSONDecoder().decode(
            BaseProject.self,
            from: data
        )

        for part in project.parts {

            let transform = try part.transform

            let matrix = try NMSCoordinateConverter.createMatrix(
                from: transform
            )

            let restored = NMSCoordinateConverter.extractTransform(
                from: matrix
            )

            // Verify that matrix conversion preserves position.
            for axis in 0..<3 {
                XCTAssertEqual(
                    transform.position[axis],
                    restored.position[axis],
                    accuracy: 0.0001
                )
            }

            // Verify that the Up vector survives conversion.
            for axis in 0..<3 {
                XCTAssertEqual(
                    transform.up[axis],
                    restored.up[axis],
                    accuracy: 0.0001
                )
            }

            // At is normalized when extracted from the matrix.
            let normalizedAt = simd_normalize(transform.at)

            for axis in 0..<3 {
                XCTAssertEqual(
                    normalizedAt[axis],
                    restored.at[axis],
                    accuracy: 0.0001
                )
            }
        }
    }
    
    func testAllLampPostCoordinatePrecision() throws {

        let url = try XCTUnwrap(
            Bundle.module.url(
                forResource: "LampPostA",
                withExtension: "json"
            )
        )

        let data = try Data(contentsOf: url)

        // Decode original JSON numbers as Double.
        struct RawPart: Decodable {
            let position: [Double]
            let up: [Double]
            let at: [Double]

            enum CodingKeys: String, CodingKey {
                case position = "Position"
                case up = "Up"
                case at = "At"
            }
        }

        struct RawProject: Decodable {
            let objects: [RawPart]

            enum CodingKeys: String, CodingKey {
                case objects = "Objects"
            }
        }

        let raw = try JSONDecoder().decode(
            RawProject.self,
            from: data
        )

        let project = try JSONDecoder().decode(
            BaseProject.self,
            from: data
        )

        var maxDifference = 0.0
        var checkedComponents = 0

        for index in project.parts.indices {

            let original = raw.objects[index]
            let imported = project.parts[index]

            let vectorPairs: [([Double], [Float])] = [
                (original.position, imported.position),
                (original.up, imported.up),
                (original.at, imported.at)
            ]

            for (originalVector, importedVector) in vectorPairs {
                for axis in 0..<3 {

                    let difference = abs(
                        originalVector[axis] - Double(importedVector[axis])
                    )

                    maxDifference = max(maxDifference, difference)
                    checkedComponents += 1
                }
            }
        }

        print("Components checked: \(checkedComponents)")
        print("Maximum precision difference: \(maxDifference)")

        XCTAssertEqual(checkedComponents, 90)
        XCTAssertEqual(maxDifference, 0.0)
    }
}
