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

    func test_init_hasNoSideEffects() async {
        let publisher = PassthroughSubject<CitySelection, Never>()
        let (sut, spy) = makeSUT(
            citySelectionPublisher: publisher,
            eventHandler: unnavailableEventCall
        )
        
        await expect(
            sut,
            actions: {},
            asserting: { XCTAssertTrue(spy.messages.isEmpty) }
        )
    }
    
    func test_selectDepartureTapped_callsClosureWithCorrectType() async {
        var receivedValues = [ConnectionType]()
        let (sut, spy) = makeSUT(eventHandler: { receivedValues.append($0) })
        
        await expect(
            sut,
            actions: { sut.selectDepartureTapped() },
            asserting: {
                XCTAssertTrue(spy.messages.isEmpty)
                XCTAssertEqual(receivedValues, [.departure])
            }
        )
    }
    
    func test_selectDestinationTapped_callsClosureWithCorrectType() async {
        var receivedValues = [ConnectionType]()
        let (sut, spy) = makeSUT(eventHandler: { receivedValues.append($0) })
        
        await expect(
            sut,
            actions: { sut.selectDestinationTapped() },
            asserting: {
                XCTAssertTrue(spy.messages.isEmpty)
                XCTAssertEqual(receivedValues, [.destination])
            }
        )
    }
    
//    func test_citySelectionPublisher_publishesNewValueForDepartureCity() {
//        let publisher = PassthroughSubject<CitySelection, Never>()
//        let citySelection = CitySelection(type: .departure, cityName: "London")
//        let (_, spy) = makeSUT(
//            citySelectionPublisher: publisher,
//            eventHandler: unnavailableEventCall
//        )
//
//        let departureExp = expectation(description: "departure expectations")
//        let destinationExp = expectation(description: "destination expectations")
//        let routeInfoExp = expectation(description: "routeInfo expectations")
//        let isLoadingExp = expectation(description: "isLoadingExp")
//        let errorMessageExp = expectation(description: "errorMessage expectations")
//        let annotationsExp = expectation(description: "annotations expectations")
//        let citySelectionExp = expectation(description: "citySelection expectation")
//
//        cancellables = [
//            publisher
//                .assertOutput(matches: [citySelection], expectation: citySelectionExp)
//        ]
//        
//        publisher.send(citySelection)
//        
//        wait(for: [citySelectionExp])
//        XCTAssertTrue(spy.messages.isEmpty)
//    }
    
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
        eventHandler: @escaping FlightConnectionsListViewEventHandling,
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
    
    /// Default verification for when the even handler shouldn't be called in a given flow
    func unnavailableEventCall(_ type: ConnectionType) {
        XCTFail("Shouldn't be called on initialization - failed with \(type)")
    }
    
    func expect(
        _ sut: FlightConnectionsListViewModel,
        departureOutputs: [String?] = [nil],
        destinationOutputs: [String?] = [nil],
        routeInfoOutputs: [String?] = [nil],
        isLoadingOutputs: [Bool] = [false],
        errorMessageOutputs: [String?] = [nil],
        annotationsOutputs: [[CityAnnotation]] = [[]],
        citySelectionOutputs: [CitySelection]? = nil,
        citySelectionSubject: PassthroughSubject<CitySelection, Never> = .init(),
        actions: () async  -> Void,
        asserting: () -> Void
    ) async {
        let departureExp = expectation(description: "departure expectations")
        let destinationExp = expectation(description: "destination expectations")
        let routeInfoExp = expectation(description: "routeInfo expectations")
        let isLoadingExp = expectation(description: "isLoadingExp")
        let errorMessageExp = expectation(description: "errorMessage expectations")
        let annotationsExp = expectation(description: "annotations expectations")
        let citySelectionExp = expectation(description: "citySelection expectation")
        
        cancellables = [
            sut.$departure
                .assertOutput(matches: departureOutputs, expectation: departureExp),
            sut.$destination
                .assertOutput(matches: destinationOutputs, expectation: destinationExp),
            sut.$routeInfo
                .assertOutput(matches: routeInfoOutputs, expectation: routeInfoExp),
            sut.$isLoading
                .assertOutput(matches: isLoadingOutputs, expectation: isLoadingExp),
            sut.$errorMessage
                .assertOutput(matches: errorMessageOutputs, expectation: errorMessageExp),
            sut.$annotations
                .assertOutput(matches: annotationsOutputs, expectation: annotationsExp),
            citySelectionSubject
                .assertOutput(matches: citySelectionOutputs, expectation: citySelectionExp),
        ]
        
        await actions()
        
        await fulfillment(
            of: [departureExp, destinationExp, routeInfoExp, isLoadingExp, errorMessageExp, annotationsExp, citySelectionExp],
            timeout: 0.1
        )
        
        asserting()
    }
}
