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
    public func calculateRoute(
        from departureCity: String,
        to destinationCity: String
    ) async throws -> (Decimal, [FlightConnection]) {
        let connections = try await flightConnectionsFetcher.fetchConnections()
        
        guard connections.contains(
            where: { $0.from == departureCity || $0.to == destinationCity }
        ) else {
            throw RouteNotPossibleError()
        }
        
        var availableCities = Set(connections.flatMap { [$0.from, $0.to] })
        var currentCity = departureCity
        availableCities.remove(currentCity)
        
        var route = [FlightConnection]()
        
        while !availableCities.isEmpty {
            let possibleFlights = connections.filter {
                $0.from == currentCity && availableCities.contains($0.to)
            }
            
            guard let cheapestConnection = possibleFlights.min(
                by: { $0.price < $1.price }
            ) else { break }
            
            availableCities.remove(cheapestConnection.to)
            route.append(cheapestConnection)
            currentCity = cheapestConnection.to
        }
        
        let totalPrice = route.reduce(0) { $0 + $1.price }
        return (route.reduce(0) { $0 + $1.price }, route)
    }
    
    public struct RouteNotPossibleError: Error {}
}
