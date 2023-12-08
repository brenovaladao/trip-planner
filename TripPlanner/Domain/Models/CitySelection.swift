//
//  CitySelection.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public struct CitySelection: Sendable, Equatable {
    public let type: ConnectionType
    public let cityName: String
    
    public init(type: ConnectionType, cityName: String) {
        self.type = type
        self.cityName = cityName
    }
}
