//
//  FlightSearchViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

@MainActor
public protocol FlightSearchViewModeling: ObservableObject {
    var title: String { get }
}

final public class FlightSearchViewModel: FlightSearchViewModeling {
    private let searchType: SearchType
    
    public init(searchType: SearchType) {
        self.searchType = searchType
    }
}

public extension FlightSearchViewModel {
    var title: String {
        searchType.screenTitle
    }
}
