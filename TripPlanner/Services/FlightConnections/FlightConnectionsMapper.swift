//
//  FlightConnectionsMapper.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public struct FlightConnectionsMapper {
    private struct Root: Decodable {
        private let connections: [RemoteFlightConnection]
        
        private struct RemoteFlightConnection: Decodable {
            let from: String
            let to: String
            let price: Double
            let coordinates: RemoteCoordinatesInfo
        }
        
        private struct RemoteCoordinatesInfo: Decodable {
            let from: RemoteCoordinate
            let to: RemoteCoordinate
        }
        
        private struct RemoteCoordinate: Decodable {
            let lat: Double
            let long: Double
        }
        
        var flightConnections: [FlightConnection] {
            connections.map {
                FlightConnection(
                    from: $0.from,
                    to: $0.to,
                    price: $0.price,
                    coordinates: CoordinatesInfo(
                        from: Coordinate(
                            lat: $0.coordinates.from.lat,
                            long: $0.coordinates.from.long
                        ),
                        to: Coordinate(
                            lat: $0.coordinates.to.lat, 
                            long: $0.coordinates.to.long
                        )
                    )
                )
            }
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FlightConnection] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return root.flightConnections
    }
}
