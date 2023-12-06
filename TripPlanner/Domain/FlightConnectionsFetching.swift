//
//  FlightConnectionsFetching.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public protocol FlightConnectionsFetching: Sendable {
    func fetchConnections() async throws -> [FlightConnection]
}
