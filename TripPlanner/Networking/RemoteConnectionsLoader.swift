//
//  RemoteConnectionsLoader.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public final class RemoteConnectionsLoader {}

extension RemoteConnectionsLoader: ConnectionsFetching {
    public func fetchConnections() async throws -> [FlightConnection] {
        []
    }
}
