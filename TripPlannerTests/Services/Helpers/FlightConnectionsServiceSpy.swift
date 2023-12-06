//
//  FlightConnectionsServiceSpy.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation
import TripPlanner

@MainActor
final class FlightConnectionsServiceSpy {
    let mockResult: Result<[FlightConnection], Error>
    private(set) var messages = [Messages]()
    
    enum Messages {
        case fetchConnections
    }
    
    init(_ mockResult: Result<[FlightConnection], Error>) {
        self.mockResult = mockResult
    }
}

extension FlightConnectionsServiceSpy: FlightConnectionsFetching {
    func fetchConnections() async throws -> [FlightConnection] {
        messages.append(.fetchConnections)
        return try mockResult.get()
    }
}
