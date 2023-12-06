//
//  FlightSearchViewModelTests.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 06/12/23.
//

import Combine
import TripPlanner
import XCTest

@MainActor
final class FlightSearchViewModelTests: XCTestCase {
    
}

private extension FlightSearchViewModelTests {
    func makeSUT(
        mockResult: Result<[String], Error> = .success([]),
        searchType: SearchType = .departure,
        citySelectionSubject: PassthroughSubject<CitySelection, Never> = .init(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FlightSearchViewModel {
        let spy = CityNamesServiceSpy(mockResult)
        let sut = FlightSearchViewModel(
            searchType: searchType,
            citySelectionSubject: citySelectionSubject,
            cityNamesService: spy
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)

        return sut
    }
}
