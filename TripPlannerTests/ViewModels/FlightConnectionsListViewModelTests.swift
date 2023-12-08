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
            eventHandler: {
                XCTFail("Shouldn't be called on initialization - failed with \($0)")
            }
        )
        
        let citySelectionExp = expectation(description: "citySelection expectation")
        cancellables = [
            publisher.assertOutput(matches: [], expectation: citySelectionExp)
        ]
        
        wait(for: [citySelectionExp])
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_selectDepartureTapped_callsClosureWithCorrectType() {
        var receivedValues = [ConnectionType]()
        let (sut, _) = makeSUT(eventHandler: { receivedValues.append($0) })
        sut.selectDepartureTapped()
        XCTAssertEqual(receivedValues, [.departure])
    }
    
    func test_selectDestinationTapped_callsClosureWithCorrectType() {
        var receivedValues = [ConnectionType]()
        let (sut, _) = makeSUT(eventHandler: { receivedValues.append($0) })
        sut.selectDestinationTapped()
        XCTAssertEqual(receivedValues, [.destination])
    }
    
//    var departure: String? { get }
//    var destination: String? { get }
//    
//    var routeInfo: String? { get }
//    var isLoading: Bool { get }
//    var errorMessage: String? { get }
//    
//    var annotations: [CityAnnotation] { get }

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
