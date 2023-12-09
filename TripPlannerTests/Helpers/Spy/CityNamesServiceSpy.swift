//
//  CityNamesServiceSpy.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation
import TripPlanner

@MainActor
final class CityNamesServiceSpy: CityNamesFetching, CityNamesAutoCompleting {
    var citiesMockResult: Result<[String], Error>
    var autoCompleteMockResult: Result<Set<String>, Error>
    private(set) var messages = [Messages]()
    
    enum Messages {
        case fetchCityNames
        case autoCompleteSearch
    }
    
    init(
        citiesMockResult: Result<[String], Error>,
        autoCompleteMockResult: Result<Set<String>, Error>
    ) {
        self.citiesMockResult = citiesMockResult
        self.autoCompleteMockResult = autoCompleteMockResult
    }
    
    func fetchCityNames(searchType: ConnectionType) async throws -> [String] {
        messages.append(.fetchCityNames)
        return try citiesMockResult.get()
    }
    
    func search(for query: String, type: ConnectionType) async throws -> Set<String> {
        messages.append(.autoCompleteSearch)
        return try autoCompleteMockResult.get()
    }
}
