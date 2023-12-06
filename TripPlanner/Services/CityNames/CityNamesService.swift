//
//  CityNamesService.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public final class CityNamesService: CityNamesFetching {
    private let flightsLoader: FlightConnectionsFetching
    
    public init(flightsLoader: FlightConnectionsFetching) {
        self.flightsLoader = flightsLoader
    }
}

public extension CityNamesService {
    func fetchCityNames(searchType: SearchType) async throws -> [String] {
        let flightConnections = try await flightsLoader.fetchConnections()
        let cityNames = switch searchType {
        case .departure:
            flightConnections.map(\.from)
        case .destination:
            flightConnections.map(\.to)
        }
        return cityNames.sorted()
    }
}
