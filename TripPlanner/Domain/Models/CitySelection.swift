//
//  CitySelection.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public struct CitySelection: Sendable, Equatable {
    public let type: SearchType
    public let cityName: String
    
    public init(type: SearchType, cityName: String) {
        self.type = type
        self.cityName = cityName
    }
}
