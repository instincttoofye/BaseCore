//
//  JSONValueTests.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//


import XCTest
@testable import BaseCore

final class JSONValueTests: XCTestCase {

    func testStringDecoding() throws {

        let data = Data(#""Hello, Traveller!""#.utf8)

        let value = try JSONDecoder().decode(
            JSONValue.self,
            from: data
        )

        XCTAssertEqual(
            value,
            .string("Hello, Traveller!")
        )
    }

    func testNumberDecoding() throws {

        let data = Data("42.5".utf8)

        let value = try JSONDecoder().decode(
            JSONValue.self,
            from: data
        )

        XCTAssertEqual(
            value,
            .number(Decimal(string: "42.5")!)
        )
    }

    func testBooleanDecoding() throws {

        let data = Data("true".utf8)

        let value = try JSONDecoder().decode(
            JSONValue.self,
            from: data
        )

        XCTAssertEqual(value, .bool(true))
    }

    func testNullDecoding() throws {

        let data = Data("null".utf8)

        let value = try JSONDecoder().decode(
            JSONValue.self,
            from: data
        )

        XCTAssertEqual(value, .null)
    }

    func testNestedObjectRoundTrip() throws {

        let json = """
        {
            "ObjectID": "^SOME_PART",
            "Metadata": {
                "Message": "Hello!",
                "Enabled": true,
                "Values": [1, 2, 3],
                "Extra": null
            }
        }
        """

        let originalData = Data(json.utf8)

        let decoded = try JSONDecoder().decode(
            JSONValue.self,
            from: originalData
        )

        let encodedData = try JSONEncoder().encode(decoded)

        let restored = try JSONDecoder().decode(
            JSONValue.self,
            from: encodedData
        )

        XCTAssertEqual(decoded, restored)
    }
}