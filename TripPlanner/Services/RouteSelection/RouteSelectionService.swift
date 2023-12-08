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
        
        let nodes = Set(connections.flatMap { [$0.from, $0.to] })
            .map { FlightNode(city: $0) }
        
        connections.forEach { flightConnection in
            guard let fromNode = nodes.first(where: { $0.city ==  flightConnection.from }),
                  let toNode = nodes.first(where: { $0.city ==  flightConnection.to })
            else { return }
            
            fromNode.neighbors.append(
                Neighbor(to: toNode, price: flightConnection.price)
            )
        }
        
        guard let departureNode = nodes.first(where: { $0.city ==  departureCity }),
              let destinationNode = nodes.first(where: { $0.city ==  destinationCity }),
              let path = Dijkstra.shortestPath(departure: departureNode, destination: destinationNode)
        else { throw RouteNotPossibleError() }
        
        let cityNames: [String] = path.lightPath
            .compactMap { $0 as? FlightNode }
            .map { $0.city }
        
        return Route(
            price: path.cumulativePrice,
            cities: map(cityNames: cityNames, in: connections)
        )
    }
}

private extension RouteSelectionService {
    func map(cityNames: [String], in connections: [FlightConnection]) -> [City] {
        cityNames.compactMap { name -> City? in
            let type: ConnectionType = name == cityNames.first ? .departure : .destination
            return getCityInfo(for: name, in: connections, as: type)
        }
    }
    
    func getCityInfo(
        for cityName: String,
        in connections: [FlightConnection],
        as connectionType: ConnectionType
    ) -> City? {
        connections
            .first(where: {
                switch connectionType {
                case .departure: $0.from == cityName
                case .destination: $0.to == cityName
                }
            })
            .map { City(flightConnection: $0, type: connectionType) }
    }
}
