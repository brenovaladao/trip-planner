//
//  FlightSearchViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Combine
import Foundation
import SwiftUI

@MainActor
public protocol FlightSearchViewModeling: ObservableObject {
    func citySelected(_ name: String)
}

public final class FlightSearchViewModel: FlightSearchViewModeling {
    private let searchType: SearchType
    private let citySelectionSubject: PassthroughSubject<CitySelection, Never>
    
    public init(
        searchType: SearchType,
        citySelectionSubject: PassthroughSubject<CitySelection, Never>
    ) {
        self.searchType = searchType
        self.citySelectionSubject = citySelectionSubject
    }
}

public extension FlightSearchViewModel {
    func citySelected(_ name: String) {
        citySelectionSubject.send((searchType, name))
    }
}
