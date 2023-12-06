//
//  MockFlightSearchViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

final class MockFlightSearchViewModel: FlightSearchViewModeling {
    init() {}
    
    var cityNames: [String] = ["Porto", "Prague", "London"]
    var isLoading: Bool = false
    var errorMessage: String?
    
    func citySelected(_ name: String) {}
    func loadCityNames() -> Task<Void, Never> {
        Task {}
    }
}
