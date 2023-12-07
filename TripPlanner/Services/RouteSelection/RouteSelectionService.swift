//
//  RouteSelectionService.swift
//  TripPlanner
//
//  Created by Breno Valadão on 07/12/23.
//

import Foundation

public final class RouteSelectionService {
    private let flightConnectionsFetcher: FlightConnectionsFetching
    
    public struct RouteNotPossibleError: Error {}

    public init(flightConnectionsFetcher: FlightConnectionsFetching) {
        self.flightConnectionsFetcher = flightConnectionsFetcher
    }
}

extension RouteSelectionService: RouteSelectionCalculating {
    public func calculateRoute(
        from departureCity: String,
        to destinationCity: String
    ) async throws -> Route {
        let connections = try await flightConnectionsFetcher.fetchConnections()
        
        guard connections.contains(where: { $0.from == departureCity }),
              connections.contains(where: { $0.to == destinationCity })
        else {
            throw RouteNotPossibleError()
        }
        
        if let singleConnection = checkIfFlighConnectionIsNeeded(
            from: connections,
            departure: departureCity,
            destination: destinationCity
        ) {
            return Route(price: singleConnection.price, connections: [singleConnection])
        }
        
        let route = checkChepeastConnections(
            from: connections,
            departureCity: departureCity
        )
        
        let totalPrice = route.reduce(0) { $0 + $1.price }
        return Route(price: totalPrice, connections: route)
    }
    
    private func checkIfFlighConnectionIsNeeded(
        from connections: [FlightConnection],
        departure: String,
        destination: String
    ) -> FlightConnection? {
        connections.first(where: {
            $0.from == departure && $0.to == destination
        })
    }

    private func checkChepeastConnections(
        from connections: [FlightConnection],
        departureCity: String
    ) -> [FlightConnection] {
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

        return route
    }
}
