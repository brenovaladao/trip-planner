//
//  Route.swift
//  TripPlanner
//
//  Created by Breno Valadão on 07/12/23.
//

import Foundation

public struct Route: Sendable, Equatable, Hashable {
    public let price: Decimal
    public let cities: [City]
    
    public init(price: Decimal, cities: [City]) {
        self.price = price
        self.cities = cities
    }
}
