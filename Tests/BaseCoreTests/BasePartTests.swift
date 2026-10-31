//
//  BasePartTests.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//


import XCTest
@testable import BaseCore

final class BasePartTests: XCTestCase {

    func testDecodeBasePart() throws {

        let json = """
        {
            "ObjectID": "^SOME_PART",
            "Position": [10, 20, 30],
            "Up": [0, 1, 0],
            "At": [0, 0, 1],
            "Timestamp": 1234567890,
            "UserData": 0
        }
        """

        let data = Data(json.utf8)

        let part = try JSONDecoder().decode(
            BasePart.self,
            from: data
        )

        XCTAssertEqual(part.objectID, "^SOME_PART")
        XCTAssertEqual(part.position, [10, 20, 30])
        XCTAssertEqual(part.up, [0, 1, 0])
        XCTAssertEqual(part.at, [0, 0, 1])
        XCTAssertEqual(part.timestamp, 1234567890)
        XCTAssertEqual(part.userData, 0)
    }

    func testEncodeBasePart() throws {

        let part = BasePart(
            objectID: "^SOME_PART",
            position: [10, 20, 30],
            up: [0, 1, 0],
            at: [0, 0, 1],
            timestamp: 1234567890,
            userData: 0
        )

        let data = try JSONEncoder().encode(part)

        let decoded = try JSONDecoder().decode(
            BasePart.self,
            from: data
        )

        XCTAssertEqual(decoded.objectID, part.objectID)
        XCTAssertEqual(decoded.position, part.position)
        XCTAssertEqual(decoded.up, part.up)
        XCTAssertEqual(decoded.at, part.at)
        XCTAssertEqual(decoded.timestamp, part.timestamp)
        XCTAssertEqual(decoded.userData, part.userData)
    }
    
    func testUnknownFieldsSurviveRoundTrip() throws {

        let json = """
        {
            "ObjectID": "^SOME_PART",
            "Position": [10, 20, 30],
            "Up": [0, 1, 0],
            "At": [0, 0, 1],
            "Timestamp": 1234567890,
            "UserData": 0,
            "Message": "Hello, Traveller!",
            "SnapID": "12345",
            "CustomMetadata": {
                "Enabled": true,
                "Values": [1, 2, 3]
            }
        }
        """

        let originalData = Data(json.utf8)

        let part = try JSONDecoder().decode(
            BasePart.self,
            from: originalData
        )

        XCTAssertEqual(
            part.extraFields["Message"],
            .string("Hello, Traveller!")
        )

        XCTAssertEqual(
            part.extraFields["SnapID"],
            .string("12345")
        )

        let encodedData = try JSONEncoder().encode(part)

        let restored = try JSONDecoder().decode(
            BasePart.self,
            from: encodedData
        )

        XCTAssertEqual(
            restored.extraFields,
            part.extraFields
        )
    }
    
    func testPartTransform() throws {

        let part = BasePart(
            objectID: "^SOME_PART",
            position: [10, 20, 30],
            up: [0, 1, 0],
            at: [0, 0, 1],
            timestamp: 1234567890,
            userData: 0
        )

        let transform = try part.transform

        XCTAssertEqual(
            transform.position,
            SIMD3<Float>(10, 20, 30)
        )

        XCTAssertEqual(
            transform.up,
            SIMD3<Float>(0, 1, 0)
        )

        XCTAssertEqual(
            transform.at,
            SIMD3<Float>(0, 0, 1)
        )
    }

    func testInvalidTransformVectorLength() throws {

        let part = BasePart(
            objectID: "^SOME_PART",
            position: [10, 20],
            up: [0, 1, 0],
            at: [0, 0, 1],
            timestamp: 1234567890,
            userData: 0
        )

        XCTAssertThrowsError(try part.transform)
    }
    
    func testUpdateTransformPreservesMetadata() throws {

        var part = BasePart(
            objectID: "^SOME_PART",
            position: [0, 0, 0],
            up: [0, 1, 0],
            at: [0, 0, 1],
            timestamp: 1234567890,
            userData: 42
        )

        part.extraFields["Message"] = .string("Hello, Traveller!")

        let newTransform = NMSTransform(
            position: SIMD3<Float>(10, 20, 30),
            up: SIMD3<Float>(0, 1, 0),
            at: SIMD3<Float>(1, 0, 0)
        )

        part.updateTransform(newTransform)

        XCTAssertEqual(part.position, [10, 20, 30])
        XCTAssertEqual(part.up, [0, 1, 0])
        XCTAssertEqual(part.at, [1, 0, 0])

        XCTAssertEqual(part.objectID, "^SOME_PART")
        XCTAssertEqual(part.timestamp, 1234567890)
        XCTAssertEqual(part.userData, 42)

        XCTAssertEqual(
            part.extraFields["Message"],
            .string("Hello, Traveller!")
        )
    }
    
    func testCompleteTransformPipeline() throws {

        let json = """
        {
            "ObjectID": "^SOME_PART",
            "Position": [0, 0, 0],
            "Up": [0, 1, 0],
            "At": [0, 0, 1],
            "Timestamp": 1234567890,
            "UserData": 0,
            "Message": "Test"
        }
        """

        var part = try JSONDecoder().decode(
            BasePart.self,
            from: Data(json.utf8)
        )

        // JSON → BasePart → NMSTransform → Matrix
        let originalTransform = try part.transform

        var matrix = try NMSCoordinateConverter.createMatrix(
            from: originalTransform
        )

        // Simulate moving the part 10 units along X.
        matrix.columns.3.x += 10

        // Matrix → NMSTransform → BasePart
        let updatedTransform = NMSCoordinateConverter.extractTransform(
            from: matrix
        )

        part.updateTransform(updatedTransform)

        // BasePart → JSON → BasePart
        let encoded = try JSONEncoder().encode(part)

        let restored = try JSONDecoder().decode(
            BasePart.self,
            from: encoded
        )

        XCTAssertEqual(restored.position, [10, 0, 0])
        XCTAssertEqual(restored.up, [0, 1, 0])
        XCTAssertEqual(restored.at, [0, 0, 1])

        XCTAssertEqual(
            restored.extraFields["Message"],
            .string("Test")
        )
    }
}
