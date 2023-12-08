//
//  MockFlightConnectionsListViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import MapKit

final class MockFlightConnectionsListViewModel: FlightConnectionsListViewModeling {
    var departure: String? = "Tokyo"
    var destination: String? = "Porto"
    var routeInfo: String? = "Price: 20\nRoute: Tokyo > Porto"
    var isLoading: Bool = false
    var errorMessage: String?
    var annotations: [CityAnnotation] = []

    init() {}

    func selectDepartureTapped() {}
    
    func selectDestinationTapped() {}
}
