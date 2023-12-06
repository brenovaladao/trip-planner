//
//  FlightSearchViewModelTests.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 06/12/23.
//

import Combine
import TripPlanner
import XCTest

@MainActor
final class FlightSearchViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    
    func test_init_hasNoSideEffects() {
        let (sut, spy) = makeSUT()
        
        expect(
            sut,
            cityNamesOutputs: [[]],
            isLoadingOutputs: [false],
            errorMessageOutputs: [nil],
            locationSelectedOutputs: nil,
            actions: {},
            asserting: {
                XCTAssertEqual(spy.messages, [])
            }
        )
    }
    
    func test_citySelected_emitsValuesOnPublisher() {
        let citySelectionSubject = PassthroughSubject<CitySelection, Never>()
        let citySelection = CitySelection(type: .departure, cityName: "a city name")
        let (sut, spy) = makeSUT(citySelectionSubject: citySelectionSubject)
        
        expect(
            sut,
            locationSelectedOutputs: [citySelection],
            citySelectionSubject: citySelectionSubject,
            actions: {
                sut.citySelected(citySelection.cityName)
            },
            asserting: {
                XCTAssertEqual(spy.messages, [])
            }
        )
    }
}

private extension FlightSearchViewModelTests {
    func makeSUT(
        mockResult: Result<[String], Error> = .success([]),
        searchType: SearchType = .departure,
        citySelectionSubject: PassthroughSubject<CitySelection, Never> = .init(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (FlightSearchViewModel, CityNamesServiceSpy) {
        let spy = CityNamesServiceSpy(mockResult)
        let sut = FlightSearchViewModel(
            searchType: searchType,
            citySelectionSubject: citySelectionSubject,
            cityNamesService: spy
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)

        return (sut, spy)
    }
    
    func expect(
        _ sut: FlightSearchViewModel,
        cityNamesOutputs: [[String]] = [[]],
        isLoadingOutputs: [Bool] = [false],
        errorMessageOutputs: [String?] = [nil],
        locationSelectedOutputs: [CitySelection]? = nil,
        citySelectionSubject: PassthroughSubject<CitySelection, Never> = .init(),
        actions: () -> Void,
        asserting: () -> Void
    ) {
        let cityNamesExp = expectation(description: "cityNames expectation")
        let isLoadingExp = expectation(description: "isLoading expectation")
        let errorExp = expectation(description: "errorMessage expectation")
        let citySelectionExp = expectation(description: "citySelection expectation")

        cancellables = [
            sut.$cityNames
                .assertOutput(matches: cityNamesOutputs, expectation: cityNamesExp),
            sut.$isLoading
                .assertOutput(matches: isLoadingOutputs, expectation: isLoadingExp),
            sut.$errorMessage
                .assertOutput(matches: errorMessageOutputs, expectation: errorExp),
            citySelectionSubject
                .assertOutput(matches: locationSelectedOutputs, expectation: citySelectionExp)
        ]
        
        actions()
        
        waitForExpectations(timeout: 1)
        
        asserting()
    }
}
