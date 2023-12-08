//
//  FlightConnectionsListViewModelTests.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 07/12/23.
//

import Combine
import TripPlanner
import XCTest

@MainActor
final class FlightConnectionsListViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    func test_init_hasNoSideEffects() {
        let publisher = PassthroughSubject<CitySelection, Never>()
        let (_, spy) = makeSUT(
            citySelectionPublisher: publisher,
            eventHandler: { _ in
                XCTFail("Shouldn't be called on initialization")
            }
        )
        
        let citySelectionExp = expectation(description: "citySelection expectation")
        cancellables = [
            publisher
                .assertOutput(matches: [], expectation: citySelectionExp)
        ]
        
        wait(for: [citySelectionExp])
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
//    var departure: String? { get }
//    var destination: String? { get }
//    
//    var routeInfo: String? { get }
//    var isLoading: Bool { get }
//    var errorMessage: String? { get }
//    
//    var annotations: [CityAnnotation] { get }
//    
//    func selectDepartureTapped()
//    func selectDestinationTapped()
    
}

extension FlightConnectionsListViewModelTests {
    func makeSUT(
        mockResult: Result<Route, Error> = .success(emptyRoute()),
        citySelectionPublisher: PassthroughSubject<CitySelection, Never> = .init(),
        eventHandler: @escaping FlightConnectionsListViewEventHandling = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (FlightConnectionsListViewModel, RouteSelectionServiceSpy) {
        let spy = RouteSelectionServiceSpy(mockResult)
        let sut = FlightConnectionsListViewModel(
            routeSelector: spy,
            citySelectionPublisher: citySelectionPublisher,
            eventHandler: eventHandler
        )
    
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)

        return (sut, spy)
    }
}
