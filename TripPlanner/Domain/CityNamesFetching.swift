//
//  CityNamesFetching.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public protocol CityNamesFetching: Sendable {
    func fetchCityNames(searchType: ConnectionType) async throws -> [String]
}
