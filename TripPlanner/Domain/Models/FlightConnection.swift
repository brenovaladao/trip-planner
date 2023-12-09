//
//  FlightConnection.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public struct FlightConnection: Sendable, Equatable, Hashable {
    public let from: City
    public let to: City
    public let price: Decimal
    
    public init(from: City, to: City, price: Decimal) {
        self.from = from
        self.to = to
        self.price = price
    }
}
