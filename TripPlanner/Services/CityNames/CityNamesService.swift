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
    public func search(for query: String, type: ConnectionType) async throws -> Set<String> {
        guard !query.isEmpty else { return [] }
        let cityNames = try await fetchCityNames(searchType: type)
        let sanitezedQuery = query.sanitized()
        return Set(cityNames)
            .filter { $0.sanitized().contains(sanitezedQuery) }
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
        Set(map(\.from.name))
            .sorted()
    }
    
    var destinationCityNames: [String] {
        Set(map(\.to.name))
            .sorted()
    }
}

extension String {
    /// Make lowercased and without whitespaces
    func sanitized() -> String {
        lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
