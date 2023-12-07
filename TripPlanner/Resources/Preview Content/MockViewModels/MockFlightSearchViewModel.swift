//
//  MockFlightSearchViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

final class MockFlightSearchViewModel: FlightSearchViewModeling {    
    @Published var cityNames: [String]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(cityNames: [String], isLoading: Bool = false, errorMessage: String? = nil) {
        self.cityNames = cityNames
        self.isLoading = isLoading
        self.errorMessage = errorMessage
    }
    
    func citySelected(_ name: String) {}
    func loadCityNames() async {}
}
