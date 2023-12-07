//
//  MockFlightConnectionsListViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

final class MockFlightConnectionsListViewModel: FlightConnectionsListViewModeling {
    var departure: String? = "Tokyo"
    var destination: String? = "Porto"
    var routeInfo: String?
    var isLoading: Bool = false
    var errorMessage: String?
    
    init() {}

    func selectDepartureTapped() {}
    
    func selectDestinationTapped() {}
}
