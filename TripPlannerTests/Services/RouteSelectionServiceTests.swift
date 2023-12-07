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
        
        let expectedRoute = Route(
            price: connections.reduce(0) { $0 + $1.price },
            connections: connections
        )
        
        try await expect(
            connections: connections,
            departure: connections[0].from,
            destination: connections[1].to,
            with: expectedRoute
        )
    }
    
    func test_calculateRoute_cheapestWithoutConnection() async throws {
        let connections = [
            aFligthConnection(),
            anotherFlightConnection()
        ]
        
        let expectedRoute = Route(
            price: connections[0].price,
            connections: [connections[0]]
        )
        
        try await expect(
            connections: connections,
            departure: connections[0].from,
            destination: connections[0].to,
            with: expectedRoute
        )
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
    
    func expect(
        connections: [FlightConnection],
        departure from: String,
        destination to: String,
        with cheapestRoute: Route,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        let (sut, spy) = makeSUT(mockResult: .success(connections))
        
        let route = try await sut.calculateRoute(from: from, to: to)
        
        XCTAssertEqual(route, cheapestRoute, file: file, line: line)
        XCTAssertEqual(spy.messages, [.fetchConnections], file: file, line: line)
    }
}
