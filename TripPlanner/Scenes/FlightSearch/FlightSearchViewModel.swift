//
//  FlightSearchViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Combine
import Foundation

@MainActor
public protocol FlightSearchViewModeling: ObservableObject {
    var cityNames: [String] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var searchQuery: String { get set }

    func citySelected(_ name: String)
    
    func loadCityNames() async
}

public final class FlightSearchViewModel: FlightSearchViewModeling {
    @Published private(set) public var cityNames: [String] = []
    @Published private(set) public var isLoading: Bool = false
    @Published private(set) public var errorMessage: String?
    @Published public var searchQuery: String = ""
    
    private let searchType: ConnectionType
    private let citySelectionSubject: PassthroughSubject<CitySelection, Never>
    private let cityNamesService: CityNamesFetching
    private let autoCompleteService: CityNamesAutoCompleting

    public init(
        searchType: ConnectionType,
        citySelectionSubject: PassthroughSubject<CitySelection, Never>,
        cityNamesService: CityNamesFetching,
        autoCompleteService: CityNamesAutoCompleting
    ) {
        self.searchType = searchType
        self.citySelectionSubject = citySelectionSubject
        self.cityNamesService = cityNamesService
        self.autoCompleteService = autoCompleteService
    }
}

@MainActor
public extension FlightSearchViewModel {
    func citySelected(_ name: String) {
        citySelectionSubject.send(
            CitySelection(type: searchType, cityName: name)
        )
    }
    
    func loadCityNames() async {
        defer { isLoading = false }
        setLoadingIfNeeded()
        resetErrorMessageIfNeeded()
        
        do {
            let cityNames = try await cityNamesService.fetchCityNames(searchType: searchType)
            guard !Task.isCancelled else { return }
            self.cityNames = cityNames
            if cityNames.isEmpty {
                errorMessage = "No cities found"
            }
        } catch is CancellationError {
        } catch {
            errorMessage = "An error happened when loading \(error.localizedDescription)"
        }
    }
}

private extension FlightSearchViewModel {
    func setLoadingIfNeeded() {
        guard !isLoading, cityNames.isEmpty else { return }
        isLoading = cityNames.isEmpty
    }
    
    func resetErrorMessageIfNeeded() {
        guard errorMessage != nil else { return }
        errorMessage = nil
    }
}
