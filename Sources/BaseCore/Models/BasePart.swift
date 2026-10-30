//
//  BasePart.swift
//  BaseCore
//
//  Created by Zach Baron on 10/30/26.
//


import Foundation

public struct BasePart: Codable, Sendable {

    public var objectID: String
    public var position: [Float]
    public var up: [Float]
    public var at: [Float]
    public var timestamp: Int
    public var userData: Int

    public init(
        objectID: String,
        position: [Float],
        up: [Float],
        at: [Float],
        timestamp: Int,
        userData: Int
    ) {
        self.objectID = objectID
        self.position = position
        self.up = up
        self.at = at
        self.timestamp = timestamp
        self.userData = userData
    }

    enum CodingKeys: String, CodingKey {
        case objectID = "ObjectID"
        case position = "Position"
        case up = "Up"
        case at = "At"
        case timestamp = "Timestamp"
        case userData = "UserData"
    }
}