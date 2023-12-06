//
//  CityNamesServiceTests.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 06/12/23.
//

import TripPlanner
import XCTest

@MainActor
final class CityNamesServiceTests: XCTestCase {
    func test_fetchCityNames_noSideEffectsOnInitialization() {
        let (_, spy) = makeSUT(mockResult: .success([]))
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_fetchCityNames_emptyOnEmptyMock() async throws {
        let (sut, spy) = makeSUT()
        
        let names = try await sut.fetchCityNames(searchType: .departure)
        
        XCTAssertEqual(spy.messages, [.fetchConnections])
        XCTAssertTrue(names.isEmpty)
    }
}

private extension CityNamesServiceTests {
    func makeSUT(
        mockResult: Result<[FlightConnection], Error> = .success([]),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (CityNamesService, FlightConnectionsServiceSpy) {
        let spy = FlightConnectionsServiceSpy(mockResult)
        let sut = CityNamesService(flightsLoader: spy)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)

        return (sut, spy)
    }
}
