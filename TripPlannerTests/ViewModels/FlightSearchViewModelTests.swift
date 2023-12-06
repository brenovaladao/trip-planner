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
    
    func test_init_hasNoSideEffects() async {
        let citySelectionSubject = PassthroughSubject<CitySelection, Never>()
        let (sut, spy) = makeSUT(citySelectionSubject: citySelectionSubject)
        
        await expect(
            sut,
            cityNamesOutputs: [[]],
            isLoadingOutputs: [false],
            errorMessageOutputs: [nil],
            locationSelectedOutputs: nil,
            citySelectionSubject: citySelectionSubject,
            actions: {},
            asserting: {
                XCTAssertEqual(spy.messages, [])
            }
        )
    }
    
    func test_citySelected_emitsValuesOnInjectedPublisher() async {
        let citySelectionSubject = PassthroughSubject<CitySelection, Never>()
        let citySelection = CitySelection(type: .departure, cityName: "a city name")
        let (sut, spy) = makeSUT(citySelectionSubject: citySelectionSubject)
        
        await expect(
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
    
    func test_loadCityNames_succeedsOnNonEmptyListOfCityNames() async {
        let cityNames = ["Cape Town", "London", "Tokyo"]
        let (sut, spy) = makeSUT(mockResult: .success(cityNames))
        
        await expect(
            sut,
            cityNamesOutputs: [[], cityNames],
            isLoadingOutputs: [false, true, false],
            errorMessageOutputs: [nil, nil],
            actions: {
                await sut.loadCityNames().value
            },
            asserting: {
                XCTAssertEqual(spy.messages, [.fetchCityNames])
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
        actions: () async  -> Void,
        asserting: () -> Void
    ) async {
        let cityNamesExp = expectation(description: "cityNames expectation")
        let isLoadingExp = expectation(description: "isLoading expectation")
        let errorMessageExp = expectation(description: "errorMessage expectation")
        let citySelectionExp = expectation(description: "citySelection expectation")

        cancellables = [
            sut.$cityNames
                .assertOutput(matches: cityNamesOutputs, expectation: cityNamesExp),
            sut.$isLoading
                .assertOutput(matches: isLoadingOutputs, expectation: isLoadingExp),
            sut.$errorMessage
                .assertOutput(matches: errorMessageOutputs, expectation: errorMessageExp),
            citySelectionSubject
                .assertOutput(matches: locationSelectedOutputs, expectation: citySelectionExp)
        ]
        
        await actions()
        
        await fulfillment(
            of: [cityNamesExp, isLoadingExp, errorMessageExp, citySelectionExp],
            timeout: 1.0
        )
        
        asserting()
    }
}