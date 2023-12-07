//
//  Route.swift
//  TripPlanner
//
//  Created by Breno Valadão on 07/12/23.
//

import Foundation

public struct Route: Sendable, Equatable, Hashable {
    public let price: Decimal
    public let connections: [FlightConnection]
    
    public init(price: Decimal, connections: [FlightConnection]) {
        self.price = price
        self.connections = connections
    }
}
