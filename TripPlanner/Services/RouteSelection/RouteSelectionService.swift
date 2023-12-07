//
//  RouteSelectionService.swift
//  TripPlanner
//
//  Created by Breno Valadão on 07/12/23.
//

import Foundation

public final class RouteSelectionService {
    private let flightConnectionsFetcher: FlightConnectionsFetching
    
    public init(flightConnectionsFetcher: FlightConnectionsFetching) {
        self.flightConnectionsFetcher = flightConnectionsFetcher
    }
}

extension RouteSelectionService: RouteSelectionCalculating {
    public func calculateRoute(from departureCity: String, to destinationCityName: String) async throws -> Route {
        let connections = try await flightConnectionsFetcher.fetchConnections()
        
        // TODO: calculate route
        
        throw RouteNotPossibleError()
    }
    
    struct RouteNotPossibleError: Error {}
}
