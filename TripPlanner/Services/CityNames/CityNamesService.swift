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
        let cityNames = switch searchType {
        case .departure:
            flightConnections.map(\.from)
        case .destination:
            flightConnections.map(\.to)
        }
        return Set(cityNames).sorted()
    }
}

extension CityNamesService: CityNamesAutoCompleting {
    public func search(for query: String) async -> [String] {
        []
    }
}
