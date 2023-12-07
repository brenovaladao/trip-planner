//
//  FlightConnection.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public struct FlightConnection: Sendable, Equatable {
    public let from: String
    public let to: String
    public let price: Decimal
    public let coordinates: CoordinatesInfo
    
    public init(from: String, to: String, price: Decimal, coordinates: CoordinatesInfo) {
        self.from = from
        self.to = to
        self.price = price
        self.coordinates = coordinates
    }
}
