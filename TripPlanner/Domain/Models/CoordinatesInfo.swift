//
//  CoordinatesInfo.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public struct CoordinatesInfo: Sendable, Equatable {
    public let from: Coordinate
    public let to: Coordinate
    
    public init(from: Coordinate, to: Coordinate) {
        self.from = from
        self.to = to
    }
}
