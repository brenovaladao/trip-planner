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
    
    func test_citySelectionPublisher_publishesNewValueForDepartureWhileDestinationIsNil() async {
        let citySelection = CitySelection(type: .departure, cityName: departureCity.name)
        let publisher = PassthroughSubject<CitySelection, Never>()
        let (sut, spy) = makeSUT(
            citySelectionPublisher: publisher,
            eventHandler: unnavailableEventCall
        )
        await expect(
            sut,
            departureOutputs: [nil, citySelection.cityName],
            citySelectionOutputs: [citySelection],
            citySelectionSubject: publisher,
            actions: { publisher.send(citySelection) },
            asserting: { XCTAssertTrue(spy.messages.isEmpty) }
        )
    }
    
    func test_citySelectionPublisher_publishesNewValueForDestinationWhileDepartureIsNil() async {
        let citySelection = CitySelection(type: .destination, cityName: destinationCity.name)
        let publisher = PassthroughSubject<CitySelection, Never>()
        let (sut, spy) = makeSUT(
            citySelectionPublisher: publisher,
            eventHandler: unnavailableEventCall
        )
        await expect(
            sut,
            destinationOutputs: [nil, citySelection.cityName],
            citySelectionOutputs: [citySelection],
            citySelectionSubject: publisher,
            actions: { publisher.send(citySelection) },
            asserting: { XCTAssertTrue(spy.messages.isEmpty) }
        )
    }
    
    func test_citySelectionPublisher_publishesNewValueForDestinationWhileDepartureIsNotNil() async {
        let citySelection = CitySelection(type: .destination, cityName: destinationCity.name)
        let publisher = PassthroughSubject<CitySelection, Never>()
        let (sut, spy) = makeSUT(
            citySelectionPublisher: publisher,
            eventHandler: unnavailableEventCall
        )
        await expect(
            sut,
            destinationOutputs: [nil, citySelection.cityName],
            citySelectionOutputs: [citySelection],
            citySelectionSubject: publisher,
            actions: { publisher.send(citySelection) },
            asserting: { XCTAssertTrue(spy.messages.isEmpty) }
        )
    }
    
    func test_citySelectionPublisher_calculatesRouteInfoWhenDepartureAndDestinationAreFilledIn() async {
        let flight = aFligthConnection()
        let departureCity = flight.to
        let destinationCity = flight.from
        let destinationSelection = CitySelection(type: .destination, cityName: destinationCity.name)
        let route = Route(price: flight.price, cities: [departureCity, destinationCity])
        let publisher = PassthroughSubject<CitySelection, Never>()
        let (sut, spy) = makeSUT(
            departure: departureCity.name,
            mockResult: .success(route),
            citySelectionPublisher: publisher,
            eventHandler: unnavailableEventCall
        )

        await expect(
            sut,
            departureOutputs: [departureCity.name],
            destinationOutputs: [nil, destinationCity.name],
            routeInfoOutputs: [nil, route.displayValue],
            isLoadingOutputs: [false, true, false],
            annotationsOutputs: [[], route.cityAnnotations],
            citySelectionOutputs: [destinationSelection],
            citySelectionSubject: publisher,
            actions: { publisher.send(destinationSelection) },
            asserting: { XCTAssertEqual(spy.messages, [.calculateRoute]) }
        )
        
    }
    
    func test_citySelectionPublisher_calculatesRouteFailureOnRouteCalculation() async {
        let destinationSelection = CitySelection(type: .destination, cityName: destinationCity.name)
        let publisher = PassthroughSubject<CitySelection, Never>()
        let error = anyNSError()
        
        let (sut, spy) = makeSUT(
            departure: departureCity.name,
            mockResult: .failure(error),
            citySelectionPublisher: publisher,
            eventHandler: unnavailableEventCall
        )
        
        await expect(
            sut,
            departureOutputs: [departureCity.name],
            destinationOutputs: [nil, destinationCity.name],
            isLoadingOutputs: [false, true, false],
            errorMessageOutputs: [nil, error.localizedDescription],
            citySelectionOutputs: [destinationSelection],
            citySelectionSubject: publisher,
            actions: { publisher.send(destinationSelection) },
            asserting: { XCTAssertEqual(spy.messages, [.calculateRoute]) }
        )
    }
}

extension FlightConnectionsListViewModelTests {
    func makeSUT(
        destination: String? = nil,
        departure: String? = nil,
        mockResult: Result<Route, Error> = .success(emptyRoute()),
        citySelectionPublisher: PassthroughSubject<CitySelection, Never> = .init(),
        eventHandler: @escaping FlightConnectionsListViewEventHandling,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (FlightConnectionsListViewModel, RouteSelectionServiceSpy) {
        let spy = RouteSelectionServiceSpy(mockResult)
        let sut = FlightConnectionsListViewModel(
            departure: departure,
            destination: destination,
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
    
    var departureCity: City {
        aFligthConnection().from
    }
    
    var destinationCity: City {
        aFligthConnection().to
    }
}
