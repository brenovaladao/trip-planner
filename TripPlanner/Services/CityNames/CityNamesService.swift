//
//  CityNamesService.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public final class CityNamesService {
    private let flightConnectionsFetcher: FlightConnectionsFetching
    
    public init(flightConnectionsFetcher: FlightConnectionsFetching) {
        self.flightConnectionsFetcher = flightConnectionsFetcher
    }
}

extension CityNamesService: CityNamesFetching {
    public func fetchCityNames(searchType: ConnectionType) async throws -> [String] {
        let flightConnections = try await flightConnectionsFetcher.fetchConnections()
        return flightConnections.getCityNames(for: searchType)
    }
}

extension CityNamesService: CityNamesAutoCompleting {
    public func search(for query: String) async -> [String] {
        []
    }
}

extension [FlightConnection] {
    func getCityNames(for type: ConnectionType) -> [String] {
        switch type {
        case .departure: departureCityNames
        case .destination: destinationCityNames
        }
    }
    
    var departureCityNames: [String] {
        Set(map(\.from))
            .sorted()
    }
    
    var destinationCityNames: [String] {
        Set(map(\.to))
            .sorted()
    }
}
