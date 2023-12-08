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
    var departure: String? { get }
    var destination: String? { get }

    var routeInfo: String? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    var annotations: [CityAnnotation] { get }

    func selectDepartureTapped()
    func selectDestinationTapped()
}

public final class FlightConnectionsListViewModel: FlightConnectionsListViewModeling {
    @Published private(set) public var departure: String?
    @Published private(set) public var destination: String?

    @Published private(set) public var routeInfo: String?
    @Published private(set) public var isLoading: Bool = false
    @Published private(set) public var errorMessage: String?

    @Published private(set) public var annotations: [CityAnnotation] = []

    private let routeSelector: RouteSelectionCalculating
    private let citySelectionPublisher: any Publisher<CitySelection, Never>

    @Binding private var navigationPath: NavigationPath
    private var cancellables = Set<AnyCancellable>()
    private(set) var routeTask: Task<Void, Never>?
    
    public init(
        routeSelector: RouteSelectionCalculating,
        citySelectionPublisher: any Publisher<CitySelection, Never>,
        navigationPath: Binding<NavigationPath>
    ) {
        self.routeSelector = routeSelector
        self.citySelectionPublisher = citySelectionPublisher
        _navigationPath = navigationPath
        bindPublishers()
    }
}

public extension FlightConnectionsListViewModel {
    func selectDepartureTapped() {
        navigationPath.append(ConnectionType.departure)
    }
    
    func selectDestinationTapped() {
        navigationPath.append(ConnectionType.destination)
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
            if destination == citySelection.cityName {
                destination = nil
            }
            departure = citySelection.cityName
        case .destination:
            if departure == citySelection.cityName {
                departure = nil
            }
            destination = citySelection.cityName
        }
        
        verifyInputCompletion()
    }
    
    func verifyInputCompletion() {
        guard let departure, let destination else {
            resetInfoView()
            return
        }
        findCheapestFlight(for: departure, destination: destination)
    }
    
    func findCheapestFlight(for departure: String, destination: String) {
        routeTask = Task { [weak self] in
            guard let self else { return }
            
            defer { isLoading = false }
            isLoading = true
            resetInfoView()
            
            do {
                let route = try await routeSelector.calculateRoute(from: departure, to: destination)
                guard !Task.isCancelled else { return }
                
                routeInfo = """
                Price: \(route.price)
                Route: \(route.cities.map { $0.name }.joined(separator: " > "))
                """
                annotations = route.cities.map { 
                    CityAnnotation(
                        name: $0.name,
                        coordinates: $0.coordinates.asCCLocationCoordinate2D
                    )
                }
                
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func resetInfoView() {
        routeInfo = nil
        errorMessage = nil
    }
}
