//
//  SearchType+Details.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

extension SearchType {
    var screenTitle: String {
        switch self {
        case .departure:
            "Departure"
        case .destination:
            "Destination"
        }
    }
}
