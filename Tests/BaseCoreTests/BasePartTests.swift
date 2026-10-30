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
}