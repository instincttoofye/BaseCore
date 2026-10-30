//
//  NMSCoordinateConverterTests.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//


import XCTest
import simd
@testable import BaseCore

final class NMSCoordinateConverterTests: XCTestCase {

    func testIdentityTransform() throws {

        let transform = NMSTransform(
            position: SIMD3<Float>(0, 0, 0),
            up: SIMD3<Float>(0, 1, 0),
            at: SIMD3<Float>(0, 0, 1)
        )

        let matrix = try NMSCoordinateConverter.createMatrix(
            from: transform
        )

        XCTAssertEqual(matrix.columns.0.x, 1, accuracy: 0.0001)
        XCTAssertEqual(matrix.columns.1.y, 1, accuracy: 0.0001)
        XCTAssertEqual(matrix.columns.2.z, 1, accuracy: 0.0001)
    }

    func testPositionPreserved() throws {

        let transform = NMSTransform(
            position: SIMD3<Float>(12, 5, -8),
            up: SIMD3<Float>(0, 1, 0),
            at: SIMD3<Float>(0, 0, 1)
        )

        let matrix = try NMSCoordinateConverter.createMatrix(
            from: transform
        )

        XCTAssertEqual(matrix.columns.3.x, 12)
        XCTAssertEqual(matrix.columns.3.y, 5)
        XCTAssertEqual(matrix.columns.3.z, -8)
    }

    func testUniformScale() throws {

        let transform = NMSTransform(
            position: SIMD3<Float>(0, 0, 0),
            up: SIMD3<Float>(0, 2, 0),
            at: SIMD3<Float>(0, 0, 1)
        )

        let matrix = try NMSCoordinateConverter.createMatrix(
            from: transform
        )

        for index in 0..<3 {

            let column = matrix[index]

            let vector = SIMD3<Float>(
                column.x,
                column.y,
                column.z
            )

            XCTAssertEqual(
                simd_length(vector),
                2,
                accuracy: 0.0001
            )
        }
    }
    func testRoundTrip() throws {

        let original = NMSTransform(
            position: SIMD3<Float>(10, 20, 30),
            up: SIMD3<Float>(0, 2, 0),
            at: SIMD3<Float>(0, 0, 1)
        )

        let matrix = try NMSCoordinateConverter.createMatrix(
            from: original
        )

        let restored = NMSCoordinateConverter.extractTransform(
            from: matrix
        )

        XCTAssertEqual(restored.position, original.position)
        XCTAssertEqual(restored.up, original.up)
        XCTAssertEqual(restored.at, original.at)
    }
    
    func testRotationAroundYAxis() throws {

        let transform = NMSTransform(
            position: SIMD3<Float>(0, 0, 0),
            up: SIMD3<Float>(0, 1, 0),
            at: SIMD3<Float>(1, 0, 0)
        )

        let matrix = try NMSCoordinateConverter.createMatrix(
            from: transform
        )

        // A 90-degree rotation around Y.
        XCTAssertEqual(matrix.columns.0.x, 0, accuracy: 0.0001)
        XCTAssertEqual(matrix.columns.0.z, -1, accuracy: 0.0001)

        XCTAssertEqual(matrix.columns.1.y, 1, accuracy: 0.0001)

        XCTAssertEqual(matrix.columns.2.x, 1, accuracy: 0.0001)
        XCTAssertEqual(matrix.columns.2.z, 0, accuracy: 0.0001)
    }
}
