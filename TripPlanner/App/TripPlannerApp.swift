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
                        eventHandler: handleFlightConnectionsEvent,
                        citySelectionPublisher: citySelectionSubject
                    )
                )
                .navigationTitle("Trip Planner")
                .navigationDestination(for: ConnectionType.self) {
                    FlightSearchView(
                        viewModel: Dependencies.makeFlightSearchViewModel(
                            searchType: $0,
                            citySelectionSubject: citySelectionSubject
                        )
                    )
                    .onReceive(citySelectionSubject) { _ in
                        // In case a city is selected, this will pop to the root view
                        navigationPath = .init()
                    }
                    .navigationTitle($0.displayRepresentation)
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

// MARK: - Navigation handling
extension TripPlannerApp {
    func handleFlightConnectionsEvent(_ type: ConnectionType) {
        navigationPath.append(type)
    }
}

extension ConnectionType {
    var displayRepresentation: String {
        switch self {
        case .departure: "Departure"
        case .destination: "Destination"
        }
    }
}
