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
    func test_init_noSideEffectsOnInitialization() {
        let (_, spy) = makeSUT(mockResult: .success([]))
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_fetchCityNames_emptyOnEmptyResult() async throws {
        let (sut, spy) = makeSUT()
        
        let names = try await sut.fetchCityNames(searchType: .departure)
        
        XCTAssertEqual(spy.messages, [.fetchConnections])
        XCTAssertTrue(names.isEmpty)
    }
    
    func test_fetchCityNames_succeedsOnValidResponseForDepartureSearchType() async throws {
        let flightConnections = [aFligthConnection(), anotherFlightConnection()]
        
        let (sut, spy) = makeSUT(mockResult: .success(flightConnections))
        
        let names = try await sut.fetchCityNames(searchType: .departure)
        
        let expectedNames = flightConnections.map(\.from).sorted()
        XCTAssertEqual(spy.messages, [.fetchConnections])
        XCTAssertEqual(names, expectedNames)
    }
    
    func test_fetchCityNames_succeedsOnValidResponseForDestinationSearchType() async throws {
        let flightConnections = [aFligthConnection(), anotherFlightConnection()]
        let (sut, spy) = makeSUT(mockResult: .success(flightConnections))
        
        let names = try await sut.fetchCityNames(searchType: .destination)
        
        let expectedNames = flightConnections.map(\.to).sorted()
        XCTAssertEqual(spy.messages, [.fetchConnections])
        XCTAssertEqual(names, expectedNames)
    }
    
    func test_fetchCityNames_failsOnResponseError() async {
        let anError = anyNSError()
        let (sut, spy) = makeSUT(mockResult: .failure(anError))
        
        do {
            _ = try await sut.fetchCityNames(searchType: .destination)
            XCTFail("Should have failed with error")
        } catch {}
        
        XCTAssertEqual(spy.messages, [.fetchConnections])
    }
    
    func test_fetchCityNames_succeedsWithoutDuplicatedCityNames() async throws {
        let flightConnections = [aFligthConnection(), aFligthConnection(), anotherFlightConnection()]
        let (sut, spy) = makeSUT(mockResult: .success(flightConnections))
        
        let names = try await sut.fetchCityNames(searchType: .departure)
        
        let expectedNames = ["Cape Town", "London"]
        XCTAssertEqual(spy.messages, [.fetchConnections])
        XCTAssertEqual(names, expectedNames)
    }
}

private extension CityNamesServiceTests {
    func makeSUT(
        mockResult: Result<[FlightConnection], Error> = .success([]),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (CityNamesService, FlightConnectionsServiceSpy) {
        let spy = FlightConnectionsServiceSpy(mockResult)
        let sut = CityNamesService(flightConnectionsFetcher: spy)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)

        return (sut, spy)
    }
}
