//
//  RemoteFlightConnectionsService.swift.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public final class RemoteFlightConnectionsService {
    private let urlSession: URLSession
    private let endpoint: URL
    
    public init(urlSession: URLSession, endpoint: URL) {
        self.urlSession = urlSession
        self.endpoint = endpoint
    }
    
    private struct UnexpectedValuesError: Error {}
}

extension RemoteFlightConnectionsService: FlightConnectionsFetching {
    public func fetchConnections() async throws -> [FlightConnection] {
        let (data, response) = try await urlSession.data(from: endpoint)
        guard let response = response as? HTTPURLResponse else {
            throw UnexpectedValuesError()
        }
        return try FlightConnectionsMapper.map(data, from: response)
    }
}
