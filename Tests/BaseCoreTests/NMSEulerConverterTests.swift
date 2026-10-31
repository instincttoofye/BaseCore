//
//  NMSEulerConverterTests.swift
//  BaseCore
//
//  Created by Zach Baron on 10/31/26.
//


import XCTest
import simd
@testable import BaseCore

final class NMSEulerConverterTests: XCTestCase {

    func testZeroRotationProducesIdentityMatrix() {

        let angles = NMSEulerConverter.EulerAngles(
            pitch: 0,
            yaw: 0,
            roll: 0
        )

        let matrix = NMSEulerConverter.createRotationMatrix(
            from: angles
        )

        let identity = matrix_identity_float3x3

        for column in 0..<3 {
            for row in 0..<3 {
                XCTAssertEqual(
                    matrix[column][row],
                    identity[column][row],
                    accuracy: 0.00001
                )
            }
        }
    }
    
    func testNinetyDegreeYawRotatesForwardVector() {

        let angles = NMSEulerConverter.EulerAngles(
            pitch: 0,
            yaw: .pi / 2,
            roll: 0
        )

        let matrix = NMSEulerConverter.createRotationMatrix(
            from: angles
        )

        let forward = SIMD3<Float>(0, 0, 1)

        let rotatedForward = matrix * forward

        XCTAssertEqual(
            rotatedForward.x,
            1,
            accuracy: 0.00001
        )

        XCTAssertEqual(
            rotatedForward.y,
            0,
            accuracy: 0.00001
        )

        XCTAssertEqual(
            rotatedForward.z,
            0,
            accuracy: 0.00001
        )
    }
    
    func testNinetyDegreePitchRotatesForwardVector() {

        let angles = NMSEulerConverter.EulerAngles(
            pitch: .pi / 2,
            yaw: 0,
            roll: 0
        )

        let matrix = NMSEulerConverter.createRotationMatrix(
            from: angles
        )

        let forward = SIMD3<Float>(0, 0, 1)

        let rotatedForward = matrix * forward

        XCTAssertEqual(rotatedForward.x, 0, accuracy: 0.00001)
        XCTAssertEqual(rotatedForward.y, 1, accuracy: 0.00001)
        XCTAssertEqual(rotatedForward.z, 0, accuracy: 0.00001)
    }
    
    func testNinetyDegreeRollRotatesRightVector() {

        let angles = NMSEulerConverter.EulerAngles(
            pitch: 0,
            yaw: 0,
            roll: .pi / 2
        )

        let matrix = NMSEulerConverter.createRotationMatrix(
            from: angles
        )

        let right = SIMD3<Float>(1, 0, 0)

        let rotatedRight = matrix * right

        XCTAssertEqual(rotatedRight.x, 0, accuracy: 0.00001)
        XCTAssertEqual(rotatedRight.y, 1, accuracy: 0.00001)
        XCTAssertEqual(rotatedRight.z, 0, accuracy: 0.00001)
    }
    
    func testEulerAnglesRoundTrip() {

        let original = NMSEulerConverter.EulerAngles(
            pitch: .pi / 6,
            yaw: .pi / 4,
            roll: .pi / 3
        )

        let matrix = NMSEulerConverter.createRotationMatrix(
            from: original
        )

        let extracted = NMSEulerConverter.extractEulerAngles(
            from: matrix
        )

        XCTAssertEqual(
            extracted.pitch,
            original.pitch,
            accuracy: 0.00001
        )

        XCTAssertEqual(
            extracted.yaw,
            original.yaw,
            accuracy: 0.00001
        )

        XCTAssertEqual(
            extracted.roll,
            original.roll,
            accuracy: 0.00001
        )
    }
    
    func testGimbalLockPreservesOrientation() {

        let original = NMSEulerConverter.EulerAngles(
            pitch: .pi / 2,
            yaw: .pi / 4,
            roll: .pi / 6
        )

        let originalMatrix = NMSEulerConverter.createRotationMatrix(
            from: original
        )

        let extracted = NMSEulerConverter.extractEulerAngles(
            from: originalMatrix
        )

        let reconstructedMatrix = NMSEulerConverter.createRotationMatrix(
            from: extracted
        )

        for column in 0..<3 {
            for row in 0..<3 {

                XCTAssertEqual(
                    reconstructedMatrix[column][row],
                    originalMatrix[column][row],
                    accuracy: 0.00001
                )
            }
        }
    }
}
