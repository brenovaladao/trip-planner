//
//  FlightSearchViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Combine
import Foundation
import SwiftUI

@MainActor
public protocol FlightSearchViewModeling: ObservableObject {
    var cityNames: [String] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    func citySelected(_ name: String)
    
    @discardableResult
    func loadCityNames() -> Task<Void, Never>
}

public final class FlightSearchViewModel: FlightSearchViewModeling {
    @Published private(set) public var cityNames: [String] = []
    @Published private(set) public var isLoading: Bool = false
    @Published private(set) public var errorMessage: String?

    private let searchType: SearchType
    private let citySelectionSubject: PassthroughSubject<CitySelection, Never>
    private let cityNamesService: CityNamesFetching
    
    public init(
        searchType: SearchType,
        citySelectionSubject: PassthroughSubject<CitySelection, Never>,
        cityNamesService: CityNamesFetching
    ) {
        self.searchType = searchType
        self.citySelectionSubject = citySelectionSubject
        self.cityNamesService = cityNamesService
    }
}

@MainActor
public extension FlightSearchViewModel {
    func citySelected(_ name: String) {
        citySelectionSubject.send(
            CitySelection(type: searchType, cityName: name)
        )
    }
    
    func loadCityNames() -> Task<Void, Never> {
        Task { [weak self] in
            guard let self, !Task.isCancelled else { 
                return
            }
            
            defer { isLoading = false }
            setLoadingIfNeeded()
            resetErrorMessageIfNeeded()
            
            do {
                cityNames = try await cityNamesService.fetchCityNames(searchType: searchType)
                if cityNames.isEmpty {
                    errorMessage = "No cities found"
                }
            } catch {
                errorMessage = "An error happened when loading \(error.localizedDescription)"
            }
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
