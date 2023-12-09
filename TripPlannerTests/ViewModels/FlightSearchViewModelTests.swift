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
            asserting: { XCTAssertEqual(spy.messages, []) }
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
            actions: { sut.citySelected(citySelection.cityName) },
            asserting: { XCTAssertEqual(spy.messages, []) }
        )
    }
    
    func test_loadCityNames_succeedsOnNonEmptyListOfCityNames() async {
        let cityNames = ["Cape Town", "London", "Tokyo"]
        
        let (sut, spy) = makeSUT(citiesMockResult: .success(cityNames))
        
        await expect(
            sut,
            cityNamesOutputs: [[], cityNames],
            isLoadingOutputs: [false, true, false],
            errorMessageOutputs: [nil],
            actions: { await sut.loadCityNames() },
            asserting: { XCTAssertEqual(spy.messages, [.fetchCityNames]) }
        )
    }
    
    func test_loadCityNames_emptyStateMessageOnEmptyListOfCityNames() async {
        let emptyMessage = "No cities found"
        let (sut, spy) = makeSUT(citiesMockResult: .success([]))
        
        await expect(
            sut,
            cityNamesOutputs: [[], []],
            isLoadingOutputs: [false, true, false],
            errorMessageOutputs: [nil, emptyMessage],
            actions: { await sut.loadCityNames() },
            asserting: { XCTAssertEqual(spy.messages, [.fetchCityNames]) }
        )
    }
    
    func test_loadCityNames_errorMessageOnServiceError() async {
        let anError = anyNSError()
        let errorMessage = "An error happened when loading \(anError.localizedDescription)"
        
        let (sut, spy) = makeSUT(citiesMockResult: .failure(anError))
        
        await expect(
            sut,
            cityNamesOutputs: [[]],
            isLoadingOutputs: [false, true, false],
            errorMessageOutputs: [nil, errorMessage],
            actions: { await sut.loadCityNames() },
            asserting: { XCTAssertEqual(spy.messages, [.fetchCityNames]) }
        )
    }
    
    func test_loadCityNames_errorMessageOnServiceErrorThenSucceedsOnRetry() async {
        let anError = anyNSError()
        let cityNames = ["Cape Town", "London", "Tokyo"]
        let errorMessage = "An error happened when loading \(anError.localizedDescription)"

        let (sut, spy) = makeSUT(citiesMockResult: .failure(anError))
        
        await expect(
            sut,
            cityNamesOutputs: [[], cityNames],
            isLoadingOutputs: [false, true, false, true, false],
            errorMessageOutputs: [nil, errorMessage, nil],
            actions: {
                await sut.loadCityNames()
                spy.citiesMockResult = .success(cityNames)
                await sut.loadCityNames()
            },
            asserting: { XCTAssertEqual(spy.messages, [.fetchCityNames, .fetchCityNames]) }
        )
    }
    
    func test_loadCityNames_reloadOnNonEmptyList() async {
        let cityNames = ["Cape Town", "London", "Tokyo"]
        
        let (sut, spy) = makeSUT(citiesMockResult: .success(cityNames))
        
        await expect(
            sut,
            cityNamesOutputs: [[], cityNames, cityNames],
            isLoadingOutputs: [false, true, false, false],
            errorMessageOutputs: [nil],
            actions: {
                await sut.loadCityNames()
                await sut.loadCityNames()
            },
            asserting: { XCTAssertEqual(spy.messages, [.fetchCityNames, .fetchCityNames]) }
        )
    }
    
    func test_loadCityNames_taskIsCancelledBeforeItExecutes() async {
        let (sut, spy) = makeSUT()

        await expect(
            sut,
            isLoadingOutputs: [false, true, false],
            actions: {
                let task = Task { await sut.loadCityNames() }
                task.cancel()
                await task.value
            },
            asserting: { XCTAssertEqual(spy.messages, [.fetchCityNames]) }
        )
    }
    
    func test_search_replacesPlacesListWithAutoCompleteResult() async {
        let cityNames = ["Cape Town", "London", "Tokyo"]
        let autoCompleteResult = ["London"]
        let query = "lon"
        let (sut, spy) = makeSUT(
            citiesMockResult: .success(cityNames),
            autoCompleteMockResult: .success(Set(autoCompleteResult))
        )
        
        await expect(
            sut,
            cityNamesOutputs: [[], cityNames, autoCompleteResult],
            isLoadingOutputs: [false, true, false],
            searchQueryOutputs: ["", query],
            actions: {
                await sut.loadCityNames()
                sut.searchQuery = query
            },
            asserting: { XCTAssertEqual(spy.messages, [.fetchCityNames, .autoCompleteSearch]) }
        )
    }
    
    func test_search_errorMessageOnInvalidSearchQuery() async {
        let cityNames = ["Cape Town", "London", "Tokyo"]
        let query = "invalid-search-query"
        let (sut, spy) = makeSUT(citiesMockResult: .success(cityNames))
        
        await expect(
            sut,
            cityNamesOutputs: [[], cityNames],
            isLoadingOutputs: [false, true, false],
            errorMessageOutputs: [nil, "City not found"],
            searchQueryOutputs: ["", query],
            actions: {
                await sut.loadCityNames()
                sut.searchQuery = query
            },
            asserting: { XCTAssertEqual(spy.messages, [.fetchCityNames, .autoCompleteSearch]) }
        )
    }
    
    func test_search_doesNothingWithEmptySearchQuery() async {
        let cityNames = ["Cape Town", "London", "Tokyo"]
        let query = ""
        let (sut, spy) = makeSUT(citiesMockResult: .success(cityNames))
        
        await expect(
            sut,
            cityNamesOutputs: [[], cityNames, cityNames],
            isLoadingOutputs: [false, true, false, false],
            searchQueryOutputs: ["", query],
            actions: {
                await sut.loadCityNames()
                sut.searchQuery = query
            },
            asserting: { XCTAssertEqual(spy.messages, [.fetchCityNames, .fetchCityNames]) }
        )
    }
}

private extension FlightSearchViewModelTests {
    func makeSUT(
        citiesMockResult: Result<[String], Error> = .success([]),
        autoCompleteMockResult: Result<Set<String>, Error> = .success(Set()),
        searchType: ConnectionType = .departure,
        citySelectionSubject: PassthroughSubject<CitySelection, Never> = .init(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (FlightSearchViewModel, CityNamesServiceSpy) {
        let spy = CityNamesServiceSpy(
            citiesMockResult: citiesMockResult,
            autoCompleteMockResult: autoCompleteMockResult
        )
        let sut = FlightSearchViewModel(
            searchType: searchType,
            citySelectionSubject: citySelectionSubject,
            cityNamesService: spy, 
            autoCompleteService: spy,
            debounceInterval: 0
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
        searchQueryOutputs: [String] = [""],
        locationSelectedOutputs: [CitySelection]? = nil,
        citySelectionSubject: PassthroughSubject<CitySelection, Never> = .init(),
        actions: () async  -> Void,
        asserting: () -> Void
    ) async {
        let cityNamesExp = expectation(description: "cityNames expectation")
        let isLoadingExp = expectation(description: "isLoading expectation")
        let errorMessageExp = expectation(description: "errorMessage expectation")
        let citySelectionExp = expectation(description: "citySelection expectation")
        let searchQueryExp = expectation(description: "searchQuery expectation")

        cancellables = [
            sut.$cityNames
                .assertOutput(matches: cityNamesOutputs, expectation: cityNamesExp),
            sut.$isLoading
                .assertOutput(matches: isLoadingOutputs, expectation: isLoadingExp),
            sut.$errorMessage
                .assertOutput(matches: errorMessageOutputs, expectation: errorMessageExp),
            sut.$searchQuery
                .assertOutput(matches: searchQueryOutputs, expectation: searchQueryExp),
            citySelectionSubject
                .assertOutput(matches: locationSelectedOutputs, expectation: citySelectionExp)
        ]
        
        await actions()
        
        await fulfillment(
            of: [cityNamesExp, isLoadingExp, errorMessageExp, citySelectionExp, searchQueryExp],
            timeout: 1
        )
        
        asserting()
    }
}
