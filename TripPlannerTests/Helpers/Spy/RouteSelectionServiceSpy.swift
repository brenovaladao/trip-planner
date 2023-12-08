//
//  RouteSelectionServiceSpy.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 08/12/23.
//

import Foundation
import TripPlanner

@MainActor
final class RouteSelectionServiceSpy: RouteSelectionCalculating {
    private(set) var mockResult: Result<Route, Error>
    private(set) var messages = [Messages]()
    
    enum Messages {
        case calculateRoute
    }
    
    init(_ mockResult: Result<Route, Error>) {
        self.mockResult = mockResult
    }
    
    func calculateRoute(from departureCity: String, to destinationCity: String) async throws -> Route {
        messages.append(.calculateRoute)
        return try mockResult.get()
    }
}
