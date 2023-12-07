//
//  Coordinate.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public struct Coordinate: Sendable, Hashable, Equatable {
    public let lat: Double
    public let long: Double
    
    public init(lat: Double, long: Double) {
        self.lat = lat
        self.long = long
    }
}
