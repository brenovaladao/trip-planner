//
//  FlightConnectionsListViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Combine
import Foundation

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

    private let eventHandler: FlightConnectionsListViewEventHandling
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        departure: String? = nil,
        destination: String? = nil,
        routeSelector: RouteSelectionCalculating,
        citySelectionPublisher: any Publisher<CitySelection, Never>,
        eventHandler: @escaping FlightConnectionsListViewEventHandling
    ) {
        self.departure = departure
        self.destination = destination
        self.routeSelector = routeSelector
        self.citySelectionPublisher = citySelectionPublisher
        self.eventHandler = eventHandler
        bindPublishers()
    }
}

public extension FlightConnectionsListViewModel {
    func selectDepartureTapped() {
        eventHandler(.departure)
    }
    
    func selectDestinationTapped() {
        eventHandler(.destination)
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
        verifyInputCompletion()
    }
    
    func verifyInputCompletion() {
        guard let departure, let destination else {
            resetInfoView()
            return
        }
        Task { [weak self] in
            guard let self else { return }
            await findCheapestFlight(for: departure, destination: destination)
        }
    }
    
    func findCheapestFlight(for departure: String, destination: String) async {
        defer { isLoading = false }
        isLoading = true
        resetInfoView()
        
        do {
            let route = try await routeSelector.calculateRoute(from: departure, to: destination)
            guard !Task.isCancelled else { return }
            
            routeInfo = route.displayValue
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
    
    func resetInfoView() {
        if routeInfo != nil {
            routeInfo = nil
        }
        if errorMessage != nil {
            errorMessage = nil
        }
    }
}
