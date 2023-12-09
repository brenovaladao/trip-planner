//
//  Dependencies.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Combine
import Foundation
import SwiftUI

/// Centralized place where I create all dependencies, either as static property, to allow reusability whenever we
/// can reuse the same instance, or as a factory method when I want a new instance (ViewModels).
enum Dependencies {
    static let flightConnectionsService: FlightConnectionsFetching = FlightConnectionsService(
        urlSession: URLSession.shared,
        endpoint: Configuration.default.apiURL
    )
    
    static let cityNamesService: CityNamesFetching = CityNamesService(
        flightConnectionsFetcher: flightConnectionsService
    )
    
    static let cityNamesAutoCompleteService: CityNamesAutoCompleting = CityNamesService(
        flightConnectionsFetcher: flightConnectionsService
    )
    
    static let routeSelectionService: RouteSelectionCalculating = RouteSelectionService(
        flightConnectionsFetcher: flightConnectionsService
    )
    
    // MARK: - ViewModels
    @MainActor
    static func makeFlightConnectionsListViewModel(
        eventHandler: @escaping FlightConnectionsListViewEventHandling,
        citySelectionPublisher: any Publisher<CitySelection, Never>
    ) -> FlightConnectionsListViewModel {
        FlightConnectionsListViewModel(
            routeSelector: routeSelectionService,
            citySelectionPublisher: citySelectionPublisher,
            eventHandler: eventHandler
        )
    }
    
    @MainActor
    static func makeFlightSearchViewModel(
        searchType: ConnectionType,
        citySelectionSubject: PassthroughSubject<CitySelection, Never>
    ) -> FlightSearchViewModel {
        FlightSearchViewModel(
            searchType: searchType,
            citySelectionSubject: citySelectionSubject, 
            cityNamesService: cityNamesService, 
            autoCompleteService: cityNamesAutoCompleteService
        )
    }
}
