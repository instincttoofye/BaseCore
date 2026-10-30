//
//  NMSCoordinateConverter.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//

import Foundation
import simd

public enum NMSCoordinateConverter {

    public enum ConversionError: Error {
        case invalidUpVector
        case invalidAtVector
        case parallelVectors
    }

    public static func createMatrix(
        from transform: NMSTransform
    ) throws -> simd_float4x4 {

        let up = transform.up
        let at = transform.at

        let scale = simd_length(up)

        guard scale > 0 else {
            throw ConversionError.invalidUpVector
        }

        guard simd_length(at) > 0 else {
            throw ConversionError.invalidAtVector
        }

        let cross = simd_cross(up, at)

        guard simd_length(cross) > 0 else {
            throw ConversionError.parallelVectors
        }

        let right = simd_normalize(cross) * scale
        let scaledAt = simd_normalize(at) * scale

        return simd_float4x4(
            SIMD4<Float>(right, 0),
            SIMD4<Float>(up, 0),
            SIMD4<Float>(scaledAt, 0),
            SIMD4<Float>(transform.position, 1)
        )
    }

    public static func extractTransform(
        from matrix: simd_float4x4
    ) -> NMSTransform {

        let position = SIMD3<Float>(
            matrix.columns.3.x,
            matrix.columns.3.y,
            matrix.columns.3.z
        )

        let up = SIMD3<Float>(
            matrix.columns.1.x,
            matrix.columns.1.y,
            matrix.columns.1.z
        )

        let atColumn = SIMD3<Float>(
            matrix.columns.2.x,
            matrix.columns.2.y,
            matrix.columns.2.z
        )

        return NMSTransform(
            position: position,
            up: up,
            at: simd_normalize(atColumn)
        )
    }
}
