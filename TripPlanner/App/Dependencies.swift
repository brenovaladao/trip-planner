//
//  Dependencies.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Combine
import Foundation
import SwiftUI

enum Dependencies {
    static let remoteFlightConnectionsLoader: FlightConnectionsFetching = FlightConnectionsService(
        urlSession: URLSession(configuration: .ephemeral),
        endpoint: URL(string: "some-url")!
    )
    
    static let cityNamesService: CityNamesFetching = CityNamesService(
        flightsLoader: remoteFlightConnectionsLoader
    )
    
    // MARK: - ViewModels
    @MainActor
    static func makeFlightConnectionsListViewModel(
        navigationPath: Binding<NavigationPath>,
        citySelectionPublisher: any Publisher<CitySelection, Never>
    ) -> FlightConnectionsListViewModel {
        FlightConnectionsListViewModel(
            navigationPath: navigationPath,
            citySelectionPublisher: citySelectionPublisher
        )
    }
    
    @MainActor
    static func makeFlightSearchViewModel(
        searchType: SearchType,
        citySelectionSubject: PassthroughSubject<CitySelection, Never>
    ) -> FlightSearchViewModel {
        FlightSearchViewModel(
            searchType: searchType,
            citySelectionSubject: citySelectionSubject
        )
    }
}
