//
//  NMSTransform.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//

import Foundation
import simd

public struct NMSTransform: Equatable, Sendable {
    public var position: SIMD3<Float>
    public var up: SIMD3<Float>
    public var at: SIMD3<Float>
    
    public init(
        position: SIMD3<Float>,
        up: SIMD3<Float>,
        at: SIMD3<Float>
    ) {
        self.position = position
        self.up = up
        self.at = at
    }
}
