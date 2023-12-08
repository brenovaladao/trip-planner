//
//  CityNamesServiceSpy.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation
import TripPlanner

@MainActor
final class CityNamesServiceSpy: CityNamesFetching {
    var mockResult: Result<[String], Error>
    private(set) var messages = [Messages]()
    
    enum Messages {
        case fetchCityNames
    }
    
    init(_ mockResult: Result<[String], Error>) {
        self.mockResult = mockResult
    }
    
    func fetchCityNames(searchType: ConnectionType) async throws -> [String] {
        messages.append(.fetchCityNames)
        return try mockResult.get()
    }
}
