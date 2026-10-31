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
}
