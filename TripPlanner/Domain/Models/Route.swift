//
//  Route.swift
//  TripPlanner
//
//  Created by Breno Valadão on 07/12/23.
//

import Foundation

public struct Route: Sendable, Equatable {
    public let price: Decimal
    public let cities: [String]
    
    public init(price: Decimal, cities: [String]) {
        self.price = price
        self.cities = cities
    }
}
