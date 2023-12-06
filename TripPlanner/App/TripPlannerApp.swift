//
//  TripPlannerApp.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Combine
import SwiftUI

@main
struct TripPlannerApp: App {
    @State private var navigationPath = NavigationPath()
    private let citySelectionSubject = PassthroughSubject<CitySelection, Never>()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                FlightConnectionsListView(
                    viewModel: Dependencies.makeFlightConnectionsListViewModel(
                        navigationPath: $navigationPath,
                        citySelectionPublisher: citySelectionSubject
                    )
                )
                .navigationDestination(for: SearchType.self) {
                    FlightSearchView(
                        viewModel: Dependencies.makeFlightSearchViewModel(
                            searchType: $0,
                            citySelectionSubject: citySelectionSubject
                        )
                    )
                    .onReceive(citySelectionSubject) { _ in
                        navigationPath = .init()
                    }
                    .navigationTitle($0.displayRepresentation)
                }
            }
        }
    }
}
