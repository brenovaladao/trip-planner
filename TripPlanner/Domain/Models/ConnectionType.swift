//
//  ConnectionType.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

public enum ConnectionType: Sendable, Hashable {
    case departure
    case destination
}

extension ConnectionType {
    var displayRepresentation: String {
        switch self {
        case .departure:
            "Departure"
        case .destination:
            "Destination"
        }
    }
}
