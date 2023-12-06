//
//  Dependencies.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

enum Dependencies {
    static let remoteFlightConnectionsLoader: FlightConnectionsFetching = RemoteFlightConnectionsLoader(
        urlSession: URLSession(configuration: .ephemeral),
        endpoint: URL(string: "some-url")!
    )
    
    // MARK: - ViewModels
    static func makeFlightConnectionsListViewModel() -> FlightConnectionsListViewModel {
        FlightConnectionsListViewModel()
    }
    
    static func makeFlightSearchViewModel() -> FlightSearchViewModel {
        FlightSearchViewModel()
    }
}
