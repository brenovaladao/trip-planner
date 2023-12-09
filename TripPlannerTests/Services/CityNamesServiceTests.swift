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

    func test_search_emptyOnServiceErrorWithEmptySearchQuery() async throws {
        let aError = anyNSError()
        let (sut, spy) = makeSUT(mockResult: .failure(aError))

        let names = try await sut.search(for: "", type: .departure)
        
        let expectedNames = Set<String>()
        XCTAssertEqual(spy.messages, [])
        XCTAssertEqual(names, expectedNames)
    }
    
    func test_search_failsOnServiceErrorWithValidSearchQuery() async {
        let aError = anyNSError()
        let (sut, spy) = makeSUT(mockResult: .failure(aError))
        
        do {
            _ = try await sut.search(for: "a query", type: .departure)
            XCTFail("Should have failed")
        } catch {}
        
        XCTAssertEqual(spy.messages, [.fetchConnections])
    }
    
    func test_search_autocompletesWithMatchingSearchQuery() async throws {
        let flightConnections = [
            makeFlightConnection(from: "Porto"),
            makeFlightConnection(from: "London"),
            makeFlightConnection(from: "Lisbon"),
            makeFlightConnection(from: "Prague"),
            makeFlightConnection(from: "Madrid")
        ]
        let (sut, _) = makeSUT(mockResult: .success(flightConnections))
        
        let samples: [(query: String, result: Set<String>)] = [
            ("p", Set(["Porto", "Prague"])),
            ("ON", Set(["London", "Lisbon"])),
            ("", Set([])),
            ("  mad   ", Set(["Madrid"])),
        ]
        
        try await samples.asyncForEach { (query, expectedNames) in
            let names = try await sut.search(for: query, type: .departure)
            XCTAssertEqual(names, expectedNames, "Expected: \(expectedNames), received: \(names)")
        }
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
