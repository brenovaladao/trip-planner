//
//  RouteSelectionCalculating.swift
//  TripPlanner
//
//  Created by Breno Valadão on 07/12/23.
//

import Foundation

public protocol RouteSelectionCalculating: Sendable {
    func calculateRoute(
        from departureCity: String,
        to destinationCity: String
    ) async throws -> Route
}
