//
//  City.swift
//  TripPlanner
//
//  Created by Breno Valadão on 08/12/23.
//

import Foundation

public struct City: Sendable, Hashable, Equatable {
    public let name: String
    public let coordinates: Coordinate
    
    public init(name: String, coordinates: Coordinate) {
        self.name = name
        self.coordinates = coordinates
    }

    public init(flightConnection: FlightConnection, type: ConnectionType) {
        switch type {
        case .departure:
            self = City(
                name: flightConnection.from,
                coordinates: flightConnection.coordinates.from
            )
        case .destination:
            self = City(
                name: flightConnection.to,
                coordinates: flightConnection.coordinates.to
            )
        }
    }
}
