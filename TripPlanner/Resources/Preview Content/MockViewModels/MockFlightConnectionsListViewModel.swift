//
//  MockFlightConnectionsListViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

final class MockFlightConnectionsListViewModel: FlightConnectionsListViewModeling {
    init() {}

    var departure: String? = "Tokyo"
    var destination: String? = "Porto"

    func selectDepartureTapped() {}
    
    func selectDestinationTapped() {}
}
