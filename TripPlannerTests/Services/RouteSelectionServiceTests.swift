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
        let (sut, spy) = makeSUT(mockResult: .success([
            makeFlightConnection(from: "London", to: "Porto", price: 2)
        ]))
        
        do {
            _ = try await sut.calculateRoute(from: "Lodon", to: "Lisbon")
            XCTFail("Should have failed with error")
        } catch is RouteSelectionService.RouteNotPossibleError {
        } catch {
            XCTFail("Should have failed with RouteNotPossibleError, failed with \(error.localizedDescription)")
        }
        
        XCTAssertEqual(spy.messages, [.fetchConnections])
    }
    
    func test_calculateRoute_cheapestWithoutConnection() async throws {
        let connections = [
            aFligthConnection(),
            anotherFlightConnection()
        ]
        
        let expectedRoute = Route(
            price: connections[0].price,
            cities: [
                connections[0].from,
                connections[0].to
            ]
        )
        
        try await expect(
            connections: connections,
            departure: connections[0].from.name,
            destination: connections[0].to.name,
            with: expectedRoute
        )
    }
    
    func test_calculateRoute_cheapestRouteFromTwoConnections() async throws {
        let connections = [
            aFligthConnection(),
            anotherFlightConnection()
        ]
        
        let expectedRoute = Route(
            price: connections.reduce(0) { $0 + $1.price },
            cities: [
                connections[0].from,
                connections[0].to,
                connections[1].to
            ]
        )
        
        try await expect(
            connections: connections,
            departure: connections[0].from.name,
            destination: connections[1].to.name,
            with: expectedRoute
        )
    }
    
    func test_calculateRoute_cheapestRouteFromMultipleAvailableCities() async throws {
        let connections = [
            makeFlightConnection(from: "London", to: "Porto", price: 2),
            makeFlightConnection(from: "London", to: "Lisbon", price: 1),
            makeFlightConnection(from: "Lisbon", to: "Berlin", price: 1),
            makeFlightConnection(from: "Lisbon", to: "Porto", price: 3),
            makeFlightConnection(from: "Porto", to: "Berlin", price: 3),
            makeFlightConnection(from: "London", to: "Berlin", price: 20)
        ]
        
        let expectedRoute = Route(
            price: 2,
            cities: [
                connections[1].from,
                connections[1].to,
                connections[2].to
            ]
        )
        
        try await expect(
            connections: connections,
            departure: "London",
            destination: "Berlin",
            with: expectedRoute
        )
    }
    
    func test_calculateRoute_cheapestRouteWithDuplicatedDepartures() async throws {
        let connections = [
            makeFlightConnection(from: "London", to: "Porto", price: 1),
            makeFlightConnection(from: "London", to: "Berlin", price: 10),
            makeFlightConnection(from: "Porto", to: "Lisbon", price: 1)
        ]
        
        let expectedRoute = Route(
            price: 10,
            cities: [
                connections[1].from,
                connections[1].to
            ]
        )
        
        try await expect(
            connections: connections,
            departure: "London",
            destination: "Berlin",
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
        let sut = RouteSelectionService(
            flightConnectionsFetcher: spy,
            shortestPathFinder: Dijkstra()
        )
        
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
