//
//  ConnectionsFetching.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public protocol ConnectionsFetching: Sendable {
    func fetchConnections() async throws -> [FlightConnection]
}
