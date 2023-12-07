//
//  RouteSelectionServiceTests.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 07/12/23.
//

import XCTest
import TripPlanner

@MainActor
final class RouteSelectionServiceTests: XCTestCase {
    func test_init_noSideEffectsOnInitialization() {
        let (_, spy) = makeSUT(mockResult: .success([]))
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_calculateRoute_errorOnEmptyConnections() async {
        let (sut, spy) = makeSUT(mockResult: .success([]))
        
        do {
            _ = try await sut.calculateRoute(from: "Porto", to: "London")
            XCTFail("Should have failed with error")
        } catch is RouteSelectionService.RouteNotPossibleError {
        } catch {
            XCTFail("Should have failed with RouteNotPossibleError, failed with \(error.localizedDescription)")
        }
        
        XCTAssertEqual(spy.messages, [.fetchConnections])
    }
    
    func test_calculateRoute_cheapestRouteFromTwoConnections() async throws {
        let connections = [
            aFligthConnection(),
            anotherFlightConnection()
        ]
        let (sut, spy) = makeSUT(mockResult: .success(connections))
        let from = connections[0].from
        let to = connections[1].to

        let route = try await sut.calculateRoute(from: from, to: to)
        
        let expectedPrice = connections.reduce(0) { $0 + $1.price }        
        XCTAssertEqual(route.0, expectedPrice)
        XCTAssertEqual(route.1, connections)
        XCTAssertEqual(spy.messages, [.fetchConnections])
    }
    
    func test_calculateRoute_cheapestWithoutConnection() async throws {
        let connections = [
            aFligthConnection(),
            anotherFlightConnection()
        ]
        let (sut, spy) = makeSUT(mockResult: .success(connections))
        let from = connections[0].from
        let to = connections[0].to

        
        let route = try await sut.calculateRoute(from: from, to: to)
        
        let expectedPrice = connections[0].price
        XCTAssertEqual(route.0, expectedPrice)
        XCTAssertEqual(route.1, [connections[0]])
        XCTAssertEqual(spy.messages, [.fetchConnections])
    }
}

private extension RouteSelectionServiceTests {
    func makeSUT(
        mockResult: Result<[FlightConnection], Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (RouteSelectionService, FlightConnectionsServiceSpy) {
        let spy = FlightConnectionsServiceSpy(mockResult)
        let sut = RouteSelectionService(flightConnectionsFetcher: spy)
        
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
    }
}
