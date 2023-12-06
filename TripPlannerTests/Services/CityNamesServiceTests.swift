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

}

private extension CityNamesServiceTests {
    func makeSUT(
        mockResult: Result<[FlightConnection], Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> CityNamesService {
        let spy = FlightConnectionsServiceSpy(mockResult)
        let sut = CityNamesService(flightsLoader: spy)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)

        return sut
    }
}
