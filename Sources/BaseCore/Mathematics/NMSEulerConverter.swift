//
//  NMSEulerConverter.swift
//  BaseCore
//
//  Created by Zach Baron on 10/31/26.
//

import Foundation
import simd

public enum NMSEulerConverter {

    public struct EulerAngles: Equatable, Sendable {

        public var pitch: Float
        public var yaw: Float
        public var roll: Float

        public init(
            pitch: Float,
            yaw: Float,
            roll: Float
        ) {
            self.pitch = pitch
            self.yaw = yaw
            self.roll = roll
        }
    }
    
    public static func createRotationMatrix(
        from angles: EulerAngles
    ) -> simd_float3x3 {

        let pitch = angles.pitch
        let yaw = angles.yaw
        let roll = angles.roll

        let pitchMatrix = simd_float3x3(
            SIMD3<Float>(1, 0, 0),
            SIMD3<Float>(0, cos(pitch), -sin(pitch)),
            SIMD3<Float>(0, sin(pitch), cos(pitch))
        )

        let yawMatrix = simd_float3x3(
            SIMD3<Float>(cos(yaw), 0, -sin(yaw)),
            SIMD3<Float>(0, 1, 0),
            SIMD3<Float>(sin(yaw), 0, cos(yaw))
        )

        let rollMatrix = simd_float3x3(
            SIMD3<Float>(cos(roll), sin(roll), 0),
            SIMD3<Float>(-sin(roll), cos(roll), 0),
            SIMD3<Float>(0, 0, 1)
        )

        return yawMatrix * pitchMatrix * rollMatrix
    }
    
    public static func extractEulerAngles(
        from matrix: simd_float3x3
    ) -> EulerAngles {

        // Our convention:
        // R = Yaw * Pitch * Roll
        // Positive pitch = nose up

        let pitch = asin(
            max(-1, min(1, matrix.columns.2.y))
        )

        let cosPitch = cos(pitch)

        let yaw: Float
        let roll: Float

        if abs(cosPitch) > 0.00001 {

            yaw = atan2(
                matrix.columns.2.x,
                matrix.columns.2.z
            )

            roll = atan2(
                matrix.columns.0.y,
                matrix.columns.1.y
            )

        } else {

            // Gimbal lock: yaw and roll are not
            // independently recoverable.
            roll = 0

            yaw = atan2(
                -matrix.columns.0.z,
                matrix.columns.0.x
            )
        }

        return EulerAngles(
            pitch: pitch,
            yaw: yaw,
            roll: roll
        )
    }
    
    public static func extractEulerAngles(
        from transform: NMSTransform
    ) throws -> EulerAngles {

        let matrix = try NMSCoordinateConverter.createMatrix(
            from: transform
        )

        let scale = simd_length(transform.up)

        let rotationMatrix = simd_float3x3(
            SIMD3<Float>(
                matrix.columns.0.x,
                matrix.columns.0.y,
                matrix.columns.0.z
            ) / scale,

            SIMD3<Float>(
                matrix.columns.1.x,
                matrix.columns.1.y,
                matrix.columns.1.z
            ) / scale,

            SIMD3<Float>(
                matrix.columns.2.x,
                matrix.columns.2.y,
                matrix.columns.2.z
            ) / scale
        )

        return extractEulerAngles(from: rotationMatrix)
    }
    
    public static func applyEulerAngles(
        _ angles: EulerAngles,
        to transform: NMSTransform
    ) -> NMSTransform {

        let rotationMatrix = createRotationMatrix(
            from: angles
        )

        // NMS stores scale in the magnitude of Up.
        let scale = simd_length(transform.up)

        // Column 1 represents the rotated Up vector.
        let newUp = rotationMatrix.columns.1 * scale

        // Column 2 represents the rotated forward direction.
        let newAt = rotationMatrix.columns.2

        return NMSTransform(
            position: transform.position,
            up: newUp,
            at: newAt
        )
    }
}
