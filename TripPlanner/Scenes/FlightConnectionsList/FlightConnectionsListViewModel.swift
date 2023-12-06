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
    func selectDepartureTapped()
    func selectDestinationTapped()
}

final public class FlightConnectionsListViewModel: FlightConnectionsListViewModeling {
    
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
            .sink { (type, name) in
                print(type.displayRepresentation, name)
            }
            .store(in: &cancellables)
    }
}