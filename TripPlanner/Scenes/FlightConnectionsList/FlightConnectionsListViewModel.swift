//
//  FlightConnectionsListViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Combine
import Foundation
import SwiftUI

@MainActor
public protocol FlightConnectionsListViewModeling: ObservableObject {
    @MainActor var departure: String? { get }
    @MainActor var destination: String? { get }

    func selectDepartureTapped()
    func selectDestinationTapped()
}

final public class FlightConnectionsListViewModel: FlightConnectionsListViewModeling {
    @Published private(set) public var departure: String?
    @Published private(set) public var destination: String?
    
    private let citySelectionPublisher: any Publisher<CitySelection, Never>
    @Binding private var navigationPath: NavigationPath
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        navigationPath: Binding<NavigationPath>,
        citySelectionPublisher: any Publisher<CitySelection, Never>
    ) {
        _navigationPath = navigationPath
        self.citySelectionPublisher = citySelectionPublisher
        bindPublishers()
    }
}

public extension FlightConnectionsListViewModel {
    func selectDepartureTapped() {
        navigationPath.append(SearchType.departure)
    }
    
    func selectDestinationTapped() {
        navigationPath.append(SearchType.destination)
    }
}

private extension FlightConnectionsListViewModel {
    func bindPublishers() {
        citySelectionPublisher
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] citySelection in
                guard let self else { return }
                handleCitySelection(citySelection)
            }
            .store(in: &cancellables)
    }
    
    func handleCitySelection(_ citySelection: CitySelection) {
        switch citySelection.type {
        case .departure:
            departure = citySelection.cityName
        case .destination:
            destination = citySelection.cityName
        }
    }
}
